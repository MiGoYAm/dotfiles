---
name: friction-log
description: >
  Log durable repo or package papercuts as local Markdown entries. Use when a
  session hits recurring friction outside the current change, or the user asks
  to record or review friction.
---

# Friction log

An entry is worth filing when the pain will recur for the next agent and points at a contract gap someone owns: a missing step, a lying type, a broken harness, docs that disagree with code, a brittle test. The bar: another agent can act on it without your session. Fix obvious, in-scope friction in the current change instead, and mention it.

## Storage

Entries live in `~/.friction-log/agent/issues/<target>/`, one Markdown file per problem, named `<UTC timestamp>-<slug>.md` (e.g. `20261116T143012Z-stale-setup-docs.md`). `<target>` is `github.com/owner/repo` or the package name; for local-only repos use the directory name (suffixed if it collides) and record the absolute path in the entry.

Check open entries for the same target first; when one matches, append your evidence to it rather than filing a duplicate. Resolved entries stay, with `Status: resolved`.

## Entry

```markdown
# Short, specific title

- Target: repo URL or package; absolute local path when available
- Owner: responsible project, package, or team
- Created: UTC date and time
- Status: open | resolved
- Priority: P0 | P1 | P2 | P3   (or the project's own scheme)
- Labels: friction[, needs-decision][, friction-skipped]

## What happened
## What you wanted
## How to reproduce   (exact commands and observed errors)
## Cost
## Preliminary investigation
## Relevant files     (repo-relative paths, line numbers when useful)
```

`needs-decision` marks entries that need a human call; `friction-skipped` makes the friction sweep leave an entry alone until someone removes it. Keep secrets and private data out. After filing or updating, report the entry's absolute path and priority.

## Reviewing

Invoked without a problem to record: list open entries for the current target with priorities and paths, or the targets that have entries when there is no current one.
