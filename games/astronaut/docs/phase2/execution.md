# Astronaut Phase 2 — Execution Plan

Implements `design.md` (phase 2). Each milestone is one branch made from the latest `main` and one PR into `main`. PRs are not stacked: the next milestone starts after the previous one is merged. Each ends with a summary covering what was built, how to playtest it, and any concerns.

| # | Milestone | Rough target | Status |
|---|---|---|---|
| P1 | Framework, Earth physics, level 1 | 10/10 | Done |
| P2 | Levels 2 and 3: jumping, riding, the first star | 17/10 | Done |
| P3 | Levels 4 and 5: platforming, the climb, the rocket | 27/10 | Done |
| P4 | Sounds and a full-run polish | 1/11 | Not started |

The targets leave about two weeks before 18/11 for your own playtesting. If time runs short, level 4 is cut first (spec).

## P1 — Framework, Earth physics, level 1

Steps:
1. Retune `player/movement_tuning.tres` to gravity 2850 and jump velocity -1000. Measure the real jump height and air time in a headless run.
2. Rename the collectible: `parts/` becomes `stars/` (Star, StarsPanel), and the panel gets `show_slots(count)`. It keeps its placeholder look until P2.
3. Add `level.gd` (Level) and the Goal interface. Rename the Rocket's signals to `needs_stars` and `completed`.
4. Build the Flag scene: atlas frames, `off` and `wave` animations, `awake_at_start`, `set_ready()` with the pop and sparkle, `needs_stars`, the celebration, then `completed`.
5. Add `celebrate()` to the player.
6. Rewrite `main.tscn` and `main.gd` as the sequencer: the `levels` array, the Fade layer, swapping levels, and wrapping after the last level.
7. Build `levels/level_1.tscn`: floor, a few decorations, the player and an awake flag. For now the sequence is just level 1, which loops.
8. Keep the phase 1 world out of the sequence. It can't be beaten with the new jump, and P3 re-lays it out as level 5.
9. Verify:
   - headless check;
   - the playtester walks level 1 to the flag, then sees the celebration, the fade and a fresh level 1;
   - the measured jump is about 175 px;
   - a full-resolution render.

Playtest: does the new jump feel like Earth without being hard? Tune `gravity` and `jump_velocity` in the Inspector. Is the flag clearly "the place to go"?

## P2 — Levels 2 and 3: jumping, riding, the first star

Steps:
1. Draw `stars/art/star.svg` and `stars/art/star_slot.svg`. Give the Star its art and a gentle bob, and give the panel slots their art.
2. Widen the moving plank to 3 tiles with thin 192×24 collision, using the `bridge` art.
3. Build `levels/level_2.tscn` (hurdles and stairs) and `levels/level_3.tscn` (two plateaus, the pit, the plank, the star, a flag that starts off) from the design's layouts.
4. Set the sequence to levels 1-3.
5. Verify:
   - the playtester runs each level's route with real inputs;
   - in level 3 the flag stays off until the star, then raises;
   - walking into the off flag pulses the slot;
   - a fall into the pit can be climbed back out of;
   - the plank never presses down on him;
   - renders.

Playtest: does he get over the hurdles? Does he wait for the plank, and does he notice the star filling its slot and the flag waking up?

## P3 — Levels 4 and 5: platforming, the climb, the rocket

Steps:
1. Build `levels/level_4.tscn`: the step and platforms A-D, two stars (one needs a jump), a flag that starts off.
2. Build `levels/level_5.tscn`, re-laying out the phase 1 world:
   - platforms P1-P3;
   - the elevator plank and the catch platform;
   - the rocket ledge with the rocket on it;
   - three stars (one needs a jump, one is collected on the ride).
3. Set the sequence to levels 1-5. After the rocket's `completed`, Main fades back to level 1.
4. Remove the phase 1 leftovers: the old world content and the now-unused part files.
5. Verify:
   - each level's route by simulation, with every jump inside the layout rules;
   - the stars gate the goal in levels 4 and 5;
   - the full sequence 1 → 5 → the launch → 1;
   - renders.

Playtest: does level 4 feel like a step up without frustration? Does the elevator ride and the rocket waking up mid-ride land as the climax?

## P4 — Sounds and a full-run polish

Steps:
1. Add `audio/flag_raise.wav` and `audio/level_complete.wav` from Kenney's CC0 audio packs, with the license kept next to them. If they can't be downloaded, synthesize simple tones with a small Godot script instead.
2. Wire the sounds into the Flag.
3. Run the whole loop twice by simulation. Tune the celebration and fade timings, and the plank speeds and pauses, if anything drags.
4. Update the spec and design if anything changed while building, and mark phase 2 done here.

Playtest: the whole game from boot, twice in a row. Does it feel like one journey, and does he want to go again?
