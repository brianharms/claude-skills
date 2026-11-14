---
name: shutdown
description: Wrap up the current work and write a handoff (SESSION_LOG.md) for the next Claude Code session on this project. Use when the user says /shutdown, "wrap up", or "write a handoff".
---

# GRACEFUL SESSION SHUTDOWN

You are being asked to wrap up your current work and prepare a handoff for the next Claude Code session on this project.

## Steps

### 1. Stop and reflect

Do NOT continue working on any tasks. Take stock of:
- What was the user's original request or goal this session?
- What did you accomplish?
- What is still in progress or incomplete?
- What problems or blockers were encountered?
- What decisions were made and why?
- What files were created or modified?
- Are there any running background processes, dev servers, or builds that the user should know about?

### 2. Find or create the handoff file

Look for a file called `SESSION_LOG.md` in the project root (the current working directory). If it doesn't exist, create it with a header:

```markdown
# Session Log

This file tracks session handoffs so the next Claude Code instance can quickly get up to speed.
```

### 3. Append the session summary

Append a new entry to `SESSION_LOG.md` with the following format:

```markdown
---

## Session — YYYY-MM-DD HH:MM

### Goal
What the user asked for / what we were working on.

### Accomplished
- Bullet list of what was completed

### In Progress / Incomplete
- Bullet list of unfinished work, with enough detail for the next session to continue

### Key Decisions
- Any architectural choices, trade-offs, or user preferences that were established

### Files Changed
- List of files that were created or significantly modified

### Known Issues
- Bugs, errors, or blockers that remain

### Running Services
- Any dev servers, background processes, or builds that may still be running (with ports/PIDs if known)

### Next Steps
- What the next session should do first to continue this work
```

Use the **actual current date and time** for the timestamp. Fill in every section based on your memory of this session. Be specific and concise — this is for another Claude instance, not a human readme. Include file paths, function names, error messages, and port numbers where relevant.

### 4. Backup to GitHub

Ensure the project is version controlled and backed up:

1. **Check if the project is a git repo.** If NOT:
   - Run `git init` to initialize a new repo.
   - Create a `.gitignore` with sensible defaults for the project type (node_modules, __pycache__, .env, logs/, settings.json with secrets, etc.).
   - Run `git add .` for the initial commit (since there are no prior commits to be selective about).
   - Commit with message: `initial commit: <brief project description>`
   - Create a GitHub repo using `gh repo create <project-name> --private --source=. --push`. If `gh` is not available, tell the user to create the repo manually and provide the commands to add the remote and push.

2. **If it IS a git repo**, check if it has a remote configured (`git remote -v`). If no remote:
   - Create one with `gh repo create <project-name> --private --source=. --push`.
   - If `gh` is not available, note it and provide manual instructions.

3. **Stage changed files explicitly** — use `git add <file1> <file2> ...` with the specific files that were modified this session. Never use `git add -A` or `git add .` (except for initial commits) to avoid accidentally staging secrets, large binaries, or unrelated files. Do NOT stage files that may contain secrets (`.env`, credentials, tokens, API keys).

4. **Commit** with a descriptive message summarizing the session's work. Use the format:

   ```
   session: <brief summary of what changed>

   - bullet points of key changes
   - include file names where helpful

   Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
   ```

   Pass the message via a HEREDOC to preserve formatting:
   ```bash
   git commit -m "$(cat <<'EOF'
   session: <summary>

   - change 1
   - change 2

   Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
   EOF
   )"
   ```

5. **Push to remote** with `git push`. If the push fails (e.g., diverged branches), do NOT force push. Instead, note the failure and let the user resolve it.

6. **Verify** with `git status` after push to confirm the working tree is clean and the branch is up to date.

### 5. Confirm and exit

Tell the user:
- The handoff file has been written
- A brief 2-3 line summary of what was captured
- Whether the GitHub backup succeeded or failed (include the commit hash if successful)
- Any running processes they may want to manually stop

Then immediately run `/exit` to end the CLI session. Do not wait for further input.
