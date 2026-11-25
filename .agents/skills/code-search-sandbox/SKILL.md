---
name: code-search-sandbox
description: Use when reading or searching code from a repo outside the workspace, such as a dependency's source or an upstream project.
---

Clone into `~/.btca/agent/sandbox/`. It is a persistent cache shared across sessions: if the repo is already there, pull the default branch instead of re-cloning, and leave clones in place when done.
