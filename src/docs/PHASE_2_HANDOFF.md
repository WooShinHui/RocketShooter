# PHASE 2 — Level Builder Foundation

2026-09-20. PHASE 1은 사용자가 조향/관성/발사/착지/복귀 정상 및 완료를 승인했다.
PHASE 2는 로컬 구현/자동 검증 완료, Studio 비행 수락 테스트 대기 상태다. PHASE 3은 시작하지 않았다.

## 1. 기존 월드 조사

Studio 편집 모드의 Command Bar에서 속성/계층/Source와 Raycast를 읽기 전용으로 조회했다.
원본 rbxl 파일은 OS 읽기 거부로 직접 파싱하지 못했다. 아래 값은 실제 열려 있는 Studio에서 확인했다.
월드 인스턴스를 삭제/이동/수정하거나 Play를 실행하지 않았다.

| 항목 | 확인 결과 |
| --- | --- |
| Canon.Cylinder 중심 | (63.394535, 9.247150, 878.244995) |
| Cylinder 크기 | (5.741364, 5.128499, 15.982408) |
| 기본 방향 | 거의 정확한 -Z. Y 위, 오른쪽 +X |
| Baseplate | 중심 (0,-8,0), 크기 (2048,16,2048), 충돌 true, 표면 Y=0 |
| Terrain | 실제 Terrain 인스턴스 존재. 아래 비행 축 샘플에서는 바닥을 제공하지 않음. 전체 voxel 지형이 비었다고 단정하지 않음 |
| Workspace.SpawnLocation | (68,5.001495,903), 크기 (12,1,12) |
| SIMULATOR MAP | Folder, BasePart 154개. 벽 Model 76개, 별도 SpawnLocation 및 Part 포함 |
| 수작업 바닥 Part | 중심 (-28.671547,2.125,765.682251), 크기 (487.960022,4.25,466.580017), 충돌 true |
| 맵 내부 추가 SpawnLocation | (-67.981544,3.45,747.302246). 기존 복귀 로직은 Workspace 직속 SpawnLocation 사용 |
| 기존 Gimmicks | 편집 모드 Workspace에는 없음. 서버가 실행 시 생성하는 프로토타입 콘텐츠 |

Workspace.Canon.Script는 Enabled=false였다. 나머지 Script 목록은 Main, DataManager,
Cannon, Lighting.SkySpace.LightConfig다. World에 별도 장애물 사망 Script는 발견하지 않았다.

## 2. 맵 밖 사망

FallenPartsDestroyHeight=-500, FallHeightEnabled=true, Gravity≈196.2를 확인했다.
X=63.3945에서 위에서 아래로 Raycast한 결과 Z=500/0/-1000은 Baseplate Y=0,
Z=-1100/-2000/-3500은 바닥 없음이다. Baseplate 끝을 지나 중력으로 낙하하면
Y=-500에서 엔진이 캐릭터 부품을 제거하는 경로가 확인된다. 단순한 X/Z 좌표 Kill 로직은 없다.
특정 사용자 사망 순간을 녹화/재현한 것은 아니다.

근거 API: https://create.roblox.com/docs/reference/engine/classes/Workspace#FallenPartsDestroyHeight

## 3. 좌표와 거리

서버는 매 탑승 시 Cylinder를 기본 pivot으로 복원하고
`Cylinder.CFrame * CFrame.new(0,0,-Cylinder.Size.Z/2)`로 총구를 다시 계산한다.
따라서 편집기에 저장된 LaunchPoint의 기존 위치 (65.127945,6.844847,875.322571)는
실제 발사 기준점이 아니다. 기본 총구는 약 (63.394535,9.247150,870.253791)다.
조준 후 실제 총구 LookVector와 기존 Power/timingMultiplier가 발사 속도를 결정한다.

WorldCoordinates는 시작 시 고정 총구 원점/수평 Forward/Right를 캡처한다.
다른 플레이어의 조준이 진행 중인 월드를 회전시키지 않는다.
구간 배치 거리는 고정 원점에서 Forward로 투영한 studs이고, 각 run의 보상 거리는
발사 시 총구에서의 최대 3차원 직선거리 그대로다. 둘을 혼동하지 않는다.
기존 UI의 m 표기와 변환 없는 studs 보상 수치는 호환을 위해 그대로 유지했다.

## 4. 기존 Gimmicks 처리

DataManager에서 LegacyGimmicks로 생성/이동/Touch 책임을 옮겼다.
DataManager는 데이터 시작과 구매/비활성 Reset Remote만 담당한다.
WorldService가 LegacyGimmicks를 한 번 시작한다. GeneratedWorld에는 Gimmicks를 만들지 않는다.

Preserve 기본값은 기존 배치/효과/보상을 유지한다:

- Ring 25개: X=0, Y=60..120, Z=-110*i. 좌우 왕복 및 기존 BoostLvl 효과.
- Bomb 15개: X=0, Y=40..100, Z=-170*i-50. 기존 감속/하강 효과.
- Target 6개: (0,0.5,-d), d=300/700/1200/1800/2500/3300. XZ 반경 40, +5 보상 유지.
- Studio 저장 레이아웃이 있으면 재사용한다. Phase0Generated 소유 태그만 재생성 대상이다.

기존 첫 Ring의 실제 총구 기준 전진 거리는 약 980 studs다. 기존 d는 발사 원점 기준 거리가 아니다.
PHASE 2에서 임의로 배치/보상을 재해석하지 않는다.
향후 대체할 때 LevelConfig.LegacyGimmicks="Disabled"로 설정하면 기존 Gimmicks 폴더를
세션의 ServerStorage.LegacyGimmicksArchive에 보관한다. 생성/이동/Touch/Target 보상도
함께 비활성화되며 Studio 저장 원본은 삭제하지 않는다. 다음 Play에서 Preserve로 되돌릴 수 있다.
현재는 이 옵션을 켜지 않았다. SIMULATOR MAP의 벽/바닥은 별도 수작업 콘텐츠로 유지한다.

## 5. LevelBuilder

LevelConfig → WorldService/WorldCoordinates → LevelBuilder → Workspace.GeneratedWorld → TestLane_1.

- 서버만 생성. 신규 Remote 없음. Rojo 매핑 확장 없음.
- 섹션 설정의 Id/Kind/Start/Length/Width/TileLength/Height/RepeatCount 사용.
- 인스턴스는 필요 구간만 생성한다. 모든 플레이어의 위치를 합집합으로 사용해 Result 화면에서 서 있는 바닥도 유지한다.
- 앞 900 / 뒤 300 studs, 속도 예측 2초(추가 최대 2500 studs), 갱신 0.25초.
- 15초간 모든 플레이어에게 불필요한 섹션만 제거. 복귀 시 같은 좌표로 재생성.
- 이미 GeneratedWorld가 있으면 덮어쓰거나 삭제하지 않고 시작을 거부해 소유권 충돌을 알린다.

## 6. 파일

신규: src/server/LevelConfig.luau, WorldCoordinates.luau, LevelBuilder.luau,
WorldService.luau, LegacyGimmicks.luau, src/docs/PHASE_2_HANDOFF.md.
수정: src/server/DataManager.server.luau, FlightService.luau,
tests/run-local.cjs, tests/regression.luau, src/docs/IMPLEMENTATION_PLAN.md.
클라이언트/SteeringConfig/PlayerData/RunPolicy/default.project.json/reference는 변경하지 않았다.

## 7. 테스트 섹션

TestLane_1 하나. 고정 총구 기준 100..612 studs, 폭 512, 길이 512.
64 studs 길이의 Anchored 바닥 8개. 표면 Y=4.5로 수작업 로비 바닥 4.25보다 0.25 높다.
기본 방향에서는 중심 X≈63.395, Z 범위≈258.254..770.254.
바닥은 충돌 가능, Touch 이벤트는 없음. 장식/장애물/추가 보상은 없다.
기존 바닥을 삭제하지 않아 일부 영역은 기존 맵 위에 놓인다. 지상 이동 단차는 수락 테스트에서 확인한다.

## 8. 장거리/이탈 정책

RepeatCount 또는 Sections 항목을 늘려 수 km까지 이어 붙일 수 있다.
예: RepeatCount=20이면 10,240 studs의 타일 구간이지만 주변 섹션만 활성화된다.
기본값 1은 단순 검증 구간이며 무한 지면을 제공하지 않는다. 실제 맵 확장은 후속 설계가 필요하다.
아직 pooling/AssetRegistry/무한 맵/원점 이동/StreamingEnabled 설정 변경은 구현하지 않았다.
섹션 메타데이터는 선형 순회하므로 매우 많은 구간/플레이어에서는 프로파일링 후 인덱싱이 필요하다.

Flying run만 검사한다. 지면 아래 100 studs 또는 파괴 높이+80 studs에 임박하면 WorldFall,
시작점 뒤 512 초과 또는 좌우 폭 `600 + max(전진거리,0)*0.8` 초과면 OutOfFlightArea다.
앞쪽 끝이나 테스트 섹션 밖이라는 이유만으로 종료하지 않는다.
이탈은 정상 착지가 아니므로 Result/reward 없이 cleanup → Returning → 기존 LoadCharacterAsync → Idle.
낙하 중 비동기 respawn을 기다리지 않고 먼저 탑승 전 안전 위치로 복원한다.
run/character 확인으로 지연 복귀가 다음 run을 지우지 않는다. 다른 플레이어의 대포 점유를 해제하지 않는다.
이 보호는 Flying 전용이며 일반 보행 추락 정책은 변경하지 않았다. 극심한 지연/순간이동으로 엔진 제거가
먼저 일어나는 경우는 기존 사망/CharacterRemoving 취소 경로로 처리되며 보상하지 않는다.

## 9. 검증

139개 mock-engine 회귀 검사: 기존 PHASE 0/1 112개 + 좌표/구간/보관/실제 WorldService 통합/복귀 27개.
17개 Rojo source Luau 컴파일 및 Rojo 7.7.0 build 성공.
물리 엔진 실비행 및 PHASE 2 Studio Play Test는 수행하지 않았다.
Studio는 읽기 전용 조사만 수행했다.
마지막 확인에서 localhost:34872 Rojo API가 HTTP 200, serverVersion=7.7.0,
projectName=rocketShooter로 응답했다. 조사 도중 연결 끊김 Output이 있었으므로
플러그인의 최종 동기화 완료까지 확인했다고 간주하지 않는다.

## 10. Studio 체크리스트

1. Rojo localhost:34872에 다시 연결하고 5개 신규 ModuleScript, 수정 FlightService/DataManager를 동기화한다.
2. Stop 후 새 Play. Workspace.Canon.Script는 계속 Disabled. GeneratedWorld/TestLane_1/Floor_* 8개 확인.
3. Output의 Origin/Forward/GroundY가 위 기준과 일치하는지 확인. 테스트 섹션 방향/높이/단차/통과 확인.
4. 기본 발사, 최대/최소 조준, A/D, Ring/Bomb, 정상 착지 보상 1회, Return, 반복 플레이 회귀 확인.
5. 맵 밖에서 실제 낙하: WorldFall 로그, 보상 없이 스폰 복귀, 카메라/입력/투명도 복원 확인.
6. 충분히 측면으로 이탈하면 OutOfFlightArea로 동일 복귀. 일반 최대 yaw/조향 비행이 조기에 잘리지 않는지 확인.
7. A 비행/복귀 중 B 탑승, A Reset/퇴장/캐릭터 교체 때 B가 영향받지 않는지 2-player 테스트.
8. 로컬 테스트 설정에서 RepeatCount=20으로 변경해 원거리 구간 활성화, 15초 뒤 정리, 복귀 재생성 확인 후 1로 원복.
9. 두 플레이어가 서로 먼 구간에 있을 때 양쪽 구간 유지. 착지 결과 화면의 플레이어 아래 바닥 유지.
10. Disabled 옵션 테스트 시 Gimmicks는 ServerStorage로 보관되고 새로 생성되지 않는지 확인 후 Preserve로 원복.
11. unpublished 환경 StudioMemory, published 로드 실패 보호 및 데이터/보상 필드 불변 확인.

## 11. 수동 오브젝트 작업/알려진 문제

이번 PHASE 2 적용을 위해 기존 맵/장애물을 삭제할 필요 없다. Canon.Script의 기존 비활성 상태를 유지한다.
GeneratedWorld 이름을 가진 수작업 오브젝트가 있다면 내용을 확인해 이름을 바꾼 후 다시 Play한다.

별도 발견: Lighting.SkySpace.LightConfig는 Enabled=true, RunContext.Legacy다.
Source/Type에 MarketplaceService.GetProductInfo의 Description을 숫자 문자열로 변환한 후
require하는 외부 모듈 로딩 경로가 있어, 단순 조명 Script로 신뢰할 수 없다.
현재 Lighting 아래 Legacy 문맥이며 사망 원인으로 단정하지 않았다. 직접 실행/require하지 않았고 수정하지 않았다.
안전한 후속 정리로 LightConfig를 수동 Disabled 유지하는 것을 권장한다. Sky 자체를 삭제할 필요는 없다.
이 외부 자산 정리를 PHASE 3 착수로 확대하지 않았다.
