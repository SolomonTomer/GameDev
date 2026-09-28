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
  world/tiles.tres                         # TileSet (placeholder tile)
  world/moving_platform.tscn, moving_platform.gd
  parts/engine_part.tscn, engine_part.gd
  parts/parts_panel.tscn, parts_panel.gd
  rocket/rocket.tscn, rocket.gd
  audio/*.wav
```

## Scene tree (main.tscn)

```
Main (Node2D, main.gd)
├─ Background (ColorRect / Sprite2D)
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

**MovementTuning**: a custom [Resource](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html). It's a data object saved as a `.tres` file and edited in the Inspector, which fits the "data-driven" principle. Starting values are guesses to tune in M1:
- Tile size: 64 px
- Run speed: ~350 px/s
- Jump height: ~3 tiles
- Coyote time: 0.2 s
- Jump buffer: 0.2 s

**Level**: a [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html). It lets us paint the level on a grid in the editor, and swapping placeholder art for real art later means changing only the TileSet.
- Every tile is fully solid, including the floor, walls and platforms (spec: platforms are solid from every side).
- Level-design rule: keep enough headroom above each jump path that a normal jump never hits the underside of the platform above.

**MovingPlatform**: an [AnimatableBody2D](https://docs.godotengine.org/en/stable/classes/class_animatablebody2d.html). It's a physics body moved by code or animation that correctly carries whatever stands on it.
- A looping [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html) moves it between two points and pauses at each end. The pause is the "wait for it" moment.
- Its travel offset, speed and pause length are exported per instance, so each one is set in the level itself.

**EnginePart**: an [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html), which detects overlaps without physical collision.
- When the player enters, it emits `collected(part)` and disables itself.

**PartsPanel**: a [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html), a HUD layer drawn above the world.
- One slot per part in the level.
- `fly_to_next_slot(from_position)` tweens a part icon from its world position into the next empty slot and plays a sound.
- `pulse_empty_slots()` gives the gentle hint.

**Rocket**: an Area2D plus sprites (body, door, hidden engine) and a [CPUParticles2D](https://docs.godotengine.org/en/stable/classes/class_cpuparticles2d.html) flame.
- `set_ready()` turns on the glow.
- When the player enters and it's not ready, it emits `needs_parts`.
- When the player enters and it is ready, it runs the launch as one sequential Tween: freeze and hide the player, close the door, show the engine as the parts snap on, ignite the flame and sound, then fly up off the screen. At the end it emits `launched`.

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

- Art: placeholder shapes and colors, or CC0 assets (for example, Kenney). Real art is a later decision.
- Audio: CC0 placeholder sounds (for example, Kenney or sfxr-generated) stored as `.wav` files under `audio/`.

## Testing

- No automated tests planned. There's no logic where bugs would be subtle, and feel is verified by playtesting.
- Every milestone must pass the headless check (`godot --headless --path games/astronaut --quit`) with no errors.
