# Astronaut

Toddler-friendly 2D climbing platformer. Design source of truth: `docs/spec.md`.

## Stack

- Godot 4.x (exact version TBD: pin to the one installed on the dev PC).
- GDScript with static typing.

## Run

- Play: `godot --path games/astronaut`
- Headless check: `godot --headless --path games/astronaut --quit`

## Tests

None yet. Add only for logic where bugs would be subtle.

## Notes

- Input is exactly 3 actions (`left`, `right`, `jump`), mapped to both the arcade box (gamepad buttons) and the keyboard.
- "Very forgiving" is the top design rule. Movement tuning lives in a Resource.
