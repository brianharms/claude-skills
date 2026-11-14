# AGENTS.md

You are a coding agent (Claude or similar) and someone asked you to install these skills. This page is for you. The
person's page is [README.md](README.md).

## 1. Ask which ones

Show them the list with one line each (run `./install.sh --list` after cloning, or use the tables in README.md) and
ask which they want: all ten, or some. Use your question tool if you have one. Do not pick for them.

## 2. Install

```bash
git clone https://github.com/brianharms/claude-skills.git
cd claude-skills
./install.sh <names...>        # no names = all ten; add --dry-run first to see what it will do
```

The installer copies each skill folder into `~/.claude/skills/` (set `CLAUDE_SKILLS_DIR` to use another folder) and
adds the skills a chosen one depends on (`grade-and-fix` needs `grade` and `hypothesize`; `walkthrough` needs `grade`).
No `sudo`, nothing outside that folder.

Read its last lines:
- `RESULT` lists what was installed.
- `SKIPPED` lines mean they already had a skill with that name. It was left alone. Tell them, and ask before you
  touch it: theirs may be a different skill.

## 3. Tell them

- How to use them: type `/` in Claude Code and pick one, or just ask for what it does ("explain how this works").
- If a skill does not show up, start a new Claude Code session.
- What the ones they picked need (README.md, "What some of them need"): a browser Claude can screenshot for `/grade`,
  Node for its screenshot receiver. Check with `node --version` if they chose `/grade` or `/grade-and-fix`.

## Rules

- Never overwrite or delete a skill in `~/.claude/skills/` that this installer did not put there. Its copies carry a
  `.installed-from-claude-skills` file; anything without it is theirs.
- `./install.sh --update` replaces only the installer's own copies, with the versions in this folder (`git pull`
  first).

## Changing the skills (for the author)

Each skill is `skills/<name>/SKILL.md` (plus any files it uses). Before every push run `tools/check.sh`: it must end
in `CLEAN`. It looks for the author's name, home path, secrets, session logs, and calls to skills that are not in this
repo. Extra words to block go in `tools/check.local`, which is never committed.
