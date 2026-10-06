# PHASE 2 balance correction (2026-09-20)

No PHASE 3 work. Existing saved currencies, levels, records and DataStore schema remain intact.

## Shared tuning

`src/shared/BalanceConfig.luau` maps to **ReplicatedStorage.BalanceConfig (ModuleScript)**.
`src/client/FlightCamera.luau` maps to **StarterPlayer.StarterPlayerScripts.FlightCamera (ModuleScript)**,
then copies into PlayerScripts at spawn. FlightClient requires its sibling FlightCamera.
Server FlightService/PlayerData/RunPolicy and client Main/FlightCamera require the shared config.
The .luau file mapping determines ModuleScript type; do not also set $className on a file $path.

Old launch magnitude = (220 + 30 L) * timing. Range grew approximately with speed squared;
Gold = floor(1.5 * whole distance) while cost = floor(100 * 1.18^(L-1)).
At level 1, one baseline flight earned 402 G against a 100 G upgrade.
Rings multiplied the entire velocity by 1.35 + .08 * BoostLvl and added 40 upward,
amplifying both distance and altitude repeatedly.

New power = 240 + 14 * (L-1)^.72. Horizontal speed = power * cos(pitch) * timing.
Vertical speed = clamp(260 * sin(pitch) * (1 + .2*(timing-1)), -35, 135), independent of L.
Gold = floor(.4 * whole distance^.85).
Power cost = floor(120 + 30*(L-1) + 2*(L-1)^1.4).
Boost cost and Trophy rules remain unchanged. No client-supplied prices or rewards.
Rings add 18 + 6*log2(BoostLvl) horizontal speed, capped at launch horizontal speed * 1.35;
upward lift +25 observes a predicted apex budget of 110 above course GroundY.
Bomb behavior unchanged. Existing run validation, cancellation and exactly-once rewards unchanged.
Flight-only camera follows the launch heading from 26 behind/12 above, looking 65 ahead/14 down;
it disconnects and restores Custom camera on result/return/cancellation.

## Predictions (not measured Studio averages)

25-degree GOOD launch, gravity 196.2, audited barrel geometry, landing root Y=7.5,
flat ground, no ring/bomb/steering/slide. Distance is the existing 3D radial measure.
Runs = next upgrade cost / representative Gold; zero-balance whole runs round upward.

| Level | Old speed | Old distance | Old Gold | Old cost | Old runs | New speed | New distance | New Gold | New cost | New runs |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|1|250|268|402|100|0.25|244|267|46|120|2.61|
|5|370|559|838|193|0.23|275|308|52|253|4.87|
|10|520|1081|1620|443|0.27|300|340|56|433|7.73|
|20|820|2651|3975|2321|0.58|341|393|64|813|12.70|
|50|1720|11576|17364|332826|19.17|441|516|80|2054|25.68|

Old level 50 landing assumes hypothetical continued ground: actual existing course ends near 6048,
so a void recovery gives no normal landing reward. Predictions omit ground slide and engine contacts.
New baseline apex stays Y=46.77 versus old Y=44/78/139/322/1363.
L1->10 takes 44 baseline successful runs with carried coins (18.3 min only if a run averages 25 sec).
PERFECT/no-ring distance at L1/10/50: 431/551/838; required run equivalents 1.74/5.09/16.84.
Optimistic aligned GOOD rings at Boost 1: L1/10/50 range 357/499/968; runs 2.03/5.55/14.88.
Actual obstacle hits, timing, steering, floor friction and contact geometry change these results.
Gold integer rounding can cause small adjacent-level effort steps; the underlying curve increases.
Existing accumulated Gold is preserved and can still fund immediate upgrades; do not reset production data.

## Module loading incident

Studio audit confirmed FlightCamera existed as ModuleScript but BalanceConfig was MISSING,
despite a connected old Rojo session. Timed WaitForChild returned nil; require(nil) caused
FlightService/PlayerData/Main errors and downstream Cannon/DataManager failures.
The disk mapping/build were correct, but the serving session had not incorporated the new mapping.
Added explicit presence/class checks with synchronization instructions before require; no fallback economy.
Restart/reconnect the serving project after mapping changes. Existing Remotes are retained.

This session's old port 34872 process could not be stopped (Windows access denied), so a fresh
server was started with the explicit default.project.json on port **34873**. User approved plugin access.
Use the Studio session connected to that port for acceptance testing; do not connect to the stale session.

## Verification

26 Luau sources compile; 188 mock regression checks pass, including missing/wrong-type config cases.
Rojo build passes; tests/verify-rojo.ps1 verifies module type, location, uniqueness and nonempty source
in the actual build artifact. tests/balance.luau reproduces tables, timing/ring sensitivity and curve checks.
Studio verification completed on the maximized window with Rojo localhost:34873:
both actual Instances are ModuleScripts at the intended paths, including runtime PlayerScripts.FlightCamera.
Unpublished StudioMemory initialized; no require errors in the Play Output.
Real prompt/click launch (PERFECT) produced Aiming -> Flying -> Result,
627 distance / 95 Gold / 2 Trophies once, then the UI return button produced Returning -> Idle
and the character visibly returned to SpawnLocation. This is one smoke run, not statistical balancing.
The local test repositioned the character near the cannon before interacting; no persistent profile edit.
Play was stopped after verification. The opened rbxl reported read-only, so the Studio changes were
not saved over it; reconnect the fresh Rojo session when reopening. Source files are saved locally.
