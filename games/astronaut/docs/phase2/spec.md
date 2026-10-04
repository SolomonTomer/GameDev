# Astronaut Phase 2 — Five Earth Levels (spec)

## Purpose

Grow the prototype from one world into up to 5 Earth levels, ordered from simple to complex, that teach a 3-year-old the basics in order: walking, jumping, riding a moving platform, counting, then everything together with the rocket. Each level adds one idea.

Same player, same rules as phase 1 (`../spec.md`): age 3, no text, very forgiving, no fail state. This spec changes phase 1 only where it says so below. Target: the 18/11 birthday.

## What changes from phase 1

- One world becomes **5 levels**, played in order.
- Physics change to an **Earth feel** (below). The existing climb is re-laid out as level 5.
- The engine parts become **stars**: one collectible everywhere, counted per level. In level 5 the 3 stars are what the rocket needs, and the launch beat where they snap on as the engine stays.
- Levels 1-4 end in a **flag**; level 5 ends in the **rocket**.
- Everything else (3 buttons, Esc quits, a single static screen per level, a closed world with a floor, sound effects only, no text) is unchanged.

## Physics: an Earth feel

- One physics setup for all 5 levels.
- Jump height about 2.75 tiles (176 px, about 2x his height), fixed: holding the button longer does not jump higher. It started at 2.5 tiles and was raised in the design phase: levels sit on a 64 px grid, and at 2.5 tiles a 2-tile step up would need more than the 75% budget below allows.
- Heavier gravity and a quicker arc: about 0.7 s in the air (target gravity about 2850 px/s², jump velocity about -1000 px/s). Final numbers are tuned by feel in the first milestone.
- Flat jump reach about 3.8 tiles at his running speed (350 px/s), plus the 0.2 s coyote time. Air control, coyote time and jump buffer stay as they are.
- Instant start and stop stay, with no momentum: stopping precisely at an edge is too hard at age 3.
- Why this feels like Earth: he no longer floats. The phase 1 jump (4 tiles, 1 s in the air) is moon-like, and it stays in git history for a future low-gravity planet.

## Forgiveness budget

Rules for laying out every level:

- A required jump never needs more than about 75% of the maximum. On the 64 px grid that means:
  - steps up of 1 or 2 tiles;
  - gaps of at most 2 tiles, including when combined with a 2-tile step up;
  - never a 3-tile step or a 3-tile gap.
- Platforms are wide. Falling still just means landing lower, with nothing lost.
- Every level is checked by simulation to confirm each required jump is reachable.

## Levels

| # | Teaches | What's in it | Stars | Goal |
|---|---|---|---|---|
| 1 | Walking | Flat ground, nothing else. Start on the left, flag on the right. | 0 | Flag, awake |
| 2 | Jumping | A few low hurdles, then a short staircase. Every rise is at most 1 tile. | 0 | Flag, awake |
| 3 | Waiting and riding; counting to 1 | One moving platform he rides over a wide gap, and 1 star. | 1 | Flag, off until the star |
| 4 | Platforming; counting to 2 | A short sequence of platforms at different heights with small gaps, and 2 stars. | 2 | Flag, off until both |
| 5 | Everything; counting to 3 | The climb: stepping platforms, a moving platform, 3 stars, and the rocket on the top ledge. | 3 | Rocket |

Level 5 is the phase 1 world re-laid out for the new jump: the old climb used 3-tile rises. Exact layouts are decided in the design phase.

## Flags

- Every Earth flag is red (Kenney's `flag_red`), with its two-frame wave animation. Other colors are left for other planets later.
- In levels with stars, the flag starts "off": the bare pole (Kenney's `flag_off`). When the last star goes in, the flag raises and starts waving, with a sparkle and a soft chime. In levels 1-2, which have no stars, the flag is awake from the start.
- Walking into an off flag makes the empty star slots pulse gently, as with the rocket. It is a hint, not a penalty.
- Touching an awake flag: input is disabled, he cheers with a little hop, the flag waves harder with sparkles and a happy jingle, then a quick fade to the next level. About 2.5 s in total.

## Stars and the panel

- A star is an outlined yellow star, drawn by us in the astronaut's style (the Kenney pack has coins but no star).
- Collecting a star flies it into a slot on the panel, with the existing pickup sound.
- The panel shows exactly as many slots as the level has stars; levels 1-2 show none.
- The level's goal (flag or rocket) stays off until every star is collected.

## Flow

- Boot into level 1. Each flag leads to the next level automatically.
- Level 5's rocket launch (as in phase 1) ends with a fade back to level 1.
- Nothing is saved. Stars reset when a level starts. Esc still quits.

## Sound

- Sound effects only.
- New: flag raise, level complete.
- Reused: star pickup and the rocket sounds.

## Explicitly out of scope — do NOT build

- Level select, menus, a title screen, level numbers or any text.
- Saving, or progress that survives a restart.
- Scrolling or a camera.
- New mechanics: springs, ladders, bouncy mushrooms, one-way platforms, enemies, hazards.
- Other planets or worlds, per-level physics, momentum or acceleration.
- More than 5 levels.

## Definition of done

On the dev PC, with the arcade box or the keyboard:

- The game boots into level 1, and walking to each flag moves on to the next level.
- In levels 3-5 the goal stays off until every star is collected.
- Level 5's launch returns to level 1.
- Every required jump in every level fits the forgiveness budget, verified by simulation.
- The physics match the Earth feel above.
- The project runs headless without errors.

## Schedule note

If time runs short before 18/11, cut level 4 first. Levels stay additive, and the rocket level is always last.
