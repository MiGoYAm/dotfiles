---
name: fix-sentry-issue
description: Apply when fixing a Sentry issue identified by a link, issue ID, or event ID.
---

# Fix Sentry issue

1. **Identify the issue.** Use Sentry MCP to inspect the issue and the
   reported event. Read relevant breadcrumbs and related events as needed.
2. **Find sibling issues.** Search for similar issues whose stack traces
   hit the same file or function. A sibling may share the cause and a fix
   which matters for issue resolution in PR description.
3. **Decide whether the code needs a fix.** Locate the failure in the affected release. 
   Compare that code with the latest target branch and check Git history for a fix. 
   Check which releases still report the error. When possible, reproduce it.
   - **The target branch already contains a fix.** Verify that the change
     addresses the reported failure and find its SHA. Mark the issue as
     resolved in Sentry and link it to the commit that fixed the bug. If you
     cannot link the SHA, explain the fix in a Sentry comment and resolve the
     issue.
   - **Confirmed one-off.** Verify the transient cause and that it has cleared, 
     for example a stale cache entry that expired and the same code works with fresh 
     data. Document the cause and evidence in a Sentry comment, then resolve the issue.
   - **Bug remains.** Continue to the fix once the reproduction or event
     evidence identifies a failure in the current code. Keep the change scoped 
     to the cause you found. Include the Sentry issue link and `Fixes <SENTRY-SHORT-ID>` 
     in the PR description. Sentry resolves the issue when a release includes the 
     PR's merge commit. Use [full-stop](../full-stop/SKILL.md) by default.
     <!--
     todo:
     Change default heuristic to `full-send`. Fix bugs as fast as possible, 
     by omiting human review. Working code is better from a delayed perfect fix.
     Human can review the fix later, but the user can get a working fix now.
     -->
   - **The cause is external.** The failure originates outside this code,
     for example a database connection error or an HTTP 500 from another
     service. Check that the code handles that failure correctly. Then look for the
     cause and/or fix on the external side.
   - **The evidence is inconclusive.** Keep investigating. A single event or
     an unsuccessful reproduction gives too little evidence to call it a
     one-off. If you cannot determine the cause, leave the issue open and
     report what evidence is missing.
