---
name: flow-walkthrough
description: Build a single-file interactive HTML walkthrough of a technical flow — the screens or stages a human moves through, the systems each one hits, one mode per version of reality (Today, Proposed, Option B). Use when someone does not understand how a flow works end to end, says "show me the flow", "map the calls", "which service does what", "today vs proposed", wants to explain a multi-step multi-system process to teammates or another team, or is about to describe such a process in prose.
---

# Flow walkthrough

A **walkthrough** is one HTML file a teammate opens from disk and steps through. Press → and the screen changes, the systems doing work light up, a tally counts the cost so far. Click a call and a drawer shows the request, every response field, and why each exists. Flip the mode and the same flow replays under different rules.

The renderer is solved: [`template.html`](template.html). You produce the **data**, the `DATA` object at the top of that file, contract in [`DATA.md`](DATA.md). Every flow problem fits the same five words:

| Word | Means | Example |
|---|---|---|
| **flow** | one entry point or scenario | Session player → Add clip |
| **step** | one screen the human sees, or one stage of a pipeline | Reel picker |
| **lane** | one system that does work | `videos-page-bff`, a queue, a cron |
| **mode** | one version of reality | Today · Proposed · Option B |
| **call** | a lane doing work at a step: request, response, and *why* | `GET /clips?studyUuid` |

Not a flow (a schema, a dependency graph, a permissions matrix)? Say so and pick a table or a plain diagram. Forcing it produces a worse page than a table.

## 1. Intake: look first, ask once

Collect what you can before asking: open the repos named, grep the client calls and the server routes, open the design file and the tickets. Then send **one** message with only the gaps:

- Which **flows** are in scope, and which **modes**? Default: Today + Proposed.
- Where is **ground truth**: repo paths, design file, tickets, ADR?
- Who **reads** this and what **decision** do they make with it? That decision is the page's one question.
- Any **product rules** that overrule what the code does today?
- The user's own **notes or understanding**, so they can be challenged.

Done when you can write flows, modes, lanes, sources, reader and decision back in under 15 lines and the user has not corrected them.

## 2. Ground truth: code beats notes, notes beat memory

For every call in every step of every mode, read the client code that fires it, the server route that serves it, and the response type field by field. Record:

- method, path, every query param with required/optional and where its value comes from (host prop, constant, user control)
- body, and any header the client sets itself
- every response field and what UI or decision **reads** it. "Typed but never read" is a finding, not a gap.
- for tickets: a key that is Done in the tracker but absent from `git log -S<KEY>` is not done

Done when every call has a `src` file:line and every response field has a `why` or "never read".

## 3. Challenge the notes

The user's notes are hypotheses. Misreads seen in real runs, so check each:

- a phrase with a hidden meaning. "NO MODAL HERE" meant *no clip-list screen*, not *no modal*.
- a flag, env, or tenant concept that doubles every path. Collapse it (treat as ON) unless the flag itself is the subject.
- a branch the notes skip. "+ New" vs "existing" at a picker; each branch has its own write.
- a product rule that beats the code. A screen that exists today and should not: keep it in Today with a `note`, drop it in Proposed.
- a call that always goes to one system "by design", written as if it followed the entry point.

Done when every note is confirmed with a source or contradicted as "your note says X, the code does Y, so Z".

## 4. Outline before pixels

Post a plain-text outline: per flow, per mode, the steps and the calls under each. Twenty lines are cheaper to correct than a 40 KB file. Build on the user's yes, or straight away if they said "just build it".

## 5. Build

Copy `template.html` to `/tmp/YYYY-MM-DD-<slug>-walkthrough.html`, outside any repo, and replace `DATA`. Dense, not big:

- ≤ 6 flows, ≤ 6 steps per flow, ≤ 5 lanes, ≤ 3 modes. More means two walkthroughs.
- `kind: 'warn'` on the one thing you want eyes on. Everywhere means nowhere.
- Every call has a `why`. Every response field has a `why`. The drawer prints *missing* in red when one is absent; that is the lint.
- A step with no call is a real step. Keep it; the reader needs to see where nothing happens.
- `sections`: "Your notes vs. the code" (✗ note / ✓ code pairs) and "Ask <team>" (≤ 5 numbered questions, each answerable yes/no).
- The renderer ships as is. A bug in it is fixed in `template.html` for everyone, then re-copied.

Done when the file opens with zero console errors and no drawer shows *missing*.

## 6. Verify: a render you have not seen does not exist

```bash
grep -cE 'src="http|href="http|@import|url\(http' FILE.html        # prints 0
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --screenshot=/tmp/w.png \
  --window-size=1400,1000 --virtual-time-budget=4000 "file:///ABS/FILE.html#f=1&s=2&m=today"
```

Look at the PNG. Then open the file in the browser and bring it to the front (`/show-me` has the osascript). Done when you have seen the last step of every flow in every mode, and one drawer (`&d=0`).

## 7. Ship

Hand over the file itself. The message says three things: the question it answers, the verdict in one line, the one decision you want from the reader. Add the mechanics: opens from disk in any modern browser, no network; Slack shows a card, not a preview; the `#f=&s=&m=` in the address bar is a deep link once opened.
