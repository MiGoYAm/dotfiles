Always use Context7 when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.

Be brief.

## Subagent model routing

- Delegate only for useful parallelism, fresh context, specialist judgment or
  tool isolation. Do a direct read or command yourself when delegation would
  cost more coordination than it saves. The tiers below are a menu, not a
  required sequence: choose the lowest tier that fits; do not run every task
  through all four.

  | T3 provider and model              | Default options                                   | Fallback when out of quota                                       | Recommended work                                                                                                                                       |
  | ---------------------------------- | ------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
  | `codex` / `gpt-6-luna`             | `reasoningEffort: low`, `serviceTier: default`    | `opencode` / `opencode/deepseek-v4.1-flash-free`, `variant: low` | Cheap, bounded verification; focused exploration, extraction, classification and log triage. Not final judgment about correctness, security or design. |
  | `codex` / `gpt-6.1-sol`            | `reasoningEffort: medium`, `serviceTier: default` |                                                                  | Default for substantial implementation and technical investigation. Use `high` for subtle code review.                                                 |

- A provider refusal such as `usage limit reached`, including per-model and
  per-plan limits, is a capacity failure. In T3, `task_cancel` the refused
  delegate first; otherwise T3 resumes it at the reset. Do not retry or fan out
  more children on the exhausted model. If the tier has a second route (Luna,
  Sol), try it first; otherwise, or when it also fails, give the work to the
  first fallback from the table that runs, in the listed order, until the quota
  resets. A fallback stands in at the same tier and is not an escalation; code
  review keeps its own stand-in below. Continue from the refused delegate's
  brief, changes and evidence without discarding them, and tell the user which
  source hit the limit and which one continues. If no fallback runs, stop the
  delegated attempt and escalate to the operator.

- Escalate one tier only for a concrete failure or unresolved risk. Preserve the
  original brief, evidence and prior findings instead of repeating an unchanged
  prompt. Do not use `priority`, fast mode, `ultracode` or `ultrathink` for
  delegated work unless the user requests it.

- Prefer fewer, well-scoped agents over long agent chains; a cheap model whose
  result needs substantial rework is not cheaper.

# UI changes

When a task changes what the user sees or how an interface behaves, finish it by
showing the change in the running app:

- For a design request, iterate with the user before polishing the code: send a
  clickable link to the running prototype and screenshots, and run code checks,
  code review and the PR flow only after they accept the design.
- Run the changed version, open it yourself, and click through what changed.
- In your reply, give a preview link or launch command and embed screenshots of
  the running app showing each changed view and state (Markdown image links with
  absolute paths). Add a short video when the change is about interaction,
  animation, or a flow that stills do not show well. Say briefly what changed,
  how to check it, and what is still missing.
- Always give a web page's link as its `*.opentunnel.xyz` URL, never `localhost`:
  it is how the owner reaches pages on remote hosts. Serve the page beyond
  loopback and give the URL that `opentunnel route add <port> --name <branch>` 
  prints. Running it again is harmless.
- Only screenshots and videos of the current code count; a build, passing tests,
  or a mockup is not a substitute. Retake them when the UI changes again. Use
  sample data and keep secrets and private data out of them.
- These rules are the user's standing request for browser work: they override
  any harness default against opening a browser to check your own edits.
- For local pages, use T3 preview tools or a local headless browser. Every host
  has T3's headless browser, so this works without a display.
- If you cannot run or capture the UI, say so and fix that first. Do not hand
  over a UI change without showing it.
