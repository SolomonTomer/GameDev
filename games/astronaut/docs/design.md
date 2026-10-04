# Astronaut Prototype — Technical Design (v1)

How we build `docs/spec.md`. If this doc and the spec disagree, the spec wins, and this doc gets fixed.

## Engine

- Godot 4.7.2 (latest stable), GDScript with static typing.
- Renderer: Compatibility. It's the simplest 2D renderer and runs on older PCs, and we need no advanced rendering.

## Project settings

- Viewport 1920×1080, stretch mode `canvas_items`, aspect `keep`, fullscreen window.
- Because the screen is static and the viewport matches the world, world coordinates equal screen coordinates. This keeps the "part flies into its slot" tweens trivial.
- **Input map** ([InputMap](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html#inputmap)):

| Action | Keyboard | Gamepad (placeholder until the box arrives) |
|---|---|---|
| `left` | Left arrow, A | Button 13 (D-pad left) |
| `right` | Right arrow, D | Button 14 (D-pad right) |
| `jump` | Space | Button 0 (A / bottom face) |
| `quit` | Esc | none |

## Folder layout

Each scene sits next to its script, grouped by feature:

```
games/astronaut/
  project.godot
  main.tscn / main.gd                      # the world screen; owns the loop
  player/player.tscn, player.gd
  player/movement_tuning.gd                # Resource class
  player/movement_tuning.tres              # tuning values
  player/astronaut_frames.tres             # SpriteFrames: the astronaut animations
  player/art/*.png                         # rendered astronaut frames
  art_src/astronaut/                       # generator for the astronaut frames (ignored by Godot)
  world/tiles.tres                         # TileSet: Kenney terrain (solid) and decoration (no collision)
  world/background.tscn                    # sky, clouds and hills behind the world
  world/art/                               # Kenney tile sheet + its XML, background tiles, CC0 license
  world/moving_platform.tscn, moving_platform.gd
  parts/engine_part.tscn, engine_part.gd
  parts/parts_panel.tscn, parts_panel.gd
  rocket/rocket.tscn, rocket.gd
  rocket/door_frames.tres, flame_frames.tres   # SpriteFrames: hatch closing, flame igniting and burning
  rocket/art/*.svg                         # rocket layers, flame frames, smoke puff and sparkle (Godot imports SVG directly)
  audio/*.wav
```

## Scene tree (main.tscn)

```
Main (Node2D, main.gd)
├─ Background (CanvasLayer instance)    sky, clouds, hills; layer -1, behind everything
├─ Decor (TileMapLayer)                 bushes, rocks, etc.; no collision
├─ Level (TileMapLayer)                 floor, walls, platforms
├─ MovingPlatform (instance)            1+ instances
├─ EnginePart ×3 (instances)            in group "engine_parts"
├─ Rocket (instance)
├─ Player (instance)
└─ PartsPanel (CanvasLayer instance)
```

## Components

**Player**: a [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html). It's Godot's node for code-controlled movement with collisions, and `move_and_slide()` handles floors, walls and riding moving platforms.
- Reads the `left`, `right` and `jump` actions. Every value comes from an exported `MovementTuning` resource: run speed, gravity, fixed jump velocity, air control, coyote time and jump-buffer window.
- Plays its own jump and land sounds (child `AudioStreamPlayer` nodes).
- `set_controls_enabled(bool)` lets the rocket freeze the player during launch.
- Its visual is an [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html) (a node that flips through image frames) using `astronaut_frames.tres`, with the animations `idle`, `run`, `jump` and `land`. Frame rates live in that resource.
- Animation rule, checked every physics frame: in the air → `jump` (it plays once and holds on the in-air pose); on landing → `land` until it finishes; otherwise `run` while moving and `idle` when still. `flip_h` mirrors the art when moving left.

**MovementTuning**: a custom [Resource](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html). It's a data object saved as a `.tres` file and edited in the Inspector, which fits the "data-driven" principle. Starting values are guesses to tune in M1:
- Tile size: 64 px
- Run speed: ~350 px/s
- Jump height: ~3 tiles
- Coyote time: 0.2 s
- Jump buffer: 0.2 s

**Level**: a [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html). It lets us paint the level on a grid in the editor, and swapping placeholder art for real art later means changing only the TileSet.
- Every tile is fully solid, including the floor, walls and platforms (spec: platforms are solid from every side).
- Level-design rule: keep enough headroom above each jump path that a normal jump never hits the underside of the platform above.
- The TileSet uses the Kenney tile sheet (`kenney_tiles.png`) as one atlas: 64 px tiles with a 1 px gap between them, which matches our grid exactly. Cells are addressed by their column and row in the sheet (`kenney_tiles.xml` maps tile names to pixel positions; column = x / 65, row = y / 65).
- Tile choice follows each cell's neighbours: the floor row uses `terrain_grass_block_top` (11:9); the left and right walls use `block_right` (10:9) and `block_left` (9:9), so the outline faces into the room; the corners use `block_center` (8:9); a platform is `horizontal_left` (1:10), `horizontal_middle` (2:10) and `horizontal_right` (5:10). A platform that touches a wall ends in a middle piece, so it joins the wall without a rounded corner.
- Every terrain tile has the same full 64×64 collision square, whatever its art looks like, so changing the art can never change what is solid.

**Decor**: a second TileMapLayer drawn behind the Level, using decoration tiles from the same TileSet. Those tiles have no collision shape, so nothing collides with them. Each decoration sits on the cell directly above a solid cell. Keep them at least one cell away from engine parts so they aren't mistaken for collectibles.

**Background**: a [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html) at layer -1, so it draws behind the whole world. It is a flat sky-colored rectangle plus two bands of a Kenney background tile (clouds, then pale hills), each a TextureRect set to tile horizontally. The hills are the pale "fade" variant on purpose: the green variant made the bushes and the astronaut blend into the background.

**MovingPlatform**: an [AnimatableBody2D](https://docs.godotengine.org/en/stable/classes/class_animatablebody2d.html). It's a physics body moved by code or animation that correctly carries whatever stands on it.
- A looping [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html) moves it between two points and pauses at each end. The pause is the "wait for it" moment.
- Its travel offset, speed and pause length are exported per instance, so each one is set in the level itself.
- Its visual is a Kenney wooden plank (`bridge`, 11:1 in the sheet) drawn at 1.5× so it fills the 96 px collision width, with its top aligned to the collision top. The collision shape is unchanged.

**EnginePart**: an [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html), which detects overlaps without physical collision.
- When the player enters, it emits `collected(part)` and disables itself.

**PartsPanel**: a [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html), a HUD layer drawn above the world.
- One slot per part in the level.
- `fly_to_next_slot(from_position)` tweens a part icon from its world position into the next empty slot and plays a sound.
- `pulse_empty_slots()` gives the gentle hint.

**Rocket**: an Area2D whose look is a stack of layers under a `Visual` Node2D, plus a `Glow` sprite behind it. Its collision box and its public API (`set_ready()`, the signals `needs_parts` and `launched`) are unchanged, so `main.gd` didn't need to change.
- **Layers** (bottom to top inside `Visual`): `Flame` and `Engine` (both hidden at first), `Body` (fins, mount, body, nose, dull window), `WindowLit`, `WindowAstronaut`, `Door`, then the particle emitters. Every layer except the flame is drawn on the same 160×230 canvas with the ground contact at the same point, so they line up with no per-layer offsets: each [Sprite2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html) just sets `offset` to move that point to the origin.
- **Pivot:** `Visual` sits at the rocket's feet (the ledge top), so scaling it squashes and stretches from the ground. The ledge is 96 px below the Rocket node's origin.
- **Door and flame** are [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html) nodes with their own SpriteFrames: the door has `open` and `close` (open → half → closed); the flame has `ignite` (plays once, then hands over) and `burn` (loops three frames).
- **Glow** is a Sprite2D with a [GradientTexture2D](https://docs.godotengine.org/en/stable/classes/class_gradienttexture2d.html), Godot's built-in gradient image. No art file is needed.
- **Effects** are [CPUParticles2D](https://docs.godotengine.org/en/stable/classes/class_cpuparticles2d.html) with a small SVG texture each: `Sparkles` (while ready), `AttachSparks` (one burst), `SmokeBurst` (one burst at ignition) and `SmokeTrail` (during lift-off, in world space so the puffs stay behind).
- **Waiting:** a looping Tween breathes `Visual.scale` gently.
- **`needs_parts`:** when the player enters before all parts are collected, it emits `needs_parts` and does a friendly double hop (`Visual` moves up 8 px and back twice). It is a hop rather than a head-shake on purpose, since the spec allows no "fail" feedback. A new hop cancels one still running.
- **`set_ready()`:** fades the glow and the lit window in, starts the sparkles, pulses the glow, and swaps the breathing for a loop that wiggles every second or so. Calling it twice does nothing the second time.
- **Launch:** when the player enters and it is ready, one sequential Tween runs, with a few short side tweens for the pops and shakes: freeze and hide the player and stop the idle loops → door closes → door sound and the astronaut's face appears in the window → engine slides in with a sparkle burst → flame ignites with a smoke burst and a rumble → lift-off sound, a quick squat, then it rises (ease-in) and stretches with a smoke trail. At the end it emits `launched`. About 3.6 seconds in total.

## Flow and state

All loop state lives in `main.gd`: `parts_collected: int` and `parts_total: int`, where `parts_total` is the count of nodes in the `engine_parts` group. The game has only one scene, so it needs no [autoload](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) (Godot's global singleton).

[Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) (Godot's built-in observer pattern) are wired in `main.gd`:

```
EnginePart.collected  → Main: parts_collected += 1; PartsPanel.fly_to_next_slot(); if all → Rocket.set_ready()
Rocket.needs_parts    → PartsPanel.pulse_empty_slots()
Rocket.launched       → Main: get_tree().reload_current_scene()   # the reset
```

Reloading the scene is the reset. It restores every part, the player and the rocket to their starting state with no reset code of our own.

The quit action (Esc) is handled in `main.gd` via `_unhandled_input` and calls `get_tree().quit()`.

## Art and audio

- Art: placeholder shapes and colors, replaced piece by piece in the art pass.
- Astronaut pipeline: `art_src/astronaut/gen.py` draws each frame as an SVG, and `render.js` (Node + Playwright's Chromium) renders them to `player/art/*.png` at 2× the in-game size. The sprite is scaled to 0.5, so it stays sharp on bigger screens. To change the character, edit `gen.py`, run both scripts, and commit the PNGs. `art_src/` has a `.gdignore`, so Godot skips it.
- Environment art: the Kenney New Platformer Pack (CC0, license kept in `world/art/KENNEY_LICENSE.txt`). We copy only what we use: the tile sheet and its XML, and two 256 px background tiles. Other terrains in the same sheet (sand, snow, stone, purple) are there for later planets.
- Rocket art: hand-written SVG files in `rocket/art/`, kept as the source of truth and imported by Godot directly (it rasterizes SVG at import), so there is no render step and no Node or Python needed. Each file is written at 2× the in-game size (the SVG's `width`/`height` are double its `viewBox`) and its sprite is scaled to 0.5, like the astronaut, so it stays sharp on bigger screens. Colors reuse the astronaut's palette (dark outline `#2b2d42`, white `#f4f6fb`, orange `#ff8c42`) plus a coral red for the nose and fins. To change the rocket, edit the SVG; Godot re-imports it when the editor regains focus.
- Audio: CC0 placeholder sounds (for example, Kenney or sfxr-generated) stored as `.wav` files under `audio/`.

## Testing

- No automated tests planned. There's no logic where bugs would be subtle, and feel is verified by playtesting.
- Every milestone must pass the headless check (`godot --headless --path games/astronaut --quit`) with no errors.
