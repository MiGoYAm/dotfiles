# Oxlint checks

The [complete audit](COVERAGE.md) covers every one of the skill's 70 guidelines:
6 delegated mechanical checks, 42 with partial detectors, and 22 requiring
review or measurement. Every guideline links back to its decision.

[oxlint.json](oxlint.json) explicitly configures 60 checks: the six delegated
checks are errors; supplemental detectors are warnings. Each configured check
has a positive and negative case run through the actual Oxlint CLI. A matched
pattern is evidence for review, not proof of a performance or security defect.

Prefer built-in Oxlint implementations. [React Doctor](https://www.react.doctor/docs/configuration/eslint-and-oxlint-plugins)
provides the additional per-file detectors. The official Next.js plugin adds
`next-official/no-location-assign-relative-destination`, which is not native in
Oxlint 1.93.0 and is additional to the 70 source guidelines.

Three checks come from [plugin.mjs](plugin.mjs):

| Local rule | Gap in the ready-made checks |
| --- | --- |
| `prefer-functional-state-update` | Scope-aware direct state/setter references, covering more than Doctor's repeated/deferred-update heuristic. |
| `no-render-regexp` | Dynamic `new RegExp` in a named JSX-returning component; Doctor/e18e focus on static constructors and loops. |
| `no-repeated-storage-read` | Adjacent literal-key reads, distinguishing storage areas and invalidation barriers. Doctor's rule reported cross-area and read-after-write counterexamples. |

No local rule has an autofix. The controls deliberately leave aliasing,
unknown calls and behavior-sensitive decisions to review. Their precise
boundaries are described below and in the audit.

The config follows Ultracite's `portedRuleMode: "curated"` setting for React
Doctor. Keep this setting on the root config when using extended presets.
Ultracite itself is not required. Sources: [Ultracite presets](https://www.ultracite.ai/docs/presets),
[Next.js plugin](https://nextjs.org/docs/app/api-reference/config/eslint).

The shared sample config targets React/Next.js projects with browser and Node
globals. Merge its checks according to the target project's runtime, compiler,
client/server file boundaries and policy. In particular, auth and concurrency
warnings never prove authorization or independence, and advice to cache, hoist,
parallelize or memoize is not an automatic transformation.

## Run

The package installs its own development dependencies inside this skill.
Config-relative paths resolve the local and npm plugins from this directory.
Pass an absolute project path because `pnpm --dir` changes the working directory.

```sh
skill_dir="$HOME/.agents/skills/vercel-react-best-practices"
pnpm --dir "$skill_dir/oxlint" install --frozen-lockfile
pnpm --dir "$skill_dir/oxlint" exec oxlint \
  --config "$skill_dir/oxlint/oxlint.json" --disable-nested-config \
  /absolute/path/to/project
```

For an existing project configuration, merge the settings from `oxlint.json`,
install `oxlint-plugin-react-doctor@0.9.23` and
`@next/eslint-plugin-next@16.4.6` in that project,
and replace `./plugin.mjs` with the absolute path to this skill's plugin or a
project-local copy. This config does not automatically replace or merge a
project's other lint configuration.

## Coverage boundaries

[COVERAGE.md](COVERAGE.md) records the exact detector scope and remaining
judgment for each guideline, including rejected and retired plugin rules.
Partial detectors leave their source guidelines in `rules/`.
[NEXTJS.md](NEXTJS.md) records all 25 Next.js-specific rule decisions.
[DOCTOR.md](DOCTOR.md) summarizes the full 907-entry audit and the candidates
that need a project decision.

## Functional state updates

```jsx
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  // Reported: this expression captures the render's state snapshot.
  const increment = () => setCount(count + 1);
  // Accepted: React supplies the previous state when processing the update.
  const incrementSafely = () => setCount(previous => previous + 1);
  return <button onClick={incrementSafely}>{count}</button>;
}
```

The rule resolves imported React bindings, including renamed `useState`
imports and default/namespace `React.useState` calls. It handles arithmetic,
array/object spreads, method calls, and nested callbacks. References are
matched by scope, so shadowed variables and similarly named object properties
are not confused with state. Literal updates and values derived only from
arguments or other state are accepted. Reassigned state/setter bindings are
outside the rule's analysis.

The rule follows direct destructured hook bindings. It does not follow copied
setter/state aliases, wrappers, values computed in previous statements, or
state hooks imported from other packages. Those cases remain review tasks.
Intentional use of a captured snapshot may require a targeted suppression.

No autofix is provided: moving calls into an updater changes when they execute,
and React can invoke updaters more than once. Keep side effects outside them.

## Render-time regex allocation

`no-render-regexp` recognizes direct `new RegExp` calls in uppercase-named
function declarations, named function expressions and variable-assigned arrows
whose own bodies contain JSX. It ignores shadowed constructors, module-scope
allocations, utilities without JSX, and nested memo/effect/event callbacks.
It does not cover class render methods, anonymous HOC callbacks, createElement
components, constructor aliases or regex literals. Keep `g`/`y` flags and
`lastIndex` semantics in mind before sharing a RegExp between calls.

## Repeated storage reads

`no-repeated-storage-read` checks adjacent variable declarations containing
direct getItem calls with literal keys. localStorage and sessionStorage use
separate identities; global, window and globalThis access are recognized.
Local bindings that shadow browser globals are ignored. Any unknown initializer,
call, write, control-flow statement or await breaks the sequence. Nested blocks
and functions are analyzed separately. Dynamic keys, copied aliases, cookies,
logical-expression initializers and cross-call cache design remain review tasks.
An intentional fresh read may require a suppression.

## Verify

```sh
pnpm --dir "$HOME/.agents/skills/vercel-react-best-practices/oxlint" test
```

The tests execute all 60 explicitly configured checks with detecting and
accepted examples. They also cover the 70-row inventory, scope/import cases,
RegExp lifecycle boundaries, storage invalidation and area separation, and
semantic equivalence of the flatMap example on empty strings.

Versions are pinned in `package.json` and `pnpm-lock.yaml`: Oxlint 1.93.0,
React Doctor 0.9.23 and the official Next.js plugin 16.4.6. The tests do not
claim to establish runtime speedups. Oxlint's JS plugin API is experimental;
see its [documentation](https://oxc.rs/docs/guide/usage/linter/js-plugins.html).
