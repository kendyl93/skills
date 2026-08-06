---
name: front-end-pr-review
description: Read-only scope brief for a reviewer of a front-end PR. Sizes the brief to the diff, explains what changed and why, and flags what could break — using the touched package's AGENTS.md as the source of how this code should be written. Use when the user wants to review a PR/branch, or asks "what changed here and is it safe".
---

This skill helps a **human reviewer** understand **someone else's PR** fast: it
maps the scope and flags risks in plain language, so the reviewer knows what to
look at and what to ask. It reads; it never edits, scores, or produces a
pass/fail checklist.

The reviewer's attention is the budget. Spend it in proportion to what they
could get wrong by merging.

## Process

### 1. Pin the diff — use the PR's own base

A PR is diffed against the base branch it declares, not an assumed `main`. Get
it from the PR itself:

- `gh pr view <url-or-number> --json baseRefName,headRefName,title,body,url`
- Diff: `git diff <baseRefName>...<headRefName>` (three-dot, merge-base).
- Commits: `git log <baseRefName>..<headRefName> --oneline`.

If no PR ref is given, ask for the PR URL/number. Confirm the diff resolves and
is non-empty before continuing.

### 2. Triage — the diff sets the size of the brief

Read the diff and pick the shape **before** opening any docs. Match it:

| The diff                                            | The brief                                                                                                     |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Constants, config, copy, types — no logic           | **One paragraph.** What changed, whether it's safe, and the one question worth asking if there is one. Nothing else. |
| One concern, logic inside one package               | **Verdict + Scope + Risks.** Skip the rest.                                                                   |
| Several packages, or logic a reviewer could misread | **Full brief** — every block in step 4.                                                                       |

A two-line diff gets a two-line answer. Reviewing two constants as if they were
a refactor wastes the reviewer's time and buries the one thing they needed.

### 3. Load the context — AGENTS.md is the source of truth

This is a monorepo of per-package `AGENTS.md` files; there is no root one.

1. From the diff, list the **packages touched**.
2. For each, find and read its `AGENTS.md` — the entry point and primary source
   of truth.
3. Whatever that AGENTS.md tells you is your source of truth. If it mentions
   another markdown file that bears on this diff, read that too. Follow the
   links it actually gives — don't assume a folder layout.
4. Follow into code only for the conventions this diff touches. If the diff
   changes a shared constant, open its consumers. Docs describe intent; the
   linked code is ground truth on conflict.
5. **Look something up externally only when the answer changes the verdict.**
   Official docs (`WebSearch` → `WebFetch`), a Figma node, a linked ticket — reach
   for these when the diff might be *wrong* in a way that should stop a merge.
   When the worst case is "a value is a few pixels off the design", the lookup
   changes nothing a reviewer decides: say the value looks off, cite the design
   as the place to check, and move on.

   If official docs **contradict** the repo's own convention, flag it in one
   line with the source. The repo isn't automatically right; surface the
   mismatch for a human to decide.

If a touched package has no AGENTS.md, say so and review it on general
front-end sense.

### 4. Write the brief

Include only the blocks step 2 selected, in this order.

**Verdict** — always. One line: merge, merge once a question is answered, or
don't merge yet, and why in half a sentence.

**Scope** — group the diff by concern, not by file. For each group:

- _What_ changed — one line.
- _Why_ — the intent, tied to a commit message, linked doc, or ticket ref.
- _Load-bearing files_ — the 1–3 files where the real logic lives (skip
  generated, snapshot, and lockfile churn).

**Risks** — plain language, one bullet each: what could break and roughly how
likely. "None spotted." is the expected answer on a small diff, and a complete
one.

**Improvement proposals** — omit this block by default. Include a proposal only
when you would raise it on the PR anyway because it changes whether you
approve. Two at most. Each gets one line, its source, and whether it belongs on
this branch or a follow-up. A suggestion you had to go looking for belongs in
neither.

**Docs consulted** — only when you researched something outside the diff, and
only the sources that changed a conclusion. A small diff needs no trust trail.

## Rules

- Read-only. Propose, never edit.
- Every line you write changes something the reviewer does — approves, asks a
  question, looks at a file. A line that only proves you read the code is one
  the reviewer has to skip.
- Assume the PR author is fallible and the repo's conventions may be out of
  date. Flag and cite; don't nitpick.
- Ground every "why" and risk in something you read — a commit, a doc, a file.
  No speculation dressed as fact.
