---
name: walkthrough
description: Guided manual QA — discovers changes, generates a test checklist, then walks the user through each test step-by-step, capturing their pass/fail verdict and fixing failures in real time.
user-invocable: true
arguments: Optional scope filter to narrow what gets tested. If omitted, tests everything since midnight.
---

# Walkthrough — Guided Manual QA

The human-in-the-loop counterpart to `//grade all`. Same discovery engine, but instead of autonomous execution, you walk the user through each test one at a time, asking them to verify and report what they see.

## PHASE 1 — Discovery

Use the same discovery logic as `//grade all`:

**If git repo:**
- `git log --since="midnight" --oneline` + `git diff HEAD~N` for ground truth.
- Cross-reference with conversation context for intent.

**If not git repo:**
- Primary: conversation context (what files were discussed/edited).
- Secondary: `find` with `-newer` midnight reference, excluding noise directories.

**Scope filtering:** If a scope argument was provided, filter to matching changes only.

## PHASE 2 — Build the Checklist

For each testable change, create a test entry:

```
[ID]. [Feature Name]
  Files: [changed files]
  What it should do: [plain English intent]
  How to test:
    1. [concrete user action — "click X", "type Y", "open Z"]
    2. [concrete user action]
    ...
  Look for: [what success looks like — specific, observable]
```

**Checklist rules:**
- Write steps as instructions to a human, not to a script. Use "click", "type", "scroll to", "open", not CSS selectors or JS commands.
- "Look for" should describe something the user can see or hear — a visual state, a message, a behavior — not an internal assertion.
- Group related tests logically (e.g., all sidebar tests together, all API tests together).
- If browser testing is needed but no dev server is running, start one (same as /grade all Phase 0) and tell the user the URL.

## PHASE 3 — Walk Through

Present the full checklist to the user first as an overview:

> "Found [N] things to verify across [M] files. Here's the full list:
> 1. [Feature name] — [one-line summary]
> 2. [Feature name] — [one-line summary]
> ...
> Starting with #1."

Then, for each test:

### Present the test

Show the test card:
```
## Test [ID]/[Total]: [Feature Name]
Files: [list]

**What to do:**
1. [step]
2. [step]
...

**What you should see:** [expected result]
```

### Wait for the user's verdict

Ask: **"Pass, fail, or skip?"**

Do NOT proceed until the user responds. This is the key difference from /grade all — the user is the judge.

### Handle the response

**If PASS:** Record it, move to the next test. Keep it brief — "Got it. Next up: [test name]."

**If FAIL:** Ask: **"What did you see instead?"** Then:
- Diagnose the issue from their description.
- Fix it.
- Tell the user what you changed.
- Ask them to re-test the same steps: **"Try again — same steps. Pass or fail?"**
- If it passes now, record as `pass (fixed)` and move on.
- If it still fails, ask for more detail and try once more. After 2 fix attempts, record as `fail` with notes and move on — don't get stuck.

**If SKIP:** Record it, move on. No questions asked.

### Between tests

- If a fix touched files relevant to a previous test, note it: "Heads up — that fix touched [file], which is also part of Test [X] that already passed. We'll re-check it at the end."
- Keep momentum. Don't over-explain between tests.

## PHASE 4 — Regression Re-check

After all tests are complete, if any fixes touched files involved in previously-passed tests, go back and re-verify those:

> "A fix we made during Test [X] touched [file], which was also part of Test [Y]. Let's re-check Test [Y] real quick."

Walk through the re-check the same way — present steps, ask for verdict.

## PHASE 5 — Summary

When all tests are done, present a summary:

```
## Walkthrough Complete

Passed: [N] (including [M] fixed during walkthrough)
Failed: [N]
Skipped: [N]

### Fixed during this session:
- [Test name]: [what was wrong → what was fixed]
- ...

### Still failing:
- [Test name]: [what the user saw, what was tried]
- ...
```

## Rules

- **The user is always the judge.** Never mark a test as passed based on your own evaluation. Only the user's "pass" counts.
- **Keep it conversational.** This is a dialogue, not a report. Short sentences, clear instructions, no jargon.
- **One test at a time.** Never dump multiple tests on the user at once. Present, wait, respond, move on.
- **Fix in real time.** When something fails, fix it immediately — don't defer to a separate fix pass.
- **Two-attempt limit on fixes.** If two fix attempts don't resolve a failure, record it and move on. Don't spiral.
- **Note regression risks.** If a fix touches a previously-passed test's files, flag it for re-check. Don't silently hope it's fine.
- **Respect "skip."** The user knows what they want to test. Don't push back on skips.
- **No screenshots needed.** The user is looking at the screen. You don't need to capture evidence — their word is the evidence.
