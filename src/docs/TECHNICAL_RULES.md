# rocketShooter — Technical Rules

## Client / Server Authority

Server-authoritative:

- currencies
- progression
- rewards
- upgrades
- purchases
- persistent data
- important run results

Client primarily handles:

- input
- camera
- UI
- presentation
- local effects

Validate RemoteEvent and RemoteFunction requests.

Never trust client-provided currency, reward, purchase, progression,
or unrestricted gameplay values.

---

## Flight State

The current prototype distributes flight state across client and server code.

PHASE 0 should establish a reliable lifecycle before adding more mechanics.

Conceptually:

    Idle
      → Aiming
      → LaunchPending
      → Flying
      → Result
      → Returning
      → Idle

Exact implementation may differ after analysis.

A previous run must never be able to modify or clean up a newer run.

Delayed tasks, event connections, effects and physics changes must belong
to the correct run lifecycle.

---

## Existing Data

Known persistent fields:

    Gold
    Trophies
    PowerLvl
    BoostLvl
    MaxDistance

Preserve compatibility.

When adding fields:

- provide defaults
- preserve old saves
- validate loaded values
- handle failures

Never reset existing data without explicit approval.

A failed DataStore load must not silently become a valid empty save that
can overwrite existing player progress.

---

## Monetization

Use official Roblox MarketplaceService APIs.

Developer Products require server-side receipt fulfillment.

Game Pass ownership must be verified through Roblox APIs.

Keep Product and Pass IDs centralized.

Never trust client purchase claims.

---

## Rojo

Rojo is already configured.

Current known Rojo source:

    src/client/Main.client.luau
    src/server/DataManager.server.luau

Do not rerun project initialization.

Do not modify `default.project.json` or expand Rojo ownership without
a concrete reason.

Studio reference scripts under `reference/` are NOT currently Rojo-managed.

---

## Architecture

Incremental modularization is encouraged when a real responsibility appears.

Possible future boundaries:

    Flight
    Cannon
    Levels
    Regions
    Rings
    Obstacles
    Economy
    Upgrades
    Equipment
    Assets
    Monetization

These are conceptual responsibilities, not mandatory modules.

Do not create architecture merely for appearance.

---

## Generated Content

Generated level content should have clear ownership.

Prefer a dedicated runtime container conceptually similar to:

    Workspace
      └─ GeneratedWorld

This allows regeneration and cleanup without damaging hand-authored content.

Determine the actual hierarchy before implementing it.

---

## Performance

Avoid:

- unnecessary per-frame loops
- many independent Heartbeat connections
- uncontrolled physics
- excessive unanchored parts
- unnecessary replication
- permanently growing generated worlds

Prefer centralized systems where they provide a concrete benefit.

---

## Verification

Important changes should consider:

- first launch
- repeated launches
- aim cancellation
- reset/death
- respawn
- return to spawn
- multiple players
- event cleanup
- delayed task cleanup
- generated-content cleanup
- DataStore failure
- invalid Remote arguments
- purchase processing
- long-distance performance

Always distinguish:

    implemented
    code-inspected
    automatically verified
    Studio play-tested

Never fabricate verification.
