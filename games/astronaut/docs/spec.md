# Astronaut Prototype — Design Spec (v1, draft)

## Purpose

A game for a 3-year-old (target: 18/11 birthday) that teaches movement, cause and effect, counting and patience, with no fail states. This v1 is a **gameloop prototype**: one planet, one world. It proves that the loop is fun and playable for a toddler before we add more content. Do not add features beyond what is listed here.

## Player profile and design rules

- Age 3, cannot read. A parent explains the game; the game never uses text or voice.
- **Very forgiving** is the top rule. When in doubt, make it easier.
- No death, no lives, no timers, no scores, no "fail" feedback of any kind.
- Moving, jumping and landing must feel good on their own, even when the child isn't trying to progress.

## Core loop

1. The game boots straight into the world. No title screen or menus.
2. The astronaut starts at the bottom of a single-screen climbing world.
3. The child climbs and collects **3 engine parts**. A panel shows 3 empty slots that fill as parts are collected.
4. Once all 3 parts are collected, the rocket at the top lights up.
5. The child walks the astronaut into the rocket, and a short cinematic plays: the parts attach, a new engine appears, and the rocket lifts off.
6. The world resets and the child can play again.

## Controls

- Exactly 3 actions: `left`, `right`, `jump`.
- Primary input: a 3-button arcade box (USB encoder, seen by the PC as a gamepad).
- Keyboard fallback, mapped to the same actions: arrow keys, A/D, and Space.
- Hold `left` or `right` to walk, and press `jump` to jump.
- A parent-only keyboard key (Esc) quits the game. The arcade box cannot quit.

## Movement (very forgiving)

- A floaty, generous jump with full air control.
- Coyote time: the child can still jump briefly after walking off an edge.
- Jump buffering: a jump pressed just before landing still happens.
- All tuning values (speeds, gravity, jump height, coyote and buffer windows) live in a Resource.

## World

- **A single static screen** with no camera scrolling. The whole world, including the rocket, is visible at all times.
- **A climb**: the astronaut starts at the bottom, and the rocket stands on a ledge at the top.
- Wide platforms and small gaps.
- **At least one moving platform** that the child has to wait for. This is the "patience" mechanic, and mistiming it costs nothing but a retry.
- The side edges of the screen are walls. The bottom has gaps into space.

## Falling

- Falling out of the bottom of the screen is not a death. The astronaut floats back up in a bubble and is placed on the last platform they stood on.
- Collected engine parts are kept.

## Engine parts

- Exactly 3 per world. Their positions are part of the level layout, not placed randomly.
- On pickup, the part flies into its slot on the panel, with a sound effect.
- Walking into the rocket before all 3 parts are collected makes the empty slots pulse gently. This is a hint, not a penalty.

## Rocket cinematic

- Very simple, with a target length of about 5–8 seconds. Input is disabled while it plays.
- The astronaut enters the rocket, the 3 parts fly from the panel onto it, a new engine appears, it ignites, and the rocket lifts off the top of the screen.
- Afterwards the world resets to its starting state, with all parts back in place.

## Presentation

- 2D, fullscreen, 1920×1080.
- Placeholder art (simple shapes or free assets) is acceptable for the prototype.
- Sound effects only, no music required: jump, land, part pickup, part-to-slot, bubble float-back, rocket slot pulse, engine attach, ignition, lift-off.

## Explicitly out of scope — do NOT build

- Enemies, hazards, death, lives, timers, scores.
- Any text or voice in the game.
- Title screen, menus, settings.
- Planet map, more planets or worlds, planet selection.
- Upgrades that change gameplay; persistent rocket state; saving.
- Currency, coins, shops.
- Joystick input; touch input; export to anything other than the dev PC.

## Definition of done

On the dev PC, using either the arcade box or the keyboard: the game boots into the world, and the child can climb and collect 3 parts, including using the moving platform. Falling out floats the astronaut back with parts kept. Entering the rocket with all 3 parts plays the cinematic, and the world then resets for another run. The project runs headless without errors.

## Later (not this build)

Recorded so the prototype doesn't block it, not to be built now:
- 3 planets × 3 worlds.
- After the cinematic, a planet map. `left` and `right` move the rocket between planets, `jump` lands on one, and each rocket upgrade unlocks new planets.
- Planets that feel different (for example, low gravity).

## Open questions (proposed defaults, need owner sign-off)

1. **Jump height:** fixed, with no hold-to-jump-higher. Toddlers don't control press duration well. *Proposed: fixed.*
2. **Respawn point:** the last platform stood on, rather than checkpoint objects. It's simpler and loses less progress. *Proposed: last platform.*
3. **Godot version:** pin the version installed on the dev PC.
