# Astronaut Prototype — Design Spec (v1)

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
5. The child walks the astronaut into the rocket. In the same screen, the astronaut gets in, the door closes, the engine starts and the rocket flies up and away.
6. On to the next level. In this prototype that is the same world, reset.

## Controls

- Exactly 3 actions: `left`, `right`, `jump`.
- Primary input: a 3-button arcade box (USB encoder, seen by the PC as a gamepad). Until the box arrives, standard gamepad buttons stand in, and they get remapped once it does.
- Keyboard fallback, mapped to the same actions: arrow keys, A/D, and Space.
- Hold `left` or `right` to walk, and press `jump` to jump. Jump height is fixed, so holding the button longer does not jump higher.
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
- Platforms are solid from every side, like real objects. The astronaut cannot jump up through them from below.
- **At least one moving platform** that the child has to wait for. This is the "patience" mechanic, and mistiming it costs nothing but a retry.
- **Closed world**: a solid floor at the bottom and walls at the side edges of the screen. Nothing can fall out of the world.

## Falling

- Falling just means dropping to a lower platform or the floor. The child carries on from where they landed, with no respawn and nothing lost.
- Level-design rule: lay out ledges so a slip usually lands one step down, not all the way back to the floor.

## Engine parts

- Exactly 3 per world. Their positions are part of the level layout, not placed randomly.
- On pickup, the part flies into its slot on the panel, with a sound effect.
- Walking into the rocket before all 3 parts are collected makes the empty slots pulse gently. This is a hint, not a penalty.

## Rocket launch

- Plays in the world screen, with no separate cutscene or camera move. Input is disabled while it plays, which takes a few seconds.
- The astronaut gets into the rocket, the door closes, the 3 parts snap on as a new engine, the engine ignites and the rocket flies up off the top of the screen.
- Afterwards the world resets to its starting state, with all parts back in place.

## Presentation

- 2D, fullscreen, 1920×1080.
- Placeholder art (simple shapes or free assets) is acceptable for the prototype.
- Sound effects only, no music required: jump, land, part pickup, part-to-slot, empty-slot pulse, door close, engine attach, ignition, lift-off.

## Explicitly out of scope — do NOT build

- Enemies, hazards, death, lives, timers, scores.
- Any text or voice in the game.
- Title screen, menus, settings.
- Planet map, more planets or worlds, planet selection.
- Upgrades that change gameplay; persistent rocket state; saving.
- Currency, coins, shops.
- Joystick input; touch input; export to anything other than the dev PC.

## Definition of done

On the dev PC, using either the arcade box or the keyboard: the game boots into the world, and the child can climb and collect 3 parts, including using the moving platform. Falling lands the astronaut lower in the world with parts kept. Entering the rocket with all 3 parts plays the launch, and the world then resets for another run. The project runs headless without errors.

## Later (not this build)

Recorded so the prototype doesn't block it, not to be built now:
- 3 planets × 3 worlds.
- After the launch, a planet map. `left` and `right` move the rocket between planets, `jump` lands on one, and each rocket upgrade unlocks new planets.
- Planets that feel different (for example, low gravity).
- Open worlds with no floor: falling out floats the astronaut back in a bubble to the last platform they stood on.
