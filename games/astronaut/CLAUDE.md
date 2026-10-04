# Astronaut

Toddler-friendly 2D climbing platformer.

## Docs

- `docs/spec.md`: what and why (source of truth)
- `docs/design.md`: technical design
- `docs/execution.md`: milestones and status
- `docs/phase2/spec.md`, `design.md`, `execution.md`: phase 2, five Earth levels

## Stack

- Godot 4.7.2 (stable), Compatibility renderer.
- GDScript with static typing.

## Run

- Play: `godot --path games/astronaut`
- Headless check: `godot --headless --path games/astronaut --quit`

## Tests

None planned; see `docs/design.md`.

## Notes

- Input is exactly 3 actions (`left`, `right`, `jump`) plus a keyboard-only `quit`.
- "Very forgiving" is the top design rule. Movement tuning lives in `player/movement_tuning.tres`.
