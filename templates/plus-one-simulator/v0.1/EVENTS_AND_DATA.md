# 버튼·이벤트·원격·데이터 계약

## 사용자 이벤트 → 서버/표시

| 진입점 | 클라이언트 이벤트 | 서버 요청/검증 | 결과 |
|---|---|---|---|
| 월드 클릭/터치 | 처리되지 않은 1회 입력 | ClickTraining(),살아있음/준비/토큰 버킷 | 실제 XP 지급/ExperienceGained |
| Free/OP | 선택 모드 또는Off | ToggleAutoClick(mode),허용모드/준비/OP프리뷰/.15s | 배타적 모드/ON외곽선 |
| Store/하단x2,x4,x8,+ | HUDPage=Store | 메뉴 열 때 서버 경제 변경 없음 | Store 모달 |
| 오른쪽 x2 Wins/Power | busy일 때 중복 호출 금지 | UsePowerBoost(Boost,Wins2/Power2) |900s/카드 타이머 |
| Store 부스트 행 | 선택된 ID | UsePowerBoost(Boost,id) | 성공/거절 메시지/기간 교체 |
| Food | HUDPage=Food,선택 index | UsePowerBoost(Food,index) | FoodSelected/Power 갱신 |
| Rebirth | HUDPage=Rebirth | 확인 버튼만 RequestRebirth(currentRebirths) | 리셋/유지값 갱신,성공 사운드 |
| Trails | HUDPage=Trails/RocketSkinShopOpen=true | Action 버튼만 SelectRocketTrail(index) | 비용/소유권/선택/메시지 |
| World Travel | HUDPage=World | 활성 travel remote없음 | World2 Coming Soon |
| Guide | HUDPage=Guide | 없음 | 설명 |
| Settings/Sound | HUDSoundMuted 로컬 토글 | 서버 요청 없음 | SoundGroup과새음성음소거 |
| 닫기/배경 | HUDPage=nil,장비 모달 닫기 | 없음 | 단일 모달 닫힘/수동 입력 복귀 |
| 장비 E/X/터치 | ProximityPrompt.Triggered | .Magnitude≤14,준비/살아있음/Idle/카탈로그 | 영구 구매/장착·피드백 |
| 훈련소 E/접근 | 잠긴Tier프롬프트/서버AutoJoin | 환생/Tier/근접/높이/개인 좌석 | 추가XP세션 |
| 훈련 E/점프 | LeaveSharedTraining() | 요청자의Idle개인세션만 | 퇴장/9stud재진입블록 |
| 테스트 +1 | StudioProgressTest(Level/Rebirth) | FreeTesting/준비/Idle/.2s | 직접 +1,실제 환생과달리Level/XP안리셋 |

공통 `HUDPage` 값:nil,Store,Food,World,Guide,Settings,Rebirth,Trails. `ProgressionModalOpen`은 메뉴 입력 잠금 브리지다. 한 모달만 열린다. 메뉴가 닫혀도 온라인 XP/자동 클릭의 서버 스케줄은 계속된다. UI 이벤트와 숫자 지급을 같은 클라이언트 함수로 합치지 않는다.

## 현 Remotes

| 이름 | 타입/방향 | 페이로드 의미 |
|---|---|---|
| ClickTraining | RemoteEvent C→S | 인자없음. XP값 받지않음 |
| ToggleAutoClick | RemoteFunction C→S | Off/Free/OP,반환 success/note |
| ExperienceGained | RemoteEvent S→C | 지급된정수gain,현재Character,source |
| RequestRebirth | RemoteFunction C→S | expectedRebirths |
| BuyTrainingTier | RemoteFunction C→S | Tier index |
| BuyXPItem | RemoteFunction C→S | expected next index |
| UsePowerBoost | RemoteFunction C→S | action=Boost/Food,id/index |
| SelectRocketTrail | RemoteFunction C→S | 영구목록index |
| SelectRocketSkin | RemoteFunction C→S | 목록index,전시근접/소유검증 |
| LeaveSharedTraining | RemoteEvent C→S | 인자없음 |
| StudioProgressTest | RemoteFunction C→S | Level/Rebirth,테스트플래그 |
| FlightState | RemoteEvent S→C | state,runId,character,reason;XP/Dive 알림도 현 호환 패킷 |
| FireCannon | RemoteEvent | 현 로켓 시작 S→C 패킷. legacy C→S 의미와 혼동 금지 |
| FlightResult | RemoteEvent S→C | metric,0gold,trophies,record,runId,character,metrics |
| ReturnToSpawn | RemoteEvent C→S | runId,action(Dive/DiveStop/기타 현 행동제어) |
| SteerFlight | RemoteEvent C→S | axis,runId,cameraRight;유한값/현재Run검증 |
| BarrierDestroyed | RemoteEvent S→C | 검증된적중/VFX. 실제서버보상후알림 |
| AimCannon/BuyUpgrade/ResetData | legacy호환 | 현재 +1 성장의새설계가아님. BuyUpgrade는현모드false,ResetData는항상false |

실제 생성 위치/핸들러와 모든 입력·속성 사용 위치는 `API_INVENTORY.md`를 확인한다. Remotes.Ensure에 없는 추가 Remotes는 각 서버 컨트롤러가 생성한다. 동일 이름/타입의 객체가 두 개 실행되는 설치를 만들지 않는다.

쿨다운: 수동 클릭토큰10/s·2,자동모드.15s,환생expected동시성검증,XP장비.2s,장비/트레일.2s,부스트/음식.4s,테스트.2s,현행동시작1.5s. 반환 실패면 안내만표시하고 클라이언트에서 값을 미리 올리지 않는다.

## 영구 프로필 스키마

| 키 | 신규 기본값 | 저장/의미 |
|---|---:|---|
| Trophies | 0 | 공통통화 |
| TrainingLevel | 0 | Level |
| TrainingXP | 0 | 현재레벨잔여XP |
| Rebirths | 0 | 영구환생 |
| TrainingTier | 1 | 영구최고훈련소 |
| XPGearLvl | 1 | XP장비단계 |
| RocketSkinMask/Equipped | 1/1 | 영구장비비트/선택,이름은호환키 |
| RocketTrailMask/Equipped | 1/1 | 영구트레일비트/선택 |
| MaxDistance/MaxAltitude | 0/0 | 현행동기록. 다음게임에서는명시적metric매핑 |
| PowerLvl/BoostLvl | 1/1 | 과거호환기본파라미터,현재직접Power구매금지 |
| Gold | 0 | 과거호환키,현재지급0 |
| EconomyVersion | 0→1 | 성공로드시검증된마이그레이션 |

서버 내부 `profile.stats`가 실제 원본이다. leaderstats와ProgressStats는복제표시용Instance며 클라이언트수정은 지급근거가 아니다. 현 모드의 Gold/PowerLvl/BoostLvl/EconomyVersion/장비마스크·선택은ProgressStats에,다른항목은leaderstats에 놓인다.

새 게임을 새 DataStore로 시작하면같은초기값/경제의미를사용한다. 기존 유저 마스크와목록순서를신규테마ID로재해석할경우정식매핑을남긴다. 원본게임의CannonGame_v3 데이터에새게임이접속하지않는다. 동결본의서버코드에이름이남아있으므로이식할때의명시적변경항목이다.

## 세션 속성과 소유자

| 속성군 | 서버/클라이언트소유 | 소비자 |
|---|---|---|
| DataReady/DataMode | 서버Data | 모든경제/초기화UI |
| FlightState/SkyRunSerial | 서버행동 | 메뉴숨김/훈련검증/행동입력/결과 |
| AutoClickMode/Enabled/OPAutoClickAvailable/Preview | 서버Clicker | ON/OFF/자동XP |
| TrainingActive/SharedTrainingTier/TrainingBuffIndex/TrainingXPMultiplier | 서버훈련 | 훈련FX/패드배율/XP정보 |
| PowerMultiplier/PowerBoostUntil/WinsMultiplier/WinsBoostUntil | 서버Boost | 타이머/Power/트로피 |
| FoodSelected/FoodPowerPercent/FriendPowerPercent | 서버Boost | 음식선택/Power/FriendBoost |
| RocketStyle/RocketTrail | 서버Data | 장비·트레일시각화 |
| ShowroomMessage/Time/Success | 서버Showroom | 필드피드백 |
| HUDPage/ProgressionModalOpen/RocketSkinShopOpen/RocketEquipmentTab | 로컬UI | 단일모달/입력잠금 |
| HUDSoundMuted | 로컬UI | 음소거 |
| GoldRingNextAt/EndsAt/Wave | 서버Workspace | 공유시간이벤트 |
| DestructionRunScore/Trophies/DestroyedObjects/CloudGate… | 서버행동 | 행동전용상태표시 |

모든속성을영구저장하지않는다. 캐릭터재생성시모달·FX·옛Run참조는닫고ResetOnSpawn=false GUI 중복생성을피한다. 설정음소거는현재플레이세션/장치로컬이며 계정간저장기능으로과장하지않는다.

## 저장 트랜잭션

저장된모든수치는유한정수,범위2^53−1이하다. masks는bit1이항상소유되고equipped는소유목록안에있어야한다. 환생≤1000000/Tier와XP장비는목록안. 과거XP곡선잔여는Advance로검증된캐리만수행한다.

UpdateAsync는새값으로무조건덮지않고기존필드가당시persisted또는현재snapshot과일치하는지확인한다. 알수없는저장필드는보존한다. 로드/저장각최대3번재시도. StudioMemory는API실패fallback이아닌미게시Studio환경분기다. 다음게임에서도저장검증·충돌거절·준비상태와실패동작을보존한다.
