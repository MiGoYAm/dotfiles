---
name: friction-log
description: >
  Log durable repo or package papercuts in local Markdown files. Use when a
  session hits recurring friction that remains outside the current change,
  or the user asks to record or review friction.
---

# Friction log

**File** durable, recurring pain with a clear owner and a reproducible contract
gap: a missing step, a lying type, a broken harness, docs that disagree with the
code, a brittle test. The next agent should be able to act on it without your
session. One-off confusion and session-only nits stay in the session.

Fix obvious, low-risk friction in the current change when it is in scope, and
mention the fix. File what is left over.

Search open local friction entries for the same repo or package first and
append new evidence to a match. Each entry carries what happened, what you
wanted, how to reproduce, the cost, what you already looked at, and relevant
files. Keep secrets and private data out.

Give each entry a priority using the project's triage scheme, defaulting to
`P0` through `P3`, and add `needs-decision` when it needs a human call.
`friction-skipped` marks an entry the friction sweep leaves alone until someone
removes the label. Entries that do not meet the filing bar stay unfiled.

## Local storage

Use `~/.friction-log/agent/issues/` as the durable log, creating directories
when filing the first entry. Group entries by repo or package, for example
`github.com/owner/repo/`. For a local-only repo, use its directory name and
record its absolute path in each entry; distinguish same-named repos with a
suffix. Keep the log outside the working repo, like `btca-local` keeps its
cloned repos outside the working directory.

Create one Markdown file per distinct problem. Use a UTC timestamp and a short
title slug, for example `20261116T143012Z-stale-setup-docs.md`; add a suffix if
the filename already exists. Update matching entries in place, preserving
their history. Keep resolved entries with `Status: resolved`.

Use this entry format, filling every section with actionable evidence:

```markdown
# Short, specific title

- Target: repo URL or package name; absolute local repo path when available
- Owner: responsible project, package, or team
- Created: UTC date and time
- Status: open
- Priority: P2
- Labels: friction

## What happened

## What you wanted

## How to reproduce

## Cost

## Preliminary investigation

## Relevant files
```

Record relevant file paths relative to the target repo, with line numbers when
useful. Include exact commands and observed errors in the reproduction steps.
After filing or updating, report the entry's absolute path and priority.

When invoked without a problem to record, list open entries for the current
repo or package with their priorities and paths. If there is no current target,
list the projects with existing entries. An empty log needs only a brief
explanation of where entries will go.
