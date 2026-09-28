# Astronaut Prototype — Execution Plan (v1)

Implements `docs/design.md`. Each milestone is one branch and one PR, and ends with a summary covering what was built, how to playtest it, and any concerns.

| # | Milestone | Status |
|---|---|---|
| M1 | Project, input, movement | Not started |
| M2 | The climbing world | Not started |
| M3 | Engine parts, panel, rocket | Not started |
| M4 | Launch, reset, sound | Not started |

## M1 — Project, input, movement

Steps:
1. Create `project.godot` (Godot 4.7.2, Compatibility renderer, 1920×1080, `canvas_items` stretch, fullscreen).
2. Set up the input map: `left`, `right`, `jump` and `quit`, with keyboard and gamepad bindings as in the design.
3. Add the `MovementTuning` Resource class and `movement_tuning.tres` with the starting values.
4. Build the Player scene: movement, fixed jump, air control, coyote time and jump buffer.
5. Build `main.tscn` with a flat floor and walls (a temporary test layout) and Esc to quit.
6. Verify the headless check passes.

Playtest: run around and jump. Does it feel floaty and generous? Do jumps pressed slightly early or late still work? Try it with him, and adjust `movement_tuning.tres` in the Inspector until it feels right.

## M2 — The climbing world

Steps:
1. Create the TileSet (a placeholder tile, with a solid variant and a one-way variant).
2. Paint the climbing layout in `main.tscn`: wide platforms, small gaps, and ledges stepped so that a slip lands one step down.
3. Build the MovingPlatform scene and place at least one where waiting is required to go on.
4. Verify the headless check passes.

Playtest: can he get from the floor to the top ledge? Is the moving platform understandable, with no frustration when he misses it?

## M3 — Engine parts, panel, rocket

Steps:
1. Build the EnginePart scene and place 3 along the climb.
2. Build the PartsPanel scene: slots, the fly-to-slot tween and the pulse.
3. Build the Rocket scene: idle, ready glow, and `needs_parts` when entered without all parts.
4. Wire the signals and part counting in `main.gd`.
5. Verify the headless check passes.

Playtest: does he notice the parts and the slots filling? Does the rocket lighting up make sense to him?

## M4 — Launch, reset, sound

Steps:
1. Build the launch sequence in the Rocket: freeze and hide the player, close the door, snap the parts on as an engine, ignite, fly off.
2. Reset by reloading the scene on `launched`.
3. Add all sound effects from the spec's list.
4. Verify the headless check and the full definition of done from the spec.

Playtest: the full loop, several times in a row. Does he want to go again?

## After M4

Remap the input to the real arcade box once it arrives, which is a small input-map change. Then review the prototype against the spec's "Later" list together.
