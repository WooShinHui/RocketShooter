# E — First Flight Presentation

Verified 2026-09-27. D is the accepted baseline; no later progression work.

## Scope and audit

Kept the Studio-owned Cannon, existing Ground scenery/markers, procedural cloud
banks and trajectory-oriented neon rings. They communicate the current spaces;
primitive trees, polygonal ring arcs, simple signs/shop/result UI remain unfinished
art. No external model, texture or executable script was imported.

The visible ring-route mismatch was the extra 38-stud lateral offset, not a new
launch physics bug. Removed that offset. LaunchTrajectory now owns muzzle transform,
aimed reference muzzle, exact character exit CFrame, velocity and ballistic reference.
FlightService and WorldService use these functions; the existing 8-stud exit and
reward-distance origin remain unchanged. Rings follow the static L20/45deg/GOOD
unboosted reference; other angles, steering and actual boosts intentionally depart
from it. They do not adapt to or force the player's flight.

Accepted Ring events produce one 3-degree maximum FOV impulse decaying over 0.28s
and one short whoosh. No shake, flash, popup, new rewards or physics changes.
Original FOV is restored on Result/cancellation/return. Discovery has its own cue
behind the existing once-per-run notice guard.

## Final applied audio only

Sources below are Creator Store pages except the Roblox purchase cue, which is
also explicitly supplied by the official audio tutorial. Source metadata was
checked against Studio MarketplaceService. Selection reflects source descriptions,
duration and intended role, not a claimed listening evaluation.

| Role | Asset ID / source | Creator | Reason | Volume / speed | Studio duration |
| --- | --- | --- | --- | --- | --- |
| Launch | [9120705982](https://create.roblox.com/store/asset/9120705982) | ProSoundEffects | Whoosh Explosion 1: brief blast rather than jump/UI click | .45 / 1 | 1.754s |
| Ring | [9120704522](https://create.roblox.com/store/asset/9120704522) | ProSoundEffects | Fast Wipes Quick Airy Slices 3: short pass-by cue | .35 / 1 | .376s |
| Collision | [9113476681](https://create.roblox.com/store/asset/9113476681) | ProSoundEffects | Body Fall Master 40: impact cue at restrained gain | .25 / 1 | 1.738s |
| Cloud Discovery | [9125644410](https://create.roblox.com/store/asset/9125644410) | ProSoundEffects | Magic Twirling chime: longer discovery accent, distinct from ring | .50 / 1 | 2.069s |
| Result | [9119802009](https://create.roblox.com/store/asset/9119802009) | ProSoundEffects | Synth Chime Single Synth Tone 3: compact result notification | .35 / 1 | 1.329s |
| Upgrade | [127645268874265](https://create.roblox.com/docs/tutorials/use-case-tutorials/audio/add-2D-audio) | Roblox | CoinTransfer_01: official purchase-feedback example | .30 / 1 | 1.661s |

Roblox documents Creator Store audio use in experiences in its
[audio asset guidance](https://create.roblox.com/docs/audio/assets). This is evidence
of distribution/source, not a blanket rights warranty. All six above passed actual
Sound-instance PreloadAsync (Success), IsLoaded, protected Audio.Play calls,
IsPlaying and advancing TimePosition in this unpublished Studio session on
2026-09-27, with no final audio load errors. Published-experience availability was
not tested. Previous probes also observed nonzero PlaybackLoudness for all six.

Preload is asynchronous and uses Sound instances, not bare ID strings (which failed
in this Studio session). One reusable voice per role bounds overlap/instance count.
Unavailable audio is logged and skipped, with no delayed cue replay or gameplay
failure. Each role uses a different SoundId; none of the former jump/landing/shared
ping placeholders remains in the final configuration.

Actual timbre, launch impact, ring satisfaction, collision comfort, discovery
achievement and overall mix require user listening. Computer Use did not provide
audible output to the agent; no subjective sound-quality approval is claimed.

## E-only verification

Two Play-only L20/45deg/GOOD runs, with no production data writes:

- Exact character launch origin error: 0 studs in both runs.
- Unboosted trajectory probe: ring touch disabled only during the first measurement;
  interpolated root-to-center errors at six forward stations were
  1.112 / .856 / .579 / .389 / .084 / .217 studs. Normal/velocity dot products
  were .999909 or greater. No arbitrary trajectory or aperture enlargement.
- No-contact run: altitude 211, reward/forward distance 345, flight time 4.22s,
  zero pulse/SFX, Clouds then Ground, Health 100, result/return/idle FOV 70.
- Ring touch restored for run two: two real accepted contacts, exactly two camera
  pulses and two Ring audio calls. At +.05s FOV was 72.02 and 72.32; at +.32s
  both were 70. Altitude 244, distance 405, time 4.73s, Health 100.
- A stale first-run Ring event sent during run two added no pulse or Ring audio.
  Result/Return FOV was 70. Temporary test objects are discarded on Stop.
- Ground/cloud appearance, discovery notice and result screen were visually seen.
  The brief ascent was numerically sampled, not successfully captured as a screenshot.

Final automatic checks: 301 regressions, 34 Luau compiles, Rojo build/mapping,
and git diff --check passed. No Power, threshold, economy,
metrics, persistent schema, ring effect/cap or obstacle gameplay values changed.

## E changed files

- Server: LaunchTrajectory.luau, FlightService.luau, WorldService.luau,
  LevelConfig.luau, CourseSection.luau.
- Client: Audio.luau, PresentationConfig.luau, FlightCamera.luau,
  FlightClient.luau, Main.client.luau.
- Tests: regression.luau, run-local.cjs.
- Docs: E_PRESENTATION.md, IMPLEMENTATION_PLAN.md.

Other working-tree changes belong to earlier accepted phases. No place file,
shared balance/cloud config, data files or persistent data was edited in E.
