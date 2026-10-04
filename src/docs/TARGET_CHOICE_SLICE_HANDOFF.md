# 3D 타깃 선택 구현 결과 — 2026-10-03

현재 승인 작업은 기존 F1 계획보다 우선하는 Human Amendment의 3종 수직 슬라이스입니다. 다음 단계를 시작하지 않았습니다.

## 적용 명세

- sourceRunId: `2026-10-03T03-00-40-418Z`
- sourceRecoveryId: `recovery-8f6yZg`
- Human Amendment 디렉터리: `amendment-nKcZ76`
- Base Spec SHA-256: `a83515d0e63154820b500def875f1d920e7f29d38e59e71df5bd106042043bab`
- Human Amendment SHA-256: `9a54846611f91dc96ae665be3f6c0081799a738a38abb76fd67d95b882e07823`
- 읽은 문서: `D:\Agent\runs\2026-10-03T03-00-40-418Z\spec_recoveries\recovery-8f6yZg\human_amendments\amendment-nKcZ76\APPROVED_IMPLEMENTATION_SPEC.md`

## 구현 및 변경 파일

| 파일 | 변경 내용 |
| --- | --- |
| `src/server/DestructibleConfig.luau` | Rock/FloatingIsland/Ruin의 임시 점수·셀 형상·결정적 배치·root 접촉 검증 |
| `src/server/BarrierSpawner.server.luau` | 기존 생성기를 확장하여 2개 선택 지점, 4개 구조물, 16개 비충돌 셀 생성. 근접 순서 70ms 체인과 복귀 재생성 유지 |
| `src/client/PresentationConfig.luau` | Rock 체인에서 기존 두 음원을 제외하고 좋은 첫 impact 음원 재사용. 3종 SFX/VFX 프로필 |
| `src/client/DestructionFX.client.luau` | 재질별 파편·재생 프로필, 재질마다 impact/chain 3개/finish 총 5개 voice, 임시 점수 UI |
| `tests/run-local.cjs` | 신규 테스트 모듈 연결 및 현재 WorldService 인터페이스에 맞춘 테스트 모형 보강 |
| `tests/target-choice.luau` | 배치·선택 경로·서버 접촉·중복 지급·체인 간격·새 비행 격리·경제 무연결 검사 |
| `src/docs/TARGET_CHOICE_SLICE_HANDOFF.md` | 구현 결과와 후속 Studio 검증 한계 기록 |

별도 TargetField/Service를 추가하지 않았습니다. LevelBuilder/CourseSection/ObstaclePatterns/AssetRegistry는 기존 지형·링·일반 장애물·장식의 책임을 유지합니다. SkyController와 Preview 전환도 유지합니다. Crystal/Meteor, 랜덤 배치, 새 경제 보상은 구현하지 않았습니다.

`DestructionRunScore`는 서버 Player attribute에만 존재하며 저장하지 않습니다. 구조물 전체당 10/30/50을 한 번 지급하고 Result까지 보여 주며, 다음 Aiming에서 0으로 초기화합니다. Gold/Trophy/PlayerData/DataStore/FlightResult/업그레이드 수식과 연결하지 않았습니다. 비행·조향·착륙 관련 소스와 기존 balance 수치는 수정하지 않았습니다.

## 배치 근거와 Preview 조건

현재 BalanceConfig의 Power 1, GOOD, 45°는 수평 약 80.59, 수직 약 183.85 studs/s입니다. Workspace Gravity와 초기 Canon.Cylinder 프레임, 기존 LaunchTrajectory의 muzzle/8-stud root offset을 사용하여 서버 시작 시 고정 참조 배치를 계산합니다. 실제 대포나 비행 상태를 변경하지 않습니다.

첫 선택은 발사 후 참조 시간 0.65초의 중앙 Rock / 우측 16 studs FloatingIsland입니다. 두 번째는 1.25초의 중앙 Rock / 우측 26 studs Ruin입니다. 낮은 단계의 암석에서 풀층·흙·하부 쐐기가 있는 섬과 석조 폐허로 성격이 바뀝니다. 모든 구조물은 좌우 조향으로 선택하는 비충돌 타깃이며 피해·감속·튕김을 적용하지 않습니다.

로컬 수식 검사에서 중앙→중앙, 부유섬→폐허, 부유섬→중앙, 중앙→폐허의 선택 가능성을 확인했습니다. 고가치 타깃 선택 시 같은 지점의 중앙 Rock 접촉 범위를 벗어납니다. 고도가 독립적으로 조작 가능한 것은 아니며 기존 조향의 높이·전방 속도 불변식을 유지합니다.

Studio 검증 기준 샷은 Power 1 / yaw 0 / pitch 45° / GOOD입니다. 기본 InitialAimPitch는 기존 25°를 유지하므로 기준 샷에서는 기존 조준 UI로 45°를 선택해야 합니다. 모든 pitch/timing에서 같은 타깃을 보장하는 시스템은 아닙니다. 실제 대포 기하와 링 접촉은 런타임 검증하지 않았습니다. 기존 링이 추가 상승·전방 속도를 만들면 참조 배치와 실제 접촉이 달라질 수 있으므로 이 차이를 MCP에서 우선 확인해야 합니다.

## SFX 진단 및 에셋

이전 impact는 `9118614058`, chain은 `8666678762`/`8666682639`, finish는 `9119049679`였습니다. 음량은 각각 .45/.2/.32, 기본 speed는 1, chain voice 2개에 70ms 간격으로 재생하고 160ms envelope를 적용했습니다. 기존 피치는 .94~1.06의 변동이며 체인 횟수에 따른 상승 로직은 없었습니다. 따라서 사용자의 crystal-like 보고를 피치 누적 문제로 확정하지 않고 체인 음원 선택을 수정했습니다.

Rock chain은 `9118614058`을 .16/.14 음량과 .94/1.02 기본 speed로 재사용합니다. 미세 변동 후 Rock speed를 .85~1.05로 제한하며, 3개 voice를 순환해 정상 70ms cadence의 200ms tail을 재시작으로 자르지 않습니다. 콤보 강도는 음량에만 반영됩니다. first impact와 기존 finish SoundId는 유지했습니다.

FloatingIsland/Ruin은 실제 기존 impact/finish 음원을 더 낮은 speed/서로 다른 음량으로 변형하는 안전한 fallback입니다. 독립적인 신규 음원을 확보하거나 import하지 않았으며 가짜 ID를 넣지 않았습니다. 전용 흙/석조 붕괴음은 청취 이후 판단할 TODO로 남겼습니다. 파편 재질·수명·크기, 섬의 풀잎 조각, 폐허의 넓은 석재 조각으로 VFX도 구분합니다.

PreloadAsync는 Sound 인스턴스 전체를 비동기로 preload하며, 로딩 실패는 경고 후 즉시 건너뜁니다. 늦게 재생할 큐를 만들지 않습니다. 실제 권한·IsLoaded·청취는 이번에 확인하지 않았습니다.

## 실제 검증 결과

- `node tests/run-local.cjs C:\Users\rdrd1\AppData\Local\Temp\rocketShooter-luau-0.739\luau.exe C:\Users\rdrd1\AppData\Local\Temp\rocketShooter-target-choice-checks`: **339개 통과**. 기존 315개 + 신규 24개 모의 엔진 검사입니다.
- 변경 소스 4개와 신규 테스트 1개에 `luau-compile.exe`: 통과.
- `git diff --check -- src tests default.project.json`: 통과.
- `rojo sourcemap default.project.json`: 텍스트 sourcemap 생성 성공. 새 서버 모듈/기존 서버·클라이언트 스크립트 매핑 확인.
- 초기 회귀 실패: 기존 모형에 `GetCloudOutpostObjective`와 `Destinations`가 빠져 있었습니다. production 파일은 변경하지 않고 테스트 모형을 보강했습니다. 신규 모형의 attribute signal 전달 누락도 수정한 뒤 최종 전수 검사를 통과했습니다.
- 초기 생성 파일 쓰기는 샌드박스가 거부하여 임시 디렉터리에 허용된 실행으로 검사했습니다. 최종 테스트 실패는 없습니다.
- 광범위한 `git diff --check`는 잠긴 `rocketShooter.rbxl`에 접근하려다 실패했습니다. 이후 검사 범위를 텍스트 소스로 제한했습니다. 잠긴 place는 소스 구현 실패가 아니며 place 파일을 수정하거나 빌드하지 않았습니다.

## Studio 변경 및 남은 검증

Studio 조작·에셋 import·시각 검사·Play Test는 수행하지 않았습니다. Rojo 설정을 변경하지 않았습니다. 기존 `src/server`/`src/client` 매핑으로 동기화하면 코드가 기존 runtime 컨테이너에 타깃을 생성합니다. Studio-owned 인스턴스 삭제·영구 place 수정은 없습니다.

MCP 검증에서는 실제 링 접촉이 포함된 Power 1 기준 샷의 도달성, 두 선택 상황의 가독성과 재미, 세 실루엣·점수·파괴 피드백, Rock 체인 청취, 음원 로딩, 기존 Landing/Result/Return을 확인해야 합니다. 이 수용 기준들은 로컬 모의 검사만으로 최종 승인하지 않았습니다.

공유 타깃 재생성은 이전 구현처럼 플레이어 복귀·캐릭터 교체에 연결되어 있어, 다른 플레이어의 비행 중 재생성이 발생할 수 있습니다. 멀티플레이어 수명 최적화는 이번 범위에서 추가하지 않았습니다. 빠른 셀 관통 시 Touched 전달과 얇은 셀의 실제 접촉도 Studio 검증 대상입니다.
