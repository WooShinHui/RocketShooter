# F0.5 — Steering physics regression fix

2026-09-27. F0 placement, progression, economy, Ring/Cloud configuration and presentation unchanged.

## Cause and minimal change

HorizontalSteering.Step already preserved input velocity Y and its launch-axis forward component. It did not cache launch Y or alter workspace.Gravity. FlightService, however, assigned the flying character to the client and then read its replicated AssemblyLinearVelocity on a server Heartbeat (20 Hz), added a lateral component, and wrote the entire XYZ snapshot back. The latest server observation was not the current client integration state; repeated absolute writes could restore an older upward Y, effectively opposing gravity. F0's continuous axis 0.7 test reproduced this with altitude 413.35 at Forward 300 and peak 943.71.

FlightService now sets explicit server network ownership for the Flying run. Existing cleanup still restores automatic ownership. Launch impulse, input validation, update cadence and lifecycle remain unchanged. HorizontalSteering.Apply computes the same bounded lateral delta but applies only `right * delta * AssemblyMass` via ApplyImpulse. It never writes an absolute steering velocity or emits Y/forward impulse. Owner and actuator now run in one simulation; no network transfer every steering tick and no new client physics authority.

Runtime source changes: FlightService.luau and HorizontalSteering.luau only. Regression mock/test changes: tests/regression.luau. No tuning values changed.

Roblox ownership/API reference: https://create.roblox.com/docs/physics/network-ownership and https://create.roblox.com/docs/reference/engine/classes/BasePart.

## Studio A/B

Same L25, GOOD=1, target pitch40/yaw-22; actual world pitch about39.75/yaw-23. Each launch velocity exactly `(69.30069, 261.52908, -163.33028)`. Server GetNetworkOwner returned nil for every run. Ring triggers were active; all runs recorded zero Ring contacts. Temporary input driver used the existing steering adapter and validated remotes. No position, velocity, gravity or destination values were changed by the driver.

| Run | Max altitude (Heartbeat) | Result Forward | Result Flight Time | Max launch-relative lateral displacement | Outpost |
|---|---:|---:|---:|---:|---|
| A: neutral steering | 198.290726 | 581 | 4.932855s | 1.6624 | Yes |
| B: held +0.7 steering | 198.287018 | 556 | 4.249823s | 114.6516 | No, steered outward |
| C: neutral then -0.7 after0.8s | 198.290726 | 570 | 4.483229s | 87.5618 | Yes |

Peak difference A/B: **0.003708 studs**. FlightTime is the unchanged lifecycle duration through landing finalization, not purely ballistic airtime; different landing paths produce different final durations/distances. The vertical comparison below is before landing.

| Sample | A time / Y velocity | B time / Y velocity |
|---|---|---|
| Initial post-simulation | 0.0007s / 258.2591 | 0.0004s / 258.2591 |
| ~0.5s | 0.5152s / 157.7060 | 0.5000s / 160.1585 |
| ~1s | 1.0160s / 58.7885 | 1.0001s / 62.0585 |
| ~1.5s | 1.5157s / -39.3115 | 1.5159s / -39.3115 |
| ~2s | 2.0156s / -137.4114 | 2.0000s / -134.1414 |

Sampling is frame-quantized; the small velocity differences match the sampling-time offsets under gravity196.2. Sustained steering no longer creates a 400+ altitude excursion.

All three runs reached Result, retained Health100, returned to Idle, and the subsequent run started. C discovered the unchanged Outpost with Ring0: RewardDistance577, Forward570, MaxAltitude198, FlightTime4.48s. Destination center/bounds remain (Forward300, Lateral65, Altitude210) / (45,60,30).

## Automated verification

Regression **315** passes (previous310 + five invariants): continuous applied impulse with gravity preserves Y/forward; identical predicted altitude; nonzero lateral displacement; no Y/forward impulse; gravity advancing after sampling cannot be overwritten by stale Y. Existing service integration asserts explicit server ownership and exercises independent/stale runs, expiry and Result cleanup.

Luau compile **35 runtime files**; Rojo build and mapping checks pass. Local Studio testing does not measure remote multiplayer latency. Play stopped; runtime-only drivers and test levels were not saved. No next phase started.
