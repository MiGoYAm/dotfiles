# Next.js rule audit

Audited all 25 `nextjs-*` entries in `oxlint-plugin-react-doctor@0.9.23`.
The exported Next.js preset includes 23; the other two are optional. Scope
is correspondence with this skill's 70 guidelines, not a general Next.js preset.

One check adds a narrow warning. It does not replace a whole guideline. Tests
verify its detecting example and that the original async-fetch example
remains undetected. No new package or local implementation is needed.

| Doctor rule suffix | Preset | Decision and boundary |
| --- | --- | --- |
| `nextjs-async-client-component` | Next.js | Outside the 70 guidelines. Checks whether Client Components are async, not whether independent server fetches run concurrently. |
| `nextjs-async-dynamic-api-not-awaited` | Next.js | Outside scope. Correctly awaiting Next.js request APIs is distinct from deferring or parallelizing independent operations. |
| `nextjs-error-boundary-missing-use-client` | Next.js | Outside scope. Error-boundary module contract. |
| `nextjs-global-error-missing-html-body` | Next.js | Outside scope. Root error-document structure. |
| `nextjs-image-missing-sizes` | Next.js | Outside scope. Responsive raster image sizing is distinct from SVG coordinate precision. |
| `nextjs-inline-script-missing-id` | Next.js | Outside scope. Script identity/deduplication is distinct from deferring noncritical script loading. |
| `nextjs-metadata-url-consistency` | Next.js | Outside scope. Canonical/Open Graph URL consistency. |
| `nextjs-missing-metadata` | Next.js | Outside scope. Search-preview metadata, not a streaming-boundary detector. |
| `nextjs-no-a-element` | Next.js | Adjacent to bundle-preload, but checks internal navigation via Link. Does not enforce hover/focus preloading of heavy code or data. |
| `nextjs-no-client-fetch-for-server-data` | Optional | Optional; overlaps no-fetch-in-effect already enabled for client-swr-dedup. Recommends moving page/layout fetching to the server, not cross-instance request deduplication. |
| `nextjs-no-client-side-redirect` | Next.js | Narrow overlap with rerender-move-effect-to-event when interaction-driven navigation uses state plus an effect. Existing no-event-handler covers that family. Not enabled: this rule also flags effects unrelated to interactions, so intent is still required. |
| `nextjs-no-css-link` | Next.js | Outside scope. Stylesheet loading does not enforce js-batch-dom-css DOM-write batching. |
| `nextjs-no-default-export-in-route-handler` | Next.js | Outside scope. App Router HTTP export contract. |
| `nextjs-no-edge-og-runtime` | Next.js | Outside scope. OG renderer runtime choice. |
| `nextjs-no-font-link` | Next.js | Outside scope. next/font loading, not hoisting static fs reads in server-hoist-static-io. |
| `nextjs-no-google-analytics-script` | Next.js | Rejected as deferral coverage. Flags next/script even with afterInteractive or lazyOnload, so it checks an integration preference rather than missing deferral. Also misses the original @vercel/analytics import. |
| `nextjs-no-head-import` | Next.js | Outside scope. App Router Metadata API compatibility. |
| `nextjs-no-img-element` | Optional | Optional; outside scope. Image optimization has no matching guideline among these 70. SVG precision and SVG animation are different concerns. |
| `nextjs-no-native-script` | Next.js | Overlaps nextjs/no-sync-scripts already enabled for rendering-script-defer-async. No redundant Doctor detector added; inline script and ordering decisions still need context. |
| `nextjs-no-polyfill-script` | Next.js | Outside scope. Redundant polyfill detection is distinct from making imports analyzable or deferring optional dependencies. |
| `nextjs-no-redirect-in-try-catch` | Next.js | Outside scope. Next.js control-flow exceptions, not auth or nonblocking work. |
| `nextjs-no-script-in-head` | Next.js | Outside scope. next/script placement contract rather than loading strategy. |
| `nextjs-no-side-effect-in-get-handler` | Next.js | Outside scope. HTTP method safety, not authentication or independent-await analysis. |
| `nextjs-no-use-search-params-without-suspense` | Next.js | Enabled warning for async-suspense-boundaries. Detects search-param consumers in page/layout files, not the original async fetch example or optimal fallback placement. The same-file check accepts any Suspense mention, so it does not prove correct boundary ownership. |
| `nextjs-no-vercel-og-import` | Next.js | Outside scope. Avoids a bundled dependency duplicate, not a barrel import, conditional loading or resource-hint check. |

Rule IDs above use the `react-doctor/` namespace. Full source:
[Next.js implementations](https://github.com/millionco/react-doctor/tree/main/packages/oxlint-plugin-react-doctor/src/plugin/rules/nextjs).
Runtime checks use the pinned installed package; upstream main may differ.

See [COVERAGE.md](COVERAGE.md) for all 70 guideline decisions and
[README.md](README.md) for the runnable configuration. Rules outside this
skill can still be useful in a project-wide Next.js preset.
