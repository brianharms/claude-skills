---
name: stepbystep
description: Walk the user through a multi-step task one step at a time, waiting for them to confirm each step is done before moving on. Use when the user says "/stepbystep", "walk me through it", "one step at a time", or when a task has several manual actions the user needs to physically perform.
---

When invoked, switch into step-by-step coaching mode for the current task.

## The rule

**Present exactly ONE step at a time. Then stop and wait.** Do not describe step 2 until the user confirms step 1 is complete (e.g. "done", "ok", "next", "got it", a screenshot, or any other signal).

## What to do on invocation

1. Identify the task the user wants walked through. It may be:
   - A task you just described in bulk that they now want broken down
   - A new task they're about to describe
   - A task already in flight (commands you already gave them in one big block)

2. If the task isn't clear, ask one short clarifying question before starting.

3. Enumerate the full list of steps **in your head** (or briefly list them to the user as an outline) so you know where you're going — but don't present the full list as the walkthrough itself.

4. Present step 1. Use this format:

   ```
   **Step 1 of N: [short title]**

   [the action — one thing to do, in plain language]

   [if there's a command, put it in a fenced block]

   [one-line success check: "You should see X" or "The file should now contain Y"]

   Let me know when you've done this.
   ```

5. **Stop.** Do not queue up step 2. Do not say "and then you'll...". Do not add "while you're doing that...". End the turn.

6. When the user confirms (any form of "done" / "ok" / "next" / "👍" / new message), present step 2 in the same format.

7. If the user reports a problem at any step, stop the walkthrough, help them debug, then resume from the step that failed. Don't skip ahead.

8. At the final step, instead of "Let me know when you've done this", say: **"That's the last step. Let me know how it went or if you hit any snags."**

## Sizing steps

Each step should be:
- One decision or one action the user physically performs
- Small enough that a confused person can complete it without re-reading
- Not so small that it feels patronizing (don't split "open Finder → press Cmd+Shift+G → paste the path" into three steps — that's one step)

Good step: *"Open the file in TextEdit: `open -e ~/.zshrc`. A window should appear with the current contents."*

Bad step (too big): *"Edit the file and replace both keys and save it."*

Bad step (too small): *"Move your mouse to the Finder icon in the dock."*

## Scope limits

- **Never** list more than one step per message while in walkthrough mode.
- **Never** assume the user did a step you didn't ask them to do.
- If the user interrupts to ask a question, answer it without advancing the step counter.
- If the user says "skip that" or "I already did that", acknowledge and move to the next step.
- Exit walkthrough mode when the user says "done", "thanks", "got it", "I'll take it from here", or when all steps are complete.

## When not to use

- If the task is fully automatable via tool calls (just do it yourself)
- If the task is a single command the user can run without explanation
- If the user is in a hurry and wants the full recipe in one message — respect that, don't force the walkthrough
