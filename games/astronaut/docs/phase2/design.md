# Astronaut Phase 2 — Technical Design

How we build `spec.md` (phase 2). If this doc and the spec disagree, the spec wins, and this doc gets fixed. The phase 1 design (`../design.md`) still applies wherever this doc doesn't change it: engine, project settings, input map, the astronaut, the rocket's look and launch, the Earth tiles and background.

## Physics

`player/movement_tuning.tres` gets new values; `player.gd` doesn't change.

| Value | Phase 1 | Phase 2 |
|---|---|---|
| `gravity` | 2048 | 2850 |
| `jump_velocity` | -1024 | -980 |
| Jump height | 256 px (4 tiles) | 175 px (2.75 tiles, about 2x his 90 px height) |
| Air time | 1.0 s | 0.70 s |
| Flat reach at 350 px/s | 350 px (5.5 tiles) | 246 px (3.8 tiles) |

`run_speed` (350), `air_control` (1.0), `coyote_time` (0.2) and `jump_buffer_time` (0.2) are unchanged. These are starting values. `jump_velocity` was tuned to -980 in P1: with discrete physics steps -1000 measured about 184 px of jump, and -980 measures about 175-177 px.

**Why 2.75 tiles rather than the spec's first "about 2.5":** levels sit on a 64 px grid, so a step up is 1 or 2 tiles. At 2.5 tiles (160 px) a 2-tile step needs 80% of the jump, over the 75% budget, which would force every climb into 1-tile steps. At 2.75 tiles a 2-tile step needs 73%. The spec is updated to match.

## Layout rules (the forgiveness budget on the grid)

Worked out from the numbers above, with 75% of the maximum as the limit:

| Move | Allowed | Uses |
|---|---|---|
| Step up | 1 or 2 tiles | 2 tiles = 73% of the jump height |
| Gap across, same height | up to 2 tiles | 2 tiles = 52% of the flat reach |
| Gap with a 2-tile step up | up to 2 tiles | 2 tiles = 69% of what's reachable |
| Never | a 3-tile step or a 3-tile gap | |

Also:
- **Headroom:** where two platforms overlap horizontally, leave at least 5 open tiles between the lower surface and the upper platform's underside. A full jump lifts his 90 px body 175 px.
- **Under moving planks:** wherever a plank can pass over a surface he can stand on, leave at least 104 px of space, so a plank never presses down on him (his body is 90 px).
- **Slab thickness:** a platform floating only 1 tile above the floor is a wall he can't walk under. Such a platform is built as a solid box down to the floor.
- **Falling:** a fall lands somewhere he can climb back from using only the moves above.

## Scene structure

Phase 1 had one scene, `main.tscn`, that was both the world and the loop. Phase 2 splits it:

```
Main (main.tscn, main.gd)                level sequencer; persists across levels
├─ Background (instance)                 unchanged, shared by all Earth levels
├─ Level (instance of the current level, swapped on completion)
├─ StarsPanel (CanvasLayer instance)     slots for the current level's stars
└─ Fade (CanvasLayer, layer 100)         full-screen ColorRect for the fade between levels

levels/level_N.tscn (one per level, root has level.gd)
├─ Decor (TileMapLayer)                  bushes, rocks, etc.; no collision
├─ Terrain (TileMapLayer)                floor, walls, platforms
├─ MovingPlatform (instances, 0-1)
├─ Stars (Node2D)                        the level's Star instances (0-3)
├─ Goal (a Flag instance, or the Rocket in level 5)
└─ Player (instance)                     placed at the level's start
```

**Main** (`main.gd`):
- `@export var levels: Array[PackedScene]` holds the five level scenes in order, set in `main.tscn`. The order is data, not code. ([PackedScene](https://docs.godotengine.org/en/stable/classes/class_packedscene.html) is a saved scene that can be instanced at runtime.)
- `_load_level(index)` frees the current level, instances the next one, adds it under Main, calls `level.setup(stars_panel)` and connects `level.completed`.
- On `completed`: fade to black (0.35 s), load the next level (wrapping from 5 back to 1), fade in (0.35 s).
- Esc still quits.
- Loading a fresh instance is the reset, as reloading the scene was in phase 1, so there is still no reset code.

**Level** (`level.gd`, `class_name Level`, on each level's root):
- `signal completed`.
- `setup(panel)` counts the children of `Stars`. Counting the container's children, rather than a group, keeps the outgoing level's stars from being counted during the swap. It then:
  - calls `panel.show_slots(count)`;
  - connects each star's `collected`, `Goal.needs_stars` and `Goal.completed`.
- When the last star is collected it calls `Goal.set_ready()`.
- `needs_stars` makes the panel pulse its empty slots; `completed` re-emits as the level's `completed`.
- This is phase 1's `main.gd` part-counting logic, moved down into the level.

**Goal interface:** the Flag and the Rocket both have `set_ready()` and the signals `needs_stars` and `completed`, so the Level treats them the same. The Rocket's `needs_parts` becomes `needs_stars` and its `launched` becomes `completed`. It emits `completed` at the same moment as before, when the launch has finished.

## New and changed pieces

**Flag** (`flag/flag.tscn`, `flag.gd`):
- **Structure:** an Area2D with an AnimatedSprite2D. Its frames are cut from the Kenney sheet with [AtlasTexture](https://docs.godotengine.org/en/stable/classes/class_atlastexture.html), which displays one region of a larger image: `flag_off` (1040, 130) and `flag_red_a`/`_b` (1105, 130 and 0, 195). No new image files.
- **Size:** drawn at 2x (128 px tall) so it reads as a goal next to the 90 px astronaut. The origin is at the foot of the pole, so placing it means putting it on the ground.
- **Animations:** `off` (one frame), `wave` (two frames, 4 fps), and the celebration, which is `wave` at a faster speed.
- **`@export var awake_at_start: bool`:** true in levels 1-2, which have no stars. The flag then starts waving silently.
- **`set_ready()`:** swaps to `wave` with a quick squash-and-stretch pop, a sparkle burst (reusing `rocket/art/sparkle.svg`) and the flag-raise sound.
- **Body enters while off:** emits `needs_stars`. The flag itself does nothing, so there is no "no" gesture.
- **Body enters while awake, only once:**
  1. Calls the player's `celebrate()`.
  2. Waves fast and bursts sparkles.
  3. Plays the level-complete jingle.
  4. After about 2 s, emits `completed`. Main's fade makes it about 2.5 s in total.

**Star** (`stars/star.tscn`, `star.gd`, replacing `parts/engine_part.*`):
- Same behavior as the engine part: an Area2D with a 20 px circle that hides, plays the pickup sound and emits `collected(star)` when he touches it.
- New look: `stars/art/star.svg`, an outlined yellow five-point star in the astronaut's style, at 2x and scaled 0.5 like the rocket art.
- It bobs gently with a looping Tween, so it reads as something to grab.

**StarsPanel** (`stars/stars_panel.tscn`, `stars_panel.gd`, replacing `parts/parts_panel.*`):
- Three slots drawn as star outlines (`stars/art/star_slot.svg`), which fill with `star.svg`.
- New `show_slots(count)`: shows the first `count` slots, hides the rest, hides the whole panel when `count` is 0, and clears filled slots.
- `fly_to_next_slot()` and `pulse_empty_slots()` keep their behavior.

**Moving plank** (`world/moving_platform.tscn`): 3 tiles wide (192 px, was 96) so a toddler can land on it easily. It is thin: the collision is 192×24 to match Kenney's `bridge` art, three tiles drawn at scale 1. The top surface is 12 px above the node's origin. `travel_offset`, `travel_speed` and `pause_time` stay per-instance exports.

**Player** (`player.gd`): new `celebrate()`. It turns controls off, then plays two little hops on the sprite only (a Tween, up 24 px and back, using the jump and land frames). Physics is off while controls are off, so the hop is visual.

**Rocket:** only the two signal renames.

## Level layouts

**Grid:** 30×17 tiles of 64 px. Walls fill columns 0 and 29; the floor is row 16 (top at y=1024). A platform "on row r" is a 1-tile slab whose top is at y = 64·r. A "box" is solid from its top row down to the floor. Column c spans x 64c to 64c+64. The player starts on the floor at column 2, (160, 979), unless noted.

**Level 1: walk.** Floor only, with two or three decorations. Flag on the floor at column 26, at (1696, 1024), awake.

**Level 2: jump.** Every step is 1 tile, and there are no gaps.
- Hurdles: 1×1 blocks on row 15 at columns 8 and 12, then a 2-wide hurdle at columns 16-17.
- Stairs: columns 20-21 on row 15, then columns 22-23 boxed from row 14, then a plateau at columns 24-28 boxed from row 13.
- Flag on the plateau at column 27, at (1760, 832), awake.

**Level 3: ride, and 1 star.**
- **Left plateau:** columns 1-8, boxed from row 14. He starts on it at column 3, (224, 851).
- **Pit:** columns 9-20 down to the floor.
- **Right plateau:** columns 21-28, boxed from row 13. Its pit wall is 3 tiles high, so it can only be reached by riding.
- **Plank:**
  - Left stop: x 576-768, top at y 896, flush with the left plateau.
  - Right stop: x 1152-1344, top at y 832, flush with the right plateau.
  - `travel_offset` (576, -64), speed 180 px/s (a 3.2 s ride), 2 s pause at each end.
- **Star:** floats mid-ride at his body height, (960, 819), so riding collects it.
- **Flag:** on the right plateau at column 26, at (1696, 832), off until the star.
- **Checks:** a fall into the pit lands on the floor, and the left wall is a 2-tile step back up (he climbs it while the plank is away, which is more practice at waiting). Under the plank's lowest point there are 104 px.

**Level 4: platforming, and 2 stars.**
- **Route:**
  1. A step at column 4 on row 15.
  2. A: columns 5-9, boxed from row 14.
  3. B: columns 12-15 on row 12. Gap 2, up 2.
  4. C: columns 18-21 on row 13. Gap 2, down 1.
  5. D: columns 24-28 on row 11. Gap 2, up 2.
- **Stars:** star 1 rests on B at (896, 723). Star 2 floats 1.5 tiles above C at (1280, 691), so getting it needs a jump.
- **Flag:** on D at column 27, at (1760, 704), off until both stars.
- **Checks:** no platforms overlap. Any fall lands on the floor, and the way back up starts at the step.

**Level 5: climb, 3 stars and the rocket.**
- **Route:**
  1. P1: columns 4-8, boxed from row 14. Up 2 from the floor.
  2. P2: columns 11-14 on row 12. Gap 2, up 2.
  3. P3: columns 17-21 on row 10. Gap 2, up 2.
  4. Elevator plank: columns 22-24 (x 1408-1600), riding from a top of y 640 (flush with P3) to y 384 (flush with the ledge). `travel_offset` (0, -256), speed 120 px/s, 2 s pause at each end.
  5. Rocket ledge: columns 25-28 on row 6.
- **Catch platform:** columns 22-28 on row 12, under the elevator. A slip off the elevator or off P3's edge lands here, and P3 is a 2-tile step back up. It sits 104 px below the elevator's lowest point and 5 tiles below the ledge.
- **Stars:**
  - Star 1 on P2, at (832, 723).
  - Star 2 floats above P3, at (1248, 499), so getting it needs a jump.
  - Star 3 floats mid-way up the elevator, at (1504, 467), so riding collects it. The rocket wakes during the ride.
- **Rocket:** on the ledge at (1728, 288), which puts its feet on the ledge top at y 384.
- **Checks:** the climb is 10 tiles in five 2-tile steps, with one ride. Falls from P1-P3 land on the floor, and the way back starts at P1.

These are starting layouts. Each is checked by simulation and adjusted in its milestone; any change stays inside the rules above.

## Art and audio

- **New SVGs:** `stars/art/star.svg` and `stars/art/star_slot.svg`, hand-written like the rocket art, imported directly by Godot.
- **Flag:** Kenney atlas regions, so no new image files.
- **Moving plank:** the existing `bridge` tile.
- **New sounds:** `audio/flag_raise.wav` (a rising three-note chime) and `audio/level_complete.wav` (a short happy jingle). Kenney audio was not downloaded; both are synthesized sine tones written by a small Godot script (the design's fallback), so they are simple placeholders like the phase 1 sounds.

## Verification

- Headless boot check on every milestone.
- The playtester simulates each level's intended route with real inputs (held directions and timed jumps) and confirms:
  - the goal is reached;
  - the goal stays off until every star is collected;
  - each required jump is reachable, with its margin logged.
- The sequence is checked end to end: level 1 → 2 → 3 → 4 → 5 → the rocket launch → level 1, with a fresh level each time and the panel showing the right number of slots.
- A full-resolution render of each level, for you to judge.
- No new automated tests.

## Build notes (changes made while building)

- **`Goal` base class** (`levels/goal.gd`): the Flag and the Rocket both extend it, declaring `needs_stars`, `completed` and `set_ready()` once, so `Level` can type its goal.
- **Player-only triggers:** the Flag and the Star ignore any body that isn't the `Player`. The flag's area touches the floor tiles at its foot, which otherwise counted as a body entering.
- **Gravity while controls are off:** `Player` still falls and lands when controls are disabled, so touching the flag mid-jump lands him before the hop (`celebrate()` waits for the floor). Input stays ignored.
- **Sounds:** synthesized, see Art and audio.
