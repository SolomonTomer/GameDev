# Astronaut Prototype — Execution Plan (v1)

Implements `docs/design.md`. Each milestone is one branch and one PR, and ends with a summary covering what was built, how to playtest it, and any concerns.

| # | Milestone | Status |
|---|---|---|
| M1 | Project, input, movement | Done |
| M2 | The climbing world | Done |
| M3 | Engine parts, panel, rocket | Done |
| M4 | Launch, reset, sound | Done |

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
1. Create the TileSet (one solid placeholder tile).
2. Paint the climbing layout in `main.tscn`: wide platforms, small gaps, ledges stepped so that a slip lands one step down, and headroom above every jump path.
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

## Art pass

Planned piece by piece, as the spec's art pass section is decided.

| # | Piece | Status |
|---|---|---|
| A1 | Astronaut character and animations | Done (PR 8) |
| A2 | Earth look for the first level: tiles, background, decorations, moving platform | In review |
| A3 | Rocket: look and animation | In review |
| A4 | Engine parts and parts panel | Not started |

### A3 — Rocket

Steps:
1. Draw the rocket as layered SVG files on one shared canvas (body, engine, lit window, astronaut in the window, three door frames), plus the flame frames, a smoke puff and a sparkle, under `rocket/art/`.
2. Add `door_frames.tres` and `flame_frames.tres` (SpriteFrames).
3. Rebuild `rocket/rocket.tscn`: `Glow`, then a `Visual` pivot at the rocket's feet holding the layers and the particle emitters. Keep the collision box and the four sounds.
4. Rewrite `rocket/rocket.gd`: breathing while waiting, a friendly hop when he arrives too early, the ready state (glow, lit window, sparkles, wiggle), and the new launch sequence. Keep `set_ready()`, `needs_parts` and `launched` exactly as they were.
5. Put the rocket's feet on the ledge: the old placeholder floated 16 px above it.
6. Verify: headless check, plus a simulated run of each state (waiting, wrong entry, ready, launch timeline, re-entry, reset after launch) and full-resolution renders of each beat.

Playtest: does he understand that the rocket has "woken up" when the last part goes in? Does he watch the launch? Is the small face in the window readable to him, and is anything in the smoke or sparkles distracting?

### A2 — Earth level

Steps:
1. Copy the Kenney tile sheet, its XML, two background tiles and the license into `world/art/`.
2. Rebuild `world/tiles.tres` on the Kenney sheet: solid terrain tiles with full-square collision, and decoration tiles without.
3. Repaint the Level layer with the same solid cells as before, choosing each tile from its neighbours.
4. Add the Decor layer and paint decorations on platform tops.
5. Add `world/background.tscn` (sky, clouds, hills) and put it first in `main.tscn`.
6. Restyle the moving platform as a wooden plank, keeping its collision.
7. Start the astronaut on the floor, since he used to start inside the first platform and drop out of it, which would show with real art.
8. Verify: headless check, the solid cells are identical to before, the full loop still plays, and a full-resolution render looks right.

Playtest: does the world read clearly? Can he tell the grass platforms (solid ground) from the wooden plank (the moving one)? Do the decorations distract from the parts?

## After M4

Remap the input to the real arcade box once it arrives, which is a small input-map change. Then review the prototype against the spec's "Later" list together.
