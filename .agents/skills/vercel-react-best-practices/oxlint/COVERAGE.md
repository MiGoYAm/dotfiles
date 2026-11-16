# Coverage of all 70 guidelines

Audited against the source examples and the installed implementations of
Oxlint 1.93.0, React Doctor 0.9.23, and the Next.js plugin 16.4.6.

- **Delegated**: the guideline's mechanical check is already delegated to lint.
  These files live in `../lint-replaced/`. This is not a claim of complete
  interprocedural analysis or proof of runtime behavior.
- **Partial**: a useful, tested check is enabled as a warning. The guideline
  stays in `../rules/`; review is still required for the boundary described.
- **Review**: no general lint rule is enabled for this guideline. The decision
  needs runtime measurements, project policy, or semantics that a local AST
  check cannot establish. A rejected candidate is named where relevant.

The table is exhaustive. Rule names in its third column refer to enabled
checks in [oxlint.json](oxlint.json). Tests use the actual Oxlint runner on
positive and negative cases, plus counterexamples for the local rules.

## Eliminating waterfalls

| Guideline | Decision | Enabled lint rules | Remaining judgment |
| --- | --- | --- | --- |
| [async-api-routes](../rules/async-api-routes.md) | Partial | `react-doctor/server-sequential-independent-await` | Local sequential awaits only; authentication, side effects, rate limits and dependencies still decide whether concurrency is valid. |
| [async-cheap-condition-before-await](../rules/async-cheap-condition-before-await.md) | Review | — | Skipping a call or reordering a condition changes effects and failures; syntax does not establish purity or cheapness. No safe general replacement found. |
| [async-defer-await](../rules/async-defer-await.md) | Partial | `react-doctor/async-defer-await` | Detects some awaits before early returns; delaying I/O may change required effects or make the common path slower. |
| [async-dependencies](../rules/async-dependencies.md) | Review | — | Requires the dependency and side-effect graph across calls. Installing better-all is an architectural choice, not a lint invariant. |
| [async-parallel](../rules/async-parallel.md) | Partial | `react-doctor/async-parallel`, `react-doctor/async-await-in-loop` | Block detector handles runs of at least three awaits; loop detector adds per-item waterfalls. Some dependent accumulators are accepted, but loops with break still report. Side effects, rate limits, failure timing and early termination require review. |
| [async-suspense-boundaries](../rules/async-suspense-boundaries.md) | Partial | `react-doctor/nextjs-no-use-search-params-without-suspense` | Finds useSearchParams consumers without Suspense in page/layout files. Does not detect the source's async data-fetching example or decide streaming boundaries, fallback UX or layout stability. |

## Bundle size

| Guideline | Decision | Enabled lint rules | Remaining judgment |
| --- | --- | --- | --- |
| [bundle-analyzable-paths](../rules/bundle-analyzable-paths.md) | Partial | `react-doctor/no-dynamic-import-path` | Detects nonliteral import paths, not filesystem output tracing. Some bundlers deliberately support dynamic imports. |
| [bundle-barrel-imports](../rules/bundle-barrel-imports.md) | Review | — | Correct examples retain barrel imports when optimizePackageImports handles them. no-barrel-import/no-barrel-file would forbid allowed code; project-specific restricted imports remain an option. |
| [bundle-conditional](../rules/bundle-conditional.md) | Review | — | Whether a module is large, optional and needed initially depends on bundle analysis and product behavior. |
| [bundle-defer-third-party](../rules/bundle-defer-third-party.md) | Review | — | Doctor's nextjs-no-google-analytics-script flags even afterInteractive/lazyOnload scripts: an integration preference, not a deferral check. It also misses the source's Analytics import. Generic scripts already have the delegated script check; safe loading/consent timing remains contextual. |
| [bundle-dynamic-imports](../rules/bundle-dynamic-imports.md) | Partial | `react-doctor/prefer-dynamic-import` | Known heavy packages only; does not discover local wrappers or decide whether they are needed for initial rendering. |
| [bundle-preload](../rules/bundle-preload.md) | Review | — | Requires knowledge of navigation intent, bandwidth and likely resource use. Blanket preloading can make performance worse. |

## Server performance

| Guideline | Decision | Enabled lint rules | Remaining judgment |
| --- | --- | --- | --- |
| [server-after-nonblocking](../rules/server-after-nonblocking.md) | Partial | `react-doctor/server-after-nonblocking` | Recognizes selected direct side-effect calls. Does not follow logUserAction wrappers or establish durability/transaction requirements. |
| [server-auth-actions](../rules/server-auth-actions.md) | Partial | `react-doctor/server-auth-actions` | A heuristic for missing guards, not proof of authentication, authorization or input validation. Custom wrappers and intentional public actions need review. |
| [server-cache-lru](../rules/server-cache-lru.md) | Review | — | Cache keys, tenancy, invalidation, memory bounds and deployment topology require a domain decision. A blanket cache insertion is unsafe. |
| [server-cache-react](../rules/server-cache-react.md) | Partial | `react-doctor/server-cache-with-object-literal` | Finds fresh literal arguments to locally identifiable React.cache functions. Does not prove caching is needed or correct, and does not follow all wrappers. |
| [server-dedup-props](../rules/server-dedup-props.md) | Partial | `react-doctor/server-dedup-props` | Detects source-plus-derived props in the same file. The actual server/client boundary, payload size and transformation cost still need review. |
| [server-hoist-static-io](../rules/server-hoist-static-io.md) | Partial | `react-doctor/server-hoist-static-io` | Recognizes selected static asset I/O; cannot establish lifetime, mutability, failure recovery or memory cost for every asset. |
| [server-no-shared-module-state](../rules/server-no-shared-module-state.md) | Partial | `react/globals` | Catches render-time reassignment in the RSC example. Indirect request-state mutation and correctly keyed shared caches still need review; avoid a blanket ban on module-level state. |
| [server-parallel-fetching](../rules/server-parallel-fetching.md) | Review | — | Requires component-tree and dataflow analysis. Local await checks do not prove parent/child fetches can run concurrently. |
| [server-parallel-nested-fetching](../rules/server-parallel-nested-fetching.md) | Review | — | Chaining per-item requests changes failure timing, resource use and concurrency. A local Promise.all shape alone is insufficient. |
| [server-serialization](../rules/server-serialization.md) | Review | — | Requires client prop usage across modules and actual payload measurements. Types alone do not establish serialized size or needed fields. |

## Client fetching

| Guideline | Decision | Enabled lint rules | Remaining judgment |
| --- | --- | --- | --- |
| [client-event-listeners](../rules/client-event-listeners.md) | Review | — | Cleanup rules do not deduplicate listeners across mounted instances. Sharing changes subscription ownership and callback routing. |
| [client-localstorage-schema](../rules/client-localstorage-schema.md) | Partial | `react-doctor/auth-token-in-web-storage`, `react-doctor/no-unsafe-json-parse` | Credential-like storage keys and unguarded parsed-value dereferences only. Neutral keys can hide tokens; versioning, schema minimization, migration and storage exceptions remain manual. Doctor's similarly named versioning rule is retired. |
| [client-passive-event-listeners](../rules/client-passive-event-listeners.md) | Partial | `react-doctor/client-passive-event-listeners` | Handles known DOM targets and listener bodies; explicit nonpassive gesture handlers remain valid. Unknown indirection cannot prove preventDefault is absent. |
| [client-swr-dedup](../rules/client-swr-dedup.md) | Partial | `react-doctor/no-fetch-in-effect` | Detects effect fetching, not duplicate requests across instances. SWR, React Query and other designs can all be valid; the rule is advisory. |

## Re-rendering

| Guideline | Decision | Enabled lint rules | Remaining judgment |
| --- | --- | --- | --- |
| [rerender-defer-reads](../rules/rerender-defer-reads.md) | Partial | `react-doctor/rerender-defer-reads-hook` | Selected hooks used only in callbacks. Does not establish whether the callback must see a captured snapshot or the current URL. |
| [rerender-dependencies](../rules/rerender-dependencies.md) | Partial | `react-doctor/rerender-dependencies` | Detects fresh inline objects/arrays/functions in dependencies, not all object-to-primitive narrowing or derived threshold subscriptions. |
| [rerender-derived-state](../rules/rerender-derived-state.md) | Partial | `react-doctor/rerender-derived-state-from-hook` | Known continuous hooks feeding a threshold; custom stores and subscriptions need review. |
| [rerender-derived-state-no-effect](../lint-replaced/rerender-derived-state-no-effect.md) | Delegated | `react/no-deriving-state-in-effects` | Mechanical derived-state-in-effect check; indirect wrappers and broader state design remain outside local lint analysis. |
| [rerender-functional-setstate](../rules/rerender-functional-setstate.md) | Partial | `vercel-react-best-practices/prefer-functional-state-update` | Scope-aware direct setter/state pairs, including React import aliases. Copied aliases, earlier computations and intentional snapshots need review. |
| [rerender-lazy-state-init](../rules/rerender-lazy-state-init.md) | Partial | `react-doctor/rerender-lazy-state-init`, `react-doctor/no-eager-new-in-use-state-initializer` | Calls and nontrivial constructors are recognized; actual cost, wrappers and other eager expression shapes still need review. |
| [rerender-memo](../rules/rerender-memo.md) | Partial | `react-doctor/rerender-memo-before-early-return` | Detects selected work before an early return, not the cost or value of extracting/memoizing a component. Account for React Compiler. |
| [rerender-memo-with-default-value](../lint-replaced/rerender-memo-with-default-value.md) | Delegated | `react/no-object-type-as-default-prop` | Mechanical unstable-default check; React Compiler may make the manual convention unnecessary. |
| [rerender-move-effect-to-event](../rules/rerender-move-effect-to-event.md) | Partial | `react-doctor/no-event-handler` | Detects modeled state-plus-effect event handlers; the intended trigger of arbitrary effects cannot be inferred reliably. |
| [rerender-no-inline-components](../lint-replaced/rerender-no-inline-components.md) | Delegated | `react/static-components` | Mechanical recreation of component types; unsupported compiler syntax/indirection is not exhaustive. |
| [rerender-simple-expression-in-memo](../rules/rerender-simple-expression-in-memo.md) | Partial | `react-doctor/no-usememo-simple-expression` | Detects simple literal arithmetic, not every logical property expression in the source example. Unknown values can be references or getters. |
| [rerender-split-combined-hooks](../rules/rerender-split-combined-hooks.md) | Review | — | Splitting can reorder effects or computations. Requires purity, dependencies and measured recomputation cost; no matching complete ready check found. |
| [rerender-transitions](../rules/rerender-transitions.md) | Partial | `react-doctor/rerender-transitions-scroll` | Selected inline scroll handlers; named handler indirection and urgency still need review. A transition does not reduce the event count. |
| [rerender-use-deferred-value](../rules/rerender-use-deferred-value.md) | Review | — | Requires proof of expensive rendering and acceptable stale UI. Syntax cannot establish either. |
| [rerender-use-ref-transient-values](../rules/rerender-use-ref-transient-values.md) | Partial | `react-doctor/rerender-state-only-in-handlers` | Finds state consumed only in handlers/subscriptions, not rendered output. Accepts rendered state and misses the original Tracker example, whose state positions visible UI. Ref conversion, DOM ownership and captured snapshots remain behavior decisions. |

## Rendering

| Guideline | Decision | Enabled lint rules | Remaining judgment |
| --- | --- | --- | --- |
| [rendering-activity](../rules/rendering-activity.md) | Review | — | Requires intended state preservation and effect lifetimes. activity-wraps-effect-heavy-subtree is retired and would not enforce adding Activity anyway. |
| [rendering-animate-svg-wrapper](../rules/rendering-animate-svg-wrapper.md) | Review | — | Browser/compositor and SVG-attribute behavior must be measured. Doctor's identically named rule is retired; a wrapper is not universally equivalent. |
| [rendering-conditional-render](../rules/rendering-conditional-render.md) | Partial | `react-doctor/rendering-conditional-render` | Numeric-looking values before JSX are detected, but names are not TypeScript proofs. A type-aware ESLint rule cannot currently run through Oxlint's JS bridge. |
| [rendering-content-visibility](../rules/rendering-content-visibility.md) | Review | — | Requires list size, viewport behavior, accessibility and layout measurements; blindly adding containment can change behavior. |
| [rendering-hoist-jsx](../rules/rendering-hoist-jsx.md) | Partial | `react-doctor/rendering-hoist-jsx` | Finds static JSX in local const declarations, not every returned static subtree. Manual hoisting may be unnecessary with React Compiler. |
| [rendering-hydration-no-flicker](../rules/rendering-hydration-no-flicker.md) | Partial | `react-doctor/no-unguarded-browser-global-in-render-or-hook-init`, `react-doctor/no-unguarded-browser-global-at-module-scope`, `react-doctor/no-hydration-branch-on-browser-global`, `react-doctor/no-match-media-in-state-initializer`, `react-doctor/rendering-hydration-no-flicker` | Adds module-level browser reads, differing browser/server branches, media-query state initializers and selected post-paint setter shapes. The original guarded storage effect remains undetected. SSR snapshots, boundary ownership and actual flicker require a running-app check. |
| [rendering-hydration-suppress-warning](../rules/rendering-hydration-suppress-warning.md) | Partial | `react-doctor/rendering-hydration-mismatch-time`, `react-doctor/no-nondeterministic-id-value-in-render-body`, `react-doctor/no-locale-format-in-render` | Known time/random reads, selected generated IDs and implicit locale/timezone formatting. A warning does not justify suppression; prefer consistent server/client output or useId where appropriate. Server-render context and intentional differences still need review. |
| [rendering-resource-hints](../rules/rendering-resource-hints.md) | Review | — | Which resources are critical or likely to be needed requires a network trace and product intent. Blanket hints waste bandwidth. |
| [rendering-script-defer-async](../lint-replaced/rendering-script-defer-async.md) | Delegated | `nextjs/no-sync-scripts` | Mechanical external render-blocking script check. Choosing ordering and a next/script strategy still needs context. |
| [rendering-svg-precision](../rules/rendering-svg-precision.md) | Partial | `react-doctor/rendering-svg-precision` | JSX attribute precision only, not standalone SVG assets or visual equivalence. Use SVGO in the asset pipeline and inspect precision changes. |
| [rendering-usetransition-loading](../rules/rendering-usetransition-loading.md) | Review | — | A loading-state name does not establish nonurgent work or transition semantics. Doctor's identically named rule is retired. |

## JavaScript

| Guideline | Decision | Enabled lint rules | Remaining judgment |
| --- | --- | --- | --- |
| [js-batch-dom-css](../rules/js-batch-dom-css.md) | Partial | `react-doctor/js-batch-dom-css` | Detects selected loop layout-read/style-write sequences, not the original straight-line example. Write-only loops are accepted. Aliasing, deliberate forced layout and actual rendering cost still require profiling. |
| [js-cache-function-results](../rules/js-cache-function-results.md) | Review | — | Purity, changing inputs, eviction, memory and invalidation are domain properties. Caching arbitrary repeated calls can be wrong. |
| [js-cache-property-access](../rules/js-cache-property-access.md) | Partial | `react-doctor/js-cache-property-access` | Detects at least three repeated deep reads inside one loop body, not the source's one read per iteration. Getters and mutations still require review. |
| [js-cache-storage](../rules/js-cache-storage.md) | Partial | `vercel-react-best-practices/no-repeated-storage-read` | Adjacent direct literal-key reads only; distinguishes storage areas and stops at unknown statements/calls. Cross-call caching and invalidation remain manual. Doctor's rule was rejected for cross-area and read-after-write false positives. |
| [js-combine-iterations](../rules/js-combine-iterations.md) | Partial | `react-doctor/js-combine-iterations` | Selected chained iterations, not separate filters in the source example. Preserve callback order, type predicates and intermediate values. |
| [js-early-exit](../rules/js-early-exit.md) | Review | — | The source changes which validation error is returned. Early exit requires the intended result, not just control-flow shape. Doctor's rule is retired. |
| [js-flatmap-filter](../rules/js-flatmap-filter.md) | Partial | `react-doctor/js-flatmap-filter` | Flags map/filter(Boolean), not every transform/filter. Preserve falsy values and callback order; flatMap can allocate temporary arrays and is not automatically faster. |
| [js-hoist-regexp](../rules/js-hoist-regexp.md) | Partial | `react-doctor/js-hoist-regexp`, `vercel-react-best-practices/no-render-regexp` | Doctor handles selected static constructors in loops; the local rule adds direct new RegExp in named JSX-returning components. Closures, dynamic constructors, flags and lastIndex still need review; no autofix. |
| [js-index-maps](../rules/js-index-maps.md) | Partial | `react-doctor/js-index-maps` | Traditional loops only; the source's map callback is not detected. Map picks the last duplicate key while find picks the first; conversion requires a uniqueness contract. |
| [js-length-check-first](../rules/js-length-check-first.md) | Partial | `react-doctor/js-length-check-first` | Recognizes every/index comparisons, not the source's sort/join comparison. The domain's equality semantics still matter. |
| [js-min-max-loop](../rules/js-min-max-loop.md) | Partial | `react-doctor/js-min-max-loop` | Simple numeric literal arrays sorted and indexed directly, not temporary variables or object comparators in the source. Preserve empty-array, NaN, mutation and tie behavior. |
| [js-request-idle-callback](../rules/js-request-idle-callback.md) | Review | — | Urgency, ordering, deadlines and browser support are not AST properties. Scheduling all analytics late can lose required events. |
| [js-set-map-lookups](../rules/js-set-map-lookups.md) | Partial | `unicorn/prefer-set-has`, `react-doctor/js-set-map-lookups` | Native rule covers selected reusable arrays; Doctor also catches includes on a parameter inside filter. String lookup is accepted. Doctor still reports when membership data mutates during iteration; preserve construction cost, mutation and equality semantics. |
| [js-tosorted-immutable](../lint-replaced/js-tosorted-immutable.md) | Delegated | `unicorn/no-array-sort` | Mechanical mutation convention, with spread-copy exceptions and a target runtime that supports toSorted or a polyfill. |

## Advanced patterns

| Guideline | Decision | Enabled lint rules | Remaining judgment |
| --- | --- | --- | --- |
| [advanced-effect-event-deps](../lint-replaced/advanced-effect-event-deps.md) | Delegated | `react/exhaustive-deps` | Mechanical dependency rule, using a plugin version that recognizes useEffectEvent. |
| [advanced-event-handler-refs](../rules/advanced-event-handler-refs.md) | Partial | `react-doctor/advanced-event-handler-refs` | Detects selected subscriptions to prop callbacks. Whether callback changes should resubscribe remains a behavior decision. |
| [advanced-init-once](../rules/advanced-init-once.md) | Review | — | A mount effect can be intentional. Module-level guards have lifetime and SSR implications; app-wide identity must be explicit. |
| [advanced-use-latest](../rules/advanced-use-latest.md) | Partial | `react-doctor/prefer-use-effect-event` | Recognizes some effect callback patterns. Which values should remain reactive is a behavior decision; Effect Events must not hide real dependencies. |

## Next.js-specific checks

[The Next.js audit](NEXTJS.md) accounts for all 25 Next.js rules in the pinned
package, including its two optional rules. One adds partial coverage; the native
script check overlaps the existing delegated control. Other checks cover
framework correctness or optimizations absent from the 70 source guidelines.

## Broader Doctor catalog audit

[The full Doctor audit](DOCTOR.md) records the review of every exported rule,
including optional and retired entries, rather than a keyword-selected subset.
[The per-rule inventory](doctor-audit.json) contains all 907 decisions and
boundaries. Additional selected checks are listed in the guideline rows above;
project-specific candidates remain separate from the shared configuration.
No additional full guideline replacement was found.

## Sources and rejected alternatives

The installed package implementations, not just exported names, determine
coverage. In React Doctor 0.9.23 the names `client-localstorage-no-version`,
`rendering-animate-svg-wrapper`, `rendering-usetransition-loading`,
`activity-wraps-effect-heavy-subtree`, `js-early-exit` and `js-tosorted-immutable`
are retired compatibility entries. They must not be counted as working checks.

Other researched plugins include ESLint React, eslint-plugin-react,
eslint-plugin-react-helpers, e18e, Unicorn, GitHub and SonarJS. Their tested
alternatives either overlap the chosen controls or leave the same semantic
gaps. ESLint React's typed conditional-rendering rule cannot run through the
current Oxlint JS bridge. e18e's static-regex rule does not cover the dynamic
render example. Unicorn's min/max rule excludes object comparators and its
full JS plugin failed to load in the tested Oxlint configuration. No extra
dependency is added merely because it exports a related name.

- [Oxlint plugin API and its type-awareness limits](https://oxc.rs/docs/guide/usage/linter/js-plugins.html)
- [React Doctor standalone plugin and project-only checks](https://www.react.doctor/docs/configuration/eslint-and-oxlint-plugins)
- [React Doctor source](https://github.com/millionco/react-doctor/tree/main/packages/oxlint-plugin-react-doctor)
- [Ultracite's selected Oxlint plugins](https://www.ultracite.ai/docs/presets)
- [Unicorn membership rule](https://github.com/sindresorhus/eslint-plugin-unicorn/blob/main/docs/rules/prefer-set-has.md)
- [e18e static-regex implementation](https://github.com/e18e/eslint-plugin/blob/main/src/rules/prefer-static-regex.ts)
- [SVGO numeric precision](https://svgo.dev/docs/plugins/cleanupNumericValues/)
