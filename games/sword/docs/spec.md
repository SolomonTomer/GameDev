# Sword Prototype — Design Spec (v1)

## Purpose

A minimal, buildable prototype to prove the core loop is fun before adding complexity. This document is the complete build spec. Do not add features beyond what is listed here.

## Core loop

1. Player is dropped into an endless arena.
2. Enemies spawn and attack; the player fights them.
3. Enemy spawn rate increases steadily over time (pressure escalates).
4. The player dies — permadeath, a single death ends the run.
5. On death, the run's earned tokens are banked and the player returns to the lobby.
6. In the lobby, the player spends tokens on the talent tree.
7. Player starts a new run.

## Player

- Single starting weapon for this build: **sword** (melee, close range).
- One default character model/controller.
- Basic movement plus a melee attack.

## Enemies

- **One** enemy type only.
- Enemies pursue the player and deal contact/melee damage.
- Difficulty scales via **spawn rate over time**, not via new enemy types or stat scaling.

## Arena

- Single endless/open arena. No rooms, no level transitions.

## Death and progression model

- **Permadeath**: one death ends the run.
- Run rewards are earned as **tokens**.
- Tokens persist across runs (meta-progression) and are spent in the lobby.

## Lobby

- Reached on death.
- Displays banked token count.
- Hosts the talent tree UI where tokens are spent.

## Talent tree (melee only for this build)

- **One** tree, for the melee/sword archetype.
- Structured as a **dependency graph**: deeper nodes require their prerequisite nodes to be unlocked first.
- **Cost rule: 1 token = 1 talent point; every node costs exactly 1 point.**
- Node effects (the actual stat/ability content) are not yet authored. Implement the tree as a generic, data-driven dependency graph so nodes can be filled in later. Provide a small placeholder set of nodes to make the system testable.

## Currency

- **Tokens** are the only currency in this build.
- Earned during a run, banked on death, spent in the lobby on talent nodes.

## Explicitly out of scope — do NOT build

These are named only to mark the boundary. Do not implement them in this prototype:

- Bosses of any kind.
- Additional weapons/archetypes (bow/hunter, wand/mage). Architecture may leave room for them, but only the sword ships here.
- Classless / shared-tree drift across archetypes.
- Talent respec and respec fees.
- Token-to-boss-modifier risk/reward mechanic.
- XP or any second currency.
- Story, narrative, or other complex systems.

## Definition of done

A player can start with the sword, enter the arena, fight the single enemy type under increasing spawn pressure, die, bank tokens, return to the lobby, spend tokens on the placeholder melee tree respecting prerequisites, and start another run.
