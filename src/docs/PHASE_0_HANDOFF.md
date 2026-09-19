# PHASE 0 implementation handoff

Local implementation and mock-engine regression checks completed on 2026-09-20.
Studio interaction, live DataStore calls, visual inspection and Play Test have NOT been performed.
PHASE 1 has not started. PHASE 0 acceptance still requires the Studio checklist below.

## Studio cutover (required, in this order)

1. Stop any running Play/Run session. Do not hot-reload this migration into a running game.
2. Save a backup of the current Place. Keep `Workspace > Canon > Script` as the original backup.
3. In EDIT mode, set that original Script's `Enabled` property to false (equivalently `Disabled` to true). Do not delete Canon, Cylinder, LaunchPoint or its ProximityPrompt.
4. Connect the existing Rojo project and complete sync. No Rojo reinitialization or project mapping changes are needed.
5. Confirm ServerScriptService has exactly one enabled new `Cannon` Script and the `FlightService`, `PlayerData`, `RunPolicy`, `Remotes` ModuleScripts, alongside the updated `DataManager` Script. Confirm StarterPlayerScripts has updated `Main` and the `FlightClient`, `RemoteClient` ModuleScripts.
6. Confirm no enabled legacy Cannon Script remains in Workspace.Canon and no reference copy was manually inserted as another executable Script. Do not re-enable the legacy Script alongside the new one.
7. Start a NEW Play session. Output should contain `[Flight] PHASE 0 Cannon server active (Workspace.Canon)`. A `Startup blocked` warning means the new controller has not started; stop Play, resolve the reported legacy Script or missing hierarchy, then start again. Disabling the old Script mid-session does not restart the gated new controller.
8. Keep the original disabled until the checklist passes. Delete it only after successful verification and with a saved backup; deletion is not required for this implementation.

The startup gate refuses to register the new Cannon controller when an enabled Script exists under Canon. It does not modify the Studio original. It is not a runtime guard against someone deliberately enabling the old script after startup.

## Source ownership

- Modified: `src/client/Main.client.luau`, `src/server/DataManager.server.luau`.
- Added: `src/client/FlightClient.luau`, `src/server/Cannon.server.luau`, `src/server/FlightService.luau`, `src/server/PlayerData.luau`, `src/server/RunPolicy.luau`.
- Tests: `tests/run-local.cjs`, `tests/regression.luau` (not Rojo-mapped).
- `src/reference/CannonServer.server.luau` and `default.project.json` are unchanged.
- Workspace/Canon/map remain Studio-owned. `Cannon.server.luau` resolves `Workspace.Canon` explicitly; its own `script.Parent` is used only to locate sibling server modules.

## Lifecycle and preserved behavior

Idle -> Aiming -> LaunchPending (client's existing 0.3 second feedback) -> Flying -> Result -> Returning -> Idle.
Death, Reset, CharacterRemoving, invalid physics or an unavailable data session cancel the run without late rewards.
Each run has a server ID, exact Character reference, saved properties, effect/connection lifetime, contact cooldowns and one finalization flag.
Cannon occupancy is released at launch. Another player may aim while a previous player flies.
Return remains character recreation, using `LoadCharacterAsync`, followed by the existing SpawnLocation offset.

- Gauge speed, zones, 0.3 second feedback and legal multipliers 0.7 / 1 / 1.5 are preserved. Client-reported PERFECT is not cryptographically verified; server timing adjudication is intentionally out of scope.
- Launch speed remains `(220 + PowerLvl * 30) * multiplier`.
- Distance remains the floored maximum 3D displacement from LaunchPoint. The first second is now sampled too; launch offset remains eight studs. The historical `m` display remains, although the quantity is studs.
- Gold remains `floor(distance * 1.5)`.
- Trophies remain `floor(distance / 300)` plus five for each existing TargetZone within XZ radius 40 at a normal landing. The original radius is intentionally preserved instead of changing the reward geometry.
- MaxDistance remains the maximum recorded distance.
- Ring and bomb velocity formulas and cooldown durations are preserved. Effects require a current live Flying run and a nearby root; cooldowns belong to that run.
- Physics is restored on server lifecycle transitions, not a standalone six-second timer. The server applies launch velocity once; the client controls presentation/pose.
- Character transparency, collision, WalkSpeed, UseJumpPower, JumpPower, JumpHeight, AutoRotate, PlatformStand, anchored state and local animation Disabled state are restored from snapshots where applicable.

Landing checks start after one second, require 0.15 seconds of grounded confirmation, and use FloorMaterial with a collidable-ground raycast fallback. Airborne speed below three no longer manufactures a landing. A 120-second aim timeout releases occupancy; a 120-second flight timeout aborts without reward and returns the character to its pre-entry position. These bounds and grounding behavior need Studio tuning if legitimate runs approach them.

## Studio development data (startup correction)

PlayerData no longer opens a DataStore at require time. Server RunService:IsStudio() together with GameId == 0 OR PlaceId == 0 selects `StudioMemory` mode before any storage access (GameId == 0 also covers unpublished templates with nonzero PlaceId). Each player receives in-memory defaults and can earn rewards and buy upgrades. There are zero GetDataStore/GetAsync/UpdateAsync calls, no autosave worker, and no persistent shutdown work. Progress is discarded on leave or Stop. `Player.DataMode` and server Output identify the mode.

Published Studio sessions and published production use `Persistent` mode. An API failure never selects memory fallback. Store acquisition now occurs inside the protected load/retry path; acquisition/read errors disable gameplay/save for the player rather than breaking ModuleScript loading.

## Data protection

Store `CannonGame_v3`, keys `Player_<UserId>` and fields Gold/Trophies/PowerLvl/BoostLvl/MaxDistance are unchanged.
No leaderstats are exposed as ready before a successful, validated load. Missing keys are accepted only after a successful GetAsync returning nil. Load errors or invalid saved fields never enable saving and disconnect the player with a message after bounded retries.
Purchases and rewards require a ready profile. Unknown saved fields and key metadata are preserved on UpdateAsync.
Saves are serialized per profile, retried up to three times, performed every 60 seconds and on leave/shutdown. UpdateAsync compares known persisted fields against the last loaded/saved snapshot and refuses conflicting writes. This is optimistic conflict detection, not a distributed session-lock implementation.
The old destructive ResetData remote returns false; the test reset button was removed. No existing data was reset by this work.
Server or network failure can still lose progress since the last successful save. Repeated write failures are logged; the implementation cannot guarantee persistence while DataStore is unavailable.

## Remote initialization

`src/server/Remotes.luau` ensures five RemoteEvents (AimCannon, FireCannon, FlightResult, ReturnToSpawn, FlightState) and two RemoteFunctions (BuyUpgrade, ResetData) directly in ReplicatedStorage. DataManager calls Ensure BEFORE requiring PlayerData/FlightService; Cannon also ensures them independently. Existing correctly typed instances are reused, missing ones are created, and duplicate names/wrong classes produce explicit errors without replacement. ResetData remains inert.

`src/client/RemoteClient.luau` resolves the six currently used remotes with one 15-second total deadline and type checking. Failure logs the missing name and stops Main initialization; there is no unlimited remote wait. FlightClient receives the already resolved table. Shop data initialization also has a finite wait.

## Remote protocol

- AimCannon C->S: yaw, pitch, runId. Owner/current Character/Aiming, numeric finite yaw [-30,30], pitch [-5,45], at most 40 accepted updates/sec. Client sends at approximately 30/sec.
- AimCannon S->C: enabled, Canon, runId, Character.
- FireCannon C->S: multiplier, runId. Exact legal values and current live occupant/run required. State transition prevents replay.
- FireCannon S->C: velocity, runId, Character, original property snapshot. Client does not reapply velocity.
- FlightResult S->C: distance, gold, trophies, record, runId, Character. Only normal valid finalization emits one result.
- FlightState S->C: state, runId, Character, optional reason. Added solely for lifecycle synchronization.
- ReturnToSpawn C->S: runId. A current Result may return; an Aiming/Flying request safely cancels without reward before returning. Returning rejects duplicate requests before character loading yields.
- BuyUpgrade: existing Gold/Trophy arguments, server cost calculation, data readiness and 0.2 second throttle.
- ResetData: inert, returns false.

## Gimmicks ownership

The builder deletes only its own `Phase0Generated` children. If a Studio-saved layout with BoosterRing/ObstacleBomb/TargetZone parts exists directly under Gimmicks, it reuses that layout without generating duplicates and logs a warning. Existing ring/bomb callbacks are attached to the new flight validator. A partial saved layout is preserved as-is, not silently filled out. Verify its intended completeness and that other Studio scripts do not also drive the same parts.

## Verification performed

- Luau 0.739 compile checks for local source.
- RunPolicy static analysis with luau-analyze.
- Rojo 7.7.0 build to a scratch rbxlx, not the user's Place.
- 75 regression assertions execute the actual production server/client modules against a mock engine: failed/malformed/late loads, conflicting and failed saves, upgrades, rewards, multiplayer occupancy, old-run requests, death/respawn/return cancellation, properties, active-run gimmicks, client timers/connections/results and migration gating. Added startup coverage simulates GetDataStore throwing the exact unpublished-place error, verifies zero storage access in memory mode, verifies persistent failure protection, checks the original four-remote inventory and idempotent creation, and runs integrated unpublished DataManager/Cannon flight/reward/return.

Re-run locally: `node tests/run-local.cjs <absolute-path-to-luau.exe> <scratch-output-directory>`.
This does not simulate Roblox physics, replication, network ownership timing, real DataStore or Studio lifecycle scheduling.

## Studio Play Test acceptance checklist

- Unpublished local rbxl: no publishing or API enablement required. Confirm StudioMemory Output, DataReady=true, default stats, full flight loop, and reset to defaults after Stop/restart.
- Published persistence tests: use a separate test universe. With API access unavailable, load refusal/kick is expected; it must not silently switch to memory mode.
- Confirm all seven remotes exist once in ReplicatedStorage and BuyUpgrade infinite-yield warnings are gone. Missing/wrong remotes must yield a named, bounded initialization warning.
- First launch, each gauge tier, 10+ full return/re-entry cycles; one reward/result per normal run.
- A flies while B aims/fires. A's result/death/return must not release B's occupancy.
- Reset/death while aiming, during click feedback, in flight and after result. No locked prompt/camera/mouse and no late reward.
- Landing before and after six seconds, steep shots near apex, slopes, R6/R15, accessories, transparent and originally noncolliding parts.
- Inspect network ownership after unanchor and test latency; initial impulse must not be reapplied by the client.
- Repeat Return clicks and replay obsolete run IDs; no newer character/run changes.
- Rings/bombs affect only active flights; repeat-touch cooldown, high-speed contact, and movement validation tolerate legitimate boosts.
- Verify TargetZone +5 and distance trophies, existing upgrade prices and MaxDistance after rejoin.
- Inspect Gimmicks for duplicated or partial Studio-saved layouts.
- On isolated test data, simulate load/write errors and confirm old saved progress remains intact. Check Output warnings and shutdown save behavior.

## Remaining limits

Live Studio behavior and migration are unverified. Client-owned physics has finite/displacement checks with generous gravity/boost allowances, not a complete anti-cheat. The gauge still trusts a client-selected legal tier as requested. The prototype's unit label and 3D/radius reward definitions remain. Optimistic persistence is not a session-lock framework. No new steering, LevelBuilder, economy or PHASE 1+ feature was added.
