# Claude Skills

Ten skills for [Claude Code](https://claude.com/claude-code): ways of working I use every day. Each one is a folder
with a `SKILL.md`. Type its name after a slash (`/explain`) or just ask for what it does.

## Install

Ask your Claude:

> Install the skills from https://github.com/brianharms/claude-skills for me

It shows you the list, asks which ones you want, and installs them. (It reads [AGENTS.md](AGENTS.md).)

Or by hand:

```bash
git clone https://github.com/brianharms/claude-skills.git
cd claude-skills
./install.sh                    # all ten
./install.sh explain risk       # or just these
```

They go into `~/.claude/skills/`. A skill you already have with the same name is never overwritten.
`./install.sh --list` shows what's here and what's installed; `./install.sh --update` refreshes the ones it put in.

## The skills

**Thinking it through**

| Skill | What it does |
|---|---|
| `/explain` | Turns a concept, bug or system from the conversation into an interactive HTML page you can click through. |
| `/hypothesize` | Three agents diagnose the same bug separately; you get their explanations ranked by likelihood. |
| `/propose` | Three agents propose different approaches to a design question; you get them ranked. |
| `/risk` | Looks at what changed in this session and predicts what could go wrong. |

**Checking the work**

| Skill | What it does |
|---|---|
| `/grade` | Screenshots each feature and grades it PASS or FAIL from what is actually on screen, not from the code. Writes `AUDIT.html`. |
| `/grade-and-fix` | `/grade`, and when something fails it diagnoses the cause with `/hypothesize`, fixes it and grades again. |
| `/walkthrough` | Walks you through testing the recent changes yourself, one test at a time, fixing failures as you go. |
| `/checklist` | Makes a click-through checklist page anyone can use to verify the work, with comments and export. |

**Getting it done**

| Skill | What it does |
|---|---|
| `/stepbystep` | Walks you through a manual task one step at a time and waits for you to finish each one. |
| `/shutdown` | Wraps up and writes a handoff to `SESSION_LOG.md` so the next session picks up where this one stopped. |

## What some of them need

- **`/grade`, `/grade-and-fix`:** a browser Claude can take screenshots in (the Claude in Chrome extension, or the
  Claude desktop app's built-in browser), and
  [Node](https://nodejs.org) for a small local screenshot receiver.
- **`/checklist`, `/explain`:** they write an HTML file and open it in your browser. `/checklist` serves it with
  Python 3 (it comes with Apple's command line tools: `xcode-select --install`).
- **`/shutdown`:** writes `SESSION_LOG.md` in your project. If the project is on GitHub, you may want that file in
  `.gitignore`: it holds working notes.

`/grade-and-fix` and `/walkthrough` call `/grade` (and `/hypothesize`), so the installer brings those along.

## License

MIT
