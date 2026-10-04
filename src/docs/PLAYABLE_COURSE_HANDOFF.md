# 플레이 가능한 초반 코스 / 스폰·배경 안정화

2026-09-20 사용자 추가 요청으로 PHASE 2 기반의 실제 코스와 효과음을 구현했다.
PHASE 3 Asset Registry를 별도 착수하지 않았고 DataStore/가격/거리 보상 공식은 유지했다.

## 수정

- 스폰: Workspace 직속 SpawnLocation을 RespawnLocation으로 지정한다. 다른 SpawnLocation은
  런타임에서 비활성화한다. 이미 생성된 캐릭터도 고정 스폰으로 정렬한다.
  늦게 도착한 CharacterAdded 콜백은 현재 캐릭터/Idle 상태를 확인해 비행 중 순간이동을 막는다.
- 하늘: Main의 Remote/캐릭터 대기 전에 밝은 기본 Sky/14시 조명을 즉시 적용한다.
  고도 400 이상 Flying에서만 SkySpace로 전환하고 360 미만에서 복귀한다.
  Reset/캐릭터 교체는 즉시 지상 Sky로 복원한다. 자산의 Script를 복제하지 않고 텍스처 속성만 복사한다.
  기존 시작 순서/대기 타임아웃에 따라 Lighting의 어두운 Sky가 남던 경로를 없앴다.
- 조향: Acceleration 40→75, MaxLateralSpeed 45→75, ForwardSpeedFraction .20→.35,
  ReleaseDeceleration 8→12. 전진/Y 속도를 직접 높이지 않는다.
- 초기 조준 각도는 25도로 올려 저각 발사로 바닥을 관통하기 쉬운 시작을 개선한다.
  마우스 조준 허용 범위와 타이밍 배율은 기존과 동일하다.
- 맵: SIMULATOR MAP과 기존 Gimmicks를 플레이 세션의 ServerStorage에 보관한다.
  저장된 rbxl 원본은 삭제하지 않는다. GeneratedWorld의 MeadowRun이 실제 코스를 담당한다.
- 효과음: 발사/Ring/Bomb/결과/구매. Roblox 패키지 효과음을 사용하며 새 외부 오디오 업로드는 없다.
  Ring/Bomb은 서버가 검증한 현재 run의 접촉에만 FlightState Effect 메시지를 보낸다.
  클라이언트는 현재 run/character/Flying 확인 후 재생한다. 새로운 Remote는 추가하지 않았다.

## 코스와 튜닝

LevelConfig: Start=-96, 512 studs × 12구간 = 6,144 studs, 끝 전진거리 6,048.
폭 1,000, 바닥 높이 4.5. 주변 구간만 생성·유지하며 기존 15초 정리 정책을 사용한다.
중앙 활주로, 잔디, 나무, 거리 표지판, 착지 타깃을 코드로 제작했다. 외부 맵 자산은 가져오지 않았다.

- Ring: 전진거리 80부터 140 간격, 1,400 이내만 생성(총 10개), 높이 50, 반경 23.
  첫 Ring은 중앙, 이후 좌우 24 studs로 교차한다. 비충돌 통과 트리거와 링 모양을 분리했다.
- Bomb: 전진거리 340부터 300 간격, 1,400 이내(총 4개), 높이 70, 좌우 48에 배치.
  시작 구간과 중앙 경로를 비워두었다. 기존 감속/하강 효과를 사용한다.
- Target: 300부터 500 간격, 1,800까지(총 4개). 기존 XZ 40 반경/+5 공식을 사용한다.
  프로토타입의 먼 목표 배치를 가까운 코스로 옮겼으므로 보상 기회/난이도는 실제 플레이로 추가 조정해야 한다.
- 장애물은 1,400 이후 추가되지 않는다. 지면은 더 멀리 이어지므로 파워 업그레이드와 장거리 검증이 가능하다.
- 거리 표지판은 고정 총구 기준 전진거리이고 결과 거리는 기존 3D 최대 직선거리라 약간 다를 수 있다.

조정 파일: src/server/LevelConfig.luau, SteeringConfig.luau,
src/client/PresentationConfig.luau. 효과음 Id/Volume/Speed를 한곳에서 교체할 수 있다.

## 파일

신규: SpawnService.luau, SessionSetup.server.luau, CourseSection.luau (server),
PresentationConfig.luau, SkyController.luau, Audio.luau (client), tests/phase2-config.luau.
수정: LevelConfig, LevelBuilder, WorldService, FlightService, SteeringConfig,
Main.client, FlightClient, tests/run-local.cjs, tests/regression.luau.
phase2-config는 기존 139개 검사의 단순 섹션 기준을 보존하는 fixture다.
별도 신규 검사는 현재 실제 GameLevelConfig를 사용한다.

## 검증

- 자동 회귀 158개 통과. 스폰 선택/늦은 캐릭터 이벤트/하늘 초기화·고도 hysteresis/
  현재 코스 생성·보관/근거리 접촉 연결·목표 점수/효과음 정리 포함.
- Rojo source 23개 Luau 컴파일, Rojo build 성공.
- Studio 최대화 상태로 Rojo 연결 및 변경 동기화, 실제 Play를 수행했다.
- 첫 생성 위치 (68,8.598,903), ClockTime=14, FlightSky 존재를 실제 클라이언트에서 조회했다.
- 새 잔디/활주로/나무/링/표지판과 밝은 하늘을 실제 화면으로 확인했다.
- action_jump.mp3, action_jump_land.mp3, electronicpingshort.wav 모두 PreloadAsync 성공 및 IsLoaded=true 확인.
  실제 청취로 음량/음질을 평가한 것은 아니다.
- 테스트 캐릭터를 Command Bar로 대포 앞에 배치한 뒤 실제 프롬프트로 탑승,
  게이지 클릭 GOOD(1.0x) 발사, 결과 379m / 568 Gold / 1 Trophy,
  결과 화면의 복귀 버튼으로 동일 스폰 및 밝은 하늘 복귀를 확인했다.
  테스트는 StudioMemory이며 실제 DataStore를 변경하지 않았다.
- 조향의 장시간 키 입력 체감, 여러 사용자 동시 플레이, 고파워 장거리/모바일은 이번 Studio 테스트에 포함하지 않았다.

## 사용자 확인

Stop 후 새 Play에서 첫 입장/Reset 3회 스폰·하늘 일관성, A/D 조향과 관성,
Ring/Bomb/Target 접근 난이도, 효과음 음량을 확인한다. 초기 조향이 과하면
Acceleration/MaxLateralSpeed를 소폭 낮추면 된다.

Canon.Script와 사용자가 비활성화한 LightConfig는 계속 비활성 상태로 둔다.
수작업 맵을 다시 비교하려면 ArchiveHandmadeMap=false로 설정할 수 있지만,
기존 Gimmicks를 함께 켜면 새 코스와 효과/보상 기회가 중복되므로 별도 비교 세션에서만 사용한다.
Studio 편집 모드는 원본 맵/원본 하늘을 유지하며 새 맵·하늘은 Play 시 적용된다.
