function findVariable(scope, name) {
  for (let current = scope; current; current = current.upper) {
    const variable = current.set.get(name);
    if (variable) return variable;
  }
}

function unwrap(node) {
  while (["TSAsExpression", "TSTypeAssertion", "TSNonNullExpression", "TSSatisfiesExpression", "ChainExpression"].includes(node.type)) {
    node = node.expression;
  }
  return node;
}

function isReactImport(variable, importedName) {
  return variable?.defs.some((definition) => {
    if (definition.type !== "ImportBinding" || definition.parent.source.value !== "react") return false;
    const specifier = definition.node;
    if (importedName === "namespace") {
      return specifier.type === "ImportNamespaceSpecifier" || specifier.type === "ImportDefaultSpecifier";
    }
    return specifier.type === "ImportSpecifier" &&
      (specifier.imported.name ?? specifier.imported.value) === importedName;
  }) ?? false;
}

function isUseState(node, sourceCode) {
  const call = unwrap(node);
  if (call.type !== "CallExpression") return false;
  const callee = unwrap(call.callee);
  const scope = sourceCode.getScope(call);
  if (callee.type === "Identifier") {
    return isReactImport(findVariable(scope, callee.name), "useState");
  }
  if (callee.type !== "MemberExpression" || callee.object.type !== "Identifier") return false;
  const property = callee.computed ? callee.property.value : callee.property.name;
  return property === "useState" &&
    isReactImport(findVariable(scope, callee.object.name), "namespace");
}

const preferFunctionalStateUpdate = {
  meta: {
    type: "suggestion",
    schema: [],
    docs: {
      description: "Prefer functional state updates when the new value reads the same React state binding.",
    },
    messages: {
      preferUpdater: "Use a functional update for '{{setter}}' because this value reads '{{state}}'. Keep any side effects outside the updater.",
    },
  },
  create(context) {
    const { sourceCode } = context;
    return {
      CallExpression(node) {
        const callee = unwrap(node.callee);
        if (callee.type !== "Identifier" || node.arguments.length !== 1) return;
        const argument = unwrap(node.arguments[0]);
        if (["ArrowFunctionExpression", "FunctionExpression", "SpreadElement"].includes(argument.type)) return;

        const scope = sourceCode.getScope(node);
        const setter = findVariable(scope, callee.name);
        const declaration = setter?.defs.find((definition) => definition.type === "Variable")?.node;
        if (declaration?.type !== "VariableDeclarator" || declaration.id.type !== "ArrayPattern" || !declaration.init) return;
        const [stateName, setterName] = declaration.id.elements;
        if (stateName?.type !== "Identifier" || setterName?.type !== "Identifier" || setterName.name !== callee.name) return;
        if (!isUseState(declaration.init, sourceCode)) return;
        // Reassigned bindings no longer reliably identify the hook's state/setter.
        if (setter.references.some((reference) => reference.isWrite() && !reference.init)) return;
        const state = findVariable(sourceCode.getScope(declaration), stateName.name);
        if (state.references.some((reference) => reference.isWrite() && !reference.init)) return;
        if (argument.type === "Identifier" && findVariable(scope, argument.name) === state) return;

        const readsState = state.references.some((reference) => reference.isRead() &&
          reference.identifier.range[0] >= argument.range[0] &&
          reference.identifier.range[1] <= argument.range[1]);
        if (!readsState) return;
        context.report({
          node: argument,
          messageId: "preferUpdater",
          data: { setter: callee.name, state: stateName.name },
        });
      },
    };
  },
};

function hasOwnJsx(node, visitorKeys) {
  if (node.type === "JSXElement" || node.type === "JSXFragment") return true;
  if (["FunctionDeclaration", "FunctionExpression", "ArrowFunctionExpression"].includes(node.type)) return false;
  return (visitorKeys[node.type] ?? []).some((key) => {
    const child = node[key];
    return Array.isArray(child)
      ? child.some((item) => item && hasOwnJsx(item, visitorKeys))
      : child && hasOwnJsx(child, visitorKeys);
  });
}

const noRenderRegExp = {
  meta: {
    type: "suggestion",
    schema: [],
    messages: {
      allocation: "RegExp is allocated during render. Review hoisting or memoization; preserve flags and lastIndex behavior.",
    },
  },
  create(context) {
    const { sourceCode } = context;
    return {
      NewExpression(node) {
        const callee = unwrap(node.callee);
        if (callee.type !== "Identifier" || callee.name !== "RegExp") return;
        if (findVariable(sourceCode.getScope(node), "RegExp")?.defs.length) return;
        let owner = node.parent;
        while (owner && !["FunctionDeclaration", "FunctionExpression", "ArrowFunctionExpression"].includes(owner.type)) {
          owner = owner.parent;
        }
        if (!owner) return;
        const name = owner.id?.name ?? (owner.parent.type === "VariableDeclarator" ? owner.parent.id.name : undefined);
        if (!name || !/^[A-Z]/.test(name) || !hasOwnJsx(owner.body, sourceCode.visitorKeys)) return;
        context.report({ node, messageId: "allocation" });
      },
    };
  },
};

function storageRead(node, sourceCode) {
  if (!node) return;
  const call = unwrap(node);
  if (call.type !== "CallExpression" || call.arguments.length !== 1) return;
  const callee = unwrap(call.callee);
  if (callee.type !== "MemberExpression") return;
  const property = callee.computed ? callee.property.value : callee.property.name;
  if (property !== "getItem") return;
  const receiver = unwrap(callee.object);
  let area;
  let globalName;
  if (receiver.type === "Identifier") {
    area = receiver.name;
    globalName = receiver.name;
  } else if (receiver.type === "MemberExpression" && receiver.object.type === "Identifier" &&
    ["window", "globalThis"].includes(receiver.object.name)) {
    area = receiver.computed ? receiver.property.value : receiver.property.name;
    globalName = receiver.object.name;
  }
  if (!["localStorage", "sessionStorage"].includes(area)) return;
  if (findVariable(sourceCode.getScope(call), globalName)?.defs.length) return;
  const key = unwrap(call.arguments[0]);
  if (key.type !== "Literal" || typeof key.value !== "string") return;
  return { area, key: key.value, node: call };
}

const noRepeatedStorageRead = {
  meta: {
    type: "suggestion",
    schema: [],
    messages: {
      repeated: "Repeated {{area}}.getItem({{key}}) in adjacent declarations. Consider reusing the earlier value when a fresh read is not required.",
    },
  },
  create(context) {
    function checkBlock(block) {
      const seen = new Map();
      for (const statement of block.body) {
        // Unknown calls, writes and control flow can invalidate any cached read.
        if (statement.type !== "VariableDeclaration") {
          seen.clear();
          continue;
        }
        for (const declaration of statement.declarations) {
          const read = storageRead(declaration.init, context.sourceCode);
          if (!read || declaration.id.type !== "Identifier") {
            seen.clear();
            continue;
          }
          const identity = JSON.stringify([read.area, read.key]);
          if (seen.has(identity)) context.report({
            node: read.node,
            messageId: "repeated",
            data: { area: read.area, key: JSON.stringify(read.key) },
          });
          seen.set(identity, true);
        }
      }
    }
    return { Program: checkBlock, BlockStatement: checkBlock };
  },
};

export default {
  meta: { name: "vercel-react-best-practices" },
  rules: {
    "prefer-functional-state-update": preferFunctionalStateUpdate,
    "no-render-regexp": noRenderRegExp,
    "no-repeated-storage-read": noRepeatedStorageRead,
  },
};
