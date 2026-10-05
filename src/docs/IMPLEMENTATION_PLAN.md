## 2026-10-04 Level bands and rocket cosmetics

Latest balancing supersedes the previous linear XP curve: RequiredXP(level)=(4+level)*(2+band)*lateBand, band=floor(level/20), lateBand=1+max(0,min(band,202)-2). First 20 levels still cost 540 XP total. XP rebirth multiplier is 1+0.5*rebirths, while PowerMultiplier retains the earlier propulsion curve. Passive +1/sec, Free 3/sec and OP 6/sec are unchanged. From level60 an additional band factor makes the curve cubic, switching back to quadratic at band202 to keep even maximum rebirth saves inside exact integer limits. Higher rebirth targets take longer with fixed bonus equipment; lower reset levels remain faster. Gold rings grant four levels worth of XP (minimum 200) once without multiplying that level-relative reward again.

Rocket cosmetics: Starter default; Ion free at rebirth 1; Bat 5 trophies; Mala 15 trophies and rebirth 1; Nova 40 trophies and rebirth 3. New saved integer fields RocketSkinMask and RocketSkinEquipped retain ownership/equip across rebirth, save and respawn. Legacy saves initialize safely and preserve trained levels, XP, trophies and equipment. Catalog indices are permanent save keys. Server validates idle state, eligibility, price and ownership; repeat equip never charges again. The shop reuses SimulatorHUD and displays actual BackRocket previews. Skins only change appearance, with no paid purchase flow.

## 2026-10-04 Clicker and reusable HUD

Screen clicks/taps award server-committed base +1 XP, including flight. Passive +1/sec and flight/toilet bonuses remain independent. Auto modes are exclusive: Off, Free (3/sec), OP (6/sec). OP is a labelled free prototype trial (ClickerConfig.PreviewOP=true); no Robux purchase/entitlement is connected. Disable PreviewOP before a paid release. Automatic rewards are server scheduled, capped for lag catch-up; manual input has an independent token bucket. No saved-data fields changed.

ClickerUI is the reusable presentation template: propulsion above an amber XP bar; level at left and XP at right inside the bar; white/rainbow cursor buttons. Reference: https://app.notion.com/p/3eea5ec9ae238061a920f227bdbe4afb, inspected in logged-in Chrome. Icon artwork is native scalable UI without external asset uploads.

## 2026-10-04 오른쪽 고도 정보

캐릭터 오른쪽에 현재 고도와 발사 레벨의 예상 최고 고도를 표시한다. 서버가 실제 발사에 쓰는 RocketMotion 프로필과 지면 기준으로 ExpectedHeight/LaunchLevel/GroundY를 전달한다. 비행 도중 레벨이 올라가도 이미 사용 중인 추진력을 바꾸지 않으므로 예상치는 발사 시점 값을 유지하고 다음 비행에서 갱신한다. 현재 고도는 상승/다이빙 모두 실시간 갱신하며 GUI 안전 영역 안으로 제한한다. 왼쪽 연료 원호는 유지한다.

## 2026-10-04 초반 시야·고속 연출·다이빙 조작 정리

첫 구름/바이옴 경계260m(이전150m). 구름과 카메라·캐릭터가 교차할 때 로컬 투명도를 높여 시야를 확보한다. 트로피 표지는 배경 없이105m 이내, 벽 너머 상시 표시 해제. 자동 다이빙 유지, F/터치 길게 누르는 동안 급강하, 놓으면 추가 가속 해제하되 이미 얻은 낙하 속도를 유지한다. 낮은 비행은 귀환 보조 문구를 작게,300m 이상 긴 낙하는 폭파 귀환 버튼으로 표시한다. 고속은 실제 속도180~5000에 비례하는 가장자리 속도선·이온 궤적·시야각 확장(최대약88도)·재사용 엔진 음원의 고음 바람층. 중앙 시야와 자유 카메라를 유지하며 가짜 버프나 물리/경험치 배수 변경 없음. 검증 D:/Agent/outputs/rocket-presentation/REPORT.md.

## 2026-10-04 사용자 QA 반영: 경험치 단위와 환생 페이스

기본 온라인 경험치는 레벨과 무관하게1/초로 고정한다. 환생 배수1/1.5/2.25/3.375…가 추가되고, 비행은 기본량 외1/초, 변기는 추가 훈련 경험치다. 장갑/발판의 별도 배수와 트로피 착지 보상은 유지한다. 요구 경험치는8+2×레벨, 환생 조건20/40/60… 유지. 첫20레벨540XP, 다음40레벨1880XP. 상승 높이·속도는 기존 레벨 추진력 곡선 그대로다. 레벨 상승 자체가 기본 경험치/초를 올리지는 않는다. 아래의3/초·12+3×레벨·8분 목표는 철회된 이전 시안이며 이 단락이 최신 기준이다. 기존40+12×레벨 곡선의 저장XP 이월을 유지한다.

## 2026-10-04 초반 성장 속도 조정

레벨 요구XP를12+3×레벨, 기본 경험치를3+0.3×max(0,레벨−1)^0.6/초로 조정한다. 비행+1/초와 변기 추가 경험치, 장갑/발판/환생 배수는 유지한다. 환생 요구레벨20/40/60… 및 돌 변기 조건(환생1·레벨5·트로피5)은 유지한다. 목표는 아이템·트로피 버프 없이 반복 비행 시 첫 두 환생 합계 약10분 이내. 기존40+12×레벨 요구량 범위의 저장된 잔여XP는 새 곡선에서 레벨로 이월하며 레벨/XP/구매/재화를 초기화하지 않는다. 검증 기록 D:/Agent/outputs/rocket-growth/REPORT.md.

## 2026-10-04 트로피 존 착지 보상

비행/변기/기본 온라인 성장은 경험치. 트로피는 서버가 확인한 하늘 트로피 존 윗면 착지에서만 지급한다. 일반 추락·폭파·취소는 트로피 0. 첫 존은 높이 90m, 옆 거리 110m, 넓이 60×68m. 12개 고정 레이어의 높이와 보상은 2배씩 증가(90/180/360…m, 1/2/4… 트로피), 마지막 높이 184320m. 옆 거리는 층당 8m 증가한다. 정상 상승 경로에서는 자동 착지되지 않으며 조종해서 옆으로 접근한 뒤 낙하 착지한다. 도달 가능한 최상층 목표의 화면 방향/가로 거리/높이 차이를 안내한다. 성공 착지는 사지 분리 없이 1.1초간 존에서 확인 후 귀환한다. 일반 바닥 충돌은 속도를 유지하며 기존 사지 분리. 서버 소유 고정 데크 윗면/법선/영역 검증, 한 비행당 한 번의 종료와 지급. 참고: references/benchmarks/reference-01/savezone.jpg.

# 2026-10-04 바닥 충돌과 원호 게이지 수정

지면 근처 높이에 따른 낙하 감속을 제거한다. 상승 끝의 quintic 감속과 낙하 시작1.2초의 부드러운 가속은 유지하며, 고속 낙하는 실제 충돌 표면까지 sweep 검사로 이동해 지면 관통을 방지한다. 지면 도착 전에 임의 높이에서 종료하지 않는다. 추진 게이지는 사용자 air_gauge.png를 참고한 왼쪽 청록색 원호 하나로 변경한다. 신규 비트맵/외부 에셋 없음. 검증 결과 D:/Agent/outputs/rocket-impact/REPORT.md.

---

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

# rocketShooter — Implementation Plan

The approved direction correction takes precedence over the historical phase order.
A+B, C and D are the accepted baseline. E — First Flight Presentation is the
current approved scope; later progression work requires separate approval.

## Approved direction and revised roadmap (2026-09-25)

"I reached a higher, farther space I could not reach before" must motivate the next
upgrade more than "I dodged obstacles better". Priorities: reach/altitude growth,
discovery, Cannon/Rocket growth, active control, then supporting obstacles/rings.

- A: Align these three design documents with growth and discovery.
- B: Independent forward/vertical Power curves, aim tradeoff, run-owned bounded ring
  lift, sparse low side obstacles and gentler penalty; preserve saves and reward rules.
- C: distinguish result metrics; bring forward the relevant PHASE 6 work (see below).
- D: First Discovery Experience — Ground -> Clouds only (see below).
- E: First Flight Presentation / Asset & SFX Polish — see E_PRESENTATION.md.
- F (NOT STARTED): PHASE 7-10 resource/upgrade loop supporting new-space reach.
- G (NOT STARTED): reconsider original PHASE 5 Ring/Combo as optional supporting rewards.
- Later historical route/equipment/collection phases remain unstarted.

### A+B tuning

BalanceConfig owns the curves. Horizontal Power remains 240+14*(L-1)^0.72;
vertical Power is 260+10*(L-1)^0.85. Horizontal aim uses cos(pitch)^4/cos(25)^3,
preserving the 25-degree baseline; vertical uses sin(pitch). Upward speed 2500 is a
technical extreme-level safeguard, replacing the early 135 cap. No camera or sky changes.
Ring lift no longer has a world-height 110 cap: total extra vertical impulse per run
is 25 + 0.35*max(0, launchVertical), with at most 25 per accepted contact. Spent lift
does not suppress existing upward velocity. Horizontal boost and debounce stay intact.

Three PHASE 4 patterns remain: Single 600 (side +65), Alternating 1200/2200
(sides +80/+120), Choice 3400 (sides -120/-160/-80). Top heights 28.5/36.5/44.5;
the central corridor stays open. Course bombs move to 1700/2900 at height 20.
All share the existing once-per-obstacle/run handler: velocity *0.9, then Y-5,
instead of *0.4 and Y-50. No new obstacle framework or damage system.

Gold formula and Trophies are unchanged. Power costs retain the old curve multiplied
by (min(verticalPower,2500)/260)^0.85 to offset extra airtime earnings. L1 remains
120 Gold. No stored fields, DataStore behavior or account balances are rewritten.

Predictions: GOOD timing, yaw zero, historical cannon geometry, gravity 196.2,
landing root Y=7.5, no rings/steering/hazards/ground slide. Heights are apex Y above
GroundY=0 in studs; these are analytical predictions, not Studio measurements.

| Power | 25deg forward / apex / seconds | 45deg forward / apex / seconds | Gold old -> new (25deg) | Cost old -> new | Runs old -> new |
| --- | --- | --- | --- | --- | --- |
| 1 | 266.7 / 46.8 / 1.19 | 162.2 / 106.7 / 1.94 | 46 -> 46 | 120 -> 120 | 2.61 -> 2.61 |
| 5 | 341.2 / 54.9 / 1.33 | 208.2 / 129.6 / 2.17 | 52 -> 56 | 253 -> 280 | 4.87 -> 5.00 |
| 10 | 414.5 / 64.0 / 1.46 | 253.6 / 154.9 / 2.40 | 56 -> 67 | 433 -> 523 | 7.73 -> 7.81 |
| 20 | 555.9 / 82.5 / 1.70 | 341.3 / 206.7 / 2.80 | 64 -> 86 | 813 -> 1128 | 12.70 -> 13.12 |
| 50 | 1003.2 / 145.5 / 2.33 | 618.8 / 383.0 / 3.88 | 80 -> 142 | 2054 -> 3784 | 25.68 -> 26.65 |

Before A+B the 25deg apex was 46.8 at every level (45deg: 67.0 due to the cap).
L200 at 45deg predicts apex 1733.8: room for later environment layers, not an
implemented region. High-angle flight currently earns less distance Gold than the
balanced shot; discovery/altitude rewards remain C+ work, not silently added here.
Runs are cost/Gold equivalents with no ring/target rewards, not guaranteed playtime.

Verification 2026-09-25: 238 mock regression checks passed, 28 runtime Luau files
compiled, Rojo build and ModuleScript artifact mapping checks passed. Coverage includes
growth through L200, angle tradeoffs, baseline upgrade effort within -5/+10% of the
previous curve, ring budget exhaustion/isolation/reset, stale contacts and low obstacle
clearance. Across representative single-collision ballistic samples, at least 78.2%
of forward range survives. This is not a guarantee for repeated collisions or terrain.
Studio acceptance: 25deg GOOD apex L1 49.6 / L50 148.1 studs; L50 at 15/25/45deg
63.3 / 148.1 / 387.9. Lifecycle, three real ring contacts (+75), and collision
velocity *0.9 then Y-5 with Health 100/result/return passed. Final budget stress check
on 2026-09-26 used the real run's server handler with colocated test rings: total
103.886/103.886, contacts 6-9 added zero vertical velocity; result and return passed.
Existing finite course end, 120s safety timeout and binary sky are unchanged; actual
environment layers and long-range landing extensions remain deferred C+ work.

Historical handoffs below describe earlier versions and are superseded by this tuning.

### C — Flight Result Metrics

Server FlightMetrics owns independent per-run maxima using validated physics samples.
Reward Distance remains maximum 3D displacement from muzzle; Gold, Trophies and
MaxDistance retain their existing rules. Forward Distance is maximum nonnegative
projection onto the horizontal launch axis captured at firing (not path length).
Max Altitude is maximum nonnegative root height above WorldService's shared GroundY,
not absolute world Y or height above the muzzle. Flight Time runs from launch to the
accepted grounded sample, including the existing landing debounce, excluding aiming
and the result screen. Distances/altitude are displayed/stored in whole studs; time
is displayed to two decimals. Sampling retains the existing 20 Hz validation cadence.

FlightResult appends a metrics table after its original six arguments. Result UI
shows reward Distance, Forward Distance, Max Altitude, Flight Time and existing rewards.
Successful runs also update MaxAltitude in the existing CannonGame_v3 / Player_<id>
save, with missing legacy values defaulting to zero. Unknown fields, raw persisted
snapshot conflict checks, load-failure protection and StudioMemory behavior remain.
Death/reset/cancellation do not award records. No altitude currency/reward is added.

WorldCoordinates.Measure(frame, position) exposes simultaneous current forward,
Ground-relative altitude and lateral coordinates for future spatial rules; do not
combine independent result maxima to infer that a particular space was reached.
A future fixed course frame can use the same function without rotating with aim.
No Region, Ground/Clouds content, new resource, Ring/Combo or SFX changes are included.

C verification 2026-09-26: 256 mock regression checks, 30 runtime Luau compilations,
Rojo build and ModuleScript mapping checks passed. One actual StudioMemory run at
L1/25deg/GOOD displayed Distance 356, Forward Distance 356, Max Altitude 49 studs,
Flight Time 1.97 s, Gold 58 and Trophy 1. MaxAltitude leaderstat matched 49; the
result UI was visually checked and its return button used successfully. Temporary
runtime test drivers are discarded on Stop; no production DataStore writes were
performed. Persistent legacy migration/conflict behavior was verified by mocks.

### D — First Discovery Experience (2026-09-26)

CloudConfig sets entry to Ground-relative altitude 180 studs and exit to 165 for
hysteresis. Using existing gravity 196.2 and cannon geometry, no-ring apex is
9.24715 + 15.991204*sin(pitch) + launchVertical^2/(2*196.2). Current measured L1/L50
25deg peaks 49.6/148.1 and L50 45deg 387.9 support the same scale as predictions.

| Power | 25deg GOOD apex | 45deg GOOD apex |
| --- | --- | --- |
| 1 | 46.8 | 106.7 |
| 5 | 54.9 | 129.6 |
| 10 | 64.0 | 154.9 |
| 15 | 73.1 | 180.4 |
| 20 | 82.5 | 206.7 |
| 50 | 145.5 | 383.0 |

First theoretical crossing: 45deg GOOD L15, PERFECT L10; L20 GOOD gives a useful
margin. At 25deg GOOD it takes L65 (PERFECT L53). These are not level gates:
bounded existing rings can help earlier; collisions, timing and physics affect
actual reach. L1 cannot cross with timing alone. No Power/cost/reward changes.

LevelConfig references CloudConfig. LevelBuilder adds CloudSection within each
existing streamed ground section; AssetRegistry supplies opaque, broad cloud banks
with four overlapping flattened lobes each. Three staggered lanes repeat every
240 studs, with varied centers at 152/198/218 altitude and vertical thickness. Gaps
preserve a view of the receding ground. No solid floor, touch trigger, damage or
cloud obstacles; the original section window/unload system owns their lifetime.

FlightMetrics exposes its current Ground-relative altitude. CloudDiscovery consumes
only validated active-run samples, with a per-run notice guard and descent hysteresis.
Existing FlightState carries Region changes with the original run id/character;
the client rejects stale/non-flying events and applies only local lighting + UI.
First discovery is distinguished from revisits using the existing saved MaxAltitude
and a session-only flag. Cancelled discovery does not write a new saved field or
award money; only normal C result finalization persists MaxAltitude. No new datastore
schema, economy, remote, or region framework. The old 400-Y Space sky switch is
replaced by bright Ground/Clouds presentation, with Ground restored on descent,
result/cancellation/character removal. One notice per run, including reentry.

E/SFX research and all later environments remain unstarted.

Spatial correction: six optional rings follow the L20/45deg GOOD reference arc at
forward distances 45/90/140/175/230/285, offset 38 studs sideways. LaunchTrajectory
shares the actual launch velocity and exit offset with FlightService; placement uses
the cannon pivot transform and Workspace gravity. The ring's local Z hole axis is
aligned to each trajectory tangent, including ascent, apex and descent. This is a
static reference path, not a prediction of steering or subsequent boosts. Ring
effects/budget, threshold, metrics and progression are unchanged.

Validation: 284 local checks, 34 runtime Luau compiles and Rojo build/mapping passed.
Studio ground-up visual inspection showed broad opaque banks with gaps and varying
ring tilt; nearby cloud geometry used 48 non-colliding parts. Actual L20/45deg GOOD
flight touched zero rings, reached altitude 211, forward/reward distance 344 and
flight time 4.23s. Cloud notice/local lighting, descent to Ground, Health 100,
Result -> Returning -> Idle passed. Result and ground views were visually inspected;
the brief mid-flight view was not captured. Temporary preview/test input is Play-only.

### E — First Flight Presentation (2026-09-27)

Removed the 38-stud ring offset and shared exact muzzle/character launch-origin
functions without changing physics or metric origins. Server-confirmed Ring contact
adds a 0.28s, at most 3-degree FOV impulse and distinct short SFX. Six separate
Creator Store/Roblox audio cues replace the packaged placeholders; Sound-instance
preload/play passed in Studio. Source, availability limits and measured trajectory /
feedback results are recorded in E_PRESENTATION.md. Cannon/Ground/Cloud visuals kept.
No progression or later regions added. Subjective audio mix still needs user listening.
Final checks: 301 regression checks, 34 Luau files compiled, Rojo build/mapping and
git diff --check passed. Two E-only Studio runs and six runtime Audio.Play probes
passed; tests used memory data and were discarded on Stop.

### Historical Audio/SFX audit (superseded by E)

Current temporary packaged sounds in PresentationConfig: Launch uses
rbxasset://sounds/action_jump.mp3; Collision uses action_jump_land.mp3;
Ring/Result/Upgrade reuse electronicpingshort.wav at different playback speeds.
No dedicated Combo/Rare Reward sound exists. Do not replace these during A+B.
Later compare multiple Roblox/Creator Store candidates per role: forceful cannon/rocket
launch, immediate short booster cue, restrained collision, repeat-friendly reward and
purchase, and extensible UI cues. Record Asset ID, creator/source, intended use,
comparison/selection reason, permission/experience availability and verification date.
Verify loading and actual audible playback separately in Studio and a published test
experience. Search visibility is not proof of permission. Import sound references only;
do not trust or run bundled model scripts. No external audio research has been done here.

After completing a major phase:

    report
    → verify
    → stop

Do not automatically begin the next major phase.

---

## PHASE 0 — Stabilize & Consolidate Existing Flight Loop

ACCEPTED BASELINE: the user confirmed the basic flight loop passed Studio
acceptance testing on 2026-09-20. Preserve this PHASE 0 behavior in later phases.

Existing gameplay:

    ProximityPrompt
      → Cannon Occupancy
      → Aim
      → Launch
      → Flight
      → Flight End
      → Distance / Reward
      → Result
      → Return

Relevant current source includes:

    src/client/Main.client.luau
    src/server/DataManager.server.luau
    reference/CannonServer.server.luau

The Cannon server reference currently represents a Studio-owned Script
inside the Canon model.

### Goal

Make the existing loop reliable before adding new gameplay.

Inspect and stabilize:

- cannon occupancy
- aiming
- fire request
- timing multiplier validation
- launch physics
- character visibility/collision
- network ownership
- camera
- flight state
- flight end conditions
- distance calculation
- reward calculation
- FlightResult
- ReturnToSpawn
- death/reset
- repeated launches
- delayed tasks
- stale state
- duplicate connections
- multiple players
- DataStore failure behavior

Server and client must agree on the lifecycle of a run.

A previous run must not be able to affect a newer run.

### Migration

During PHASE 0, determine whether the Studio-owned Cannon server Script
should be migrated into Rojo-managed source.

If migration is beneficial:

1. remove dependence on accidental `script.Parent` filesystem placement
2. preserve existing Canon behavior
3. establish explicit references/ownership
4. migrate deliberately
5. verify the Rojo-managed replacement
6. only then remove/disable the old Studio Script

Never run duplicate server implementations simultaneously.

### Acceptance

The player can repeatedly:

    enter
    → aim
    → launch
    → fly
    → finish
    → receive exactly one result/reward
    → return
    → repeat

without state corruption.

DataStore failures must not overwrite valid existing progress with
unintended defaults.

---

## PHASE 1 — Horizontal Flight Control

ACCEPTED BASELINE: on 2026-09-20 the user confirmed A/D steering, inertia,
launch, landing and return all passed Studio testing and approved PHASE 1 completion.
Local implementation passed 112 mock-engine checks, Luau compilation and Rojo build.
See PHASE_1_HANDOFF.md for the original handoff.

Add meaningful left/right steering.

Keep launch power and trajectory relevant.

Do not create unrestricted free flight.

---

## PHASE 2 — Level Builder Foundation

ACCEPTED BASELINE: on 2026-09-23 the user accepted PHASE 0-2 and balance corrections
as completed. Studio world inspection and prior automated verification are recorded below.
See PHASE_2_HANDOFF.md. Do not begin PHASE 3 automatically.

2026-09-20 follow-up: user requested stronger steering, a playable nearby course,
stable spawn/sky and sound effects. Implemented on the PHASE 2 foundation;
158 automated checks passed and one real Studio launch/result/return cycle passed.
See PLAYABLE_COURSE_HANDOFF.md for scope, tuning and remaining acceptance checks.

2026-09-20 balance follow-up: shared progression curves, separate horizontal/vertical
launch growth, bounded ring boost and course-facing flight camera implemented.
See BALANCE_HANDOFF.md for predictions, verification and the Rojo config sync fix.
This was PHASE 2 correction work; PHASE 3 was subsequently authorized separately.

Determine:

- actual flight direction
- coordinate conventions
- distance/progression metric
- generated-content ownership

Create the minimum data-driven system needed for reusable flight sections.

Target:

A configuration can generate a deterministic simple section.

Do not overbuild.

---

## PHASE 3 — Asset Registry

ACCEPTED BASELINE: user approved PHASE 3 completion on 2026-09-23.

Implemented 2026-09-23: server-only `src/server/AssetRegistry.luau` contains immutable
Key -> definition data (Category, Size, Color, optional Template). Categories:
Obstacle, Ring, Environment, Landmark, LandingTarget. `Get(key)` returns a definition
or nil; `Create(key)` returns unparented geometry + Primitive/Template/Fallback status.
No Marketplace IDs are loaded and no external assets were researched or inserted.

LevelBuilder accepts optional `Assets` on a Section in LevelConfig, for example:

```luau
Assets = {
    {Key = "Test.Environment", Offset = 40, Lateral = 60, Height = 8},
    {Key = "Local.Landmark", Offset = 100, Lateral = -60, Height = 15},
}
```

Offset is relative to each repeated section start, Lateral to course right, Height
above course GroundY; the object's pivot faces course forward. All placement math uses
WorldCoordinates. Objects live inside GeneratedWorld's section and unload with it.
Current LevelConfig has no Assets placements: current course/Gimmicks and balance are unchanged.

Test.* keys are noncolliding primitive blocks (including the Ring placeholder), not
functional gameplay objects. Local.Landmark optionally clones a reviewed Model/BasePart
named Landmark in ServerStorage.AssetTemplates, without expanding Rojo ownership there.
Source templates remain untouched. Clones have code descendants removed and parts anchored,
noncolliding/non-touching before parenting; root LandingTarget reward metadata is cleared.
Future gameplay bindings are deliberately outside this phase.

Missing key/template, wrong type, empty model or clone failure uses a primitive fallback.
Invalid placement or fallback creation failure skips that placement without stopping the
section or other assets. No remote loads/yields occur during generation. Fallbacks have
AssetKey/AssetCategory/AssetFallback attributes; template failures warn once per key.

Verification: 207 mock regression checks, Luau compilation and Rojo build/artifact checks.
New coverage includes primitive categories, missing/wrong/unclonable templates, code removal,
source preservation, rotated placement, failure isolation, unload and deterministic rebuild.
No new Studio Play Test in PHASE 3. PHASE 4 was subsequently authorized separately.

Create reusable asset references.

Start only with assets required for upcoming gameplay.

Reuse suitable existing assets.

Research/integrate external assets when available tools permit it.

---

## PHASE 4 — Obstacles

Implemented 2026-09-23: LevelConfig.Obstacles -> ObstaclePatterns -> AssetRegistry,
owned by the existing GeneratedWorld sections. Six boxes: Single at 200, alternating
at 420/840, three-box Choice with two 28-stud gaps at 1260. Start/Lateral/Height,
Width/HeightSize/Depth, Count/Spacing/SideOffset/Gap are configurable; no new assets.
Existing Bomb handler supplies velocity * 0.4 plus Y -50, no health damage; contacts
are once per obstacle per run (stable generated ID across section rebuilds).
222 regression checks, 28 Luau compiles and Rojo build passed. L1 lateral spacing
checked analytically; farther patterns are progression content, not all guaranteed
reachable on the first baseline shot. Existing ring/flight/reward/data values unchanged.
Studio: collision smoke test gave one penalty, Health 100, result and normal return.
A second attempt using temporary automated adapter input did not demonstrate lateral
movement, so keyboard A/D avoidance and later patterns remain manual acceptance checks.
No PHASE 5 work.

Use LevelBuilder to create meaningful obstacle sections.

Steering can improve a run; obstacle mastery is not a prerequisite for progression.
The original dense placement and penalty above are historical and superseded by A+B.

---

## PHASE 5 — Rings / Combo

Implement:

- reusable rings
- RingSection generation
- detection
- combo
- combo break
- reward integration

Courses should be configurable.

---

## PHASE 6 — Run Result Model

Clearly separate:

    Distance
    Score
    Reward

Important reward calculation must remain server-authoritative.

---

## PHASE 7 — Gunpowder Gathering

Create the first ground-resource activity.

Gunpowder becomes the primary direct cannon/rocket progression resource.

---

## PHASE 8 — Cannon Upgrade

Connect:

    Gunpowder
        → stronger launch

Start with a small number of meaningful stats.

---

## PHASE 9 — Flight Resource

Introduce a resource earned through successful flight.

Primary purpose:

    improve Gunpowder acquisition

Complete the circular progression loop.

---

## PHASE 10 — Mining Progression

Introduce appropriate improvements such as:

- speed
- yield
- capacity

Do not eliminate the gathering loop.

---

## PHASE 11 — Regions

Create data-driven distance regions with distinct gameplay and content.

---

## PHASE 12 — Region Content

Use LevelBuilder + AssetRegistry to create coherent region content.

Include appropriate:

- environment
- obstacles
- rings
- rewards
- assets

---

## PHASE 13 — Route Choice

Introduce meaningful branching:

    SAFE
    SKILL
    RESOURCE

Different routes should pursue different objectives.

---

## PHASE 14 — Equipment Builds

Introduce cannon/rocket identities such as:

    Power
    Control
    Combo
    Resource

Avoid pure vertical replacement.

---

## PHASE 15 — Collection

Expand:

- cannons
- rockets
- skins
- trails
- effects
- collectibles

---

## PHASE 16 — Landing Challenges

Make landing an additional skill and reward opportunity.

---

## PHASE 17 — Dynamic Events

Add controlled run variation.

---

## PHASE 18 — Multiplayer

Add competitive/cooperative interaction after the core loop is stable.

Design counterplay before disruptive mechanics.

---

## PHASE 19 — Monetization Infrastructure

Implement robust MarketplaceService systems.

Separate:

- Developer Products
- Game Passes
- Cosmetics

Keep fulfillment server-authoritative.

---

## PHASE 20 — Monetization Content

Potential initial products:

- cannon skins
- rocket skins
- trails
- launch effects
- temporary boosts
- mining convenience

Do not remove the reason to play.

---

## PHASE 21 — Retention

After the core loop is proven:

- missions
- daily rewards
- milestones
- achievements
- records
- leaderboards
- rotating challenges

## 2026-10-03 — User-authorized height / AFK / rebirth content pass
Implemented direct user scope without agents. See CONTENT_PASS_2026_10_03.md for migration, tuning, runtime evidence, and unresolved Notion reference access. Intro/tutorial remain deferred. New SkyLife fall hazards supersede earlier nonfatal-obstacle guidance for those objects only.


## 2026-10-04 Notion revision
See NOTION_REVISION_2026_10_04.md. Scattered reward targets, destructible islands, pursuing enemies, low-ground ascent, progression/clicker/toilet systems and icon-first UI applied; 488 mocked regression checks and Studio core-path QA passed. User review pending; no template extraction or publishing.


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

Completed requested cloud revision. All production Luau compiles; existing 2679 mock assertions and Rojo build pass. Additional trajectory checks validate every gate's recommended power, one power below the recommendation, spacing, stage families and sky transitions. Studio actual flights: unequipped rebirth0 Lv20 clears first gate and safely awards47 run trophies; Lv190 clears third gate (predicted12579.02, observed12575), safely awards518. Sky changed at12500 on ascent,10494 on descent, then3998 and476; no timed mountain reset. All eight presentation groups instantiate 4 through12 characters, with every actual SpecialMesh dependency preload successful. Desktop warning visually inspected; iPhone portrait401x778 and landscape750x361 both TextFits=true. Lightning triggered inside both observed gates and was disabled outside. Console has no runtime errors. Rollback backups and report: D:/Agent/outputs/gate-revision. Native Studio save still required; no publishing.


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


### 2026-10-05 — Two requested speed presentation effects

RocketSpeedFX now uses48 long gradient streaks (previous24), cyan/violet/warm-gold colors and continuously integrated animation phase. High-speed ascent repeats a bounded shockwave every1.1s, doubles the approximate wake length to240 studs and emits two small built-in sparkle wisps (max40 total particles/s,0.12–0.2s lifetime). One shockwave frame is reused/replaced; no accumulating objects. Speed threshold/intensity curve and the existing FOV control remain unchanged.

A white four-edge UIGradient vignette appears on descent, with intensity based on downward speed plus an F/held-dive boost. It eases on/off, leaves the center transparent and does not block input. A fullscreen RocketSpeedOverlay sits one display order below RocketFlightGui. The existing speed banner hides on compact-height screens to avoid overlapping gameplay HUD. Clear resets intensity and vignette to0, hides the overlay layer and removes character trail/particle attachments.

Only production RocketSpeedFX.luau and RocketClient.luau changed. No physics, controls, world targets, rewards, persistent data or equipment changes; no imported asset. Validation: all production Luau compilation, Rojo build and existing2937 regressions. Actual Studio Lv190 ascent screenshot shows colored streaks; sampled upward speed2222 and intensity0.760, two wisps with combined rate30.38, wake length about242 studs. Normal high-speed descent vignette reached0.697; F held at speed184 gave0.432 with transparent center. Normal landing cleared both intensities, pulse and visibility to0/false. New Studio connection id matched rocketShooter.rbxl. Delivery/backups: D:/Agent/outputs/speed-fx. Studio source backups: ServerStorage.SpeedFXRollback. Mobile hardware performance still needs device testing.


User visual correction (supersedes shockwave/wake/wisp design above): removed circular shockwave, speed banner and all added character-attached wake/particles. Speed effect uses40 long peripheral streaks plus40 trailing afterimages, leaving the middle clear. The thin cool-white descent edge haze is capped at0.14 intensity (effective one-edge alpha at most0.091), instead of a broad white wash. The overlay uses ScreenInsets.None, ClipToDeviceSafeArea=false and SafeAreaCompatibility.None so phone safe-area bounds do not form an inset rectangle.

Compact flight UI: hides the idle clicker power/XP bar during flight; replaces floating fuel/altitude blocks with a fixed one-line height/fuel/level readout; smaller action buttons, reward text and next-target guide; chain notices stack below the readout/guide; XP popups use one bottom-center slot; inactive event countdown hides during compact flight. Desktop flight readouts and idle mobile progression are retained. Changed client files additionally include ClickerClient, DiveBreakGuide, DestructionFX and ExperiencePopup. Actual750x361 mobile emulator showed no overlaps among reward/readout/guide/chain/actions and all text labels fitted. Actual1080-level flight reached190214 altitude and space sky; descending screenshot confirmed clear center, peripheral streaks, no circle and aligned compact HUD. Final compile/Rojo/2937 regressions passed. Device hardware FPS and portrait physical-device QA remain unverified.


### 2026-10-05 — Descent target reaction-time revision

Implemented speed-proportional0.7-second target spacing and1.8-second spawn lead in BreakCourse/DiveBreakZone; long packs do not overlap and high flights reserve the final lane-choice zone. Flight controls/physics remain unchanged. Short-flight layouts remain above ground; existing one-time server rewards are retained. Updated dive-impact and dive-break-zone assertions for normal/aim/F timing. All production Luau compile and2941 regressions pass. Actual50000m tests include repeated screen-dependent WASD with downward camera and toggled F, not only stationary central routes. Final dynamic trial:4/6 high-speed Course blocks,2/3 final floors,10/10 rings; movement remains challenging. Exact evidence and rollback source are in D:/Agent/outputs/descent-timing. No publish or persisted test data; Play stopped. Rojo source verified in Studio; native current-place save remains Ctrl+S.


### 2026-10-05 — Fixed descent windows, equipment and flight camera

Supersedes the thin, final-only descent target layout: repeated fixed XZ lane sections now provide a three-second vertical collision window at the planned descent speed (90–3600), with central x1 and two side x3 choices. A player can reach a lane after crossing its entrance and still hit it. Current/next sections are bounded to six lane models. Each lane contains sixty large height-colored butter meshes; no yellow wireframe/outline parts remain. Meshes in a lane share one destruction/reward claim. Rings and harmless descent cloud targets remain. Standard ascent course is unchanged; its thin descent walls no longer spawn. Flight movement is unchanged.

An unfinished cloud catches the player when fuel runs out or they abort inside it. Already-completed gates remain safe on the return descent. Failed runs award zero trophies and preserve previously banked trophies. The normal auto-clicker uses the former OP cursor; OP uses a rainbow gradient cursor. Five purchased trails gain animated colored exhaust-wrapping streams. Ten procedural rocket shapes were appended to the original five (sausage, keyboard, pencil, banana, donut, fish, soda, pizza, cloud, satellite); original saved equipment indices remain valid. Wakpuball was omitted at user request.

Ascent retains the Roblox Custom camera with minimum zoom 0.5 and zero Humanoid camera offset, allowing mouse-wheel zoom and first person. Previous camera settings restore on flight completion.

Validation: all production Luau compile, 2806 mocked regression checks, Rojo build, actual Studio Play. Dynamic ~50075m descent used downward camera, all WASD directions and toggled F; 72 feedback samples, 19 input changes, 8 lane claims across 4 sections including 5 bonuses. One bonus was reached about 1.5s after its entrance, confirming late lateral recovery. These are agent trials, not human success-rate statistics. Actual cloud failures at ~588m and ~59021m awarded zero; purchased sausage/Prism visuals and all 15 rocket previews were inspected. Latest no-wireframe descent counted 180 butter meshes and zero outline parts; upward flight wheel input reached ~0.502 first-person distance and zoomed back to ~22.98. Physical mobile pinch/FPS and multiplayer load remain unverified. Evidence and guarded source backups: D:/Agent/outputs/flight-followup. No publish.
