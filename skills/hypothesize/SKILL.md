---
name: hypothesize
description: Spawn 3 parallel agents to independently diagnose the current bug/problem, then present their hypotheses ranked by likelihood.
---

When invoked, identify the current bug or problem from conversation context. Then launch 3 Agent subagents **in parallel**, each tasked with independently diagnosing the problem and proposing a fix.

## Agent Instructions

Each agent gets the same context about the bug/problem but is assigned a **different investigative angle**:

- **Agent A — "The Obvious Suspect"**: Look for the most straightforward, surface-level cause. Check the most recently changed code, the most common mistake patterns, and the simplest explanation. Prefer Occam's razor.
- **Agent B — "The Deep Diver"**: Dig deeper into the architecture. Look for systemic issues, interaction effects between components, race conditions, state management bugs, or incorrect assumptions in the data flow. Consider what could be subtly wrong even if the surface looks correct.
- **Agent C — "The Contrarian"**: Challenge the framing of the problem itself. Consider whether the bug is actually somewhere entirely different than where it appears. Look for environmental factors, build/config issues, stale caches, wrong dependencies, or upstream data problems. Think laterally.

Each agent must return:
1. **Diagnosis** — What they believe the root cause is (2-3 sentences)
2. **Evidence** — What they found in the code/files that supports their theory
3. **Proposed Fix** — Concrete steps or code changes to resolve it
4. **Confidence** — Self-assessed confidence level (Low / Medium / High)

## Agent Prompts

Give each agent:
- A clear description of the bug/problem (symptoms, error messages, observed vs expected behavior)
- The relevant file paths and any context from the conversation
- Their assigned investigative angle (from above)
- Instruction to **read the actual code** and cite specific files/lines
- Instruction to return their findings in the 4-part format above
- Instruction that they are **research only** — do NOT edit any files

## Presentation

After all 3 agents return, present the results to the user as a ranked list:

### Format

```
## Hypotheses

### 1. [Title] — Confidence: [High/Medium/Low]
**Agent**: [A/B/C nickname]
**Diagnosis**: ...
**Evidence**: ...
**Proposed Fix**: ...

### 2. [Title] — Confidence: [High/Medium/Low]
...

### 3. [Title] — Confidence: [High/Medium/Low]
...
```

Rank by your own assessment of likelihood, weighing the agent's confidence, the strength of their evidence, and how well the diagnosis explains the observed symptoms. Add a brief note if you think one hypothesis is significantly more likely than the others.

After presenting, ask: **"Want me to pursue one of these?"**
