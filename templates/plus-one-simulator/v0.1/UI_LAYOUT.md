# 현재 UI의 정확한 레이아웃 규격

공통 UI의 위치/순서/비율/색/폰트/이벤트를 유지한다. 치수는 Roblox 논리 픽셀이다. `reference/ui-runtime.json`은 1365×768 뷰포트에서 캡처했다. ScreenGui 안전 영역 때문에 `AbsolutePosition`과 화면 캡처의 물리 픽셀 좌표는 그대로 일치하지 않을 수 있다. 실제 구현은 아래 UDim2와 소스 함수를 사용한다. UI 스케일링·중앙 애니메이션 이후 런타임 Position이 생성 코드의 좌상단 Position과 다른 것은 정상이다.

## 공통 화면 구성

| 영역 | 현재 구성 | 기준 구현 |
|---|---|---|
| 왼쪽 위 | 트로피 아이콘+잔액, 그 아래 환생 아이콘+횟수. 노란 숫자, 별도 배경 상자 없음 | `SimulatorHUD.currency`, `CurrencyHud` |
| 왼쪽 중앙 | 가로로 긴 Store. 아래 2×2: Rebirth/Food, Trails/World Travel | `TotalHud.Navigation` |
| 오른쪽 위 | Guide, Settings 원형 버튼. Roblox 메뉴 버튼과 같은 높이 | `TopToolsHUD.TopTools` |
| 그 바로 아래 | Rebirth +1 / Level +1, FREE PLAYTEST (현 중간본의 테스트 기능) | `StudioProgressTest.client` |
| 오른쪽 중앙 | x2 Wins, 그 아래 x2 Power. 각 카드 아래 15분 또는 남은 시간 | `TotalHud.DurationOffers` |
| 왼쪽 아래 | Friend Boost: +n% 민트색 | `TotalHud.FriendBoost` |
| 하단 중앙 | 청록 Power 숫자 → 금색 XP 게이지/암회색 트랙 → x2/x4/x8/+ 카드 | `ClickerUI`, `ClickerClient` |
| XP 게이지 왼쪽 | Thrust +n, Growth +n% | `ClickerUI.EquipmentBonuses` |
| XP 게이지 오른쪽 | 위 OP Auto Click 무지개, 아래 Auto Click 흰색. ON/OFF, ON이면 초록 외곽선 | `ClickerUI.Button` |
| 화면 상단 중앙 | 골드 보너스 이벤트 카운트다운/활성 시간 | `RocketClient.GoldRingEventNotice` |
| 캐릭터 근처 | 서버가 실제 지급한 +n XP 팝업 | `ExperiencePopup`, `XPProjection` |

Gifts/Training/Inventory 바로가기와 옛 GrowthDock은 현재 표시하지 않는다. 이미지 스터드/대시 장식도 없다. 숨겨진 옛 UI를 화면에 다시 올리지 않는다.

## UDim2와 반응형 수치

### 왼쪽 메뉴 / 오른쪽 카드

Navigation은 224×282, X=12. Store=(0,0),224×66. Rebirth=(0,76),106×98. Food=(118,76),106×98. Trails=(0,184),106×98. WorldTravel=(118,184),106×98. 아이콘이 있는 타일은 58×58, 상단 중앙, 글자는 Y=65. Store 아이콘은 (18,7),52×52, 글자는 X=78.

안전 영역 크기를 W,H라 할 때 `s=max(.4,min(1,(H-310)/282,W/1100))`. 왼쪽 Y=`max(120,(H-192-282*s)/2+40)`. 오른쪽 카드도 같은 s를 사용한다. DurationOffers는 AnchorPoint=(1,.5),Position=(1,-12,.48,0),Size=180×230. Wins2=(0,0),180×92. Power2=(0,128),180×92. 남은 시간 라벨은 Y=94/222,180×25. 카드 내부 아이콘 45×45,(8,20),TBD/Robux는 오른쪽 위.

FriendBoost는 AnchorPoint=(0,1),Position=(0,12,1,-10),왼쪽 정렬. W<900 또는 H<600이면 글자16/너비190, 아니면22/260. 높이30.

### 상단 버튼

TopToolsHUD만 **TopbarSafeInsets**. TopTools AnchorPoint=(1,0),Position=(1,-16,0,12),Size=96×44. Guide는 X=0, Settings는 X=52. 클릭 영역44×44, 아이콘24×24,(10,10),원형 UICorner. 일반 메뉴처럼 전체 도크 스케일을 적용하지 않는다. Roblox CoreGui의 메뉴/채팅 아이콘은 플랫폼 UI이므로 복제하지 않는다.

테스트 영역은 CoreUISafeInsets,AnchorPoint=(1,0),Position=(1,-10,0,8),Size=222×56. 버튼108×28, X=0/114, Status Y=32. `TemporaryFreeTesting=true`일 때의 현재 중간본에 포함되며 출시 상태와 구분한다.

### 하단 그룹

BottomHUD:1040×192,AnchorPoint=(.5,1),Position=(.5,0,1,-12). 전체를 하나의 UIScale로 묶는다. 배율=`min(1,max(1,W-24)/1040,max(1,H-24)/500)`.

| 요소 | BottomHUD/ClickerProgress 내부 위치 | 크기 |
|---|---|---|
| ClickerProgress | BottomHUD (172,0) | 560×190 |
| Power | Progress (0,0) | 365×44, 글자38, 가운데 정렬 |
| PowerMultiplier | Progress (370,0) | 190×22, 글자18, 오른쪽 정렬 |
| FoodPercent | Progress (370,22) | 190×22, 글자18 |
| XPBar | Progress (0,48) | 560×58 |
| Level | XPBar (14,0) | (45%−14)×100%, 글자30, 왼쪽 정렬 |
| XPValue | XPBar (45%,0) | (55%−14)×100%, 글자32, 오른쪽 정렬 |
| XPFill | XPBar (0,0) | 폭 clamp(XP/RequiredXP,0,1),높이100% |
| EquipmentBonuses | BottomHUD (0,48) | 156×110 |
| Thrust / Growth | Bonuses (0,0)/(0,36) | 156×36, 글자20, 오른쪽 정렬 |
| UpgradeOffers | Progress (0,114) | 560×74 |
| x2/x4/x8 | Offers X=0/164/328,Y=0 | 각154×74 |
| + | Offers (502,0) | 58×74 |
| ClickerButtons | BottomHUD (752,40) | 228×152 |
| OP / Free | Buttons (0,0)/(0,82) | 각228×70 |

XP 트랙 RGB(57,57,51),금색 채움(255,191,32). 채움에는 그라데이션이 없다. XP 바 UICorner=5px/검은 외곽선4px. Power=(115,235,255),Thrust=(160,215,255),Growth/Food=(134,255,184),Multiplier=(197,171,255). x2/x4/x8 카드의 색은 (255,215,48)/(255,146,38)/(250,73,83),표시 가격99/199/349. 카드 클릭은 **Store를 여는 것**이며 직접 결제하거나 부스트를 지급하지 않는다.

OP의 5색 배경 그라데이션 Rotation20: (255,84,120),(255,213,62),(71,233,163),(72,177,255),(182,98,255). Free 배경은 완전 흰색,그라데이션 없음. 두 커서는 실제 같은 이미지135569585073294를 사용하며 OP 커서만 별도의 5색 그라데이션 Rotation35. ON이면 외곽선(74,255,132),5px; OFF는 검정4px. `3/s`,`6/s` 같은 클릭 속도 캡션은 화면에 표시하지 않는다.

### 상태에 따른 표시

- Idle: 메뉴·오른쪽 카드·상단 도구·하단 장비·상품·자동 클릭 버튼 표시.
- 행동 진행 중(현 `Flying`): 메뉴/오른쪽 카드/상단 도구를 숨기고 열린 HUDPage를 닫는다. 자동 클릭 버튼·장비 보너스·상품도 숨긴다. 서버 자동 클릭 모드가 자동으로 OFF가 되는 것은 아니다.
- 데스크톱 행동 중 W≥700,H≥500: Power/XP 표시를 유지하고 Progress의 Y를80으로 이동.
- 작은 화면 행동 중: 하단 그룹을 숨긴다. 캐릭터 XP 팝업은 화면 하단의 간소화 위치로 표시.
- 모달 열림: 하단 그룹·경험치 팝업·월드 수동 클릭을 차단한다. 온라인 XP/서버 자동 XP를 정지시키지 않는다.
- 재생성: ResetOnSpawn=false인 화면은 유지한다. 캐릭터에 연결된 팝업/훈련 좌석은 정리한다.

## 팝업과 페이지

중앙 모달의 배경(30,48,73),글자 GothamBlack/흰색/외곽선. Shade를 클릭하거나 Close를 눌러 닫는다. `HUDPage`로 한 페이지만 활성화한다.

| 페이지 | 레이아웃 | 내용/동작 |
|---|---|---|
| Store | TotalMenus.Panel560×470 | Wins2/Power2/Power4/Power8, 각508×64, Y=0/76/152/228; FREE TEST/15min |
| Food | 같은 Panel | None/Snack/Meal/Feast,선택 카드 노란색,현재 무료/세션 선택 |
| World | 같은 Panel | World 2 · Coming Soon. 실제 이동/해금 없음 |
| Guide | 같은 Panel | 성장/장비/훈련/Power 공식 안내. 다음 게임에서는 행동 설명 문장만 대응 행동으로 바꿀 수 있음 |
| Settings | 같은 Panel | Sound ON/OFF,현재/새 음성 로컬 음소거. 세션 동안만 적용 |
| Rebirth | ProgressionGui.RebirthPanel500×460 | RequiredLevel,현재/다음 XP 배율 카드,진행 게이지,Confirm,Skip Coming Soon,초기화/유지 안내 |
| Trails | RocketSkinGui.Shop560×530 | 잔액·장비 보너스,스크롤 카드516×94/간격102,선택/Owned/Buy/Locked 상태. 로켓 탭은 숨김 |

TotalMenus:제목(22,12),450×48/글자32;Close(494,12),50×48;Content(18,80),524×330;Status(18,418),524×38. Rebirth 세부 구조와 실제 열린 상태는 `reference/ui-pages.json`/`ProgressionHud.client.luau` 그대로 사용한다.

Trails는 초기 생성값보다 마지막 HUD.fit 콜백이 우선한다. w=min(560,max(280,safeWidth−24)),h=min(530,max(230,safeHeight−24)),배율1,narrow=w<480,compact=h<450. 데스크톱 리스트는(16,106),528×362,카드Action(390,22),114×50,메시지(18,482),524×36,Close(494,10),50×44. 작은 화면 리스트 Y=78,너비w−32,높이h−78−42. narrow 카드 Action 폭98/Name X78,일반114/X98. 이 반응형을 그대로 유지하며 숨겨진 장비 탭을 다시 보여주지 않는다.

현재 결과 연출은 중앙 ResultPanel이 아니라 `FlightSummary.client`의 **캐릭터 머리 위 결과 텍스트 묶음**이다. 기존 Main은 ResultGui를 비활성화하고 RocketClient만 시작한다. 자동 복귀 후 머리에 XP/트로피/행동 기록/New Record를 .12s 간격으로 표시하고2.6s후제거한다. 크기360×32/글자23/행간27,초당22px상승,1.1s지연뒤1.3s페이드. 결과 중앙 모달/Return 버튼을 새로 만들지 않는다. 현 `SimulatorHUD.result`는 보존된 과거 헬퍼이지 현재 화면이 아니다.

HUD.fit 배율=`clamp(min(viewport.X/(width+32),viewport.Y/(height+96)),.45,1)`. 팝업은 중앙 AnchorPoint(.5,.5) 유지. MenuEntranceScale은 .92→1, .18s,Back/Out. 버튼은 중앙 AnchorPoint(.5,.5)를 보존하며 Hover=1.035,Press=.95,Normal=1, .13s Quad/Out. 위치 갱신/크기 변경 후에도 원래 중심을 유지한다.

## 시각 검수

`current-ui.png`는 실화면,`ui-layout.png`는 좌표 도면이다. 수치/남은 시간/XP 팝업은 데이터이고 레이아웃 변경이 아니다. 새 게임은 같은 뷰포트/안전 영역에서 화면을 캡처하여 버튼 순서,앵커,간격,그라데이션,팝업·반응형을 비교한다. 외부 에셋 ID는 `UIIcons`/`ASSETS.md`를 그대로 사용한다.
