---
name: front-end-pr-review
description: Read-only scope brief for a reviewer of a front-end PR. Explains what changed and why, grouped by scope, using the touched package's AGENTS.md (and every doc it links) as the source of how this code should be written. Adds a plain-language risks block and optional improvement proposals. Use when the user wants to review a PR/branch, or asks "what changed here and is it safe".
---

This skill helps a **human reviewer** understand **someone else's PR** fast. It
does not grade the code or edit anything — it maps the scope, flags risks in
plain language, and optionally proposes improvements. For a violations/spec
audit, use `code-review` instead.

## Process

### 1. Pin the diff — use the PR's own base

A PR is diffed against the base branch it declares, not an assumed `main`. Get
it from the PR itself:

- `gh pr view <url-or-number> --json baseRefName,headRefName,title,body,url`
- Diff: `git diff <baseRefName>...<headRefName>` (three-dot, merge-base).
- Commits: `git log <baseRefName>..<headRefName> --oneline`.

If no PR ref is given, ask for the PR URL/number. Confirm the diff resolves and
is non-empty before continuing.

### 2. Load the context — AGENTS.md is the source of truth, then escalate

This is a monorepo of per-package `AGENTS.md` files; there is no root one.

1. From the diff, list the **packages touched**.
2. For each, find and read its `AGENTS.md` file — the entry point and primary
   source of truth.
3. Whatever that AGENTS.md tells you is your source of truth. If it mentions any
   other markdown file, go read that file too. Follow the links it actually
   gives — don't assume a folder layout.
4. Follow into code. If AGENTS.md or a doc names a convention that lives in code
   (a base component, a shared hook, a lint rule), open that file. Docs describe
   intent; the linked code is ground truth on conflict.
5. **Escalate named concepts to official sources — only on doubt.** When
   AGENTS.md or a doc invokes a named methodology or library best-practice
   (e.g. "atomic design", a testing-library rule, an a11y standard) and the
   diff appears to **contradict or stretch** it, look it up — prefer **official
   documentation** (`WebSearch` → `WebFetch` the official docs) and judge the
   diff against that authority, not memory or a blog. If the code already looks
   consistent with the convention, don't research it — no rabbit holes.
   Whenever a finding or suggestion rests on something you looked up, link the
   exact source URL alongside it.

   If the official docs **contradict** the repo's own convention, lightly flag
   it — "AGENTS.md says X, but the official docs say Y; worth a second look" —
   with the source. The repo isn't automatically right; don't rewrite the
   convention, just surface the mismatch for a human to decide.

If a touched package has no AGENTS.md, say so and review it on general
front-end sense plus official best-practice only.

### 3. Write the brief

Output these blocks, in this order. Keep it skimmable — a reviewer reads the
first line of each block and drills in only if needed.

**Scope** — group the diff by concern (not by file). For each group:

- _What_ changed — one line.
- _Why_ — the intent, tied to a commit message, linked doc, or Jira ref.
- _Load-bearing files_ — the 1–3 files where the real logic lives (skip
  generated, snapshot, and lockfile churn).

**Risks** — plain language, compact. One bullet per risk, no jargon: what could
break and roughly how likely. If there are none worth a reviewer's attention,
write "None spotted." A reviewer who wants depth will ask.

**Improvement proposals** _(only if any)_ — start from the **problem this PR is
solving**, find the best-practice answer to _that_ problem (repo docs first,
then official documentation via step 2.5), and only suggest where the diff falls
short of it. For each: the suggestion in one line, its source (repo doc or
official-docs URL), and where it belongs — **this branch** (small, in-scope,
low-risk) or **a follow-up branch** (out of scope, or big enough to review on
its own). No generic advice untethered to this PR's problem.

**Docs consulted** — every AGENTS.md, linked doc/file, and official-docs URL you
actually read, as a short list. This is the trust trail; keep it honest.

## Rules

- Read-only. Propose, never edit.
- Assume the PR author is fallible — they may not know every best practice, and
  the repo's own conventions may be out of date. Surface what looks off, but
  stay light: flag and cite, don't nitpick or lecture.
- Ground every "why", risk, and proposal in something you read — a commit, a
  doc, a file, or an official-docs URL. No speculation dressed as fact.
- Be compact by default. Depth on request.
