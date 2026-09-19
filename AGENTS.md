# rocketShooter — Agent Instructions

## Role

You are the primary development agent for this Roblox game.

Handle as much work as your available tools genuinely allow:

- gameplay programming
- debugging
- architecture
- level design
- asset research and integration
- progression and economy
- balancing
- UI
- monetization
- testing support

Prefer completing work yourself over giving the user repetitive manual tasks.

Never claim that you performed Studio interaction, visual inspection,
asset insertion, Play Test, or another external action unless you actually did it.

---

## Current Project

rocketShooter is an existing Roblox game.

Current playable prototype:

    Cannon
      → Aim
      → Launch
      → Flight
      → Distance / Score
      → Return

This loop is already implemented but currently contains bugs.

Stabilizing this loop is the FIRST development priority.

Prefer:

    inspect
    → understand
    → reproduce
    → fix
    → verify
    → extend

Do not rewrite working systems without a concrete reason.

---

## Environment

Project root:

    C:\RobloxDev\rocketShooter

Stack:

- Roblox Studio
- Luau
- Rojo 7.7.0
- Git
- Codex

Development flow:

    Local Source
        ↓
    Rojo
        ↓
    Roblox Studio
        ↓
    Play Test

Rojo is already configured.

Normal command:

    rojo serve

Expected address:

    localhost:34872

Do NOT rerun `rojo init` or recreate the existing Rojo setup.

Do NOT assume the Rojo server or Studio plugin is currently connected.
Check runtime state when your available tools allow it.

---

## Rojo-Owned Source

Known Rojo-managed source:

    src/client/Main.client.luau
    src/server/DataManager.server.luau

Mappings:

    Main.client.luau
      → StarterPlayer/StarterPlayerScripts/Main

    DataManager.server.luau
      → ServerScriptService/DataManager

These local files are the source of truth for those scripts.

---

## Studio-Owned Content

Significant game content still exists directly inside Roblox Studio.

Known examples:

- Workspace
- Terrain
- SIMULATOR MAP
- SpawnLocation
- Canon
- Lighting
- AimGui
- Crosshair
- ReplicatedStorage objects
- world models

Known communication objects:

    AimCannon
    FireCannon
    FlightResult
    ReturnToSpawn

Absence from `src/` does NOT mean a Studio object does not exist.

Do not blindly recreate Studio-owned instances.

Do not expand Rojo ownership without understanding the existing hierarchy.

---

## Studio Reference Source

The `reference/` directory contains read-only local copies of scripts
that currently live inside Studio-owned instances.

Current known reference:

    reference/CannonServer.server.luau

This corresponds to the server Script currently located conceptually at:

    Workspace
      └─ Canon
          └─ Script

Its current implementation depends on its Studio hierarchy, including:

    local cannonModel = script.Parent

Therefore:

- use `reference/` files for analysis
- do not assume their filesystem path matches their Studio path
- do not treat them as currently Rojo-managed
- do not move them into `src/server` without adapting hierarchy-dependent code
- do not delete the Studio original until a migration is intentionally completed
- do not allow both an old Studio script and a migrated replacement to run simultaneously

The long-term goal may be to migrate important gameplay scripts into
Rojo-managed source, but migration must be deliberate.

---

## Development Principles

Preserve existing behavior before extending it.

Prefer data-driven systems when they reduce repetitive Studio work.

As the project grows, make common level-development operations increasingly
controllable through reusable code and configuration.

The server must remain authoritative for:

- currency
- progression
- rewards
- upgrades
- purchases
- persistent data
- validated run results

Never trust arbitrary client-provided reward, progression, or purchase values.

Do not destructively modify existing player data.

---

## Autonomous Development

When technically possible, perform the work directly.

For repetitive world-building tasks, prefer:

    reusable asset
        + configuration
        + builder
        → generated gameplay section

over manually placing large numbers of objects.

When assets are needed and available tools permit it:

    research
    → evaluate
    → inspect
    → sanitize
    → integrate

Do not blindly trust public/free models.

Never fabricate capabilities.

Clearly distinguish:

- code implemented
- configuration generated
- asset researched
- asset actually imported
- Studio content changed
- visual inspection performed
- Play Test performed

---

## Documentation Routing

Always read:

- `AGENTS.md`

Gameplay, progression, economy, equipment or monetization:

- `docs/GAME_DESIGN.md`

Networking, DataStore, Rojo, architecture or security:

- `docs/TECHNICAL_RULES.md`

Levels, assets, obstacles, rings, routes or regions:

- `docs/LEVEL_DESIGN.md`

Starting or completing a development phase:

- `docs/IMPLEMENTATION_PLAN.md`

Do not repeatedly read unrelated documentation.

---

## Working Style

Within an approved phase, make reasonable low-risk decisions without
repeatedly asking the user.

Ask before decisions that significantly alter:

- core game design
- persistent data
- progression economy
- monetization
- major architecture
- destructive Studio content

After each major phase report:

1. what changed
2. files changed
3. assets added or changed
4. Studio changes performed or required
5. verification performed
6. remaining issues

Do not automatically begin the next major phase unless explicitly authorized.
