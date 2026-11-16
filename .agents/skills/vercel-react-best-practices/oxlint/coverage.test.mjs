import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";
import { runInNewContext } from "node:vm";
import { lint } from "./test-utils.mjs";

const cases = JSON.parse(readFileSync(new URL("./coverage-cases.json", import.meta.url), "utf8"));
const configPath = fileURLToPath(new URL("./oxlint.json", import.meta.url));
const config = JSON.parse(readFileSync(configPath, "utf8"));

function examples(entry) {
  if (entry.bad) return { bad: entry.bad, good: entry.good };
  const archive = new Set(["advanced-effect-event-deps", "rerender-no-inline-components",
    "rerender-memo-with-default-value", "rerender-derived-state-no-effect",
    "js-tosorted-immutable", "rendering-script-defer-async"]);
  const folder = archive.has(entry.guideline) ? "lint-replaced" : "rules";
  const markdown = readFileSync(new URL(`../${folder}/${entry.guideline}.md`, import.meta.url), "utf8");
  const result = {};
  for (const [key, heading] of [["bad", "Incorrect"], ["good", "Correct"]]) {
    let code = markdown.split(`**${heading}`)[1].match(/```\w*\n([\s\S]*?)```/)[1];
    const imports = entry.imports?.length ? `import {${entry.imports.join(",")}} from 'react';\n` : "";
    // Keep directives before imports in the server-action fixtures.
    code = code.startsWith("'use server'")
      ? code.replace("'use server'", `'use server';\n${imports}`)
      : imports + code;
    result[key] = code;
  }
  return result;
}

function diagnosticFor(rule) {
  const [plugin, name] = rule.split("/");
  const prefix = rule === "react/exhaustive-deps" ? "react-hooks" : plugin === "nextjs" ? "next" : plugin;
  return `${prefix}(${name})`;
}

test("each enabled rule reports its bad case and accepts its good case through the shipped config", (t) => {
  const directory = mkdtempSync(join(tmpdir(), "vrbp-coverage-"));
  t.after(() => rmSync(directory, { recursive: true, force: true }));
  assert.deepEqual(new Set(cases.map((entry) => entry.rule)), new Set(Object.keys(config.rules)),
    "Every configured check needs an executable positive/negative case");
  const files = [];
  cases.forEach((entry, index) => {
    const inputs = { ...examples(entry) };
    entry.accepted?.forEach((code, extra) => { inputs[`accepted-${extra}`] = code; });
    for (const [kind, code] of Object.entries(inputs)) {
      const path = entry.filename
        ? join(directory, `${index}-${kind}`, entry.filename)
        : join(directory, `${index}-${kind}.tsx`);
      if (entry.filename) mkdirSync(join(directory, `${index}-${kind}`));
      writeFileSync(path, code);
      files.push(path);
    }
  });
  const diagnostics = lint(configPath, files);
  cases.forEach((entry, index) => {
    const kinds = ["bad", "good", ...(entry.accepted ?? []).map((_, extra) => `accepted-${extra}`)];
    for (const kind of kinds) {
      const matches = diagnostics.filter((item) => item.filename.endsWith(entry.filename
          ? `/${index}-${kind}/${entry.filename}` : `/${index}-${kind}.tsx`) &&
        item.code === diagnosticFor(entry.rule));
      assert.equal(matches.length > 0, kind === "bad", `${entry.rule}: ${kind} ${JSON.stringify(matches)}`);
    }
  });
});

test("the audit accounts for every guideline exactly once and keeps partial checks out of the archive", () => {
  const inventory = [];
  for (const folder of ["rules", "lint-replaced"]) {
    for (const name of readdirSync(new URL(`../${folder}/`, import.meta.url))) {
      if (name.endsWith(".md") && !name.startsWith("_") && name !== "README.md") {
        inventory.push([name.slice(0, -3), folder]);
      }
    }
  }
  const markdown = readFileSync(new URL("./COVERAGE.md", import.meta.url), "utf8");
  const rows = [...markdown.matchAll(/^\| \[([^\]]+)\]\([^)]+\) \| (Delegated|Partial|Review) \| ([^|]+) \|/gm)];
  assert.equal(inventory.length, 70);
  assert.equal(rows.length, inventory.length);
  assert.deepEqual(new Set(rows.map((row) => row[1])), new Set(inventory.map(([name]) => name)));
  const mappedRules = new Set();
  for (const [, name, decision, rules] of rows) {
    const folder = inventory.find(([id]) => id === name)[1];
    assert.equal(folder === "lint-replaced", decision === "Delegated", name);
    const keys = [...rules.matchAll(/`([^`]+)`/g)].map((match) => match[1]);
    assert.equal(keys.length > 0, decision !== "Review", name);
    for (const key of keys) {
      assert.ok(config.rules[key], `${name}: ${key} is not enabled`);
      mappedRules.add(key);
    }
  }
  // This official Next.js control is useful but is not one of the 70 source guidelines.
  mappedRules.add("next-official/no-location-assign-relative-destination");
  assert.deepEqual(mappedRules, new Set(Object.keys(config.rules)));
});

test("the flatMap example preserves filter(Boolean) behavior for empty strings", () => {
  const { bad, good } = examples({ guideline: "js-flatmap-filter" });
  const users = [
    { isActive: true, name: "" },
    { isActive: true, name: "Ada" },
    { isActive: false, name: "Ben" },
  ];
  for (const code of [bad, good]) {
    assert.equal(runInNewContext(`${code}\nJSON.stringify(userNames)`, { users }), '["Ada"]');
  }
});

test("the full Doctor audit covers the installed catalog and records actual enabled rules", async () => {
  const { default: doctor } = await import("oxlint-plugin-react-doctor");
  const audit = JSON.parse(readFileSync(new URL("./doctor-audit.json", import.meta.url), "utf8"));
  const packageInfo = JSON.parse(readFileSync(new URL(
    "./node_modules/oxlint-plugin-react-doctor/package.json", import.meta.url), "utf8"));
  assert.equal(audit.version, packageInfo.version);
  assert.equal(audit.rules.length, Object.keys(doctor.rules).length);
  assert.deepEqual(new Set(audit.rules.map((entry) => entry.id)), new Set(Object.keys(doctor.rules)));
  const guidelines = new Set();
  for (const folder of ["rules", "lint-replaced"]) {
    for (const name of readdirSync(new URL(`../${folder}/`, import.meta.url))) {
      if (name.endsWith(".md") && name !== "README.md" && !name.startsWith("_")) {
        guidelines.add(name.slice(0, -3));
      }
    }
  }
  for (const entry of audit.rules) {
    assert.ok(entry.reason && entry.evidence, entry.id);
    assert.equal(entry.enabled, Boolean(config.rules[`react-doctor/${entry.id}`]), entry.id);
    assert.equal(entry.lifecycle, doctor.rules[entry.id].lifecycle ?? "active", entry.id);
    assert.equal(entry.defaultEnabled, doctor.rules[entry.id].defaultEnabled ?? true, entry.id);
    assert.equal(entry.selection === "enabled", entry.enabled, entry.id);
    for (const guideline of entry.guidelines) assert.ok(guidelines.has(guideline), `${entry.id}: ${guideline}`);
  }
});
