# GameDev

A repo of independent game prototypes. The owner is an experienced backend (C#) engineer and system designer who is new to game development.

## Repo layout

```
games/<game>/
  CLAUDE.md          game-specific stack version, run/test commands, notes
  docs/spec.md       design spec: what and why. The source of truth for that game
  docs/design.md     technical design: how (scenes, nodes, data, signals)
  docs/execution.md  execution plan: milestones, steps, status
  project.godot      the Godot project lives at the game folder root
```

Docs flow in one direction: spec → technical design → execution. Each is approved before the next is written. If a later doc needs something the earlier one doesn't say, update the earlier one first.

- Each game is self-contained. No code shared or imported between games unless we explicitly agree to add a `shared/` folder.
- A new game starts with `games/<name>/docs/spec.md` and `games/<name>/CLAUDE.md`.

## Default stack

- Godot 4 with GDScript, using static typing (typed variables, parameters, return values). Each game's `CLAUDE.md` pins the exact Godot version.
- Engine idioms first: scenes, nodes, signals, Resources and autoloads over backend patterns (DI containers, layered architectures). If an idiom seems to fight good design, raise it instead of working around it.

## Design principles

- Data-driven: tuning values and content (stats, spawn curves, talent nodes, etc.) live in Resources (`.tres`) or data files, not hardcoded in logic.
- Simple over clever: build exactly what the spec asks. No speculative extensibility, and no abstraction until something is needed in three places.
- Comments only for a non-obvious "why".
- Tests are minimal: only for logic where bugs would be subtle (progression rules, graph logic). Playtesting verifies feel.
- Verify before claiming done: the project must run headless without errors and existing tests must pass. That alone only proves the scene parses, not that it's playable. Before reporting any milestone or gameplay change as complete, dispatch the `godot-playtester` subagent (`.claude/agents/godot-playtester.md`) to actually simulate and playtest the relevant mechanics headlessly. Fix anything it reports and re-dispatch it to confirm before telling me a milestone is done.

## Working with me

### Spec phase: I drive, you refine
- I bring the idea and direction. You ask focused questions, surface gaps, contradictions and risks, push back on weak ideas, and draft spec text from what we agree on.
- I make every design decision. Don't finalize spec content I haven't agreed to.

### Implementation phase
- Before coding a spec, write `docs/design.md` and `docs/execution.md` (the milestone plan) and wait for approval.
- Keep `docs/execution.md` status current as milestones progress.
- Then work through each milestone on your own. Stop only for real blockers, or when you believe the spec is wrong or see a clearly better design. In that case explain briefly, propose an alternative, and wait for my call.
- Never build beyond the spec, and never build anything on its out-of-scope list. If something seems missing, ask.
- End each milestone with a short summary: what was built, how to playtest it, and any concerns.

### Communication
- Brief with reasoning: bottom line first, then the why in a sentence or two.
- I'm new to gamedev and want to understand it. When an engine concept first comes up, give a one-line explanation and a link to the relevant Godot docs page, plus a short example only if it helps. No tutorials. Skip backend concepts; I know them.

## Git

- One branch and one PR per milestone. I review and merge; never push to `main`.
- Small, logical commits whose messages explain why.
