# RocketShooter

Roblox / Luau / Rojo 7.7.0 project. Current development snapshot: 2026-10-05.

## Current playable loop

Train or click for XP → step onto the rocket pad → rise and steer → break targets → dive → land on a trophy zone or return → upgrade / rebirth / equip a cosmetic rocket.

Implemented systems include server-authoritative progression, passive/manual/automatic XP, training toilets, rebirth, trophy zones, gold-ring XP events, altitude scenery, destructible targets, flight effects, responsive HUD and five rocket skins. Tutorial and paid products are deferred. The OP auto-click mode is a free prototype preview, not a connected purchase.

## Open the existing game

Open `rocketShooter.rbxl` in Roblox Studio, then run:

```powershell
rojo serve default.project.json
```

Connect Studio's Rojo plugin to `localhost:34872` and review the sync diff. Source code lives in `src/`; the place also contains Studio-owned map, terrain, lighting and assets. A generated Rojo build does not replace the complete hand-authored place.

```powershell
rojo build default.project.json -o rocketShooter.rbxlx
node tests/run-local.cjs <path-to-luau.exe>
```

The local regression runner mocks the Roblox engine; it does not validate device performance, networking or Studio physics. Unpublished Studio sessions use temporary StudioMemory without DataStore reads/writes. Published experiences use persistent storage and need separate save/rejoin validation.

## Development records

- `src/docs/DEVELOPMENT_SNAPSHOT_2026_10_05.md`: consolidated checkpoint and remaining work.
- `src/docs/GAME_DESIGN.md`: design and successive revisions.
- `src/docs/TECHNICAL_RULES.md`: authority, persistence, Rojo and implementation contracts.
- `src/docs/IMPLEMENTATION_PLAN.md`: phase history.
- `AGENTS.md`: instructions for development agents.

The binary place is tracked because it preserves Studio-owned content. Generated builds, test scratch, logs, lock files and credentials are ignored. Keep source updates and place saves synchronized; do not commit a transient Play session as the development place.
