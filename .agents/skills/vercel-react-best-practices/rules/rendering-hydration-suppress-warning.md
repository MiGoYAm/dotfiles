---
title: Suppress Expected Hydration Mismatches
impact: LOW-MEDIUM
impactDescription: avoids noisy hydration warnings for known differences
tags: rendering, hydration, ssr, nextjs
---

## Suppress Expected Hydration Mismatches

(Skill: `vercel-react-best-practices`; lint: Partial; `react-doctor/rendering-hydration-mismatch-time`, `react-doctor/no-nondeterministic-id-value-in-render-body`, `react-doctor/no-locale-format-in-render`.)

See [the full audit](../oxlint/COVERAGE.md) for coverage and remaining judgment.

In SSR frameworks (e.g., Next.js), some values are intentionally different on server vs client (random IDs, dates, locale/timezone formatting). For these *expected* mismatches, wrap the dynamic text in an element with `suppressHydrationWarning` to prevent noisy warnings. Do not use this to hide real bugs. Don’t overuse it.

**Incorrect (known mismatch warnings):**

```tsx
function Timestamp() {
  return <span>{new Date().toLocaleString()}</span>
}
```

**Correct (suppress expected mismatch only):**

```tsx
function Timestamp() {
  return (
    <span suppressHydrationWarning>
      {new Date().toLocaleString()}
    </span>
  )
}
```
