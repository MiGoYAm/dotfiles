---
name: fix-sentry-issue
description: Apply when fixing a Sentry issue identified by a link, issue ID, or event ID.
---

# Fix Sentry issue

The goal is a Sentry issue whose final state is backed by evidence: fixed by
a PR, resolved with the commit or cause that explains it, or left open with a
list of what evidence is missing.

## Path

1. **Understand the failure.** Read the issue, the event, its breadcrumbs and
   related events through Sentry MCP. Look for sibling issues whose stack
   traces hit the same code, since they may share the cause and the fix.
   Before changing anything, also check sources the issue does not point
   to, such as traces, logs or recent deploys, when they could bear on the
   failure.
2. **Find the cause.** Locate the failure in the affected release, compare
   it with the target branch and its Git history, check which releases still
   report it, and reproduce it when you can. This step is done when you can
   name the cause and point to evidence for it. One event or a failed
   reproduction is too little evidence.
3. **Close the loop** with the outcome that matches the cause.

## Outcomes

- **Already fixed on the target branch.** Resolve the issue in Sentry and
  link the fixing commit SHA. If you cannot link it, explain the fix in a
  comment.
- **Transient cause that has cleared**, such as a stale cache entry. Comment
  with the cause and evidence, then resolve.
- **External cause**, such as a database outage or a 5xx from another
  service. Make sure this code handles the failure well, then trace the cause
  to its owner.
- **Bug in current code.** Fix the cause you found and cover siblings that
  share it. In the PR description, link each issue and add
  `Fixes <SENTRY-SHORT-ID>` for it; Sentry resolves the issue when a release
  includes the merge commit. Use [full-stop](../full-stop/SKILL.md).
  <!--
  todo:
  Change default heuristic to `full-send`. Fix bugs as fast as possible,
  by omiting human review. Working code is better from a delayed perfect fix.
  Human can review the fix later, but the user can get a working fix now.
  -->
- **Cause still unknown.** Leave the issue open and report what evidence is
  missing.
