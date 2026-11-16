# Full React Doctor audit

All 907 exported entries in `oxlint-plugin-react-doctor@0.9.23` were assigned
once across three independent Codex Personal reviews. Each entry was compared
with all 70 guideline texts, including optional, retired and project-only rules.

[doctor-audit.json](doctor-audit.json) contains one record per entry, with its
mapped guidelines, reason, evidence, lifecycle, default status and final sample
configuration selection. `disposition` preserves the review assessment;
`new-partial` means a candidate found during this audit, not an enabled rule or
a full replacement. `enabled` and `selection` describe the final configuration.
The inventory test checks this record set against the installed plugin.

Reviewers inspected potentially related implementations and ran focused cases
through pinned Oxlint. Clearly unrelated contracts, such as ARIA schema values,
were assessed semantically without manufacturing performance fixtures. Detailed
exploratory runs used temporary fixtures; their observations are retained in
the records. The committed coverage tests reproduce every enabled control's
positive/negative cases and selected boundaries. This is not a runtime benchmark
or proof that every behavior accepted by a detector is correct.

## Selected additions

Nine further advisory checks are enabled after reproducing their detecting and
accepted cases with the shipped configuration:

- `auth-token-in-web-storage` and `no-unsafe-json-parse` cover narrow credential
  storage and parsed-value access risks. They do not enforce a storage schema.
- `js-batch-dom-css` adds selected layout-read/style-write loops. It misses the
  original straight-line example and cannot decide whether reflow is deliberate.
- `no-match-media-in-state-initializer`,
  `no-unguarded-browser-global-at-module-scope`,
  `no-hydration-branch-on-browser-global` and `rendering-hydration-no-flicker`
  extend SSR/hydration detection. Actual flicker still needs a running-app check.
- `no-nondeterministic-id-value-in-render-body` and `no-locale-format-in-render`
  add unstable IDs and locale/timezone output. A warning does not justify hiding
  a hydration mismatch; consistent output or useId may be appropriate.

No additional full guideline replacement was found. The three local rules
remain useful; candidate overlaps did not close their documented gaps.

## Candidates needing a project decision

These additional partial candidates stay out of the shared sample configuration.
Many target libraries absent from a React/Next.js project; others impose a
broader policy than the source guideline. These are suggestions to evaluate,
not instructions to install every library or turn every rule on.

| Doctor rule | Related guidelines | Boundary or decision |
| --- | --- | --- |
| `jotai-derived-atom-returns-fresh-object` | `rerender-derived-state` | Returning only required fields instead of a fresh derived collection reduces subscriptions/redraws, a package-specific subset of subscribe-to-derived-state guidance. Does not check useWindowWidth/media-query source or prove shallow equality safe. |
| `jotai-tq-use-raw-query-atom` | `rerender-derived-state`, `rerender-defer-reads` | Optional Jotai TanStack Query extension for subscribing to a derived field instead of the entire changing query result. It does not replace the continuous-width example or arbitrary store selector analysis. |
| `js-hoist-intl` | `js-cache-function-results` | Adds reusable Intl formatter allocation advice, a narrow instance of avoiding repeated expensive work. It does not cache arbitrary function results by input, infer purity, or decide invalidation. |
| `no-create-store-in-render` | `advanced-init-once` | Narrow extension for app store creation during render, which can reset subscriptions and state. It does not enforce once-per-app initialization across remounts or decide valid per-request/per-instance stores. |
| `no-full-lodash-import` | `bundle-barrel-imports` | A package-specific direct-import check matches the guideline explicit lodash example family. It cannot inspect arbitrary barrel modules or establish whether Next optimizePackageImports already makes a barrel safe. Use only with project bundler policy. |
| `no-prop-callback-in-effect` | `rerender-move-effect-to-event` | Adds a narrow parent synchronization effect warning. Interaction-triggered callbacks can move to handlers, but subscription-driven callbacks may intentionally run in effects; lifting state/provider use is a design decision. |
| `no-whole-object-dep-with-member-reads` | `rerender-dependencies` | Adds object-to-member dependency advice for memo/callback/imperative hooks. It intentionally excludes useEffect, so it does not close the actual guideline effect example or split combined computations. |
| `query-destructure-result` | `rerender-defer-reads`, `rerender-derived-state` | Optional specialized subscription-minimization warning: spreading a query result reads every tracked field. Supports narrowing subscriptions but does not detect continuously changing values converted into a boolean, or a hook used only in an event callback. |
| `query-no-mutation-in-effect-as-read` | `client-swr-dedup` | TanStack useMutation used as an effect-driven read can bypass cached/deduplicated query ownership, semantically the fetch-in-effect problem. Very narrow read-name heuristics and response consumption apply; no blanket useMutation ban. |
| `query-no-rest-destructuring` | `rerender-derived-state`, `rerender-defer-reads` | TanStack Query field subscription advice is a narrow extension of subscribing only to needed derived state. It does not deduplicate queries or infer arbitrary callback-only usage. |
| `query-stable-query-client` | `advanced-init-once`, `rerender-lazy-state-init` | Detects render-time QueryClient recreation, a narrow lifetime/lazy-initialization concern. useState laziness preserves per-instance identity, not once-per-app initialization across remounts. |
| `r3f-no-fresh-use-three-selector` | `rerender-derived-state` | Adds R3F selector reference-stability advice, reducing avoidable subscriptions/renders in that store. It does not infer the source continuous-width-to-boolean threshold or choose optimal subscription granularity. |
| `r3f-no-state-in-pointer-move` | `rerender-use-ref-transient-values` | Adds direct high-frequency R3F pointer-state detection, including visual transient positions missed by the enabled state-only-in-handlers check. Ref mutation and commit semantics require review. |
| `r3f-no-state-in-use-frame` | `rerender-use-ref-transient-values`, `rerender-transitions` | Frame-loop state writes are a package-specific warning about frequent renders. A ref is valid only if the value need not drive React output, and a transition does not reduce frame count. |
| `r3f-prefer-use-loader` | `client-swr-dedup`, `async-suspense-boundaries` | Imperative effect loading bypasses R3F request caching/deduplication, a specialized resource version of client dedup guidance. Recommending Suspense-backed useLoader does not prove strategic boundary/fallback placement. |
| `react-router-no-router-in-render` | `advanced-init-once` | Router recreation during render resets navigation state; avoiding it is a narrow initialization-lifetime extension. It does not enforce app initialization once per load or detect the source analytics effect. |
| `react-router-prefer-route-lazy` | `bundle-dynamic-imports`, `async-parallel` | Adds route-module lazy loading advice to avoid a component-only loading waterfall. It does not decide whether ordinary components are heavy/optional or parallelize arbitrary I/O. |
| `react-router-return-navigation-promise-in-transition` | `rendering-usetransition-loading`, `rerender-transitions` | Adds a narrow pending-lifetime correctness guard for navigation already wrapped in transitions. Does not discover manual loading flags or choose nonurgent updates. |
| `redux-useselector-inline-derivation` | `rerender-derived-state`, `rerender-memo` | A fresh collection selector result triggers redraws on Redux actions. Memoized selector derivation is a narrow extension of reducing subscription-driven renders, not the source boolean threshold subscription or pre-return memo extraction. |
| `redux-useselector-returns-new-collection` | `rerender-derived-state` | Fresh selector collections force extra subscriptions/redraws despite unchanged selected fields, related to derived-value subscriptions. Stable memoized selectors, shallowEqual and domain equality remain valid; source width threshold is not recognized. |
| `rn-bottom-sheet-no-state-in-on-animate` | `rerender-use-ref-transient-values` | Bottom Sheet animation-coupled state adds render work and can use shared animated values. Narrowly related to transient values, but onAnimate fires at transition start and is not proof of a per-frame update or a valid ref conversion. |
| `rn-list-callback-per-row` | `rerender-memo` | Adds native-list per-row callback identity advice that can preserve memo bailouts. Does not extract expensive pre-return computation or prove rows are memoized or costly. |
| `rn-list-data-mapped` | `rerender-memo` | React Native list data mapping can invalidate memoized rows. This is an advisory stable-input extension, not the source expensive JSX before early return or proof that memoization pays off. |
| `rn-no-inline-object-in-list-item` | `rerender-memo` | Fresh object props inside React Native list render callbacks can defeat memoized rows. This is limited stable-prop advice, not the guideline pre-return expensive computation check. |
| `rn-no-scroll-state` | `rerender-use-ref-transient-values`, `rerender-transitions` | Native scroll handlers using state are a frequent-update subset of transient-value guidance. Rule recommends refs/shared values rather than transitions and cannot infer whether state drives UI requiring a render. |
| `server-no-mutable-module-state` | `server-no-shared-module-state` | Could extend render-time react/globals to use-server action modules, but not safe as blanket configuration. Reports safe process initialization flags and correctly keyed caches explicitly allowed by the guideline. Original RSC has no use-server directive and is missed. |
| `three-no-object-construction-in-render` | `rerender-memo`, `rerender-lazy-state-init` | Adds render-time mutable Three.js allocation warnings. This is a package-specific repeated-work subset; it does not infer cost, decide lifetimes, or cover general early-return extraction. |
| `three-no-state-in-animation-loop` | `rerender-use-ref-transient-values`, `rerender-transitions` | Frequent state writes in a Three.js animation callback are a narrow transient-value/render-frequency warning. Keeping React-visible state may still be required. |
| `three-no-state-in-pointer-move` | `rerender-use-ref-transient-values` | Continuous pointer state in Three canvas handlers is a targeted transient-value warning. It neither decides which displayed values require React state nor covers all browser mousemove/R3F mesh handlers. |
| `valtio-no-snapshot-in-callback` | `rerender-defer-reads` | Direct package-specific match for deferring subscribed state reads to callback usage. It does not replace URL-hook or arbitrary store handling. |
| `zustand-no-fresh-selector-result` | `rerender-derived-state` | Adds Zustand v5 selector snapshot identity safety. Stable selectors can reduce unnecessary renders but this does not narrow continuous subscriptions to semantic thresholds automatically. |
| `zustand-no-whole-store-destructure` | `rerender-derived-state`, `rerender-defer-reads` | Adds narrow-store subscription advice, useful when components read only a small subset of state. Does not establish boolean thresholds or move callback-only reads to their usage point. |

In particular, `server-no-mutable-module-state` reports correctly keyed caches
and initialization guards allowed by the guideline. It is not a safe blanket
replacement. `no-full-lodash-import` needs the project's bundler policy because
Next.js import optimization can make a root import acceptable.
`no-whole-object-dep-with-member-reads` excludes useEffect, so it does not close
the effect-dependency example. A package-specific initialization rule preserving
per-component identity does not establish once-per-app lifetime across remounts.

See [COVERAGE.md](COVERAGE.md) for the 70 guideline decisions and
[NEXTJS.md](NEXTJS.md) for the Next.js subset. Upstream source:
[React Doctor rule registry](https://github.com/millionco/react-doctor/blob/main/packages/oxlint-plugin-react-doctor/src/plugin/rule-registry.ts).
The pinned installed version, rather than upstream main, determined this audit.
