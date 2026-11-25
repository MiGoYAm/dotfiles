---
name: making-ui-changes
description: Use when a change alters what the user sees or how an interface behaves.
---

# Making UI changes

A UI change is done when the user has seen it running. Run the current code, click through what changed yourself, then hand over:

- A preview link: the `*.opentunnel.xyz` URL printed by `opentunnel route add <port> --name <branch>` (idempotent; `localhost` is unreachable for the user).
- Screenshots of each changed view and state, embedded as Markdown images with absolute paths. Add a short video when the change is an interaction, animation, or flow that stills don't convey.
- A few lines on what changed, how to check it, and what is still missing.

Captures must come from the current code with sample data; retake them after further UI edits. A build, passing tests, or a mockup is not evidence. If you can't run or capture the UI, make that the first thing you fix, and say so if you can't.

For a design request, iterate on the running prototype with the user first; code checks, review, and the PR flow come after they accept the design.
