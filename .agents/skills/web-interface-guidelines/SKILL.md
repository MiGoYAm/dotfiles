---
name: web-interface-guidelines
description: Review UI code for Vercel Web Interface Guidelines compliance. Use when reviewing React, Next.js, or other web UI code for accessibility, focus states, forms, animation, typography, content handling, images, performance, navigation/state, touch behavior, layout, theming, locale/i18n, hydration safety, hover states, or copy quality.
---

# Web Interface Guidelines

Review files for compliance with the rules below. Output concise but comprehensive. High signal-to-noise.

## Rules

### Accessibility

- Icon-only buttons need `aria-label`
- Form controls need `<label>` or `aria-label`
- Interactive elements need keyboard handlers (`onKeyDown`/`onKeyUp`)
- `<button>` for actions, `<a>`/`<Link>` for navigation, not `<div onClick>`
- Images need `alt`, or `alt=""` if decorative
- Decorative icons need `aria-hidden="true"`
- Async updates like toasts and validation need `aria-live="polite"`
- Use semantic HTML like `<button>`, `<a>`, `<label>`, `<table>` before ARIA
- Headings must be hierarchical `<h1>` through `<h6>`; include skip link for main content
- Use `scroll-margin-top` on heading anchors

### Focus States

- Interactive elements need visible focus: `focus-visible:ring-*` or equivalent
- Never use `outline-none` or `outline: none` without a focus replacement
- Prefer `:focus-visible` over `:focus`
- Group focus with `:focus-within` for compound controls

### Forms

- Inputs need `autocomplete` and meaningful `name`
- Use correct `type` and `inputmode`
- Never block paste with `onPaste` plus `preventDefault`
- Labels must be clickable via `htmlFor` or by wrapping the control
- Disable spellcheck on emails, codes, and usernames with `spellCheck={false}`
- Checkboxes and radios need a single shared hit target with the label
- Submit button stays enabled until request starts; show spinner during request
- Errors should appear inline next to fields; focus first error on submit
- Placeholders should end with `…` and show an example pattern
- Use `autocomplete="off"` on non-auth fields to avoid password manager triggers
- Warn before navigation with unsaved changes via `beforeunload` or router guard

### Animation

- Honor `prefers-reduced-motion`
- Animate only `transform` and `opacity` when possible
- Never use `transition: all`; list properties explicitly
- Set the correct `transform-origin`
- For SVG, animate transforms on a `<g>` wrapper with `transform-box: fill-box` and `transform-origin: center`
- Animations should be interruptible and respond to user input mid-animation

### Typography

- Use `…`, not `...`
- Use curly quotes, not straight quotes
- Use non-breaking spaces for `10&nbsp;MB`, `⌘&nbsp;K`, and brand names
- Loading states should end with `…`: `Loading…`, `Saving…`
- Use `font-variant-numeric: tabular-nums` for number columns and comparisons
- Use `text-wrap: balance` or `text-pretty` on headings

### Content Handling

- Text containers must handle long content with `truncate`, `line-clamp-*`, or `break-words`
- Flex children need `min-w-0` for text truncation
- Handle empty states; do not render broken UI for empty strings or arrays
- User-generated content should handle short, average, and very long inputs

### Images

- `<img>` needs explicit `width` and `height`
- Below-fold images should use `loading="lazy"`
- Above-fold critical images should use `priority` or `fetchpriority="high"`

### Performance

- Large lists over 50 items should virtualize, or use `content-visibility: auto`
- Do not read layout in render with `getBoundingClientRect`, `offsetHeight`, `offsetWidth`, or `scrollTop`
- Batch DOM reads and writes; avoid interleaving
- Prefer uncontrolled inputs; controlled inputs must be cheap per keystroke
- Add `<link rel="preconnect">` for CDN and asset domains
- Preload critical fonts with `<link rel="preload" as="font">` and `font-display: swap`

### Navigation & State

- URL should reflect state: filters, tabs, pagination, expanded panels in query params
- Links must use `<a>` or `<Link>` to preserve Cmd/Ctrl-click and middle-click support
- Deep-link all stateful UI; if it uses `useState`, consider URL sync via `nuqs` or similar
- Destructive actions need confirmation modal or undo window, never immediate

### Touch & Interaction

- Use `touch-action: manipulation` to prevent double-tap zoom delay
- Set `-webkit-tap-highlight-color` intentionally
- Use `overscroll-behavior: contain` in modals, drawers, and sheets
- During drag, disable text selection and set `inert` on dragged elements
- Use `autoFocus` sparingly; desktop only, single primary input, avoid on mobile

### Safe Areas & Layout

- Full-bleed layouts need `env(safe-area-inset-*)` for notches
- Avoid unwanted scrollbars with `overflow-x-hidden` and content overflow fixes
- Prefer flex or grid over JS measurement for layout

### Dark Mode & Theming

- Set `color-scheme: dark` on `<html>` for dark themes
- Set `<meta name="theme-color">` to the page background
- Native `<select>` needs explicit `background-color` and `color` in Windows dark mode

### Locale & I18n

- Use `Intl.DateTimeFormat` for dates and times
- Use `Intl.NumberFormat` for numbers and currency
- Detect language via `Accept-Language` or `navigator.languages`, not IP
- Wrap brand names, code tokens, and identifiers with `translate="no"`

### Hydration Safety

- Inputs with `value` need `onChange`, or use `defaultValue` for uncontrolled inputs
- Guard date and time rendering against server/client hydration mismatches
- Use `suppressHydrationWarning` only where truly needed

### Hover & Interactive States

- Buttons and links need `hover:` state for visual feedback
- Hover, active, and focus states should be more prominent than the rest

### Content & Copy

- Use active voice: `Install the CLI`, not `The CLI will be installed`
- Use Title Case for headings and buttons
- Use numerals for counts: `8 deployments`, not `eight`
- Use specific button labels: `Save API Key`, not `Continue`
- Error messages should include the fix or next step, not just the problem
- Use second person; avoid first person
- Use `&` over `and` where space-constrained

### Anti-Patterns

- `user-scalable=no` or `maximum-scale=1` disabling zoom
- `onPaste` with `preventDefault`
- `transition: all`
- `outline-none` without a focus-visible replacement
- Inline `onClick` navigation without `<a>`
- `<div>` or `<span>` with click handlers that should be `<button>`
- Images without dimensions
- Large arrays using `.map()` without virtualization
- Form inputs without labels
- Icon buttons without `aria-label`
- Hardcoded date or number formats instead of `Intl.*`
- `autoFocus` without clear justification

## Output Format

Group by file. Use `file:line` format. Keep it terse.

```text
## src/Button.tsx

src/Button.tsx:42 - icon button missing aria-label
src/Button.tsx:18 - input lacks label
src/Button.tsx:55 - animation missing prefers-reduced-motion
src/Button.tsx:67 - transition: all → list properties

## src/Modal.tsx

src/Modal.tsx:12 - missing overscroll-behavior: contain
src/Modal.tsx:34 - "..." → "…"

## src/Card.tsx

✓ pass
```

State the issue and location. Skip explanation unless the fix is non-obvious. No preamble.
