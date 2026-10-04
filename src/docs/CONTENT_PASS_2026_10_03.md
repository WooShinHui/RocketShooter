# Height / AFK / Rebirth content pass — 2026-10-03

User-authorized scope: flesh out the existing prototype directly in Codex, with no agents; add rebirth, AFK training ideas, scattered altitude-dependent meme creatures with fall risk, and a cliff/hill launch map. Intro/tutorial remain deferred. This instruction supersedes earlier distance-road and nonfatal-obstacle direction for the new SkyLife hazards. Legacy gimmick behavior stays in its original code.

## Source and incomplete reference access

Read existing AGENTS, GAME_DESIGN, LEVEL_DESIGN, IMPLEMENTATION_PLAN, technical rules, human-playtest repair brief and reference-01 benchmark analysis. The repair brief describes AFK food/animation/tiers and the benchmark describes Lv.20 rebirth. The supplied Notion page could not be opened by web tools. Browser inventory was empty; native Computer Use initialization returned `Trusted RPC service is not configured: sky`. User permission was obtained but did not establish a usable connection. Therefore the Notion body, screenshots and image-by-image requirements are NOT reviewed. This pass implements the user message plus the local sources; it is not full Notion acceptance.

## Implementation

- `ProgressionConfig`: level20 training cap, level XP = 10+5*(level-1), rebirth permanent training multiplier = 1+0.25*rebirths, safety cap1000. Training adds floor(3*(level-1)*multiplier) effective launch Power levels on the server, alongside existing purchased levels and session Fuel power.
- 7 treadmill tiers: wood/stone/iron/gold/diamond/emerald/divine, rates1/1.5/3/5/7.5/10/15. Sequential unlock, server-priced Trophy purchases; levels1/5/10/15/20/20/20, costs0/5/15/40/80/160/320; emerald needs2 rebirths, divine5. Tiers persist across rebirth.
- `TrainingService`: checks server character position on an unlocked belt, living character and Idle state, grants XP from bounded server clock time. No remote accepts XP/rate/time from clients. `TrainingFX`: existing character run animation and bobbing food prop. No new audio asset imported; existing Upgrade audio is reused for transactions. Custom eating/fart animations/SFX from the historical idea are not implemented.
- `PlayerData`: additive saved fields TrainingLevel/TrainingXP/Rebirths/TrainingTier. Old fields, unknown fields, existing store name, optimistic concurrency and load-failure protections remain. Rebirth resets only TrainingLevel/XP, not Gold/Trophies/purchased Power/Boost/records/tiers. Expected-current serial prevents stale/duplicate rebirth and tier requests. Rebirth UI explains the reset and requires two clicks.
- `CliffCamp`: finite grassy launch hill, deep rock cliff, distant wedge mountains, trees, valley landing area, 7 training stations/food props/signs. Repeated road Sections removed. Baseplate is archived only in the running session; saved Studio originals are preserved. Existing cannon and spawn are retained. Runtime terrain generation is local source-owned, not a saved replacement rbxl.
- Initial aim pitch40 instead of25. Existing aim input still supports its prior pitch limits. Falling below the hill is legitimate normal descent: valley floor is at-220, flight floor guard changes from-100 to-300 so normal landing can still pay rewards.
- `SkyLife`: deterministic independent 3D scatter over forward[-350,1100], lateral[-540,540], 4 altitude bands55–140/150–340/360–850/900–1800. Counts16/14/12/10, total52 creatures; 12 cloud clusters. Low: dumpling and wax-ball; clouds: brainrot/gugugaga; upper:67/febby; space:cosmic variants. The names are user-provided themes, represented by original procedural shapes/eyes/folds/lobes/wings/pacifier/labels, not copied character assets or imported meshes. Sizes/radii4–7 studs. All bodies anchored and nonphysical; server moves their models at5Hz.
- Collision uses server swept segments against actual animated body centers. First second is exempt to protect launch. Hit forces downward velocity, disables subsequent steering/gimmick boosts, and on ground/world fall invokes the existing recovery lifecycle without awarding the run. Persistent progress is not lost. `AltitudeMood`: presentation-only low/cloud/upper/space lighting/stars and region label, with actual altitude thresholds150/350/900; discovery/rewards still server-owned.
- Old trajectory-only destruction preview is disabled via existing DestructionSpikeFlag; its implementation remains available. This is an explicit replacement of that preview placement, not deletion of original code.

## Verification

- Final compile and Rojo build PASS.
- 476 mock checks PASS: existing457, new progression17 and hazard lifecycle2. Historical course checks now read an explicitly preserved legacy-course-config fixture because the production road is intentionally removed; this is not proof of the new map. New map is checked in actual Studio.
- Actual new Play: config/module/UI creation, 7 stations, GeneratedWorld road section count0, runtime Baseplate archive, 52 creature distributions and 12 clouds observed. Console showed no runtime error in exercised states.
- Actual treadmill navigation: TrainingActive=true, XP13 at level2, run animation tracks active. Natural level20 pacing remains unmeasured (wood tier needs about17.4min at x1; first observed tick establishes the time budget).
- Actual normal launch: altitude HUD106/109 studs observed; valley landing result Gold67/Trophy1, then actual return to spawn. Uses live user inputs and existing navigation tool.
- Actual rebirth/tier UI test: ONLY disposable unpublished StudioMemory profile seeded to TrainingLevel20 and Trophy50. BuyTier click gave stone tier2 and Trophy45. Two rebirth clicks yielded Rebirth1, TrainingLevel1, XP0 while keeping tier2, Trophy45, Gold67, MaxAltitude109. This is a controlled threshold/transaction test, not natural growth-to-cap.
- Actual runtime sphere sweep: hit at a creature body returned dumpling; empty sky segment CLEAR. Controlled collision: a live creature was temporarily moved into an already launched player's path for0.7s, then restored. Server recorded LastSkyHazard, downward velocity-257, recovery reason SkyHazardFall; after4s Idle at spawn, Gold/Trophy0, result hidden. This proves integrated collision/recovery, not natural encounter frequency.
- Final fresh Play loaded SkyLayerGui; no errors in current exercised console.

## Remaining requirements / review

1. Obtain readable Notion/export/screenshots and map every pictured requirement to existing/new/deferred features. Do not claim full reference fidelity yet.
2. Tune natural training time, Trophy prices, rebirth power/regrind curve and object encounter density with real play. Current values are centralized first-pass tuning.
3. Real mobile portrait/landscape/device input, multiplayer fairness/load, full high-altitude/space flight, eating/VFX/SFX richness and final 3D asset polish remain unverified or unimplemented as described above.
4. Published DataStore service/reconnect test is not run. Existing mock persistence tests verify old saves/defaults, protected saves and additive fields. Studio used memory only.
5. Intro/tutorial intentionally deferred. No monetization/new external assets/publishing. No external agents used.

Backup, hashes, captures, regression logs and runtime JSON: `D:/Agent/outputs/content-pass/`. Final Studio can be returned to Edit without losing source-generated content; start a fresh Play to regenerate it.
