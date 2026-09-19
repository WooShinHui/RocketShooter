# PHASE 1 — Horizontal Flight Control

PHASE 0 was accepted by the user after Studio testing. This phase adds only bounded
horizontal correction; no PHASE 2 Level Builder, world content, economy or camera redesign.

## Controls and physics

During Flying, A / Left Arrow requests -1 and D / Right Arrow requests +1.
Opposing keys produce zero. Release removes thrust and slowly decays lateral drift.
Text entry and window focus loss neutralize input. Bindings and connections exist
only for the current run and are removed on result, cancel, death/character removal or return.

The server captures the launch velocity's horizontal forward unit vector. Its
perpendicular horizontal right vector is fixed for that run. Each steering step
changes only the velocity component on that right vector. It leaves world-Y and
launch-forward projections unchanged; it does not reset the full launch velocity.

Requested lateral speed is axis times min(MaxLateralSpeed, current forward speed
times ForwardSpeedFraction). Velocity approaches that target at a bounded rate.
Steering does not rotate the forward basis, reverse forward travel, add lift or
replenish forward speed. A near-vertical launch or almost-stopped forward travel
cannot gain sideways propulsion. Existing obstacle/ring impulses are not snapped
away; correction remains acceleration-limited, including when an external impulse
puts lateral speed above the steering target limit.

No steering input leaves the PHASE 0 trajectory untouched. After steering has
actually changed lateral velocity, neutral input gradually reduces lateral drift.
Total speed may rise slightly from the bounded lateral component; forward speed
never rises directly from steering. The existing 3D distance formula naturally
includes lateral displacement, without changing distance or reward rules.

## Responsibility and protocol

`SteerFlight` is a new RemoteEvent directly under ReplicatedStorage, safely created
by the existing Remotes.Ensure registry and checked by RemoteClient's bounded wait.
It carries `(axis, runId)`, never a velocity, position, dt or power value.

The client emits a normalized axis at 10 Hz. The server checks player/run ID,
current Character, live Flying state and ready data, then finite numeric [-1,1]
input and an accepted-packet rate limit. A missing refresh for 0.35 seconds means
neutral input. No old input or delayed callback is carried into a new run.

The existing server Heartbeat performs correction after movement validation and
landing finalization; a completed run receives no last steering impulse. Accepted
lateral corrections are accounted for in the existing movement validation budget.
Network ownership remains as in PHASE 0. The client performs no predicted velocity
writes, so server latency and replication responsiveness require Studio testing.

Keyboard handling is isolated in SteeringInput. Its SetAxis(-1..1) interface can
be driven by a future touch adapter without changing server physics. Mobile UI is
not implemented in this phase. Camera code is unchanged; arrow keys are consumed
as steering only during flight.

## Tuning

All tuning is in `src/server/SteeringConfig.luau`:

| Parameter | Initial value | Meaning |
|---|---:|---|
| Acceleration | 40 | Lateral correction acceleration, studs/s² |
| ReleaseDeceleration | 8 | Neutral drift deceleration, studs/s² |
| MaxLateralSpeed | 45 | Maximum requested lateral speed, studs/s |
| ForwardSpeedFraction | 0.20 | Additional cap relative to remaining forward speed |
| MinForwardSpeed | 5 | Threshold for sideways propulsion |
| MaxStepSeconds | 0.10 | Limit correction after a stalled frame |
| InputTimeout | 0.35 | Seconds before missing input becomes neutral |
| MinPacketInterval | 0.04 | Minimum server-accepted packet interval |
| Client.SendInterval | 0.10 | Client refresh interval, sent by server at launch |

Keep InputTimeout comfortably above Client.SendInterval. Stop/restart Play after
changing config so both server modules and launch-supplied client settings refresh.

## Files

Added SteeringConfig and HorizontalSteering server ModuleScripts and SteeringInput
client ModuleScript. Updated FlightService, FlightClient, Remotes, RemoteClient and
regression tests. Updated the implementation plan to record the user-accepted
PHASE 0 baseline. No DataStore, reward formula, Cannon occupancy, ReturnToSpawn,
map/asset, reference source or Rojo mapping changes were required.

## Verification and Studio checklist

Completed: 112 regression assertions passed, all 14 Luau source files compiled,
and Rojo 7.7.0 built the expected 12 runtime scripts/modules. Hash comparison
confirmed PlayerData, DataManager, RunPolicy, Cannon bootstrap, Main UI and the
reference script remain identical to the user-accepted PHASE 0 baseline.

Automated tests exercise the production modules in a mock environment, including
all PHASE 0 regressions plus steering projection invariants, acceleration/caps,
release/expiry, timestep behavior, input validation, multiplayer isolation,
stale-run rejection, key/focus handling, binding cleanup and Remote provisioning.
These tests do not simulate Roblox physics, replication or real keyboard routing.
No Studio steering Play Test was performed by the agent.

1. Stop Play, sync existing Rojo project and verify the three new ModuleScripts.
   Keep the legacy Workspace.Canon.Script disabled. Start a new Play session;
   ReplicatedStorage.SteerFlight should appear automatically, with no duplicates.
2. Compare no-input shots with the accepted PHASE 0 baseline at identical power
   and aim. Check distance/reward/return and unpublished StudioMemory operation.
3. Hold A/D and arrows, release, and reverse. Expect gradual correction and drift,
   not an instant side-step. Check a rotated cannon and low-forward-speed shots.
4. Verify the camera stays normal and arrow keys do not also rotate the camera.
   Chat typing and alt-tab must neutralize steering; resume with a fresh key press.
5. Fly through rings/bombs while steering, land before/after six seconds, and
   verify one result/reward. Check for erroneous InvalidPhysics cancellation.
6. Reset/die while holding a key, return, and launch again. No stuck input, leftover
   bindings, old-run steering or camera lock should remain.
7. Two clients: A flies/steers while B aims/flies. Check independent steering and
   unchanged Cannon occupancy. Test simulated latency and packet interruption.
8. Repeat 10+ full loops and tune only SteeringConfig if steering feels weak,
   abrupt or latency-sensitive. PHASE 2 remains unstarted.
