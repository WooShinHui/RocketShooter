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
