---
name: fix-sentry-issue
description: Apply when fixing, investigating, or triaging a Sentry issue, or when the user shares a Sentry link, issue ID, or event ID.
---

# Fix Sentry issue

Done means the issue sits in a state backed by evidence: fixed by a PR,
resolved with the commit or cause that explains it, or left open with the
missing evidence named. Every comment or resolution you leave states the
cause and its evidence.

## Cause

Start from Sentry MCP: the issue, its events and breadcrumbs, and
sibling issues whose stack traces hit the same code; siblings often share
the cause and the fix. Traces, logs and recent deploys can matter even when
the issue does not point to them.

The cause is found when evidence beyond one event or a failed reproduction
backs it: the failing code in the affected release, its state on the target
branch and in Git history, which releases still report it, and a
reproduction when one is possible.

## Outcomes

- **Already fixed on the target branch.**: Resolve the issue with the fixing commit SHA
  linked, or a comment naming the fix when no SHA links.
- **Transient cause that has cleared**, such as a stale cache entry. Comment
  with the cause and evidence, then resolve.
- **External cause**, such as a database outage or a 5xx from another
  service. Change this code only if it handles the failure badly. Comment on
  the issue with the cause and evidence. Resolve it once the cause has cleared; 
  otherwise leave it open.
- **Bug in current code**: fix the cause and every sibling that shares it.
  Link each issue in the PR description with `Fixes <SENTRY-SHORT-ID>`;
  Sentry resolves it when a release includes the merge commit. Ship with
  [full-stop](../full-stop/SKILL.md).
- **Unknown**: leave open and report the missing evidence.
