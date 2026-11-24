---
name: making-ui-changes
description: Apply when making UI changes.
---

# Making UI Changes

When a task changes what the user sees or how an interface behaves, finish it by
showing the change in the running app:

- For a design request, iterate with the user before polishing the code: send a
  clickable link to the running prototype and screenshots, and run code checks,
  code review and the PR flow only after they accept the design.
- Run the changed version, open it yourself, and click through what changed.
- In your reply, give a preview link and embed screenshots of the running app 
  showing each changed view and state (Markdown image links with absolute paths).
  Add a short video when the change is about interaction, animation, or a flow that 
  stills do not show well. Say briefly what changed, how to check it, and what is 
  still missing.
- Always give a web page's link as its `*.opentunnel.xyz` URL, never `localhost`. 
  Give the URL that `opentunnel route add <port> --name <branch>` prints. 
  Running it again is harmless.
- Only screenshots and videos of the current code count; a build, passing tests,
  or a mockup is not a substitute. Retake them when the UI changes again. Use
  sample data and keep secrets and private data out of them.
- If you cannot run or capture the UI, say so and fix that first. Do not hand
  over a UI change without showing it.
