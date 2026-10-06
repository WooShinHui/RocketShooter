# F0 — Cloud Outpost validation

2026-09-27. E baseline preserved. No next phase started.

Follow-up: the sustained-steering issue recorded below was subsequently fixed and A/B validated in [F0.5](F05_STEERING_FIX.md). The F0 measurements below remain the historical pre-fix evidence; destination placement/bounds are unchanged.

## Final placement and ownership

- Cloud Outpost: procedural floating observatory, broad deck and two towers; 25 anchored, non-colliding parts. No external assets.
- LevelConfig → LevelBuilder → AssetRegistry → GeneratedWorld, owned/unloaded by its generated section.
- Course-relative center: Forward 300, Lateral +65, Ground-relative altitude 210 studs.
- Audited Studio world center: (128.3945, 210, 570.2538).
- Arrival box: Forward 255–345, Lateral 5–125, Altitude 180–240. No enlargement or relocation during resumed validation.
- Uses current validated position through WorldCoordinates.Measure and FlightMetrics.CurrentAltitude, never separate historical maxima.
- Cloud entry remains altitude 180. Outpost requires the physical box simultaneously. Session player attribute plus per-run notification guard; no persistence/rewards added.
- Clear foreground cloud corridor keeps the navy/ivory/gold silhouette visible. Cannon aiming views and airborne approach were visually inspected. No text label substitutes for the landmark.

## Studio runs

All reported normal results use GOOD timing (1.0). Automated temporary input invoked existing aim/fire/return remotes; actual physics and server discovery ran unchanged. Ring triggers/effects were not disabled.

| Condition | Reward Distance | Forward Distance* | Max Altitude | Flight Time | Rings | Outpost |
|---|---:|---:|---:|---:|---:|---|
| Earlier accepted weak run: L1 / 25° / center | 369 | 369 | 49 | 2.05s | 0 | No |
| L25 / ~40° / right ~12.5° | 587 | 587 | 239 | 4.53s | 1 | First discovery |
| L25 / ~39.75° / right ~23° | 539 | 538 | 198 | 4.10s | **0** | **Yes**, session revisit |
| L25 / ~39.75° / left ~23° | 539 | 538 | 198 | 4.12s | **0** | **No**, Clouds only |

*Result Forward Distance projects onto the actual launch axis. Destination placement projects onto the fixed course axis; these values legitimately differ for yawed launches.

The target input was pitch 40°, yaw ±22°. The audited cylinder introduces a small difference in world direction. Actual no-ring launch velocity was (±69.301, 261.529, -163.330).

No-ring success: minimum center distance 67.28, minimum box distance 0. First inside server sample (Forward, Altitude, Lateral) = (257.64, 192.82, 116.07); center error = (-42.36, -17.18, +51.07). At course Forward 300: altitude 174.17, lateral 134.04, already leaving the arrival volume. The flight crosses the actual platform's near/right approach, rather than needing to pass through its center.

Wrong-side run: minimum center distance 183.63, minimum box distance 110.43. At Forward 300: altitude 174.21, lateral -134.04. MaxAltitude 198 does not auto-discover the destination. No stale Outpost notice in this next run.

Normal successful and wrong-side runs retained Health 100 and completed Result → Returning → Idle. The next run also started successfully. Cloud notice preceded Outpost notice; first/revisit text both observed. Studio Play was stopped after validation; temporary scripts and session test levels were not saved to the place.

## Why the interrupted L25 / 40° test failed

Reproduced its held steering axis 0.7, with gravity still 196.2. At Forward 300, actual altitude was **413.35**, lateral 21.48; error relative to Outpost center: (0, +203.35, -43.52). Minimum center distance 140.63; minimum box distance **75.26**. At the closest box sample, center error was (-103.87, +76.88, -56.15).

This is an existing sustained-steering physics/synchronization issue, not an unreachable destination or undersized bounds: vertical deceleration became much smaller than gravity while steering was repeatedly applied. Peak reached 943.71 and the run drifted beyond the landing strip before WorldFall recovery. FlightService rewrites the full AssemblyLinearVelocity from a server sample while the client owns character physics; repeated stale Y replication is the suspected mechanism. That internal mechanism has not been independently isolated with a physics fix.

The same launch tier with neutral in-flight input follows the expected no-ring altitude range and reaches the existing arrival box through initial yaw. **The sustained-steering issue remains unresolved** because this task explicitly forbids changing baseline physics/lifecycle. Do not describe the overall flight baseline as bug-free or silently tune placement to this anomalous trajectory.

## Growth rationale and verification

Existing LaunchTrajectory predicted altitude at the box's Forward=255 near face for centered 45° GOOD: L15=89.58, L20=157.86, L22=180.89, L25=211.96. L22 is an approximate challenge threshold, not a guaranteed success at every yaw. The actual L25 no-ring run establishes a practical middle-growth route. Early L1 cannot reach the required altitude. No Power/economy change was necessary.

Previous final automated verification retained: regression **310**, Luau **35** runtime files, Rojo build/mapping pass. No runtime code changed during this resumed validation, so these checks were not unnecessarily repeated. Diff whitespace check passed.

Remaining placeholders: procedural observatory art, temporary DISCOVERED/REVISITED notice, fly-through structure rather than a walkable destination. No next-region silhouette, shop, quest UI, new resource or SFX change. DataStore schema unchanged.
