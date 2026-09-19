# rocketShooter — Implementation Plan

Complete major phases in order unless explicitly instructed otherwise.

After completing a major phase:

    report
    → verify
    → stop

Do not automatically begin the next major phase.

---

## PHASE 0 — Stabilize & Consolidate Existing Flight Loop

CURRENT PRIORITY.

Existing gameplay:

    ProximityPrompt
      → Cannon Occupancy
      → Aim
      → Launch
      → Flight
      → Flight End
      → Distance / Reward
      → Result
      → Return

Relevant current source includes:

    src/client/Main.client.luau
    src/server/DataManager.server.luau
    reference/CannonServer.server.luau

The Cannon server reference currently represents a Studio-owned Script
inside the Canon model.

### Goal

Make the existing loop reliable before adding new gameplay.

Inspect and stabilize:

- cannon occupancy
- aiming
- fire request
- timing multiplier validation
- launch physics
- character visibility/collision
- network ownership
- camera
- flight state
- flight end conditions
- distance calculation
- reward calculation
- FlightResult
- ReturnToSpawn
- death/reset
- repeated launches
- delayed tasks
- stale state
- duplicate connections
- multiple players
- DataStore failure behavior

Server and client must agree on the lifecycle of a run.

A previous run must not be able to affect a newer run.

### Migration

During PHASE 0, determine whether the Studio-owned Cannon server Script
should be migrated into Rojo-managed source.

If migration is beneficial:

1. remove dependence on accidental `script.Parent` filesystem placement
2. preserve existing Canon behavior
3. establish explicit references/ownership
4. migrate deliberately
5. verify the Rojo-managed replacement
6. only then remove/disable the old Studio Script

Never run duplicate server implementations simultaneously.

### Acceptance

The player can repeatedly:

    enter
    → aim
    → launch
    → fly
    → finish
    → receive exactly one result/reward
    → return
    → repeat

without state corruption.

DataStore failures must not overwrite valid existing progress with
unintended defaults.

---

## PHASE 1 — Horizontal Flight Control

Add meaningful left/right steering.

Keep launch power and trajectory relevant.

Do not create unrestricted free flight.

---

## PHASE 2 — Level Builder Foundation

Determine:

- actual flight direction
- coordinate conventions
- distance/progression metric
- generated-content ownership

Create the minimum data-driven system needed for reusable flight sections.

Target:

A configuration can generate a deterministic simple section.

Do not overbuild.

---

## PHASE 3 — Asset Registry

Create reusable asset references.

Start only with assets required for upcoming gameplay.

Reuse suitable existing assets.

Research/integrate external assets when available tools permit it.

---

## PHASE 4 — Obstacles

Use LevelBuilder to create meaningful obstacle sections.

Steering should now affect run success.

---

## PHASE 5 — Rings / Combo

Implement:

- reusable rings
- RingSection generation
- detection
- combo
- combo break
- reward integration

Courses should be configurable.

---

## PHASE 6 — Run Result Model

Clearly separate:

    Distance
    Score
    Reward

Important reward calculation must remain server-authoritative.

---

## PHASE 7 — Gunpowder Gathering

Create the first ground-resource activity.

Gunpowder becomes the primary direct cannon/rocket progression resource.

---

## PHASE 8 — Cannon Upgrade

Connect:

    Gunpowder
        → stronger launch

Start with a small number of meaningful stats.

---

## PHASE 9 — Flight Resource

Introduce a resource earned through successful flight.

Primary purpose:

    improve Gunpowder acquisition

Complete the circular progression loop.

---

## PHASE 10 — Mining Progression

Introduce appropriate improvements such as:

- speed
- yield
- capacity

Do not eliminate the gathering loop.

---

## PHASE 11 — Regions

Create data-driven distance regions with distinct gameplay and content.

---

## PHASE 12 — Region Content

Use LevelBuilder + AssetRegistry to create coherent region content.

Include appropriate:

- environment
- obstacles
- rings
- rewards
- assets

---

## PHASE 13 — Route Choice

Introduce meaningful branching:

    SAFE
    SKILL
    RESOURCE

Different routes should pursue different objectives.

---

## PHASE 14 — Equipment Builds

Introduce cannon/rocket identities such as:

    Power
    Control
    Combo
    Resource

Avoid pure vertical replacement.

---

## PHASE 15 — Collection

Expand:

- cannons
- rockets
- skins
- trails
- effects
- collectibles

---

## PHASE 16 — Landing Challenges

Make landing an additional skill and reward opportunity.

---

## PHASE 17 — Dynamic Events

Add controlled run variation.

---

## PHASE 18 — Multiplayer

Add competitive/cooperative interaction after the core loop is stable.

Design counterplay before disruptive mechanics.

---

## PHASE 19 — Monetization Infrastructure

Implement robust MarketplaceService systems.

Separate:

- Developer Products
- Game Passes
- Cosmetics

Keep fulfillment server-authoritative.

---

## PHASE 20 — Monetization Content

Potential initial products:

- cannon skins
- rocket skins
- trails
- launch effects
- temporary boosts
- mining convenience

Do not remove the reason to play.

---

## PHASE 21 — Retention

After the core loop is proven:

- missions
- daily rewards
- milestones
- achievements
- records
- leaderboards
- rotating challenges
