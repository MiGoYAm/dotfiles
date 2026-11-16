# Rules delegated to Oxlint

These guidelines from `vercel-react-best-practices` have direct Oxlint
equivalents. Keep their original explanations and examples here for projects
that have not enabled the corresponding lint rules. When linting is configured
for the target files, use its diagnostics instead of repeating these checks in
agent reviews. Lint enforcement does not imply an automatic fix.

Prefer native Oxlint rules. Move another guideline here only after verifying
that the rule covers its behavior, including its examples and exceptions.
Partial checks and optimization suggestions stay in `../rules/`. For an
external plugin, verify both rule coverage and actual execution through
Oxlint's `jsPlugins`; ESLint support alone is insufficient.

## Mapping

| Guideline | Built-in Oxlint rule |
| --- | --- |
| [Effect Event dependencies](advanced-effect-event-deps.md) | `react/exhaustive-deps` |
| [Components defined during render](rerender-no-inline-components.md) | `react/static-components` |
| [Unstable default props](rerender-memo-with-default-value.md) | `react/no-object-type-as-default-prop` |
| [State derived in effects](rerender-derived-state-no-effect.md) | `react/no-deriving-state-in-effects` |
| [Immutable sorting](js-tosorted-immutable.md) | `unicorn/no-array-sort` |
| [Non-blocking scripts](rendering-script-defer-async.md) | `nextjs/no-sync-scripts` |

## Configuration

The ready-to-run [configuration](../oxlint/oxlint.json) enables all six mapped
checks plus supplemental warnings. See [setup](../oxlint/README.md) for
installation and running it against a project. The six mappings themselves
use built-in plugins and need no npm plugin; the supplemental checks use React Doctor, the official Next.js plugin, and
a local plugin.

`allowAfterSpread` preserves the guideline's `[...items].sort()` fallback and
allows sorting a fresh array. `allowExpressionStatement: false` also catches
standalone `items.sort()` mutations. Enable this replacement when `toSorted()`
is available in the target runtime or polyfilled.

`react/static-components` and `react/no-deriving-state-in-effects` use Oxlint's
experimental React Compiler analysis. Enable them explicitly and verify the
installed version; they are not default checks. Running the compiler's lint
analysis does not require enabling React Compiler optimization in the app.
With React Compiler optimization enabled, reassess whether checking unstable
default props is still useful.

## Verification

Verified with Oxlint **1.93.0** on the incorrect and correct examples from all
six guidelines. Each incorrect example produced its mapped diagnostic, and
all six correct examples passed the mapped checks. Unrelated default checks,
such as unused variables in standalone snippets, are outside this verification.
The default-prop examples include a
semicolon after `memo(...)` so the following JSX parses as a separate statement.

This verifies the documented patterns, not exhaustive static analysis of all
JavaScript. Recheck mappings when upgrading Oxlint or changing these examples.

Sources: [built-in plugins](https://oxc.rs/docs/guide/usage/linter/plugins.html),
[JS plugin compatibility](https://oxc.rs/docs/guide/usage/linter/js-plugins.html).
Each archived guideline links to its specific Oxlint rule documentation.
