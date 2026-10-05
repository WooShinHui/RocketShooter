## 2026-10-04 오른쪽 고도 정보

캐릭터 오른쪽에 현재 고도와 발사 레벨의 예상 최고 고도를 표시한다. 서버가 실제 발사에 쓰는 RocketMotion 프로필과 지면 기준으로 ExpectedHeight/LaunchLevel/GroundY를 전달한다. 비행 도중 레벨이 올라가도 이미 사용 중인 추진력을 바꾸지 않으므로 예상치는 발사 시점 값을 유지하고 다음 비행에서 갱신한다. 현재 고도는 상승/다이빙 모두 실시간 갱신하며 GUI 안전 영역 안으로 제한한다. 왼쪽 연료 원호는 유지한다.

## 2026-10-04 초반 시야·고속 연출·다이빙 조작 정리

첫 구름/바이옴 경계260m(이전150m). 구름과 카메라·캐릭터가 교차할 때 로컬 투명도를 높여 시야를 확보한다. 트로피 표지는 배경 없이105m 이내, 벽 너머 상시 표시 해제. 자동 다이빙 유지, F/터치 길게 누르는 동안 급강하, 놓으면 추가 가속 해제하되 이미 얻은 낙하 속도를 유지한다. 낮은 비행은 귀환 보조 문구를 작게,300m 이상 긴 낙하는 폭파 귀환 버튼으로 표시한다. 고속은 실제 속도180~5000에 비례하는 가장자리 속도선·이온 궤적·시야각 확장(최대약88도)·재사용 엔진 음원의 고음 바람층. 중앙 시야와 자유 카메라를 유지하며 가짜 버프나 물리/경험치 배수 변경 없음. 검증 D:/Agent/outputs/rocket-presentation/REPORT.md.

# 2026-10-04 다이빙·무한 레벨·골드 링 개편

최신 사용자 지시: 20레벨 상한 제거, 환생 시 레벨0/XP0, 요구 레벨은 환생 횟수에 따라20/40/60/80…이며 한 번 클릭으로 실행한다. 보통 레벨업 요구XP는40+12×레벨로 늘리고 기본 경험치는 계속 증가한다. 기존 저장 필드/구매/트로피/기록은 보존한다. 로켓 고도는 기존 추진력 곡선을 유지하되 최신 속도 QA에 따라 상승시간은5~12초 안으로 완화하며 속도·가속도도 성장한다. 연료 소진 시 자동 조작 가능한 머리 아래 다이빙으로 전환; F/모바일 버튼으로 가속, E/모바일 버튼으로 폭파·사지 분리·보상 확정 후 귀환. 상승·다이빙 모두WASD/스틱과 자유 카메라 유지.

골드 링은 서버30분 주기,3분 활성,저·고레벨12개 고도+현재 비행 중인 원격 경로에 무작위 배치하며 서버의 실제 양방향 평면 통과로 경험치·점수 지급. 동일 링 중복 불가/한 이벤트당 플레이어 최대3회. 골드 재화는 추가하지 않는다. 구름은 로컬 비충돌 구간 경계로 위를 가리고 통과 후 다음 구역을 보여 주며 기존 말랑이·벽·섬·적은 유지한다. 이동 방향에 따라 몸체 기울임과 다이빙 팔 자세를 적용한다.

검증 기록: D:/Agent/outputs/rocket-dive/REPORT.md.

추가 사용자 지시: 파괴 가능한 하늘섬 보너스 블록은 복원·유지한다. 통과해도 반응 없는 분위기용 조형물만 경로 밖으로 옮긴다. 예전 착륙 플랫폼/CloudOutpost는 로켓 모드에서 제거한다. 분위기용 지형은 경로의 양옆 최소 약500m 밖에 배치하고 빈도를 줄인다. 추진 게이지는 캐릭터 화면 위치를 따라가는 좌우 세로 막대로 바꾸며 위에서 아래로 소진된다.

---

# 2026-10-04 초반 높이/시간 분리와 파괴 사운드

1레벨은 기본 추진력235.64에 따른 약141m 상승량을 약5초 동안 오른다. 시작 높이를 포함한 최고 고도는 약150m다. 지난735 재매핑은 철회한다. 높이와 시간은 별도 값이며, 속도는 sine 곡선으로 점화→가속→감속한다. 연료 소진 후 기존8m 낙하 귀환을 유지한다. 성장에 따라 높이/최고 속도가 점차 늘고 우주 높이 상한은 그대로다. 느린 구간 파괴 벽은 최소12m 간격으로 분리한다.

무료 Creator Store 음원 Balloon Pop1(9113263454),Balloon Pop4(9113263647),Boxing Hits12(9113568487),rocket-jet engine loop(77862630063982)를 검색/Studio 삽입했다. Slime 별도 파괴음 및 짧은 연속 팝, 충분한 음원 tail, 분사에 따른 엔진 루프를 적용한다. 특정 왁뿌볼 원본 사운드라고 주장하지 않는다. 외형 시안 Mala(마라탕 냄비/국물/면/젓가락),Bat(야구방망이)를 추가하되 가격/소유권/BM은 아직 정의하지 않는다.

---

# 2026-10-04 자유 시점과 초반 비행 시간

상승 시 CameraType.Custom/Humanoid 주제로 Roblox 기본 마우스·터치·게임패드 회전 및 줌을 유지한다. 기본 구도는 캐릭터보다 낮은 위치에서 하늘을 보며, 상승 중 매 프레임 CFrame을 덮어쓰지 않는다. 종료 시 Humanoid.CameraOffset을 복구한다.

1레벨 추진력 기준을 735로 재매핑하여 정상 비행이 작은 낙하 판정까지 약 5.1초 지속된다. 레벨별 높이는 계속 증가하고 최고 추진력7500의 우주 높이는 유지한다. 저레벨 로켓 비행은 각 묶음당 기존2/5개를 유지하고 묶음2개를 배치한다. 단순 종료 지연이나 가짜 파괴 점수는 사용하지 않는다.

---

# 2026-10-04 로켓 점화·시점·스폰 수정

시작 순간 대포 속도를 넣지 않는다. 0.65초 점화와 부드러운 가속 뒤 감속하며, RocketMotion이 기존 추진력에 따른 최대 높이를 보존한다. 서버가 수직 추진과 자세를 결정하고 파괴 코스도 같은 궤적을 예측한다. 캐릭터를 화면 중앙 부근에서 따라가는 카메라와 연료 표시를 사용한다. 스폰 표면은 숨기고 잔디보다 높은 별도 복귀 데크를 사용해 겹친 표면 깜빡임을 제거한다.

RocketStyles는 외형·분사 색만 정의한다. Starter/Ion/Nova는 서버 선택용 외형 구성이고 실제 유료 상품·가격·소유권·BM 구매는 아직 구현하지 않는다. 향후 교체 모델이나 유료 외형을 적용할 때 추진력/경험치 성장 및 서버 소유권 검증과 분리한다. 새 분사는 텍스처가 지정된 불꽃/연기, Beam, 노즐 발광으로 점화→가속→소진을 보여 준다.

---

# 2026-10-04 로켓 자동 상승 개편

사용자 최신 지시가 아래의 이전 대포·조준·낙하 코스 기획보다 우선한다. 발판을 밟으면 등 로켓으로 자동 상승하고 2축 자유 이동하며 파괴한다. 추진력이 끝나 최고점에서 8만큼 내려오면 낙사 처리와 즉시 귀환한다. 경험치 레벨이 추진력을 높이고, 비행 기본 +1 XP/초와 변기 방치 수련을 경험치 아이템·현재 보유 트로피 발판·환생 배수로 증폭한다. 재화는 트로피 하나다. 저장 스키마 EconomyVersion=1에서 Gold를 Trophies로 1:1 단 한 번 전환하며 기존 구매 추진력과 기록을 보존한다. 새 XP 아이템은 서버에서 가격·순서·잔액을 검증한다. 캐릭터·클라이언트 입력·지연 작업은 비행 단위로 관리하고 서버가 비행 보상과 귀환을 확정한다.

노션 참고: https://app.notion.com/p/3eea5ec9ae2380bd8605ebef5781d462 — Chrome에서 본문 확인, 보유 트로피 부족 시 버프 재잠금 방식 채택. 구현·검증 결과는 outputs/rocket-rebuild/REPORT.md에 기록한다.

---

# rocketShooter — Level Design

## Goal

Prioritize reaching farther/higher and discovering new spaces, then Cannon/Rocket
growth, active control, and finally supporting obstacles/rings/gimmicks. A successful
upgrade should make a previously unreachable space approachable. Do not turn the
generated world into a compulsory obstacle course.

Gradually make flight content constructible through data/configuration
instead of requiring every object to be manually placed in Studio.

Target concept:

    LevelConfig
        ↓
    LevelBuilder
        ↓
    AssetRegistry
        ↓
    Generated Flight Course

Do not build the entire architecture prematurely.

Add pieces when gameplay actually requires them.

---

## Level Sections

Prefer reusable gameplay sections such as:

- ObstacleField
- RingSection
- RouteSplit
- ResourceSection
- EventSection
- LandingSection

A section represents a gameplay idea, not merely decoration.

---

## Distance & Coordinates

The game progresses through both forward reach and altitude. Future region placement
should use course-forward projection and height above a shared world datum. Existing
reward distance is the maximum 3D radial displacement from launch; leave that metric
and saved records unchanged in A+B. Ground/Clouds/High Altitude/Upper Atmosphere/Space
are future environment goals, not content implemented by this correction.

Before implementing level generation, inspect the existing implementation
and determine:

- actual flight direction
- coordinate axis
- launch origin/reference
- current distance calculation
- existing map layout

Do not assume a coordinate axis.

The current prototype's distance system may not necessarily be the final
region progression metric.

---

## Obstacles

Preserve Single/Alternating/Choice patterns as sparse, low, optional side pockets.
Maintain a clear center route; include legacy Course bombs in the overall density
budget. Do not scale obstacle heights with Power: outgrowing low hazards is a reward.
Penalty tuning should preserve most of a run after one error, without health damage.

Obstacle generation may eventually describe:

- distance range
- asset pool
- density
- difficulty
- movement
- safe gaps

Generated layouts must remain achievable and readable.

Randomness is variation, not a substitute for level design.

---

## Rings

Ring sections should eventually support configuration such as:

- start position/distance
- count
- spacing
- curve
- difficulty
- reward profile

Possible patterns:

- straight
- left/right curve
- wave
- ascending/descending
- precision sequence

New courses should primarily require configuration rather than new
gameplay code.

---

## Routes

Route splits should create different objectives.

Examples:

    SAFE
    SKILL
    RESOURCE

Route identity should be visually readable before the player must decide.

---

## Regions

Regions should eventually be data-driven.

Potential properties:

    Name
    DistanceRange
    AltitudeRange
    Environment
    AssetPool
    Obstacles
    Rings
    RewardProfile
    Events

Avoid scattering region-specific values throughout unrelated scripts.

Distance and altitude activation, shared altitude-based presentation, and new region
content are deferred beyond A+B. Existing LevelBuilder/AssetRegistry ownership stays.

---

## Asset Registry

Reusable assets should eventually be referenced centrally.

Conceptually:

    Assets.Obstacles.*
    Assets.Rings.*
    Assets.Environment.*
    Assets.Cannons.*
    Assets.Rockets.*

Exact architecture is not predetermined.

---

## Asset Discovery

When available tools permit it, actively research and select appropriate
assets rather than automatically requiring the user to find them.

Evaluate:

- visual consistency
- gameplay readability
- performance
- permitted usage
- geometry complexity
- unnecessary or suspicious scripts

Never blindly trust imported free models.

Preferred workflow:

    discover
      → inspect
      → sanitize
      → register
      → integrate

If direct Studio insertion is available, perform it when safe.

If unavailable, automate as much integration as possible and clearly
identify the remaining manual action.

---

## Art Direction

Until finalized, prefer:

- stylized
- colorful
- readable silhouettes
- coherent visual style
- moderate geometry complexity
- Roblox-appropriate visuals

Gameplay readability takes priority over realism.

---

## Long-Distance Performance

The player may eventually travel very far.

Do not assume unlimited world content can remain active forever.

Future solutions may include:

- distance-based activation
- region spawning/despawning
- pooling
- section recycling

Implement these when scale or profiling justifies them.

---

## Agent Workflow

When improving a flight region:

    inspect gameplay purpose
        ↓
    identify missing interaction
        ↓
    design section
        ↓
    select/research assets
        ↓
    configure/build section
        ↓
    integrate
        ↓
    verify
        ↓
    tune from Play Test feedback

Avoid filling empty space with meaningless scenery.


## 2026-10-05 — User QA: destruction trophies, propulsion equipment, IconPack

Supersedes trophy landing zones and appearance-only rockets. Trophy zones and flight zone guidance no longer run. Server-validated course rows, bonus/slime targets, islands and pierced enemies award one base trophy per logical object immediately, multiplied by the object's ground-relative altitude band: 0 / 260 / 850 / 3500 / 16000 / 40000 / 70000 / 100000 / 140000 with multipliers 1 / 2 / 3 / 5 / 8 / 12 / 20 / 30 / 40. Debris parts and gold XP rings do not award trophies. Visited/hit guards prevent duplicate awards. Returning does not pay the run total again. Existing trophies are retained.

Rocket bonuses: Starter 0%, Ion 10%, Bat 15%, Mala 30%, Nova 50%; existing unlock requirements/prices/ownership remain. Five trophy trails: Ember 15 (+10%), Mint 60 (+20%), Violet 180 (+35%), Aurora 600 (+50%), Prism 1800 (+75%). None is free and +0%. Only equipped items contribute, with one additive multiplier 1+skinBonus+trailBonus on the server's launch vertical propulsion before RocketMotion prediction. Selection is idle-only and applies next launch. Trail masks/selections are persisted with safe defaults for old saves; invalid saves fail closed.

Simulator Icon Pack decals are centralized in UIIcons and used for cursors, trophy, rocket, trail, rebirth, gifts, upgrades and equipment shop controls. Both clicker surfaces are white while off and yellow only for the server-selected active mode. Their adjacent cursor artwork distinguishes Free vs OP. OP remains the existing free preview. No Robux products were introduced.

Delivery and QA evidence: D:/Agent/outputs/qa-propulsion/REPORT.md.


## 2026-10-05 — Cloud gate / butter prototype (user requested)

Supersedes immediate destruction trophies and whole-engine percentage equipment from the earlier QA revision. Each flight escrows server-validated destruction trophies; a safe descent/landing or explosion commits them once via PlayerData.Award. BrainrotCaught/Death/cancellation grants zero current-flight trophies and never debits existing trophies. XP earned during flight is retained. The user explicitly selected loss of current-flight trophies only.

First hollow white cloud chamber spans altitude 480–670. Unrebirthed, unequipped Lv15 enters and stalls; Lv19 stalls before escape; Lv20 escapes. Gate failure uses dwell time or sustained low ascent velocity inside the chamber, not a hard level rejection. Q and the touch button discard fuel and enter controlled descent; F still boosts descent, E returns by explosion while descending. Retreat below the chamber floor clears danger. Later gate ranges: 1000–1450, 2750–3500, 13200–16000, 34000–40000, 60000–70000, 86000–100000, 121000–140000. Sky changes at exit on ascent, and after the lower floor on descent. Old bonus/island/course geometry is excluded from chamber interiors. Three local, bounded geometry-only brainrots visualize server pursuit pressure; they are not physical NPC AI.

Equipment formula: launchVertical = baseVertical + flatEquipmentThrust + max(0,baseVertical-starterVertical)*growthEquipmentBonus. Rocket flat/growth pairs: Starter 0/0%, Ion 8/3%, Bat 10/4%, Mala 16/7%, Nova 25/10%. Trail pairs: None 0/0%, Ember 5/2%, Mint 9/4%, Violet 14/7%, Aurora 20/10%, Prism 25/15%. Combined growth bonus caps at25%. Prices, unlock requirements, ownership and persistence are preserved. The percentage never multiplies the starting engine and is not snapshotted at purchase. Recommended gate levels are calculated server-side at launch using the player's current equipment/rebirth and a14-stud exit margin.

Butter inventory asset118384093858616: reviewed mesh83573042900595, untextured/tintable. Course and sky bonus block geometry uses butter; four course colors and varied tilts. Butter fragments are bounded local visual effects. Set CourseVisualConfig.Style to Brick for art-only rollback. Brainrot inventory pack137461628889541: three vetted single-mesh characters extracted as geometry/texture IDs. No imported scripts or NPC logic run; raw reference imports removed after inspection. Inventory searches for dumplings/dumpling/dum Model and dumplings Image found no match; existing dumpling party remains.

QA and calculation evidence: D:/Agent/outputs/cloud-gates/REPORT.md. Files have byte-exact rollback backups. No publishing or new Robux monetization. A native Studio save remains necessary.


### Follow-up: user asset ID and altitude palette

User supplied model98272741474273, registered as duplings (the missing letter explains prior inventory search failure), then explicitly requested diverse colors by altitude. Reviewed mesh110356585242168 and Back face85735925995041; all nine imported scripts excluded. Existing dumpling targets/7-chain party use the reviewed mesh/face. CourseVisualConfig now centralizes nine sky-aligned altitude palettes with three colors each. Butter walls/bonus blocks, dumplings and recycled dumpling parties use these palettes. Runtime fragment limits/collision/award rules are retained. Raw reference model removed. Studio:39 dumpling models/39 faces/zero imported scripts; swept collision emitted Dumpling FX and increased run trophies. Documentation supersedes the prior missing-dumplings limitation.


## 2026-10-05 — Cloud spacing, threat and recommendation revision

Supersedes prior cloud ranges and three-identical-chaser presentation.

Eight gate entry/exit altitudes: 480/670, 4000/4800, 10500/12500, 24000/28000, 52000/60000, 96000/110000, 160000/185000, 265000/300000. Stage families: Tung/Tralalero/Ballerina; Patapim/Crocodilo; Lirili/Chimpanzini; Odin; Tralaledon; Saturnita; Grande Combinasion; Dragon/Strawberry Elephant. Leader visual heights: 18/26/36/48/60/72/88/104 studs. Other heights: 12/16/22/28/34/40/48/56. Pre-entry warning is large red text, including required and current HUD power, plus Q retreat. It appears near the next chamber (always for the first ascent) and hides inside or during descent. Lightning occurs only inside a chamber, with modest, brief flashes. Sky/mood/palette boundaries align with the new exits.


### Follow-up: entry signage, legacy map, smooth exits and dive controls

User clarified that propulsion requirements belong beneath the cloud entrance, not on the avatar/HUD. StageCurtains now owns an anchored entry sign surface170x32 studs,28 below the floor,220 toward the course. Large red text remains personal to the launch equipment/rebirth. No GatePowerWarning ScreenGui remains. Sign creation completes its Requirement label before publishing; ResetOnSpawn=false and direct object references replace child-name indexing. Missing GUI/label is rebuilt; cleanup owns both sign and chamber. The reported Requirement-not-a-valid-member error was reproduced in Studio and fixed. Deleting the live label deliberately caused successful recreation within0.25s; subsequent flights and all-boundary QA had no runtime errors.

SIMULATOR MAP with78 top-level children was moved out of edit Workspace to ServerStorage.GateRevisionRollback.RemovedHandmadeMap for rollback. Existing generated launch/return/training systems remain. Native Studio Ctrl+S is still required.

Sky textures are preloaded asynchronously (Studio failures0). A cloud-colored transition overlay grows near the chamber exit, masks the texture change, holds0.12s, then reveals over0.65s. It does not block input and leaves flight HUD above it. Every gate was tested in Studio at inside/exited/settled heights, then all8 descent floors were checked. All expected sky IDs matched; outgoing textures remained stable after the fade, masking cleared to0, and descent returned to expected six sky faces. This is staged-height presentation QA, not a continuous flight through all8 gates. JSON evidence is in D:/Agent/outputs/gate-revision/all-stage-sky-qa.json and all-stage-descent-qa.json. Real first/third flights also changed skies while the cloud veil was opaque.

Dive lateral control previously fixed110 speed with240 acceleration. It now scales clamp(abs(fallSpeed)*0.25,220,720), accelerates max(1800,lateralSpeed*6), reverses/brakes rapidly, and keeps ascent90/240 unchanged. Normal WASD aiming smoothly limits high fall speed to1800 using2400/s deceleration; F bypasses this aim slowdown. Neutral descent retains original momentum/limits. Eight behavioural assertions verify response, reversal, release braking, limits and F exception. Studio actual D/A input during Lv190 descent achieved314.25 sideways speed and604.78 netX movement, safely returning. Final regression count2687, all production Luau compiled and Rojo build passed.


### 2026-10-05 — User correction: actual underside and proportional descent

Supersedes the separate entry sign and previous220 lateral minimum. The requirement SurfaceGui is attached directly to the cloud Floor with Face=Bottom. A large red centered label occupies80% width,24% height of a1024-square canvas and reads 권장 레벨 N!, using server-calculated GateLevels for current rebirth/equipment. No CloudEntryAnchor part is created. Direct references and GUI/label recovery remain. Dive WASD speed is min(abs(descentSpeed)*0.20,480), with no minimum speed jump; response/braking acceleration=max(120,lateralSpeed*5). At fall90/500/1000/2400 this gives18/100/200/480 sideways speed. Normal aiming slowdown and F exception remain.


### 2026-10-05 — Approved descent destruction prototype

Three run-owned target layers appear below the first cloud during descent. Normal layers use ground-relative heights420/280/140; early low flights scale the layers below their available height (no targets below80). Each layer offers a cyan132x12x132 central butter platform and two gold60x12x132 side platforms at X offsets±110. The route locks at creation and does not follow steering. Spawn lead is max(180 studs,1.5 seconds of current downward speed). Nine persistent streamed models use noncollidable visual parts and neon outlines; run cleanup removes the entire container.

Server swept segment collision reuses BreakCourse.Touches, checks descending travel only, and grants one target per layer per run. Side targets use3 reward units; logical destroyed object counts still rise by1. Height multipliers remain in DestructionRewardConfig. At full420/280/140 heights, the zone alone grants5 trophies for three central hits or15 for three side hits. These rewards join the existing flight escrow and bank only on safe return; death/caught/cancel loses the current flight escrow only. No saved fields, equipment prices or vertical/steering rules changed.

DiveBreakGuide previews the next layer, distance and actual server-calculated trophy amount. Its heading sits below the existing trophy meter, with projected cyan/gold choice labels kept above the lower HUD. DestructionFX shows a distinct descent/bonus hit notice and places it below the guide. DiveZoneHits/DiveZoneBonusHits are included in transient result metrics. Disable DiveBreakZone.Enabled to turn off this prototype. Existing butter mesh83573042900595 is reused; no asset purchase/import.

Verification: all production Luau compiled, Rojo build passed,2882 mocked checks passed. Studio actual Lv20 center route hit3 targets; actual D steering selected the third-layer side bonus. Safe return banked rewards once and removed all zone models/hid guide. High-speed QA and final source verification are recorded in D:/Agent/outputs/dive-zone/REPORT.md. This is a first-cloud prototype: at high fall speed the three layers are crossed quickly, so advance lane choice matters; it does not promise long intervals between targets. Multiplayer load, mobile hardware feel and long-term reward pacing still need playtesting.


### 2026-10-05 — Larger descent targets, ring run and cloud piercing

Supersedes the descent prototype target sizes and one-claim-per-layer rule. Standard descent chain bounds are360x280x24 (previous100x64x8), with118x138x24 visible butter tiles; ascent bounds/tiles are unchanged. Later descent packs lock to the initial descent XZ lane. Final three target layers use240x24x280 footprints on all lanes, side offsets±200. Only the actually hit target breaks; untouched alternatives stay visible until the player passes the layer. Each individual target can pay once. The enlarged neighboring lanes overlap40 studs to tolerate imperfect aim; a crossing can legitimately break both adjacent targets. Trophy units remain1 central/3 bonus, with actual target height multipliers. Targets spawn up to3 seconds of current downward speed ahead (minimum270 studs).

At descent start, a fixed ring path is planned from the existing RocketRules.DiveSpeed trajectory: up to10 radius170 rings, roughly0.5-second steps. Actual Lv20/Lv190 flights crossed all10 over4.00/4.05 seconds. Very short beginner flights clip the route above ground rather than altering fall speed. Ring hits grant one existing destruction reward unit and one tier score, through the flight escrow. They are independent of the thirty-minute GoldRingEvent and do not grant its XP bonus.

Each descended cloud gets two rows of three static brainrot targets using that gate's reviewed icon-pack family, with visual height60 or twice its normal chaser height. Server swept collision pierces them without physical blocking or death; each enemy awards one destruction unit once. CloudGateRules resets pressure/slow counters while diving and never returns Caught in descent, including abort inside a cloud. Local ascent chasers hide during descent; cloud lightning remains active. No flight motion/steering, saved fields or equipment prices changed.

Guide filters block/ring/enemy models correctly and shows ring progress when outside the final block zone. Destruction feedback distinguishes ring passage and brainrot piercing. Transient result metrics include DiveRingHits/DiveEnemyHits. Source changes: BreakCourse, DiveBreakZone, RocketFlightService, CloudGateRules, CloudGateChasers, DiveBreakGuide, DestructionFX; tests and these four phase docs. Existing butter mesh and GateEncounterConfig families reused; no new asset import.

Validation: production Luau compilation, Rojo build,2935 mocked checks. Actual Studio Lv20:10 rings,2 pierced cloud enemies,3 central targets, safe return; Lv190:10 rings,6 enemies across3 clouds,3 central targets, safe return at1257 descent speed. Console runtime errors0. Source backup and exact rollback are under D:/Agent/outputs/descent-wide; Studio source backups in ServerStorage.DescentWideRollback. Low-level lane adjustment and final verification are in REPORT.md. Multiplayer/device performance and longer-term reward pacing remain playtest work.

Final camera correction: side targets and cloud enemy lanes freeze along the validated camera-relative right vector at descent start, rather than global X. Steering packets carry a normalized optional camera basis; server validates it with RocketRules.Input and only uses it to orient run-owned geometry, never to grant rewards. Blocks and hit bounds share the rotated frame. Existing controls are unchanged. RocketClient shows a cyan descent piercing hint instead of the ascent chase countdown. Actual final Lv20 D-input test hit3 central and2 side targets,10 rings and2 cloud enemies, then returned safely. Final mocked count2937.


### 2026-10-05 — Readable high-speed descent targets

Supersedes the fixed 18-stud descent chain spacing and fixed 420/280/140 final floors for fast flights. Course targets use current validated speed (90–3600), 1.8 seconds of spawn lead (minimum160 studs), and0.7 seconds between rows (minimum60 studs). Flights below500 studs retain a compact above-ground layout. Subsequent packs wait until the preceding pack's lowest spawned row is passed; cloud exclusions and below-ground clipping remain. Long flights above8000 reserve the final choice zone through5180 studs (140 + two0.7-second intervals at3600), so ordinary chain walls cannot distract from final lane choices.

Final lane targets use0.7 seconds of current descent speed between floors, minimum140 studs; lowest floor stays140 when enough height exists. Spawn lead is1.8 seconds, minimum270 studs. Short flights compress within their available height. Each target retains its fixed world position after creation. Controls, acceleration, fall limits, collision sweep, target size, reward units/multipliers, rings, enemies and saved data are unchanged; changing target heights/counts can change per-flight reward totals.

Validation: all production Luau compiled;2941 mocked regression checks passed. Actual ~50000m recovery flight: lower Course rows6/10 instead of baseline0/12; final floor span1.399s instead of0.117s normally and0.066s at F speed. Actual F tests included both2/3 and3/3 final floors; the3/3 route hit center then two side bonuses.

User requested further dynamic steering QA. A downward-looking camera was visually captured. Actual WASD keyboard events were selected repeatedly from on-screen projected visible targets, with F toggled during flight; no player position or velocity injection during descent. First dynamic flight:70 input cycles,36 changes, high-speed Course6/8 and final floors2/3. After final-zone overlap exclusion:72 cycles,29 changes using all WASD directions and F; high-speed Course4/6, final floors2/3 (two bonuses), rings10/10, enemies2 individual hits across24 alternative-lane models. Peak50075m, landing speed3600. These automated visual-feedback agent trials are not representative human/mobile success rates and do not imply free steering is easy.

Evidence/backups: D:/Agent/outputs/descent-timing; final telemetry in dynamic-final.json. No publishing; StudioMemory tests were stopped. Native place saving requires Studio Ctrl+S; source sync was verified in Edit mode.
