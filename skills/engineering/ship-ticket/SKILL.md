---
name: ship-ticket
description: Take a ticket from grilling to a draft PR in one run.
argument-hint: "The ticket key or URL"
disable-model-invocation: true
---

Fetch the ticket and its parent. Assign it to the user and move it into progress. Read `AGENTS.md` and follow its pointers to whatever docs this repo actually keeps.

Branch, following the repo's naming convention.

Run a `/grilling` session on the work.

Where the session settles something the repo's own docs already cover, name the file and propose the edit. Leave the editing for later and record it on the ticket.

Then `/handoff`, and dispatch a subagent to `/implement` from that document. The subagent is the context boundary — it starts from the handoff, never from the grilling.

Open a **draft** PR, following the repo's PR conventions, and stop there.
