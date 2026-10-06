# 성장·경제 고정 규격

수치는 v0.1 동결 `reference/source/shared/`와 `reference/source/server/PlayerData.luau`를 기준으로 고정한다. 숫자에 로켓/Thrust라는 이름이 있다고 해서 임의로 단순 +1 Power 선형 성장으로 바꾸지 않는다. 이 게임의 +1은 **기본 클릭 XP=1**이며 레벨/배율을 통해 Power가 바뀐다.

## 레벨·환생·XP

L은0부터 시작,b=floor(L/20). 레벨업에 필요한 XP:

```text
lateBand(b) = 1 + max(0,min(b,202)-2)
RequiredXP(L) = min(2^53-1,(4+max(0,L))*(2+floor(max(0,L)/20))*lateBand(b))
RebirthRequired(R) = 20*(R+1)
XPRebirthMultiplier(R) = 1 + .5*clamp(R,0,1000000)
PowerRebirthMultiplier(R) = 1.5^clamp(R,0,30)*(1+max(0,R-30)*.02)
TrainingPower(L,R) = floor(max(0,L-1)*3*PowerRebirthMultiplier(R))
```

샘플 RequiredXP: L0=8,L1=10,L19=46,L20=72,L39=129,L40=176,L59=252,L60=640,L80=1512. `Advance`는 이 곡선의 누적 비용 `XPBetween`을 사용하여 여러 레벨을 이분 탐색으로 넘는다. XP를 매 레벨0으로 버리거나 부동소수점이 안전 한계를 넘도록 만들지 않는다.

일반 지급 XP=`baseGain × XPRebirthMultiplier × TrophyPadMultiplier × XPGearMultiplier + 이전 소수 잔여`. 정수 부분만 지급하고 소수 부분은 보존한다. GoldRing 이벤트 XP는 unscaled 지급이므로 위 배율을 또 곱하지 않는다.

| XP 원천 | 기본값 | 조건 |
|---|---:|---|
| 온라인 | 1/s | DataReady,서버 실시간 예산. 캐릭터/행동/훈련과 독립 |
| 수동 클릭 | 1/클릭 | 살아 있는 현재 캐릭터,10/s 토큰 버킷,버스트2 |
| Free Auto | 3클릭/s | 서버 스케줄,모드 Free |
| OP Auto | 6클릭/s | 서버 스케줄,현재 PreviewOP=true |
| 훈련 | 아래 Tier Rate/s | 검증된 개인 좌석/Idle |
| 행동 | 현 로켓 시작1 및 FlightXPInterval=1s마다1 | 동결 행동 예제. 다음 행동은 같은 시간/시작 XP 슬롯을 연결 |
| 보너스 이벤트 | max(200,XPBetween(L,L+4)) | 웨이브당최대3개/중복없음,unscaled |

## 훈련소 / XP 장비 / 패드

| 영구 Tier | 환생 요구 | 기본 추가 XP/s |
|---|---:|---:|
| Wood | 0 | 1 |
| Stone | 1 | 1.5 |
| Iron | 2 | 3 |
| Gold | 3 | 5 |
| Diamond | 4 | 7.5 |
| Emerald | 5 | 10 |
| Divine | 6 | 15 |

현 모드에서 훈련소는 트로피 비용0/레벨 요구없음. 코드의 과거 Cost/Level 필드는 legacy 분기용이다. 최고 해금 Tier는 영구 저장한다.

| XP 장비 단계 | 배율 | 트로피 가격 |
|---|---:|---:|
| Basic Gloves | 1 | 0 |
| Training Gloves | 1.5 | 5 |
| Enhanced Gloves | 2 | 20 |
| Golden Gloves | 3 | 60 |
| Crystal Gloves | 5 | 200 |
| Space Gloves | 10 | 700 |
| Legendary Gloves | 20 | 2500 |

XP 장비는 다음 인덱스만 구매하는 기존 서버 API가 존재하지만 현재 TotalHUD에 별도 XP 장비 구매 바로가기는 없다. 숨겨진 legacy Training 페이지를 현 메뉴에 추가하지 않는다. 그 API/데이터는 보존하고 STATUS의 도달 가능성 구분을 따른다.

패드 트로피 요구0/3/15/100/500 → XP 배율1/2/3/5/10. 서버가 현재 패드 위치/잔액을 확인한다. `TrainingBuffIndex`는 위치를 떠난다고 즉시 초기화되지 않는 현 구현이며 `Data.TrophyMultiplier`가 현재 잔액을 다시 검사해 부족하면1로 계산한다. 새 게임에서 임의의 시간제 버프로 바꾸지 않는다.

## Power / 장비

```text
rawPower = PowerLvl + TrainingPower(Level,Rebirths)
display/actionInputPower = min(2^53-1,rawPower*PowerMultiplier*(1+FoodPercent)*(1+FriendPercent))
flat = skin.FlatThrust + trail.FlatThrust
growth = min(.25,skin.GrowthBoost+trail.GrowthBoost)
equipmentResponse(base,starter) = base + flat + max(0,base-starter)*growth
```

기본 PowerLvl=1. UI의 Power는 raw×세션요인이며 고정 Thrust/Growth는 별도 라벨이다. 장비 보너스를 Power 숫자에 더해서 중복 표시하거나 엔진의 starter 부분에 Growth를 곱하지 않는다. 로켓은 Power를 `Balance.VerticalPower`/발사 각도로 변환한 뒤 위 장비식을 적용한다. 돌/침/검에서는 그 변환부만 자기 힘/속도/거리/범위 함수로 대체하고 기본/훈련분의 분리와 flat/growth 의미를 유지한다. 이 변환은 ACTION_ADAPTER의 명시적인 행동 차이이며 공통 XP 곡선 변경이 아니다.

| 음식 | Power 비율 |
|---|---:|
| None / Snack / Meal / Feast | 0 / .05 / .10 / .20 |

Power2/4/8은 각각2/4/8배,900s,선택 교체/재사용900s리셋. Wins2는2배/900s. 검증된 같은 서버 친구당.1,친구들끼리는 더하고 음식과는 곱한다.100×2×1.2×1.1=264. 음식/부스트/친구/자동 클릭 모드는 저장하지 않는다.

## 트로피 경제

행동 어댑터는 실제 서버 목표 판정으로 count와 진행 구간을 결정한다. 클라이언트가 트로피값/배율/count를 제출하지 않는다. 현재 예제의 논리적 파괴1개 기본1트로피. 고도 구간은0/260/850/3500/16000/40000/70000/100000/140000에 배율1/2/3/5/8/12/20/30/40. Wins 배율은 각 적중 시점에1회만 적용하고 정산 때 재적용하지 않는다. 현재 Run 미정산 잔액은40000000에서 포화된다.

다른 행동에는 서버가 계산한 진행 구간(거리/타깃 단계/스테이지)을 같은 **보상 단계1/2/3/5/8/12/20/30/40**로 매핑한다. 물리 단위별 임계값만 행동 정의에서 명시하고,초기 어댑터를 만들 때 기존 로켓과 비교한 구간 매핑표를 남긴다. 임의로 “검 한 번이면1000트로피”처럼 경제를 바꾸지 않는다. `TrophyZoneConfig`의 착지 층별 Reward는 현 로켓의 위치/목표 표시이며,실제 지급 경로는 `RocketFlightService.destroyed/finish`다. 문서의 옛 “층 착지=트로피 지급”을 현 공통 보상으로 추가하지 않는다.

## 영구 장비 카탈로그

목록 순서는 저장 비트 인덱스다. 삭제/정렬 변경 금지. 각 구매는 비용+소유권을 서버에서 동시에 커밋하고 소유한 것을 다시 장착할 때 재결제하지 않는다. 환생 무료 마일스톤 장비는 로드/환생 시 지급된다.

| index | ID | 가격 | 환생 | FlatThrust | Growth |
|---:|---|---:|---:|---:|---:|
| 1 | Starter | 0 | 0 | 0 | 0 |
| 2 | Ion | 0 | 1 | 8 | .03 |
| 3 | Bat | 5 | 0 | 10 | .04 |
| 4 | Mala | 15 | 1 | 16 | .07 |
| 5 | Nova | 40 | 3 | 25 | .10 |
| 6 | Sausage | 80 | 0 | 18 | .06 |
| 7 | Keyboard | 120 | 0 | 20 | .07 |
| 8 | Pencil | 180 | 0 | 22 | .08 |
| 9 | Banana | 260 | 0 | 23 | .09 |
| 10 | Donut | 360 | 0 | 25 | .10 |
| 11 | Fish | 500 | 0 | 27 | .10 |
| 12 | Soda | 700 | 0 | 29 | .11 |
| 13 | Pizza | 950 | 0 | 31 | .12 |
| 14 | Cloud | 1300 | 0 | 33 | .13 |
| 15 | Satellite | 1700 | 0 | 35 | .14 |

현재 전시는 index1~10만 사용한다. 미전시/미소유 장비를 원격 구매하지 않는다. 전시 장비는 왼쪽 쇼룸14stud 이내/E로 구매·장착한다. 다음 게임도 전시/영구 구매/근접 검증을 유지한다. 장비 아트를 행동에 맞춰 바꾸더라도 인덱스·비용·보너스는 유지한다.

| 트레일 index/ID | 가격 | Flat | Growth |
|---|---:|---:|---:|
| 1 None | 0 | 0 | 0 |
| 2 Ember | 15 | 5 | .02 |
| 3 Mint | 60 | 9 | .04 |
| 4 Violet | 180 | 14 | .07 |
| 5 Aurora | 600 | 20 | .10 |
| 6 Prism | 1800 | 25 | .15 |

트레일은 현재 Trails 팝업에서 구매/장착한다. 비용/소유/현재 선택을 카드에 표시한다. 실제 Colors/Lifetime/Width는 `RocketTrailCatalog` 그대로 유지하고 행동 대상에 부착하는 부분만 어댑터에서 바꾼다.

## 현 테스트/미구현 정책

TemporaryFreeTesting=true,PreviewOP=true. FREE TEST 부스트와 음식은 무료이며 실제 Marketplace 결제/영수증/ProductId가 없다. 하단99/199/349와 오른쪽TBD는 표시용 가격이다. World2/Skip/그룹 보상은 Coming Soon. 새 게임의 첫 이식본도 동일하다. 실제 수익화나 잠금 규칙은 사용자가 별도 요청할 때 새로운 버전에서 정한다.
