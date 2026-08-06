# skills

## Install

For Claude Code. Other agents: see [Other agents](#other-agents).

```bash
git clone git@github.com:kendyl93/skills.git ~/code/skills
cd ~/code/skills && ./install.sh
```

Symlinks every skill into `~/.claude/skills/`, so they work in **every** repo
and nothing gets committed to yours. Restart Claude Code to pick them up.

Keep the clone where it is — the symlinks point at it.

## Use

Just ask, and Claude picks the matching skill:

> review this PR: https://github.com/org/repo/pull/1234

Or name one directly: `/front-end-pr-review <pr-url>`

## Maintain

```bash
git pull                  # update (live, no reinstall)
./install.sh              # link skills added since last pull
./install.sh --uninstall  # remove
./install.sh --help       # dry-run, force, per-project install
```

## Other agents

The skills are plain Markdown — nothing Claude-specific inside them. Only the
auto-discovery is: Claude Code scans `~/.claude/skills/`, other tools don't. To
use them in Cursor, Codex, or anything else, point it at the files:

```bash
./install.sh --target <wherever your tool reads instructions>
```

Or reference a skill by path from your `AGENTS.md` / rules file:

> For front-end PR reviews, follow `~/code/skills/skills/productivity/front-end-pr-review/SKILL.md`.

You lose on-demand loading — the tool reads it always, or only when you say so —
but the instructions work the same.

| Tool              | Where that goes                              |
| ----------------- | -------------------------------------------- |
| Codex CLI         | `~/.codex/AGENTS.md`                         |
| Gemini CLI        | `~/.gemini/GEMINI.md`                        |
| Copilot / VS Code | `~/.copilot/instructions/`                   |
| Cursor            | Settings → Customize → Rules (no file on disk) |
