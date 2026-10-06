# 실제 코드 API/의존성 인벤토리

정적 사용 위치의 완전한 색인이다. 문자열 목록/동적 반복으로 생성한 속성은 실제 Config/서버코드를 함께 확인한다. 문자열이 등장한다고 현재 활성 기능이라는 뜻은 아니다. 정확한 이벤트 의미는 EVENTS_AND_DATA,현재 비노출 기능은 STATUS가 우선한다.

## 속성 읽기/쓰기/변경 신호

| key | 사용 위치 |
|---|---|
| ActiveChevron | [LaunchPadGuide.client.luau:29](reference/source/client/LaunchPadGuide.client.luau), [LaunchPadGuide.client.luau:34](reference/source/client/LaunchPadGuide.client.luau) |
| AltitudeBand | [SkyLife.luau:70](reference/source/server/SkyLife.luau), [SkyLife.luau:130](reference/source/server/SkyLife.luau), [SkyLife.luau:237](reference/source/server/SkyLife.luau) |
| AltitudeBiome | [AltitudeMood.client.luau:9](reference/source/client/AltitudeMood.client.luau), [AltitudeMood.client.luau:10](reference/source/client/AltitudeMood.client.luau), [SkyController.luau:61](reference/source/client/SkyController.luau) |
| AltitudeLayer | [AltitudeMood.client.luau:9](reference/source/client/AltitudeMood.client.luau), [AltitudeMood.client.luau:10](reference/source/client/AltitudeMood.client.luau), [SkyController.luau:65](reference/source/client/SkyController.luau) |
| AltitudeSky | [SkyController.luau:53](reference/source/client/SkyController.luau) |
| AltitudeSkyAsset | [SkyController.luau:54](reference/source/client/SkyController.luau) |
| AssetCategory | [AssetRegistry.luau:169](reference/source/server/AssetRegistry.luau) |
| AssetFallback | [AssetRegistry.luau:170](reference/source/server/AssetRegistry.luau) |
| AssetKey | [AssetRegistry.luau:168](reference/source/server/AssetRegistry.luau) |
| Attacking | [SkyEnemyFX.client.luau:18](reference/source/client/SkyEnemyFX.client.luau), [SkyLife.luau:245](reference/source/server/SkyLife.luau), [SkyLife.luau:251](reference/source/server/SkyLife.luau) |
| AutoClickEnabled | [ProgressionHud.client.luau:134](reference/source/client/ProgressionHud.client.luau), [ClickerService.server.luau:9](reference/source/server/ClickerService.server.luau), [ClickerService.server.luau:22](reference/source/server/ClickerService.server.luau) |
| AutoClickMode | [ClickerClient.client.luau:35](reference/source/client/ClickerClient.client.luau), [ClickerClient.client.luau:49](reference/source/client/ClickerClient.client.luau), [ClickerService.server.luau:9](reference/source/server/ClickerService.server.luau), [ClickerService.server.luau:18](reference/source/server/ClickerService.server.luau), [ClickerService.server.luau:22](reference/source/server/ClickerService.server.luau), [ClickerService.server.luau:28](reference/source/server/ClickerService.server.luau), [PlayerData.luau:177](reference/source/server/PlayerData.luau) |
| AvailableAt | [ConsumedButter.client.luau:10](reference/source/client/ConsumedButter.client.luau), [SkyLife.luau:172](reference/source/server/SkyLife.luau), [SkyLife.luau:198](reference/source/server/SkyLife.luau), [SkyLife.luau:243](reference/source/server/SkyLife.luau), [SkyLife.luau:285](reference/source/server/SkyLife.luau), [SkyLife.luau:299](reference/source/server/SkyLife.luau), [SkyLife.luau:305](reference/source/server/SkyLife.luau), [SkyLife.luau:310](reference/source/server/SkyLife.luau), [SkyLife.luau:312](reference/source/server/SkyLife.luau), [SkyLife.luau:332](reference/source/server/SkyLife.luau), [SkyLife.luau:333](reference/source/server/SkyLife.luau) |
| Biome | [AltitudeLandscape.client.luau:13](reference/source/client/AltitudeLandscape.client.luau), [SkyLife.luau:136](reference/source/server/SkyLife.luau) |
| Boss | [CloudGateChasers.client.luau:14](reference/source/client/CloudGateChasers.client.luau) |
| Broken | [DiveBreakGuide.client.luau:22](reference/source/client/DiveBreakGuide.client.luau), [DiveBreakGuide.client.luau:25](reference/source/client/DiveBreakGuide.client.luau), [DiveBreakZone.luau:77](reference/source/server/DiveBreakZone.luau), [DiveBreakZone.luau:84](reference/source/server/DiveBreakZone.luau), [DiveBreakZone.luau:89](reference/source/server/DiveBreakZone.luau), [DiveBreakZone.luau:116](reference/source/server/DiveBreakZone.luau), [DiveBreakZone.luau:131](reference/source/server/DiveBreakZone.luau) |
| ChainIndex | [BreakCourse.luau:74](reference/source/server/BreakCourse.luau) |
| ChainLength | [BreakCourse.luau:74](reference/source/server/BreakCourse.luau) |
| ChaserCount | [CloudGateChasers.client.luau:22](reference/source/client/CloudGateChasers.client.luau) |
| CloudGateIndex | [CloudGateChasers.client.luau:25](reference/source/client/CloudGateChasers.client.luau), [CloudGateLightning.client.luau:11](reference/source/client/CloudGateLightning.client.luau), [RocketClient.luau:181](reference/source/client/RocketClient.luau), [RocketFlightService.luau:35](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:240](reference/source/server/RocketFlightService.luau) |
| CloudGateOutcome | [RocketFlightService.luau:114](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:145](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:242](reference/source/server/RocketFlightService.luau) |
| CloudGatePressure | [CloudGateChasers.client.luau:28](reference/source/client/CloudGateChasers.client.luau), [RocketClient.luau:187](reference/source/client/RocketClient.luau), [RocketFlightService.luau:35](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:241](reference/source/server/RocketFlightService.luau) |
| CloudsDiscovered | [FlightService.luau:308](reference/source/server/FlightService.luau), [FlightService.luau:528](reference/source/server/FlightService.luau) |
| CollisionProxy | [BrainrotVisuals.luau:24](reference/source/server/BrainrotVisuals.luau), [SkyLife.luau:43](reference/source/server/SkyLife.luau), [SkyLife.luau:132](reference/source/server/SkyLife.luau), [SkyLife.luau:313](reference/source/server/SkyLife.luau) |
| CurrencyName | [RocketUI.luau:190](reference/source/shared/RocketUI.luau) |
| DataMode | [PlayerData.luau:331](reference/source/server/PlayerData.luau) |
| DataReady | [StudioProgressTest.client.luau:38](reference/source/client/StudioProgressTest.client.luau), [PlayerData.luau:309](reference/source/server/PlayerData.luau), [PlayerData.luau:330](reference/source/server/PlayerData.luau), [PlayerData.luau:406](reference/source/server/PlayerData.luau), [PowerBoosts.luau:43](reference/source/server/PowerBoosts.luau) |
| DestinationId | [Destination.luau:11](reference/source/server/Destination.luau) |
| Destroyed | [BarrierSpawner.server.luau:73](reference/source/server/BarrierSpawner.server.luau) |
| DestroyedObjects | [RocketClient.luau:179](reference/source/client/RocketClient.luau), [RocketFlightService.luau:80](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:115](reference/source/server/RocketFlightService.luau) |
| DestructionRunScore | [DestructionFX.client.luau:66](reference/source/client/DestructionFX.client.luau), [DestructionFX.client.luau:68](reference/source/client/DestructionFX.client.luau), [BarrierSpawner.server.luau:77](reference/source/server/BarrierSpawner.server.luau), [BarrierSpawner.server.luau:78](reference/source/server/BarrierSpawner.server.luau), [BarrierSpawner.server.luau:148](reference/source/server/BarrierSpawner.server.luau), [BarrierSpawner.server.luau:156](reference/source/server/BarrierSpawner.server.luau), [FlightService.luau:305](reference/source/server/FlightService.luau), [FlightService.luau:448](reference/source/server/FlightService.luau), [FlightService.luau:455](reference/source/server/FlightService.luau), [FlightService.luau:522](reference/source/server/FlightService.luau), [RocketFlightService.luau:115](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:265](reference/source/server/RocketFlightService.luau), [SkyLife.luau:315](reference/source/server/SkyLife.luau) |
| DestructionRunTrophies | [RocketClient.luau:179](reference/source/client/RocketClient.luau), [RocketFlightService.luau:80](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:115](reference/source/server/RocketFlightService.luau) |
| DisplayIndex | [CampShowroom.luau:15](reference/source/server/CampShowroom.luau), [ShowroomService.server.luau:18](reference/source/server/ShowroomService.server.luau) |
| DisplayKind | [CampShowroom.luau:15](reference/source/server/CampShowroom.luau), [ShowroomService.server.luau:13](reference/source/server/ShowroomService.server.luau), [ShowroomService.server.luau:18](reference/source/server/ShowroomService.server.luau) |
| DisplayName | [Destination.luau:12](reference/source/server/Destination.luau) |
| DisplayOnly | [ClickerUI.luau:55](reference/source/shared/ClickerUI.luau) |
| DisplaySlot | [CampShowroom.luau:41](reference/source/server/CampShowroom.luau) |
| DiveTargetActive | [DescentChallenge.client.luau:66](reference/source/client/DescentChallenge.client.luau), [FlightService.luau:497](reference/source/server/FlightService.luau) |
| DiveTargetDistance | [DescentChallenge.client.luau:73](reference/source/client/DescentChallenge.client.luau), [FlightService.luau:496](reference/source/server/FlightService.luau) |
| DiveTargetPosition | [DescentChallenge.client.luau:65](reference/source/client/DescentChallenge.client.luau), [FlightService.luau:494](reference/source/server/FlightService.luau) |
| DiveTargetsLeft | [DescentChallenge.client.luau:68](reference/source/client/DescentChallenge.client.luau), [DescentChallenge.client.luau:73](reference/source/client/DescentChallenge.client.luau), [FlightService.luau:495](reference/source/server/FlightService.luau) |
| DiveVignetteIntensity | [RocketSpeedFX.luau:28](reference/source/client/RocketSpeedFX.luau), [RocketSpeedFX.luau:41](reference/source/client/RocketSpeedFX.luau) |
| Diving | [FlightCamera.luau:23](reference/source/client/FlightCamera.luau), [FlightService.luau:108](reference/source/server/FlightService.luau), [FlightService.luau:470](reference/source/server/FlightService.luau) |
| ExpectedDirection | [CourseSection.luau:66](reference/source/server/CourseSection.luau) |
| FlightAborted | [RocketFlightService.luau:114](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:149](reference/source/server/RocketFlightService.luau) |
| FlightState | [AltitudeLandscape.client.luau:68](reference/source/client/AltitudeLandscape.client.luau), [AltitudeMood.client.luau:9](reference/source/client/AltitudeMood.client.luau), [AltitudeMood.client.luau:10](reference/source/client/AltitudeMood.client.luau), [ClickerClient.client.luau:15](reference/source/client/ClickerClient.client.luau), [ClickerClient.client.luau:40](reference/source/client/ClickerClient.client.luau), [CloudGateChasers.client.luau:26](reference/source/client/CloudGateChasers.client.luau), [CloudGateLightning.client.luau:12](reference/source/client/CloudGateLightning.client.luau), [ConsumedButter.client.luau:16](reference/source/client/ConsumedButter.client.luau), [ConsumedButter.client.luau:23](reference/source/client/ConsumedButter.client.luau), [ConsumedButter.client.luau:34](reference/source/client/ConsumedButter.client.luau), [DestructionFX.client.luau:64](reference/source/client/DestructionFX.client.luau), [DestructionFX.client.luau:344](reference/source/client/DestructionFX.client.luau), [DestructionFX.client.luau:397](reference/source/client/DestructionFX.client.luau), [DestructionFX.client.luau:405](reference/source/client/DestructionFX.client.luau), [DestructionFX.client.luau:407](reference/source/client/DestructionFX.client.luau), [DiveBreakGuide.client.luau:15](reference/source/client/DiveBreakGuide.client.luau), [ExperiencePopup.client.luau:16](reference/source/client/ExperiencePopup.client.luau), [ExperiencePopup.client.luau:28](reference/source/client/ExperiencePopup.client.luau), [FlightStreaming.client.luau:6](reference/source/client/FlightStreaming.client.luau), [FlightStreaming.client.luau:8](reference/source/client/FlightStreaming.client.luau), [FlightSummary.client.luau:20](reference/source/client/FlightSummary.client.luau), [LaunchPadGuide.client.luau:27](reference/source/client/LaunchPadGuide.client.luau), [MobileLayout.client.luau:32](reference/source/client/MobileLayout.client.luau), [ProgressionHud.client.luau:40](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:41](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:135](reference/source/client/ProgressionHud.client.luau), [ProtoFuelClient.client.luau:94](reference/source/client/ProtoFuelClient.client.luau), [ProtoFuelClient.client.luau:101](reference/source/client/ProtoFuelClient.client.luau), [ProtoFuelClient.client.luau:125](reference/source/client/ProtoFuelClient.client.luau), [ProtoFuelClient.client.luau:139](reference/source/client/ProtoFuelClient.client.luau), [RocketSkinShop.client.luau:86](reference/source/client/RocketSkinShop.client.luau), [SkyController.luau:190](reference/source/client/SkyController.luau), [SkyController.luau:191](reference/source/client/SkyController.luau), [SkyController.luau:195](reference/source/client/SkyController.luau), [SkyEnemyFX.client.luau:9](reference/source/client/SkyEnemyFX.client.luau), [StageCurtains.luau:62](reference/source/client/StageCurtains.luau), [StudioProgressTest.client.luau:37](reference/source/client/StudioProgressTest.client.luau), [TotalHud.client.luau:114](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:115](reference/source/client/TotalHud.client.luau), [BarrierSpawner.server.luau:64](reference/source/server/BarrierSpawner.server.luau), [BarrierSpawner.server.luau:96](reference/source/server/BarrierSpawner.server.luau), [BarrierSpawner.server.luau:152](reference/source/server/BarrierSpawner.server.luau), [BarrierSpawner.server.luau:153](reference/source/server/BarrierSpawner.server.luau), [FlightService.luau:78](reference/source/server/FlightService.luau), [FlightService.luau:148](reference/source/server/FlightService.luau), [FlightService.luau:261](reference/source/server/FlightService.luau), [FlightService.luau:317](reference/source/server/FlightService.luau), [GoldRingEvent.luau:47](reference/source/server/GoldRingEvent.luau), [GoldRingEvent.luau:64](reference/source/server/GoldRingEvent.luau), [PlayerData.luau:96](reference/source/server/PlayerData.luau), [PlayerData.luau:115](reference/source/server/PlayerData.luau), [PlayerData.luau:150](reference/source/server/PlayerData.luau), [PlayerData.luau:155](reference/source/server/PlayerData.luau), [PowerBoosts.luau:44](reference/source/server/PowerBoosts.luau), [ProtoFuelService.luau:22](reference/source/server/ProtoFuelService.luau), [ProtoFuelService.luau:106](reference/source/server/ProtoFuelService.luau), [ProtoFuelService.luau:107](reference/source/server/ProtoFuelService.luau), [ProtoFuelService.luau:108](reference/source/server/ProtoFuelService.luau), [RocketFlightService.luau:30](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:43](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:72](reference/source/server/RocketFlightService.luau), [SharedTraining.luau:22](reference/source/server/SharedTraining.luau), [SharedTraining.luau:42](reference/source/server/SharedTraining.luau), [SharedTraining.luau:49](reference/source/server/SharedTraining.luau), [ShowroomService.server.luau:9](reference/source/server/ShowroomService.server.luau), [SkyLife.luau:188](reference/source/server/SkyLife.luau), [SkyLife.luau:207](reference/source/server/SkyLife.luau), [SkyLife.luau:321](reference/source/server/SkyLife.luau), [SpawnService.luau:21](reference/source/server/SpawnService.luau), [StudioProgressTest.server.luau:18](reference/source/server/StudioProgressTest.server.luau), [TrainingService.server.luau:29](reference/source/server/TrainingService.server.luau) |
| FoodPowerPercent | [ClickerClient.client.luau:30](reference/source/client/ClickerClient.client.luau), [PowerBoosts.luau:28](reference/source/server/PowerBoosts.luau) |
| FoodSelected | [TotalHud.client.luau:87](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:112](reference/source/client/TotalHud.client.luau), [PowerBoosts.luau:29](reference/source/server/PowerBoosts.luau) |
| Forward | [LevelBuilder.luau:42](reference/source/server/LevelBuilder.luau), [SkyIslandSpawner.server.luau:19](reference/source/server/SkyIslandSpawner.server.luau) |
| FriendPowerPercent | [ClickerClient.client.luau:30](reference/source/client/ClickerClient.client.luau), [TotalHud.client.luau:138](reference/source/client/TotalHud.client.luau), [PowerBoosts.luau:28](reference/source/server/PowerBoosts.luau) |
| GateIndex | [CloudGateChasers.client.luau:9](reference/source/client/CloudGateChasers.client.luau), [CloudGateLightning.client.luau:29](reference/source/client/CloudGateLightning.client.luau), [DiveBreakZone.luau:131](reference/source/server/DiveBreakZone.luau) |
| GoldRingEndsAt | [RocketClient.luau:113](reference/source/client/RocketClient.luau), [GoldRingEvent.luau:35](reference/source/server/GoldRingEvent.luau), [GoldRingEvent.luau:53](reference/source/server/GoldRingEvent.luau), [GoldRingEvent.luau:58](reference/source/server/GoldRingEvent.luau) |
| GoldRingId | [GoldRingEvent.luau:21](reference/source/server/GoldRingEvent.luau) |
| GoldRingNextAt | [RocketClient.luau:113](reference/source/client/RocketClient.luau), [GoldRingEvent.luau:53](reference/source/server/GoldRingEvent.luau), [GoldRingEvent.luau:58](reference/source/server/GoldRingEvent.luau) |
| GoldRingWave | [GoldRingEvent.luau:21](reference/source/server/GoldRingEvent.luau), [GoldRingEvent.luau:53](reference/source/server/GoldRingEvent.luau) |
| HUDPage | [ProgressionHud.client.luau:171](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:172](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:176](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:177](reference/source/client/ProgressionHud.client.luau), [RocketSkinShop.client.luau:82](reference/source/client/RocketSkinShop.client.luau), [TotalHud.client.luau:31](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:105](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:109](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:111](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:112](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:113](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:117](reference/source/client/TotalHud.client.luau), [ClickerUI.luau:61](reference/source/shared/ClickerUI.luau), [ClickerUI.luau:64](reference/source/shared/ClickerUI.luau) |
| HUDSoundMuted | [TotalHud.client.luau:11](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:16](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:17](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:97](reference/source/client/TotalHud.client.luau), [TotalHud.client.luau:99](reference/source/client/TotalHud.client.luau) |
| HUDTemplateVersion | [SimulatorHUD.luau:28](reference/source/shared/SimulatorHUD.luau) |
| HazardRadius | [SkyLife.luau:71](reference/source/server/SkyLife.luau), [SkyLife.luau:151](reference/source/server/SkyLife.luau), [SkyLife.luau:284](reference/source/server/SkyLife.luau) |
| HitBoxSize | [SkyLife.luau:130](reference/source/server/SkyLife.luau), [SkyLife.luau:266](reference/source/server/SkyLife.luau) |
| HitRadius | [SkyLife.luau:71](reference/source/server/SkyLife.luau), [SkyLife.luau:130](reference/source/server/SkyLife.luau), [SkyLife.luau:151](reference/source/server/SkyLife.luau), [SkyLife.luau:171](reference/source/server/SkyLife.luau), [SkyLife.luau:300](reference/source/server/SkyLife.luau), [SkyLife.luau:309](reference/source/server/SkyLife.luau) |
| IsSkyIsland | [FlightService.luau:56](reference/source/server/FlightService.luau), [SkyIslandSpawner.server.luau:36](reference/source/server/SkyIslandSpawner.server.luau) |
| Kind | [LevelBuilder.luau:53](reference/source/server/LevelBuilder.luau) |
| LandingBurstDone | [LimbLanding.luau:4](reference/source/server/LimbLanding.luau), [LimbLanding.luau:5](reference/source/server/LimbLanding.luau) |
| LandingDetached | [LimbLanding.luau:21](reference/source/server/LimbLanding.luau) |
| LandingSurface | [AssetRegistry.luau:53](reference/source/server/AssetRegistry.luau) |
| LandingTarget | [AssetRegistry.luau:167](reference/source/server/AssetRegistry.luau), [CourseSection.luau:77](reference/source/server/CourseSection.luau), [WorldService.luau:80](reference/source/server/WorldService.luau) |
| Lane | [DiveBreakGuide.client.luau:42](reference/source/client/DiveBreakGuide.client.luau) |
| LastSkyHazard | [FlightService.luau:306](reference/source/server/FlightService.luau), [FlightService.luau:460](reference/source/server/FlightService.luau), [RocketFlightService.luau:115](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:270](reference/source/server/RocketFlightService.luau) |
| LayerIndex | [DiveBreakGuide.client.luau:42](reference/source/client/DiveBreakGuide.client.luau) |
| LayoutOrigin | [LevelBuilder.luau:41](reference/source/server/LevelBuilder.luau), [SkyIslandSpawner.server.luau:19](reference/source/server/SkyIslandSpawner.server.luau) |
| Length | [LevelBuilder.luau:52](reference/source/server/LevelBuilder.luau) |
| MaterialTag | [BarrierSpawner.server.luau:125](reference/source/server/BarrierSpawner.server.luau) |
| MinAltitude | [SkyLife.luau:72](reference/source/server/SkyLife.luau) |
| OPAutoClickAvailable | [ClickerClient.client.luau:37](reference/source/client/ClickerClient.client.luau), [ClickerService.server.luau:10](reference/source/server/ClickerService.server.luau) |
| OPAutoClickPreview | [ClickerService.server.luau:10](reference/source/server/ClickerService.server.luau) |
| ObstacleId | [FlightService.luau:335](reference/source/server/FlightService.luau), [ObstaclePatterns.luau:52](reference/source/server/ObstaclePatterns.luau) |
| ObstaclePattern | [ObstaclePatterns.luau:53](reference/source/server/ObstaclePatterns.luau) |
| Owner | [CliffCamp.luau:21](reference/source/server/CliffCamp.luau), [LevelBuilder.luau:40](reference/source/server/LevelBuilder.luau), [SkyIslandSpawner.server.luau:15](reference/source/server/SkyIslandSpawner.server.luau), [SkyLife.luau:49](reference/source/server/SkyLife.luau) |
| PartyEndsAt | [SkyLife.luau:41](reference/source/server/SkyLife.luau), [SkyLife.luau:172](reference/source/server/SkyLife.luau), [SkyLife.luau:198](reference/source/server/SkyLife.luau), [SkyLife.luau:300](reference/source/server/SkyLife.luau), [SkyLife.luau:305](reference/source/server/SkyLife.luau) |
| PartyGroup | [SkyLife.luau:172](reference/source/server/SkyLife.luau), [SkyLife.luau:299](reference/source/server/SkyLife.luau), [SkyLife.luau:305](reference/source/server/SkyLife.luau), [SkyLife.luau:311](reference/source/server/SkyLife.luau), [SkyLife.luau:317](reference/source/server/SkyLife.luau), [SkyLife.luau:322](reference/source/server/SkyLife.luau) |
| Passed | [DiveBreakGuide.client.luau:22](reference/source/client/DiveBreakGuide.client.luau), [DiveBreakZone.luau:41](reference/source/server/DiveBreakZone.luau) |
| Phase0Generated | [LegacyGimmicks.luau:28](reference/source/server/LegacyGimmicks.luau), [LegacyGimmicks.luau:68](reference/source/server/LegacyGimmicks.luau), [LegacyGimmicks.luau:96](reference/source/server/LegacyGimmicks.luau), [LegacyGimmicks.luau:123](reference/source/server/LegacyGimmicks.luau) |
| PlayerId | [DiveBreakGuide.client.luau:18](reference/source/client/DiveBreakGuide.client.luau), [BreakCourse.luau:55](reference/source/server/BreakCourse.luau), [DiveBreakZone.luau:21](reference/source/server/DiveBreakZone.luau) |
| PowerBoostUntil | [PowerBoosts.luau:30](reference/source/server/PowerBoosts.luau) |
| PowerMultiplier | [ClickerClient.client.luau:30](reference/source/client/ClickerClient.client.luau), [PowerBoosts.luau:28](reference/source/server/PowerBoosts.luau) |
| PreviousCenter | [SkyLife.luau:245](reference/source/server/SkyLife.luau), [SkyLife.luau:253](reference/source/server/SkyLife.luau), [SkyLife.luau:286](reference/source/server/SkyLife.luau) |
| Progress | [RocketUI.luau:169](reference/source/shared/RocketUI.luau) |
| ProgressionModalOpen | [ClickerClient.client.luau:17](reference/source/client/ClickerClient.client.luau), [ClickerClient.client.luau:40](reference/source/client/ClickerClient.client.luau), [ClickerClient.client.luau:41](reference/source/client/ClickerClient.client.luau), [ClickerClient.client.luau:56](reference/source/client/ClickerClient.client.luau), [ExperiencePopup.client.luau:15](reference/source/client/ExperiencePopup.client.luau), [ExperiencePopup.client.luau:27](reference/source/client/ExperiencePopup.client.luau), [ProgressionHud.client.luau:136](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:140](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:147](reference/source/client/ProgressionHud.client.luau), [RocketSkinShop.client.luau:79](reference/source/client/RocketSkinShop.client.luau), [TotalHud.client.luau:109](reference/source/client/TotalHud.client.luau) |
| Region | [Destination.luau:13](reference/source/server/Destination.luau) |
| RequiredLevel | [ProgressionHud.client.luau:127](reference/source/client/ProgressionHud.client.luau) |
| RequiredRebirths | [ProgressionHud.client.luau:127](reference/source/client/ProgressionHud.client.luau) |
| RequiredTrophies | [CliffCamp.luau:75](reference/source/server/CliffCamp.luau) |
| RingHits | [DiveBreakGuide.client.luau:60](reference/source/client/DiveBreakGuide.client.luau), [DiveBreakZone.luau:83](reference/source/server/DiveBreakZone.luau), [DiveBreakZone.luau:124](reference/source/server/DiveBreakZone.luau) |
| RingTotal | [DiveBreakGuide.client.luau:60](reference/source/client/DiveBreakGuide.client.luau), [DiveBreakZone.luau:124](reference/source/server/DiveBreakZone.luau) |
| RocketEquipmentTab | [ProgressionHud.client.luau:40](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:41](reference/source/client/ProgressionHud.client.luau), [RocketSkinShop.client.luau:76](reference/source/client/RocketSkinShop.client.luau), [RocketSkinShop.client.luau:80](reference/source/client/RocketSkinShop.client.luau), [RocketSkinShop.client.luau:85](reference/source/client/RocketSkinShop.client.luau), [TotalHud.client.luau:106](reference/source/client/TotalHud.client.luau) |
| RocketFuel | [RocketClient.luau:160](reference/source/client/RocketClient.luau), [BackRocket.luau:65](reference/source/server/BackRocket.luau) |
| RocketIndex | [Showroom.client.luau:24](reference/source/client/Showroom.client.luau), [CampShowroom.luau:41](reference/source/server/CampShowroom.luau) |
| RocketPhase | [RocketClient.luau:160](reference/source/client/RocketClient.luau), [RocketTrailStreams.client.luau:25](reference/source/client/RocketTrailStreams.client.luau), [BackRocket.luau:65](reference/source/server/BackRocket.luau) |
| RocketSkinShopOpen | [ProgressionHud.client.luau:40](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:41](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:139](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:145](reference/source/client/ProgressionHud.client.luau), [RocketSkinShop.client.luau:82](reference/source/client/RocketSkinShop.client.luau), [RocketSkinShop.client.luau:84](reference/source/client/RocketSkinShop.client.luau), [TotalHud.client.luau:106](reference/source/client/TotalHud.client.luau) |
| RocketStyle | [PlayerData.luau:235](reference/source/server/PlayerData.luau), [PlayerData.luau:404](reference/source/server/PlayerData.luau), [RocketFlightService.luau:169](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:172](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:173](reference/source/server/RocketFlightService.luau) |
| RocketThrust | [RocketClient.luau:162](reference/source/client/RocketClient.luau), [RocketTrailStreams.client.luau:25](reference/source/client/RocketTrailStreams.client.luau), [BackRocket.luau:65](reference/source/server/BackRocket.luau) |
| RocketTrail | [PlayerData.luau:249](reference/source/server/PlayerData.luau), [PlayerData.luau:405](reference/source/server/PlayerData.luau), [RocketFlightService.luau:169](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:172](reference/source/server/RocketFlightService.luau), [RocketFlightService.luau:174](reference/source/server/RocketFlightService.luau) |
| RunId | [DiveBreakGuide.client.luau:16](reference/source/client/DiveBreakGuide.client.luau), [DiveBreakGuide.client.luau:18](reference/source/client/DiveBreakGuide.client.luau), [BreakCourse.luau:55](reference/source/server/BreakCourse.luau), [BreakCourse.luau:74](reference/source/server/BreakCourse.luau), [DiveBreakZone.luau:21](reference/source/server/DiveBreakZone.luau) |
| RunScore | [BarrierSpawner.server.luau:116](reference/source/server/BarrierSpawner.server.luau) |
| Score | [SkyLife.luau:71](reference/source/server/SkyLife.luau), [SkyLife.luau:130](reference/source/server/SkyLife.luau), [SkyLife.luau:171](reference/source/server/SkyLife.luau), [SkyLife.luau:305](reference/source/server/SkyLife.luau), [SkyLife.luau:312](reference/source/server/SkyLife.luau) |
| Selected | [RocketClient.luau:95](reference/source/client/RocketClient.luau), [ClickerUI.luau:80](reference/source/shared/ClickerUI.luau) |
| SharedTrainingTier | [Showroom.client.luau:6](reference/source/client/Showroom.client.luau), [Showroom.client.luau:33](reference/source/client/Showroom.client.luau), [Showroom.client.luau:46](reference/source/client/Showroom.client.luau), [Showroom.client.luau:53](reference/source/client/Showroom.client.luau), [Showroom.client.luau:54](reference/source/client/Showroom.client.luau), [SharedTraining.luau:16](reference/source/server/SharedTraining.luau), [SharedTraining.luau:36](reference/source/server/SharedTraining.luau), [ShowroomService.server.luau:9](reference/source/server/ShowroomService.server.luau) |
| ShowroomMessage | [Showroom.client.luau:16](reference/source/client/Showroom.client.luau), [ShowroomService.server.luau:19](reference/source/server/ShowroomService.server.luau) |
| ShowroomMessageTime | [Showroom.client.luau:17](reference/source/client/Showroom.client.luau), [Showroom.client.luau:19](reference/source/client/Showroom.client.luau), [ShowroomService.server.luau:19](reference/source/server/ShowroomService.server.luau) |
| ShowroomSuccess | [Showroom.client.luau:16](reference/source/client/Showroom.client.luau), [ShowroomService.server.luau:19](reference/source/server/ShowroomService.server.luau) |
| ShowroomVersion | [CampShowroom.luau:29](reference/source/server/CampShowroom.luau) |
| SimulatorAnimated | [SimulatorTheme.luau:14](reference/source/shared/SimulatorTheme.luau) |
| SkyKind | [AltitudeLandscape.client.luau:13](reference/source/client/AltitudeLandscape.client.luau), [SkyEnemyFX.client.luau:11](reference/source/client/SkyEnemyFX.client.luau), [StageCurtains.luau:35](reference/source/client/StageCurtains.luau), [GoldRingEvent.luau:21](reference/source/server/GoldRingEvent.luau), [SkyLife.luau:37](reference/source/server/SkyLife.luau), [SkyLife.luau:38](reference/source/server/SkyLife.luau), [SkyLife.luau:70](reference/source/server/SkyLife.luau), [SkyLife.luau:130](reference/source/server/SkyLife.luau), [SkyLife.luau:151](reference/source/server/SkyLife.luau), [SkyLife.luau:159](reference/source/server/SkyLife.luau), [SkyLife.luau:163](reference/source/server/SkyLife.luau), [SkyLife.luau:309](reference/source/server/SkyLife.luau), [SkyLife.luau:331](reference/source/server/SkyLife.luau) |
| SkyPreloadComplete | [SkyController.luau:173](reference/source/client/SkyController.luau) |
| SkyPreloadFailures | [SkyController.luau:173](reference/source/client/SkyController.luau) |
| SkyRunSerial | [ConsumedButter.client.luau:17](reference/source/client/ConsumedButter.client.luau), [ConsumedButter.client.luau:35](reference/source/client/ConsumedButter.client.luau), [DestructionFX.client.luau:348](reference/source/client/DestructionFX.client.luau), [DiveBreakGuide.client.luau:16](reference/source/client/DiveBreakGuide.client.luau), [DiveBreakGuide.client.luau:18](reference/source/client/DiveBreakGuide.client.luau), [FlightService.luau:304](reference/source/server/FlightService.luau), [GoldRingEvent.luau:72](reference/source/server/GoldRingEvent.luau), [RocketFlightService.luau:115](reference/source/server/RocketFlightService.luau), [SkyLife.luau:321](reference/source/server/SkyLife.luau) |
| SourceAssetId | [CampShowroom.luau:58](reference/source/server/CampShowroom.luau) |
| SpeedIntensity | [RocketSpeedFX.luau:28](reference/source/client/RocketSpeedFX.luau), [RocketSpeedFX.luau:41](reference/source/client/RocketSpeedFX.luau) |
| StartDistance | [LevelBuilder.luau:51](reference/source/server/LevelBuilder.luau) |
| StrikeCount | [CloudGateLightning.client.luau:28](reference/source/client/CloudGateLightning.client.luau) |
| Style | [BackRocket.luau:10](reference/source/server/BackRocket.luau) |
| TargetChoice | [BarrierSpawner.server.luau:126](reference/source/server/BarrierSpawner.server.luau) |
| TargetId | [ConsumedButter.client.luau:26](reference/source/client/ConsumedButter.client.luau), [BarrierSpawner.server.luau:114](reference/source/server/BarrierSpawner.server.luau), [SkyLife.luau:71](reference/source/server/SkyLife.luau), [SkyLife.luau:130](reference/source/server/SkyLife.luau), [SkyLife.luau:198](reference/source/server/SkyLife.luau), [SkyLife.luau:298](reference/source/server/SkyLife.luau), [SkyLife.luau:304](reference/source/server/SkyLife.luau), [SkyLife.luau:309](reference/source/server/SkyLife.luau) |
| TargetKind | [DiveBreakGuide.client.luau:22](reference/source/client/DiveBreakGuide.client.luau), [DiveBreakGuide.client.luau:25](reference/source/client/DiveBreakGuide.client.luau), [DiveBreakZone.luau:116](reference/source/server/DiveBreakZone.luau), [DiveBreakZone.luau:131](reference/source/server/DiveBreakZone.luau) |
| TargetType | [BarrierSpawner.server.luau:115](reference/source/server/BarrierSpawner.server.luau) |
| Targeted | [SkyLife.luau:245](reference/source/server/SkyLife.luau), [SkyLife.luau:251](reference/source/server/SkyLife.luau) |
| Trail | [RocketTrailStreams.client.luau:24](reference/source/client/RocketTrailStreams.client.luau), [BackRocket.luau:10](reference/source/server/BackRocket.luau) |
| TrainingActive | [TrainingFX.client.luau:15](reference/source/client/TrainingFX.client.luau), [TrainingFX.client.luau:43](reference/source/client/TrainingFX.client.luau), [TrainingFX.client.luau:70](reference/source/client/TrainingFX.client.luau), [SharedTraining.luau:16](reference/source/server/SharedTraining.luau), [TrainingService.server.luau:44](reference/source/server/TrainingService.server.luau) |
| TrainingBuffIndex | [PlayerData.luau:121](reference/source/server/PlayerData.luau), [TrainingService.server.luau:36](reference/source/server/TrainingService.server.luau) |
| TrainingTier | [ProtoFuelClient.client.luau:145](reference/source/client/ProtoFuelClient.client.luau), [Showroom.client.luau:24](reference/source/client/Showroom.client.luau), [CampShowroom.luau:58](reference/source/server/CampShowroom.luau), [CliffCamp.luau:53](reference/source/server/CliffCamp.luau), [CliffCamp.luau:58](reference/source/server/CliffCamp.luau), [ProtoFuelService.luau:32](reference/source/server/ProtoFuelService.luau), [SharedTraining.luau:20](reference/source/server/SharedTraining.luau), [SharedTraining.luau:54](reference/source/server/SharedTraining.luau) |
| TrainingXPMultiplier | [ProgressionHud.client.luau:112](reference/source/client/ProgressionHud.client.luau), [ProgressionHud.client.luau:122](reference/source/client/ProgressionHud.client.luau), [PlayerData.luau:167](reference/source/server/PlayerData.luau), [TrainingService.server.luau:39](reference/source/server/TrainingService.server.luau) |
| TrophyAmount | [DiveBreakGuide.client.luau:42](reference/source/client/DiveBreakGuide.client.luau) |
| TrophyReward | [TrophyZones.luau:18](reference/source/server/TrophyZones.luau) |
| TrophyZoneIndex | [TrophyZones.luau:18](reference/source/server/TrophyZones.luau) |
| UIReference | [ClickerClient.client.luau:7](reference/source/client/ClickerClient.client.luau) |
| VisualHeight | [CloudGateChasers.client.luau:14](reference/source/client/CloudGateChasers.client.luau) |
| VisualKind | [ConsumedButter.client.luau:26](reference/source/client/ConsumedButter.client.luau), [SkyLife.luau:117](reference/source/server/SkyLife.luau), [SkyLife.luau:143](reference/source/server/SkyLife.luau), [SkyLife.luau:322](reference/source/server/SkyLife.luau) |
| WindowBottom | [DiveBreakGuide.client.luau:22](reference/source/client/DiveBreakGuide.client.luau), [DiveBreakGuide.client.luau:44](reference/source/client/DiveBreakGuide.client.luau) |
| WindowTop | [DiveBreakGuide.client.luau:23](reference/source/client/DiveBreakGuide.client.luau), [DiveBreakGuide.client.luau:41](reference/source/client/DiveBreakGuide.client.luau) |
| WinsBoostUntil | [PowerBoosts.luau:30](reference/source/server/PowerBoosts.luau) |
| WinsMultiplier | [PowerBoosts.luau:29](reference/source/server/PowerBoosts.luau) |
| XPMultiplier | [CliffCamp.luau:75](reference/source/server/CliffCamp.luau) |

## 함수 선언

| 함수(인자) | 소스 |
|---|---|
| `part(parent,name,pos,size,color,material,shape)` | [AltitudeLandscape.client.luau:6](reference/source/client/AltitudeLandscape.client.luau) |
| `build(key,center,region,seed)` | [AltitudeLandscape.client.luau:12](reference/source/client/AltitudeLandscape.client.luau) |
| `clear()` | [AltitudeLandscape.client.luau:61](reference/source/client/AltitudeLandscape.client.luau) |
| `sync()` | [AltitudeMood.client.luau:9](reference/source/client/AltitudeMood.client.luau) |
| `getSound(kind)` | [Audio.luau:6](reference/source/client/Audio.luau) |
| `Audio.Preload()` | [Audio.luau:21](reference/source/client/Audio.luau) |
| `Audio.Play(kind)` | [Audio.luau:36](reference/source/client/Audio.luau) |
| `Audio.Engine(throttle)` | [Audio.luau:42](reference/source/client/Audio.luau) |
| `Audio.Rush(intensity)` | [Audio.luau:50](reference/source/client/Audio.luau) |
| `resize()` | [ClickerClient.client.luau:12](reference/source/client/ClickerClient.client.luau) |
| `value(name)` | [ClickerClient.client.luau:22](reference/source/client/ClickerClient.client.luau) |
| `update()` | [ClickerClient.client.luau:23](reference/source/client/ClickerClient.client.luau) |
| `selectMode(mode)` | [ClickerClient.client.luau:47](reference/source/client/ClickerClient.client.luau) |
| `manual(processed)` | [ClickerClient.client.luau:55](reference/source/client/ClickerClient.client.luau) |
| `clear()` | [CloudGateChasers.client.luau:7](reference/source/client/CloudGateChasers.client.luau) |
| `make(index)` | [CloudGateChasers.client.luau:8](reference/source/client/CloudGateChasers.client.luau) |
| `hide()` | [CloudGateLightning.client.luau:6](reference/source/client/CloudGateLightning.client.luau) |
| `restore()` | [ConsumedButter.client.luau:8](reference/source/client/ConsumedButter.client.luau) |
| `Hud.Start(player)` | [CurrencyHud.luau:5](reference/source/client/CurrencyHud.luau) |
| `sync()` | [CurrencyHud.luau:26](reference/source/client/CurrencyHud.luau) |
| `updateBalances()` | [CurrencyHud.luau:31](reference/source/client/CurrencyHud.luau) |
| `clear()` | [DescentChallenge.client.luau:16](reference/source/client/DescentChallenge.client.luau) |
| `line(parent,name,a,b,width,color)` | [DescentChallenge.client.luau:19](reference/source/client/DescentChallenge.client.luau) |
| `circle(parent,name,center,radius,color)` | [DescentChallenge.client.luau:23](reference/source/client/DescentChallenge.client.luau) |
| `badge(parent,pos,text)` | [DescentChallenge.client.luau:30](reference/source/client/DescentChallenge.client.luau) |
| `update(data)` | [DescentChallenge.client.luau:35](reference/source/client/DescentChallenge.client.luau) |
| `updateScore()` | [DestructionFX.client.luau:63](reference/source/client/DestructionFX.client.luau) |
| `newVoice(name, cue)` | [DestructionFX.client.luau:78](reference/source/client/DestructionFX.client.luau) |
| `playCue(sound, intensity, profile)` | [DestructionFX.client.luau:123](reference/source/client/DestructionFX.client.luau) |
| `screenFlash(opacity, seconds)` | [DestructionFX.client.luau:141](reference/source/client/DestructionFX.client.luau) |
| `removeOffset()` | [DestructionFX.client.luau:148](reference/source/client/DestructionFX.client.luau) |
| `stopPunch()` | [DestructionFX.client.luau:156](reference/source/client/DestructionFX.client.luau) |
| `punch(strength, duration)` | [DestructionFX.client.luau:165](reference/source/client/DestructionFX.client.luau) |
| `visualPart(name, color, material, class)` | [DestructionFX.client.luau:195](reference/source/client/DestructionFX.client.luau) |
| `addAccent(part, duration, goal)` | [DestructionFX.client.luau:203](reference/source/client/DestructionFX.client.luau) |
| `impactLayers(data, first, intensity, finishing)` | [DestructionFX.client.luau:218](reference/source/client/DestructionFX.client.luau) |
| `spawnFragments(data, first, intensity)` | [DestructionFX.client.luau:252](reference/source/client/DestructionFX.client.luau) |
| `startMotion()` | [DestructionFX.client.luau:284](reference/source/client/DestructionFX.client.luau) |
| `cancelFinish()` | [DestructionFX.client.luau:325](reference/source/client/DestructionFX.client.luau) |
| `clearEffects()` | [DestructionFX.client.luau:328](reference/source/client/DestructionFX.client.luau) |
| `show(character,gain)` | [ExperiencePopup.client.luau:10](reference/source/client/ExperiencePopup.client.luau) |
| `render()` | [ExperiencePopup.client.luau:21](reference/source/client/ExperiencePopup.client.luau) |
| `Camera.Start(root, launchVelocity, isCurrent)` | [FlightCamera.luau:9](reference/source/client/FlightCamera.luau) |
| `update()` | [FlightCamera.luau:16](reference/source/client/FlightCamera.luau) |
| `Controller.Start(aimGui, resultGui, remotes, objectiveHud, mobile)` | [FlightClient.luau:11](reference/source/client/FlightClient.luau) |
| `cameraRestore()` | [FlightClient.luau:20](reference/source/client/FlightClient.luau) |
| `stopAim(run)` | [FlightClient.luau:29](reference/source/client/FlightClient.luau) |
| `stopFlight(run)` | [FlightClient.luau:36](reference/source/client/FlightClient.luau) |
| `clear()` | [FlightClient.luau:58](reference/source/client/FlightClient.luau) |
| `matches(id, character)` | [FlightClient.luau:65](reference/source/client/FlightClient.luau) |
| `launch()` | [FlightClient.luau:83](reference/source/client/FlightClient.luau) |
| `effect(class, name)` | [FlightClient.luau:124](reference/source/client/FlightClient.luau) |
| `update()` | [FlightStreaming.client.luau:5](reference/source/client/FlightStreaming.client.luau) |
| `clear()` | [FlightSummary.client.luau:11](reference/source/client/FlightSummary.client.luau) |
| `burst(rows,afterReturn)` | [FlightSummary.client.luau:15](reference/source/client/FlightSummary.client.luau) |
| `button(parent,name,text,position,size)` | [MobileControls.luau:5](reference/source/client/MobileControls.luau) |
| `scope(parent)` | [MobileControls.luau:11](reference/source/client/MobileControls.luau) |
| `connect(signal,fn)` | [MobileControls.luau:14](reference/source/client/MobileControls.luau) |
| `hold(b,key)` | [MobileControls.luau:15](reference/source/client/MobileControls.luau) |
| `active(key)` | [MobileControls.luau:22](reference/source/client/MobileControls.luau) |
| `stop()` | [MobileControls.luau:23](reference/source/client/MobileControls.luau) |
| `Mobile.Aim(gui,adjust,fire)` | [MobileControls.luau:29](reference/source/client/MobileControls.luau) |
| `Mobile.Steer(setAxis)` | [MobileControls.luau:40](reference/source/client/MobileControls.luau) |
| `update()` | [MobileLayout.client.luau:5](reference/source/client/MobileLayout.client.luau) |
| `find(screen,name)` | [MobileLayout.client.luau:8](reference/source/client/MobileLayout.client.luau) |
| `bind()` | [MobileLayout.client.luau:25](reference/source/client/MobileLayout.client.luau) |
| `finite(value)` | [ObjectiveHud.luau:7](reference/source/client/ObjectiveHud.luau) |
| `valid(meta)` | [ObjectiveHud.luau:11](reference/source/client/ObjectiveHud.luau) |
| `ObjectiveHud.new(playerGui)` | [ObjectiveHud.luau:17](reference/source/client/ObjectiveHud.luau) |
| `hud.Stop()` | [ObjectiveHud.luau:47](reference/source/client/ObjectiveHud.luau) |
| `hud.Start(root, objectiveMeta, isActive)` | [ObjectiveHud.luau:53](reference/source/client/ObjectiveHud.luau) |
| `update()` | [ObjectiveHud.luau:61](reference/source/client/ObjectiveHud.luau) |
| `label(parent,name,x,y,w,h,text,size,color)` | [ProgressionHud.client.luau:11](reference/source/client/ProgressionHud.client.luau) |
| `box(parent,name,x,y,w,h,color)` | [ProgressionHud.client.luau:14](reference/source/client/ProgressionHud.client.luau) |
| `button(parent,name,x,y,w,h,text,color,size)` | [ProgressionHud.client.luau:17](reference/source/client/ProgressionHud.client.luau) |
| `val(name)` | [ProgressionHud.client.luau:102](reference/source/client/ProgressionHud.client.luau) |
| `update()` | [ProgressionHud.client.luau:103](reference/source/client/ProgressionHud.client.luau) |
| `show(kind)` | [ProgressionHud.client.luau:138](reference/source/client/ProgressionHud.client.luau) |
| `prepare()` | [ProgressionHud.client.luau:158](reference/source/client/ProgressionHud.client.luau) |
| `screen(name)` | [ProtoFuelClient.client.luau:16](reference/source/client/ProtoFuelClient.client.luau) |
| `panel(gui, position, size)` | [ProtoFuelClient.client.luau:22](reference/source/client/ProtoFuelClient.client.luau) |
| `label(parent, position, size)` | [ProtoFuelClient.client.luau:34](reference/source/client/ProtoFuelClient.client.luau) |
| `clearNotice()` | [ProtoFuelClient.client.luau:89](reference/source/client/ProtoFuelClient.client.luau) |
| `phaseChanged()` | [ProtoFuelClient.client.luau:93](reference/source/client/ProtoFuelClient.client.luau) |
| `RemoteClient.Wait(timeout)` | [RemoteClient.luau:10](reference/source/client/RemoteClient.luau) |
| `Controller.Start(remotes,objective)` | [RocketClient.luau:14](reference/source/client/RocketClient.luau) |
| `segment(name,width,color,transparency)` | [RocketClient.luau:28](reference/source/client/RocketClient.luau) |
| `altitudeText(name,y,height,size,color)` | [RocketClient.luau:38](reference/source/client/RocketClient.luau) |
| `choice(name,x,text,color)` | [RocketClient.luau:45](reference/source/client/RocketClient.luau) |
| `layoutActions()` | [RocketClient.luau:53](reference/source/client/RocketClient.luau) |
| `bindActionViewport()` | [RocketClient.luau:71](reference/source/client/RocketClient.luau) |
| `act(action)` | [RocketClient.luau:86](reference/source/client/RocketClient.luau) |
| `setDive(enabled)` | [RocketClient.luau:89](reference/source/client/RocketClient.luau) |
| `toggleDive()` | [RocketClient.luau:97](reference/source/client/RocketClient.luau) |
| `clear()` | [RocketClient.luau:120](reference/source/client/RocketClient.luau) |
| `Input.Start(humanoid,send)` | [RocketInput.luau:4](reference/source/client/RocketInput.luau) |
| `text(parent,name,x,y,w,h,value,size,color)` | [RocketSkinShop.client.luau:12](reference/source/client/RocketSkinShop.client.luau) |
| `button(parent,name,x,y,w,h,value,color)` | [RocketSkinShop.client.luau:15](reference/source/client/RocketSkinShop.client.luau) |
| `update()` | [RocketSkinShop.client.luau:29](reference/source/client/RocketSkinShop.client.luau) |
| `choose(kind)` | [RocketSkinShop.client.luau:73](reference/source/client/RocketSkinShop.client.luau) |
| `setOpen(open)` | [RocketSkinShop.client.luau:78](reference/source/client/RocketSkinShop.client.luau) |
| `dismiss()` | [RocketSkinShop.client.luau:82](reference/source/client/RocketSkinShop.client.luau) |
| `FX.Create(gui)` | [RocketSpeedFX.luau:3](reference/source/client/RocketSpeedFX.luau) |
| `effect.Clear()` | [RocketSpeedFX.luau:26](reference/source/client/RocketSpeedFX.luau) |
| `effect.Attach(_root)` | [RocketSpeedFX.luau:31](reference/source/client/RocketSpeedFX.luau) |
| `effect.Update(speed,diving,dt,_point,boosting)` | [RocketSpeedFX.luau:32](reference/source/client/RocketSpeedFX.luau) |
| `clear(m)` | [RocketTrailStreams.client.luau:5](reference/source/client/RocketTrailStreams.client.luau) |
| `build(m,id)` | [RocketTrailStreams.client.luau:6](reference/source/client/RocketTrailStreams.client.luau) |
| `add(object)` | [RocketUISamples.client.luau:33](reference/source/client/RocketUISamples.client.luau) |
| `text(parent, value)` | [RocketUISamples.client.luau:38](reference/source/client/RocketUISamples.client.luau) |
| `leaveOnJump()` | [Showroom.client.luau:5](reference/source/client/Showroom.client.luau) |
| `notify()` | [Showroom.client.luau:15](reference/source/client/Showroom.client.luau) |
| `bind(v)` | [Showroom.client.luau:22](reference/source/client/Showroom.client.luau) |
| `update()` | [Showroom.client.luau:28](reference/source/client/Showroom.client.luau) |
| `clearVeil()` | [SkyController.luau:22](reference/source/client/SkyController.luau) |
| `revealSky()` | [SkyController.luau:23](reference/source/client/SkyController.luau) |
| `cancelTransition()` | [SkyController.luau:32](reference/source/client/SkyController.luau) |
| `switchPreviewSky(space)` | [SkyController.luau:37](reference/source/client/SkyController.luau) |
| `applyPreview(stage, immediate, biome, band)` | [SkyController.luau:57](reference/source/client/SkyController.luau) |
| `apply(clouds)` | [SkyController.luau:87](reference/source/client/SkyController.luau) |
| `Sky.Reset()` | [SkyController.luau:98](reference/source/client/SkyController.luau) |
| `Sky.SetRegion(region)` | [SkyController.luau:106](reference/source/client/SkyController.luau) |
| `Sky.ShowDestination(destination)` | [SkyController.luau:118](reference/source/client/SkyController.luau) |
| `Sky.Start()` | [SkyController.luau:126](reference/source/client/SkyController.luau) |
| `C.SetRecommendations(required,current,diving)` | [StageCurtains.luau:5](reference/source/client/StageCurtains.luau) |
| `C.WarningOnScreen()` | [StageCurtains.luau:6](reference/source/client/StageCurtains.luau) |
| `remove(entry)` | [StageCurtains.luau:15](reference/source/client/StageCurtains.luau) |
| `clear()` | [StageCurtains.luau:20](reference/source/client/StageCurtains.luau) |
| `C.Start()` | [StageCurtains.luau:21](reference/source/client/StageCurtains.luau) |
| `makeSign(entry)` | [StageCurtains.luau:27](reference/source/client/StageCurtains.luau) |
| `make(index)` | [StageCurtains.luau:34](reference/source/client/StageCurtains.luau) |
| `Input.Start(sendAxis, settings, mobile)` | [SteeringInput.luau:9](reference/source/client/SteeringInput.luau) |
| `controller.SetAxis(value)` | [SteeringInput.luau:14](reference/source/client/SteeringInput.luau) |
| `neutral()` | [SteeringInput.luau:19](reference/source/client/SteeringInput.luau) |
| `update()` | [SteeringInput.luau:23](reference/source/client/SteeringInput.luau) |
| `controller.Stop()` | [SteeringInput.luau:61](reference/source/client/SteeringInput.luau) |
| `button(name,x,text,action)` | [StudioProgressTest.client.luau:21](reference/source/client/StudioProgressTest.client.luau) |
| `update()` | [StudioProgressTest.client.luau:36](reference/source/client/StudioProgressTest.client.luau) |
| `soundAdded(v)` | [TotalHud.client.luau:8](reference/source/client/TotalHud.client.luau) |
| `label(parent,name,text,x,y,w,h,size,color)` | [TotalHud.client.luau:22](reference/source/client/TotalHud.client.luau) |
| `button(parent,name,text,x,y,w,h,color,icon)` | [TotalHud.client.luau:25](reference/source/client/TotalHud.client.luau) |
| `open(page)` | [TotalHud.client.luau:31](reference/source/client/TotalHud.client.luau) |
| `request(action,id)` | [TotalHud.client.luau:51](reference/source/client/TotalHud.client.luau) |
| `clear()` | [TotalHud.client.luau:73](reference/source/client/TotalHud.client.luau) |
| `row(name,text,y,color,callback,icon)` | [TotalHud.client.luau:74](reference/source/client/TotalHud.client.luau) |
| `render(page)` | [TotalHud.client.luau:79](reference/source/client/TotalHud.client.luau) |
| `pageChanged()` | [TotalHud.client.luau:104](reference/source/client/TotalHud.client.luau) |
| `resize()` | [TotalHud.client.luau:119](reference/source/client/TotalHud.client.luau) |
| `timer(attr,mult)` | [TotalHud.client.luau:133](reference/source/client/TotalHud.client.luau) |
| `stop()` | [TrainingFX.client.luau:6](reference/source/client/TrainingFX.client.luau) |
| `sync()` | [TrainingFX.client.luau:13](reference/source/client/TrainingFX.client.luau) |
| `finite(n)` | [XPProjection.luau:3](reference/source/client/XPProjection.luau) |
| `Projection.Calculate(camera,worldPosition,age)` | [XPProjection.luau:4](reference/source/client/XPProjection.luau) |
| `resetCannon()` | [CannonServer.server.luau:18](reference/source/reference/CannonServer.server.luau) |
| `report(key, message)` | [AssetRegistry.luau:24](reference/source/server/AssetRegistry.luau) |
| `Registry.Get(key)` | [AssetRegistry.luau:30](reference/source/server/AssetRegistry.luau) |
| `primitive(definition)` | [AssetRegistry.luau:34](reference/source/server/AssetRegistry.luau) |
| `block(name, size, position, color, tilt)` | [AssetRegistry.luau:38](reference/source/server/AssetRegistry.luau) |
| `Registry.Create(key)` | [AssetRegistry.luau:125](reference/source/server/AssetRegistry.luau) |
| `prepare(item)` | [AssetRegistry.luau:139](reference/source/server/AssetRegistry.luau) |
| `Rocket.Attach(character,styleId,trailId)` | [BackRocket.luau:5](reference/source/server/BackRocket.luau) |
| `part(name,size,offset,color,shape)` | [BackRocket.luau:11](reference/source/server/BackRocket.luau) |
| `Rocket.Pulse(character,throttle,phase,fuel)` | [BackRocket.luau:63](reference/source/server/BackRocket.luau) |
| `Rocket.Set(character,enabled)` | [BackRocket.luau:75](reference/source/server/BackRocket.luau) |
| `playerFromHit(hit)` | [BarrierSpawner.server.luau:48](reference/source/server/BarrierSpawner.server.luau) |
| `touched(state, triggerPart, hit)` | [BarrierSpawner.server.luau:60](reference/source/server/BarrierSpawner.server.luau) |
| `rebuild()` | [BarrierSpawner.server.luau:107](reference/source/server/BarrierSpawner.server.luau) |
| `resetIfDirty()` | [BarrierSpawner.server.luau:143](reference/source/server/BarrierSpawner.server.luau) |
| `watchPlayer(player)` | [BarrierSpawner.server.luau:146](reference/source/server/BarrierSpawner.server.luau) |
| `Visuals.Apply(model,name,position,radius)` | [BrainrotVisuals.luau:20](reference/source/server/BrainrotVisuals.luau) |
| `Course.Tier(level)` | [BreakCourse.luau:6](reference/source/server/BreakCourse.luau) |
| `Course.Plan(position,velocity,gravity,level,dive,motion)` | [BreakCourse.luau:10](reference/source/server/BreakCourse.luau) |
| `swept(row,from,to)` | [BreakCourse.luau:36](reference/source/server/BreakCourse.luau) |
| `makePart(parent,name,size,frame,color)` | [BreakCourse.luau:48](reference/source/server/BreakCourse.luau) |
| `Course.Create(player,id,position,velocity,gravity,level,motion)` | [BreakCourse.luau:52](reference/source/server/BreakCourse.luau) |
| `Course.Spawn(c,position,velocity,dive)` | [BreakCourse.luau:60](reference/source/server/BreakCourse.luau) |
| `Course.Update(c,position,velocity,elapsed,descent)` | [BreakCourse.luau:97](reference/source/server/BreakCourse.luau) |
| `Course.DiveTarget(c,position)` | [BreakCourse.luau:115](reference/source/server/BreakCourse.luau) |
| `Course.Sample(c,from,to,emit)` | [BreakCourse.luau:125](reference/source/server/BreakCourse.luau) |
| `Course.Destroy(c)` | [BreakCourse.luau:138](reference/source/server/BreakCourse.luau) |
| `part(parent,name,size,cf,color)` | [CampShowroom.luau:11](reference/source/server/CampShowroom.luau) |
| `prompt(anchor,kind,index,name)` | [CampShowroom.luau:14](reference/source/server/CampShowroom.luau) |
| `badge(anchor,title)` | [CampShowroom.luau:17](reference/source/server/CampShowroom.luau) |
| `Showroom.Build(camp)` | [CampShowroom.luau:24](reference/source/server/CampShowroom.luau) |
| `cf(x,z,y,facing)` | [CampShowroom.luau:28](reference/source/server/CampShowroom.luau) |
| `heading(name,x,title,color)` | [CampShowroom.luau:75](reference/source/server/CampShowroom.luau) |
| `watch(player)` | [ClickerService.server.luau:8](reference/source/server/ClickerService.server.luau) |
| `part(parent,name,size,position,color,material,shape)` | [CliffCamp.luau:4](reference/source/server/CliffCamp.luau) |
| `sign(parent,text,pos,width,color)` | [CliffCamp.luau:11](reference/source/server/CliffCamp.luau) |
| `Camp.Start(frame)` | [CliffCamp.luau:19](reference/source/server/CliffCamp.luau) |
| `at(forward,right,y)` | [CliffCamp.luau:28](reference/source/server/CliffCamp.luau) |
| `Discovery.Create(bestAltitude, visitedThisSession)` | [CloudDiscovery.luau:4](reference/source/server/CloudDiscovery.luau) |
| `Discovery.Sample(discovery, metrics)` | [CloudDiscovery.luau:10](reference/source/server/CloudDiscovery.luau) |
| `Clouds.Build(parent, frame, plan, config, destinations)` | [CloudSection.luau:5](reference/source/server/CloudSection.luau) |
| `Course.RingPlacements(frame, config, gravity)` | [CourseSection.luau:5](reference/source/server/CourseSection.luau) |
| `Course.Build(model, frame, plan, config, applyGimmick)` | [CourseSection.luau:19](reference/source/server/CourseSection.luau) |
| `part(name, distance, side, height, size, color)` | [CourseSection.luau:20](reference/source/server/CourseSection.luau) |
| `each(start, last, step, callback)` | [CourseSection.luau:45](reference/source/server/CourseSection.luau) |
| `Challenge.FallSpeed(route,height)` | [DescentChallenge.luau:3](reference/source/server/DescentChallenge.luau) |
| `Challenge.TimeToFall(distance,gravity,speed,height)` | [DescentChallenge.luau:6](reference/source/server/DescentChallenge.luau) |
| `Challenge.Create(position,velocity,groundY,gravity,id)` | [DescentChallenge.luau:18](reference/source/server/DescentChallenge.luau) |
| `Challenge.Sample(route,from,to)` | [DescentChallenge.luau:39](reference/source/server/DescentChallenge.luau) |
| `Challenge.Reward(route,position,landingType)` | [DescentChallenge.luau:52](reference/source/server/DescentChallenge.luau) |
| `Challenge.Payload(route)` | [DescentChallenge.luau:62](reference/source/server/DescentChallenge.luau) |
| `Destination.Build(parent, frame, plan, definitions)` | [Destination.luau:5](reference/source/server/Destination.luau) |
| `Destination.Sample(frame, position, metrics, definitions, visited)` | [Destination.luau:24](reference/source/server/Destination.luau) |
| `Config.Placements(origin, velocity, right, gravity, referenceFor)` | [DestructibleConfig.luau:25](reference/source/server/DestructibleConfig.luau) |
| `Config.Cells(kind)` | [DestructibleConfig.luau:39](reference/source/server/DestructibleConfig.luau) |
| `Config.Contains(part, position, contactRadius)` | [DestructibleConfig.luau:66](reference/source/server/DestructibleConfig.luau) |
| `Zone.Plan(height,speed,topOverride)` | [DiveBreakZone.luau:9](reference/source/server/DiveBreakZone.luau) |
| `Zone.Create(player,id,parent,score,groundY)` | [DiveBreakZone.luau:20](reference/source/server/DiveBreakZone.luau) |
| `part(parent,name,size,position,color)` | [DiveBreakZone.luau:24](reference/source/server/DiveBreakZone.luau) |
| `frame(z,position)` | [DiveBreakZone.luau:28](reference/source/server/DiveBreakZone.luau) |
| `Zone.Update(z,position,velocity,diving,basis)` | [DiveBreakZone.luau:31](reference/source/server/DiveBreakZone.luau) |
| `Zone.Sample(z,from,to,diving,touches,emit)` | [DiveBreakZone.luau:72](reference/source/server/DiveBreakZone.luau) |
| `Zone.Crosses(center,from,to,radius)` | [DiveBreakZone.luau:96](reference/source/server/DiveBreakZone.luau) |
| `Zone.RingPlan(height)` | [DiveBreakZone.luau:101](reference/source/server/DiveBreakZone.luau) |
| `Zone.Extras(z,position)` | [DiveBreakZone.luau:112](reference/source/server/DiveBreakZone.luau) |
| `Impact.Bounds(character,root)` | [DiveImpact.luau:3](reference/source/server/DiveImpact.luau) |
| `Impact.BottomOffset(character,root)` | [DiveImpact.luau:16](reference/source/server/DiveImpact.luau) |
| `Impact.Sweep(world,character,root,velocity,dt,previous)` | [DiveImpact.luau:19](reference/source/server/DiveImpact.luau) |
| `Metrics.Create(origin, launchDirection, groundY, startedAt)` | [FlightMetrics.luau:4](reference/source/server/FlightMetrics.luau) |
| `Metrics.Sample(metrics, position, now)` | [FlightMetrics.luau:13](reference/source/server/FlightMetrics.luau) |
| `Metrics.Snapshot(metrics)` | [FlightMetrics.luau:23](reference/source/server/FlightMetrics.luau) |
| `landingType(instance)` | [FlightService.luau:53](reference/source/server/FlightService.luau) |
| `vectorFinite(value)` | [FlightService.luau:64](reference/source/server/FlightService.luau) |
| `live(run)` | [FlightService.luau:69](reference/source/server/FlightService.luau) |
| `state(run, value, reason)` | [FlightService.luau:76](reference/source/server/FlightService.luau) |
| `release(run)` | [FlightService.luau:84](reference/source/server/FlightService.luau) |
| `restoreParts(run, visibility, collision)` | [FlightService.luau:94](reference/source/server/FlightService.luau) |
| `cleanup(run, restorePosition)` | [FlightService.luau:103](reference/source/server/FlightService.luau) |
| `cancel(run, reason)` | [FlightService.luau:141](reference/source/server/FlightService.luau) |
| `returnToSpawn(run, reason)` | [FlightService.luau:151](reference/source/server/FlightService.luau) |
| `recover(run, reason)` | [FlightService.luau:167](reference/source/server/FlightService.luau) |
| `finish(run)` | [FlightService.luau:179](reference/source/server/FlightService.luau) |
| `begin(player)` | [FlightService.luau:226](reference/source/server/FlightService.luau) |
| `hide(part)` | [FlightService.luau:246](reference/source/server/FlightService.luau) |
| `fire(player, multiplier, id)` | [FlightService.luau:265](reference/source/server/FlightService.luau) |
| `Flight.ApplyGimmick(part, hit, kind)` | [FlightService.luau:324](reference/source/server/FlightService.luau) |
| `Flight.Start(model)` | [FlightService.luau:362](reference/source/server/FlightService.luau) |
| `watch(player)` | [FlightService.luau:402](reference/source/server/FlightService.luau) |
| `focus(player,name,position)` | [FlightStreaming.luau:3](reference/source/server/FlightStreaming.luau) |
| `Streaming.Create(player,position,velocity)` | [FlightStreaming.luau:10](reference/source/server/FlightStreaming.luau) |
| `Streaming.Update(c,position,velocity,descent)` | [FlightStreaming.luau:14](reference/source/server/FlightStreaming.luau) |
| `Streaming.Destroy(c)` | [FlightStreaming.luau:19](reference/source/server/FlightStreaming.luau) |
| `Event.Crosses(center,from,to,radius)` | [GoldRingEvent.luau:8](reference/source/server/GoldRingEvent.luau) |
| `Event.CanClaim(record,id)` | [GoldRingEvent.luau:16](reference/source/server/GoldRingEvent.luau) |
| `ring(position,index)` | [GoldRingEvent.luau:19](reference/source/server/GoldRingEvent.luau) |
| `Event.Update(now)` | [GoldRingEvent.luau:32](reference/source/server/GoldRingEvent.luau) |
| `Event.Start(position)` | [GoldRingEvent.luau:55](reference/source/server/GoldRingEvent.luau) |
| `Event.Collect(player,from,to)` | [GoldRingEvent.luau:63](reference/source/server/GoldRingEvent.luau) |
| `Steering.Create(launchVelocity)` | [HorizontalSteering.luau:4](reference/source/server/HorizontalSteering.luau) |
| `Steering.Accept(control, axis, now)` | [HorizontalSteering.luau:14](reference/source/server/HorizontalSteering.luau) |
| `Steering.Step(control, velocity, dt, now)` | [HorizontalSteering.luau:21](reference/source/server/HorizontalSteering.luau) |
| `Steering.Apply(control, root, dt, now)` | [HorizontalSteering.luau:42](reference/source/server/HorizontalSteering.luau) |
| `Trajectory.Muzzle(cylinderFrame, cylinderLength)` | [LaunchTrajectory.luau:6](reference/source/server/LaunchTrajectory.luau) |
| `Trajectory.AimedMuzzle(basePivot, pivotToCylinder, cylinderLength, yaw, pitch)` | [LaunchTrajectory.luau:10](reference/source/server/LaunchTrajectory.luau) |
| `Trajectory.Origin(muzzle)` | [LaunchTrajectory.luau:15](reference/source/server/LaunchTrajectory.luau) |
| `Trajectory.Velocity(look, level, timing, fuelBoost)` | [LaunchTrajectory.luau:19](reference/source/server/LaunchTrajectory.luau) |
| `Trajectory.AtForward(frame, muzzle, level, timing, gravity, distance)` | [LaunchTrajectory.luau:29](reference/source/server/LaunchTrajectory.luau) |
| `Legacy.Start(applyGimmick, mode)` | [LegacyGimmicks.luau:5](reference/source/server/LegacyGimmicks.luau) |
| `buildMapGimmicks()` | [LegacyGimmicks.luau:22](reference/source/server/LegacyGimmicks.luau) |
| `Builder.Plans(config)` | [LevelBuilder.luau:10](reference/source/server/LevelBuilder.luau) |
| `Builder.new(parent, frame, config, applyGimmick)` | [LevelBuilder.luau:35](reference/source/server/LevelBuilder.luau) |
| `Landing.Burst(character,root)` | [LimbLanding.luau:3](reference/source/server/LimbLanding.luau) |
| `Obstacles.Placements(config)` | [ObstaclePatterns.luau:6](reference/source/server/ObstaclePatterns.luau) |
| `add(side, suffix)` | [ObstaclePatterns.luau:19](reference/source/server/ObstaclePatterns.luau) |
| `Obstacles.Build(model, frame, plan, config, applyGimmick)` | [ObstaclePatterns.luau:39](reference/source/server/ObstaclePatterns.luau) |
| `valid(value, minimum)` | [PlayerData.luau:31](reference/source/server/PlayerData.luau) |
| `sameFields(a, b)` | [PlayerData.luau:36](reference/source/server/PlayerData.luau) |
| `Data.IsReady(player)` | [PlayerData.luau:43](reference/source/server/PlayerData.luau) |
| `Data.GetLevel(player, name)` | [PlayerData.luau:48](reference/source/server/PlayerData.luau) |
| `Data.Award(player, distance, gold, trophies, altitude)` | [PlayerData.luau:53](reference/source/server/PlayerData.luau) |
| `Data.Buy(player, kind)` | [PlayerData.luau:72](reference/source/server/PlayerData.luau) |
| `idle(player)` | [PlayerData.luau:95](reference/source/server/PlayerData.luau) |
| `Data.GetTrainingPower(player)` | [PlayerData.luau:100](reference/source/server/PlayerData.luau) |
| `Data.LaunchVertical(player,base,starter)` | [PlayerData.luau:108](reference/source/server/PlayerData.luau) |
| `Data.AwardDestructionTrophies(player,gain)` | [PlayerData.luau:114](reference/source/server/PlayerData.luau) |
| `Data.TrophyMultiplier(player)` | [PlayerData.luau:119](reference/source/server/PlayerData.luau) |
| `addXP(player,gain,source,unscaled)` | [PlayerData.luau:126](reference/source/server/PlayerData.luau) |
| `Data.PassiveXP(player,seconds)` | [PlayerData.luau:140](reference/source/server/PlayerData.luau) |
| `Data.AwardGoldRingXP(player)` | [PlayerData.luau:149](reference/source/server/PlayerData.luau) |
| `Data.AwardFlightXP(player,gain)` | [PlayerData.luau:154](reference/source/server/PlayerData.luau) |
| `Data.BuyXPItem(player,expected)` | [PlayerData.luau:159](reference/source/server/PlayerData.luau) |
| `clickAlive(player)` | [PlayerData.luau:171](reference/source/server/PlayerData.luau) |
| `Data.AwardAutoClickXP(player,count,mode)` | [PlayerData.luau:176](reference/source/server/PlayerData.luau) |
| `Data.ClickXP(player)` | [PlayerData.luau:181](reference/source/server/PlayerData.luau) |
| `Data.Train(player,seconds,tier)` | [PlayerData.luau:196](reference/source/server/PlayerData.luau) |
| `Data.Rebirth(player,expected)` | [PlayerData.luau:209](reference/source/server/PlayerData.luau) |
| `Data.SelectRocketSkin(player,index)` | [PlayerData.luau:222](reference/source/server/PlayerData.luau) |
| `Data.SelectRocketTrail(player,index)` | [PlayerData.luau:239](reference/source/server/PlayerData.luau) |
| `Data.BuyTrainingTier(player,expected)` | [PlayerData.luau:252](reference/source/server/PlayerData.luau) |
| `Data.Save(player)` | [PlayerData.luau:272](reference/source/server/PlayerData.luau) |
| `load(player)` | [PlayerData.luau:326](reference/source/server/PlayerData.luau) |
| `Data.Start()` | [PlayerData.luau:409](reference/source/server/PlayerData.luau) |
| `get(p)` | [PowerBoosts.luau:5](reference/source/server/PowerBoosts.luau) |
| `friends(p)` | [PowerBoosts.luau:9](reference/source/server/PowerBoosts.luau) |
| `S.Factors(p,now)` | [PowerBoosts.luau:14](reference/source/server/PowerBoosts.luau) |
| `S.Power(p,base)` | [PowerBoosts.luau:18](reference/source/server/PowerBoosts.luau) |
| `S.Trophies(p,gain)` | [PowerBoosts.luau:22](reference/source/server/PowerBoosts.luau) |
| `S.Publish(p)` | [PowerBoosts.luau:26](reference/source/server/PowerBoosts.luau) |
| `S.Grant(p,id)` | [PowerBoosts.luau:34](reference/source/server/PowerBoosts.luau) |
| `S.Request(p,action,id)` | [PowerBoosts.luau:41](reference/source/server/PowerBoosts.luau) |
| `check(p,other)` | [PowerBoosts.luau:54](reference/source/server/PowerBoosts.luau) |
| `S.Start()` | [PowerBoosts.luau:69](reference/source/server/PowerBoosts.luau) |
| `joined(p)` | [PowerBoosts.luau:70](reference/source/server/PowerBoosts.luau) |
| `get(player)` | [ProtoFuelService.luau:12](reference/source/server/ProtoFuelService.luau) |
| `eligible(player, now, s)` | [ProtoFuelService.luau:21](reference/source/server/ProtoFuelService.luau) |
| `advance(player, s, now)` | [ProtoFuelService.luau:39](reference/source/server/ProtoFuelService.luau) |
| `Fuel.getFuelState(player)` | [ProtoFuelService.luau:48](reference/source/server/ProtoFuelService.luau) |
| `send(player)` | [ProtoFuelService.luau:54](reference/source/server/ProtoFuelService.luau) |
| `Fuel.consumeFuelForLaunch(player)` | [ProtoFuelService.luau:58](reference/source/server/ProtoFuelService.luau) |
| `Fuel.getSessionPowerBonus(player)` | [ProtoFuelService.luau:63](reference/source/server/ProtoFuelService.luau) |
| `Fuel.consumeFuelForPowerUp(player)` | [ProtoFuelService.luau:67](reference/source/server/ProtoFuelService.luau) |
| `Fuel.Start()` | [ProtoFuelService.luau:79](reference/source/server/ProtoFuelService.luau) |
| `remote(name)` | [ProtoFuelService.luau:81](reference/source/server/ProtoFuelService.luau) |
| `request(player, requested)` | [ProtoFuelService.luau:90](reference/source/server/ProtoFuelService.luau) |
| `watch(player)` | [ProtoFuelService.luau:103](reference/source/server/ProtoFuelService.luau) |
| `Remotes.Ensure()` | [Remotes.luau:19](reference/source/server/Remotes.luau) |
| `Economy.Migrate(values,itemCount)` | [RocketEconomy.luau:3](reference/source/server/RocketEconomy.luau) |
| `finite(v)` | [RocketFlightService.luau:27](reference/source/server/RocketFlightService.luau) |
| `validVector(v)` | [RocketFlightService.luau:28](reference/source/server/RocketFlightService.luau) |
| `state(run,value,reason)` | [RocketFlightService.luau:29](reference/source/server/RocketFlightService.luau) |
| `cleanup(run)` | [RocketFlightService.luau:33](reference/source/server/RocketFlightService.luau) |
| `abandon(run,reason)` | [RocketFlightService.luau:40](reference/source/server/RocketFlightService.luau) |
| `finish(run,reason,reward)` | [RocketFlightService.luau:46](reference/source/server/RocketFlightService.luau) |
| `destroyed(run,position,units)` | [RocketFlightService.luau:76](reference/source/server/RocketFlightService.luau) |
| `recommendations(player,originY)` | [RocketFlightService.luau:82](reference/source/server/RocketFlightService.luau) |
| `profile(raw)` | [RocketFlightService.luau:85](reference/source/server/RocketFlightService.luau) |
| `launch(player)` | [RocketFlightService.luau:98](reference/source/server/RocketFlightService.luau) |
| `beginDive(run,reason)` | [RocketFlightService.luau:140](reference/source/server/RocketFlightService.luau) |
| `Service.Start(cannon)` | [RocketFlightService.luau:153](reference/source/server/RocketFlightService.luau) |
| `watch(player)` | [RocketFlightService.luau:165](reference/source/server/RocketFlightService.luau) |
| `characterAdded(character)` | [RocketFlightService.luau:166](reference/source/server/RocketFlightService.luau) |
| `refreshEquipment()` | [RocketFlightService.luau:172](reference/source/server/RocketFlightService.luau) |
| `Pose.Create(character)` | [RocketPose.luau:2](reference/source/server/RocketPose.luau) |
| `Pose.Dive(p)` | [RocketPose.luau:12](reference/source/server/RocketPose.luau) |
| `Pose.Restore(p)` | [RocketPose.luau:16](reference/source/server/RocketPose.luau) |
| `Rules.DiveSpeed(current,target,gravity,age,dt)` | [RocketRules.luau:2](reference/source/server/RocketRules.luau) |
| `Rules.DiveTarget(height,boost,current,normalLimit,boostLimit)` | [RocketRules.luau:9](reference/source/server/RocketRules.luau) |
| `Rules.DiveSteering(fallSpeed,minimum,maximum,ratio,acceleration)` | [RocketRules.luau:15](reference/source/server/RocketRules.luau) |
| `Rules.DiveAim(current,target,steering,boost,limit,deceleration,dt)` | [RocketRules.luau:19](reference/source/server/RocketRules.luau) |
| `Rules.FlightTimeout(height,burn,normalLimit)` | [RocketRules.luau:26](reference/source/server/RocketRules.luau) |
| `Rules.Input(value)` | [RocketRules.luau:29](reference/source/server/RocketRules.luau) |
| `Rules.Fallen(peak,y,velocity,drop)` | [RocketRules.luau:33](reference/source/server/RocketRules.luau) |
| `Rules.Trophies(zoneReward)` | [RocketRules.luau:36](reference/source/server/RocketRules.luau) |
| `Rules.Step(current,target,acceleration,dt)` | [RocketRules.luau:40](reference/source/server/RocketRules.luau) |
| `S.Build(part,style)` | [RocketShapes.luau:3](reference/source/server/RocketShapes.luau) |
| `p(name,size,x,y,z,color,shape,angle)` | [RocketShapes.luau:5](reference/source/server/RocketShapes.luau) |
| `Policy.finite(value)` | [RunPolicy.luau:8](reference/source/server/RunPolicy.luau) |
| `Policy.validAim(yaw, pitch)` | [RunPolicy.luau:12](reference/source/server/RunPolicy.luau) |
| `Policy.validMultiplier(value)` | [RunPolicy.luau:17](reference/source/server/RunPolicy.luau) |
| `Policy.reward(distance, targetCount)` | [RunPolicy.luau:21](reference/source/server/RunPolicy.luau) |
| `Policy.isCurrent(run, id, character)` | [RunPolicy.luau:25](reference/source/server/RunPolicy.luau) |
| `Service.Leave(player)` | [SharedTraining.luau:10](reference/source/server/SharedTraining.luau) |
| `Service.Join(player,station,automatic)` | [SharedTraining.luau:18](reference/source/server/SharedTraining.luau) |
| `groupPart(p)` | [SharedTraining.luau:31](reference/source/server/SharedTraining.luau) |
| `Service.ActiveTier(player)` | [SharedTraining.luau:39](reference/source/server/SharedTraining.luau) |
| `Service.AutoJoin(player,stations)` | [SharedTraining.luau:46](reference/source/server/SharedTraining.luau) |
| `Effects.Pedestal(base,color)` | [ShowroomEffects.luau:3](reference/source/server/ShowroomEffects.luau) |
| `Effects.Toilet(model,base,style)` | [ShowroomEffects.luau:14](reference/source/server/ShowroomEffects.luau) |
| `bind(p)` | [ShowroomService.server.luau:12](reference/source/server/ShowroomService.server.luau) |
| `inGate(y,radius)` | [SkyLife.luau:8](reference/source/server/SkyLife.luau) |
| `Life.StreamSectionRange(altitude,verticalSpeed)` | [SkyLife.luau:23](reference/source/server/SkyLife.luau) |
| `part(m,name,pos,size,color,shape)` | [SkyLife.luau:28](reference/source/server/SkyLife.luau) |
| `badge(m,text,color,radius)` | [SkyLife.luau:36](reference/source/server/SkyLife.luau) |
| `hide(m,hidden)` | [SkyLife.luau:40](reference/source/server/SkyLife.luau) |
| `Life.Start(frame)` | [SkyLife.luau:46](reference/source/server/SkyLife.luau) |
| `at(f,r,y)` | [SkyLife.luau:51](reference/source/server/SkyLife.luau) |
| `spawnBand(b,band)` | [SkyLife.luau:52](reference/source/server/SkyLife.luau) |
| `touches(m,from,to,radius)` | [SkyLife.luau:264](reference/source/server/SkyLife.luau) |
| `Life.Hit(from,to)` | [SkyLife.luau:281](reference/source/server/SkyLife.luau) |
| `Life.Collect(player,from,to,visited,onDestroyed)` | [SkyLife.luau:293](reference/source/server/SkyLife.luau) |
| `Life.BreakEnemy(player,m,visited)` | [SkyLife.luau:330](reference/source/server/SkyLife.luau) |
| `Patrol.New(origin,seed)` | [SkyPatrol.luau:3](reference/source/server/SkyPatrol.luau) |
| `Patrol.Step(state,dt,now)` | [SkyPatrol.luau:6](reference/source/server/SkyPatrol.luau) |
| `Service.Start()` | [SpawnService.luau:4](reference/source/server/SpawnService.luau) |
| `disableOther(object)` | [SpawnService.luau:9](reference/source/server/SpawnService.luau) |
| `watch(player)` | [SpawnService.luau:15](reference/source/server/SpawnService.luau) |
| `place(character)` | [SpawnService.luau:17](reference/source/server/SpawnService.luau) |
| `remote(name)` | [TrainingService.server.luau:7](reference/source/server/TrainingService.server.luau) |
| `part(name,size,position,color,solid,parent)` | [TrophyZones.luau:6](reference/source/server/TrophyZones.luau) |
| `Zones.Start(launchPosition,ground)` | [TrophyZones.luau:9](reference/source/server/TrophyZones.luau) |
| `Zones.Ascend(character)` | [TrophyZones.luau:32](reference/source/server/TrophyZones.luau) |
| `Zones.Restore(saved)` | [TrophyZones.luau:37](reference/source/server/TrophyZones.luau) |
| `Zones.Resolve(instance,point,normal)` | [TrophyZones.luau:40](reference/source/server/TrophyZones.luau) |
| `Zones.IsDeck(instance)` | [TrophyZones.luau:48](reference/source/server/TrophyZones.luau) |
| `Zones.Sweep(character,root,previous,nextPosition)` | [TrophyZones.luau:49](reference/source/server/TrophyZones.luau) |
| `Zones.Target(height)` | [TrophyZones.luau:67](reference/source/server/TrophyZones.luau) |
| `Coordinates.Create(muzzleFrame, groundY)` | [WorldCoordinates.luau:3](reference/source/server/WorldCoordinates.luau) |
| `Coordinates.Project(frame, position)` | [WorldCoordinates.luau:12](reference/source/server/WorldCoordinates.luau) |
| `Coordinates.Measure(frame, position)` | [WorldCoordinates.luau:19](reference/source/server/WorldCoordinates.luau) |
| `Coordinates.Position(frame, distance, lateral, height)` | [WorldCoordinates.luau:24](reference/source/server/WorldCoordinates.luau) |
| `Coordinates.RewardDistance(position, launchOrigin)` | [WorldCoordinates.luau:29](reference/source/server/WorldCoordinates.luau) |
| `Coordinates.ExitReason(frame, position, velocity, destroyHeight, bounds)` | [WorldCoordinates.luau:33](reference/source/server/WorldCoordinates.luau) |
| `World.Start(cannon, applyGimmick)` | [WorldService.luau:14](reference/source/server/WorldService.luau) |
| `update()` | [WorldService.luau:46](reference/source/server/WorldService.luau) |
| `World.TargetCount(position)` | [WorldService.luau:75](reference/source/server/WorldService.luau) |
| `World.HazardHit(from,to)` | [WorldService.luau:89](reference/source/server/WorldService.luau) |
| `World.BreakSkyEnemy(player,model,visited)` | [WorldService.luau:94](reference/source/server/WorldService.luau) |
| `World.CollectSky(player,from,to,visited,onDestroyed)` | [WorldService.luau:98](reference/source/server/WorldService.luau) |
| `World.GroundY()` | [WorldService.luau:102](reference/source/server/WorldService.luau) |
| `World.GetCloudOutpostObjective()` | [WorldService.luau:106](reference/source/server/WorldService.luau) |
| `World.SampleDestination(position, metrics, visited)` | [WorldService.luau:120](reference/source/server/WorldService.luau) |
| `World.ExitReason(position, velocity)` | [WorldService.luau:125](reference/source/server/WorldService.luau) |
| `Balance.PowerValue(level)` | [BalanceConfig.luau:17](reference/source/shared/BalanceConfig.luau) |
| `Balance.VerticalPower(level)` | [BalanceConfig.luau:21](reference/source/shared/BalanceConfig.luau) |
| `Balance.LaunchComponents(level, aimY, timing)` | [BalanceConfig.luau:26](reference/source/shared/BalanceConfig.luau) |
| `Balance.PowerCost(level)` | [BalanceConfig.luau:38](reference/source/shared/BalanceConfig.luau) |
| `Balance.BoostCost(level)` | [BalanceConfig.luau:47](reference/source/shared/BalanceConfig.luau) |
| `Balance.GoldReward(distance)` | [BalanceConfig.luau:51](reference/source/shared/BalanceConfig.luau) |
| `Balance.Reward(distance, targets)` | [BalanceConfig.luau:55](reference/source/shared/BalanceConfig.luau) |
| `Balance.RingLiftBudget(launchVertical)` | [BalanceConfig.luau:61](reference/source/shared/BalanceConfig.luau) |
| `Balance.RingComponents(horizontal, vertical, boostLevel, launchHorizontal, remainingLift)` | [BalanceConfig.luau:65](reference/source/shared/BalanceConfig.luau) |
| `C.Rate(mode)` | [ClickerConfig.luau:3](reference/source/shared/ClickerConfig.luau) |
| `C.ValidMode(mode)` | [ClickerConfig.luau:4](reference/source/shared/ClickerConfig.luau) |
| `C.Step(balance,dt,mode)` | [ClickerConfig.luau:5](reference/source/shared/ClickerConfig.luau) |
| `text(parent,name,size,color)` | [ClickerUI.luau:7](reference/source/shared/ClickerUI.luau) |
| `surface(frame,color,radius)` | [ClickerUI.luau:10](reference/source/shared/ClickerUI.luau) |
| `UI.Cursor(parent,op)` | [ClickerUI.luau:16](reference/source/shared/ClickerUI.luau) |
| `UI.Progress(parent)` | [ClickerUI.luau:19](reference/source/shared/ClickerUI.luau) |
| `UI.Button(parent,mode)` | [ClickerUI.luau:30](reference/source/shared/ClickerUI.luau) |
| `UI.BottomLayout(gui,view)` | [ClickerUI.luau:44](reference/source/shared/ClickerUI.luau) |
| `UI.ResizeProgress(view,width,compact)` | [ClickerUI.luau:70](reference/source/shared/ClickerUI.luau) |
| `UI.UpdateProgress(view,level,xp,required,power)` | [ClickerUI.luau:73](reference/source/shared/ClickerUI.luau) |
| `UI.UpdateButton(view,selected)` | [ClickerUI.luau:77](reference/source/shared/ClickerUI.luau) |
| `G.Step(state,gates,previous,height,dt,diving,velocity)` | [CloudGateRules.luau:3](reference/source/shared/CloudGateRules.luau) |
| `G.Band(band,gates,height)` | [CloudGateRules.luau:27](reference/source/shared/CloudGateRules.luau) |
| `C.Color(height,index)` | [CourseVisualConfig.luau:15](reference/source/shared/CourseVisualConfig.luau) |
| `finite(v)` | [DestructionRewardConfig.luau:3](reference/source/shared/DestructionRewardConfig.luau) |
| `C.Multiplier(height)` | [DestructionRewardConfig.luau:4](reference/source/shared/DestructionRewardConfig.luau) |
| `C.Reward(count,height)` | [DestructionRewardConfig.luau:8](reference/source/shared/DestructionRewardConfig.luau) |
| `E.Bonuses(skin,trail)` | [EquipmentPower.luau:4](reference/source/shared/EquipmentPower.luau) |
| `E.Vertical(base,starter,skin,trail)` | [EquipmentPower.luau:7](reference/source/shared/EquipmentPower.luau) |
| `E.Description(item)` | [EquipmentPower.luau:11](reference/source/shared/EquipmentPower.luau) |
| `R.Crossing(profile,height,sample)` | [GateRequirements.luau:3](reference/source/shared/GateRequirements.luau) |
| `R.CanPass(gate,originY,profile,sample)` | [GateRequirements.luau:8](reference/source/shared/GateRequirements.luau) |
| `R.Power(gate,originY,makeProfile,sample)` | [GateRequirements.luau:16](reference/source/shared/GateRequirements.luau) |
| `M.Attach(panel)` | [MenuOverlay.luau:4](reference/source/shared/MenuOverlay.luau) |
| `changed()` | [MenuOverlay.luau:7](reference/source/shared/MenuOverlay.luau) |
| `C.Apply(base,multiplier,foodPercent,friendPercent)` | [PowerBoostConfig.luau:5](reference/source/shared/PowerBoostConfig.luau) |
| `C.Active(multiplier,expires,now)` | [PowerBoostConfig.luau:8](reference/source/shared/PowerBoostConfig.luau) |
| `C.PassiveXPRate(_level)` | [ProgressionConfig.luau:29](reference/source/shared/ProgressionConfig.luau) |
| `lateBand(b)` | [ProgressionConfig.luau:33](reference/source/shared/ProgressionConfig.luau) |
| `C.RequiredXP(level)` | [ProgressionConfig.luau:34](reference/source/shared/ProgressionConfig.luau) |
| `C.RebirthRequired(rebirths)` | [ProgressionConfig.luau:37](reference/source/shared/ProgressionConfig.luau) |
| `C.XPBetween(from,to)` | [ProgressionConfig.luau:46](reference/source/shared/ProgressionConfig.luau) |
| `partial(start,finish,band)` | [ProgressionConfig.luau:51](reference/source/shared/ProgressionConfig.luau) |
| `complete(a,b)` | [ProgressionConfig.luau:56](reference/source/shared/ProgressionConfig.luau) |
| `C.Advance(level,xp)` | [ProgressionConfig.luau:73](reference/source/shared/ProgressionConfig.luau) |
| `C.GoldRingXP(level)` | [ProgressionConfig.luau:82](reference/source/shared/ProgressionConfig.luau) |
| `C.Multiplier(rebirths)` | [ProgressionConfig.luau:83](reference/source/shared/ProgressionConfig.luau) |
| `C.PowerMultiplier(rebirths)` | [ProgressionConfig.luau:85](reference/source/shared/ProgressionConfig.luau) |
| `C.PowerBonus(level,rebirths)` | [ProgressionConfig.luau:86](reference/source/shared/ProgressionConfig.luau) |
| `Motion.Create(vertical,gravity)` | [RocketMotion.luau:3](reference/source/shared/RocketMotion.luau) |
| `Motion.CreateRocket(vertical,gravity)` | [RocketMotion.luau:15](reference/source/shared/RocketMotion.luau) |
| `Motion.Sample(p,time)` | [RocketMotion.luau:29](reference/source/shared/RocketMotion.luau) |
| `C.Owns(mask,index)` | [RocketSkinCatalog.luau:20](reference/source/shared/RocketSkinCatalog.luau) |
| `C.Valid(mask,index)` | [RocketSkinCatalog.luau:21](reference/source/shared/RocketSkinCatalog.luau) |
| `C.Grant(mask,index)` | [RocketSkinCatalog.luau:26](reference/source/shared/RocketSkinCatalog.luau) |
| `C.Milestones(mask,rebirths)` | [RocketSkinCatalog.luau:27](reference/source/shared/RocketSkinCatalog.luau) |
| `C.Owns(mask,index)` | [RocketTrailCatalog.luau:10](reference/source/shared/RocketTrailCatalog.luau) |
| `C.Grant(mask,index)` | [RocketTrailCatalog.luau:11](reference/source/shared/RocketTrailCatalog.luau) |
| `C.Valid(mask,index)` | [RocketTrailCatalog.luau:12](reference/source/shared/RocketTrailCatalog.luau) |
| `C.Find(id)` | [RocketTrailCatalog.luau:15](reference/source/shared/RocketTrailCatalog.luau) |
| `C.Sequence(item)` | [RocketTrailCatalog.luau:16](reference/source/shared/RocketTrailCatalog.luau) |
| `new(className, props, parent)` | [RocketUI.luau:33](reference/source/shared/RocketUI.luau) |
| `placement(object, props, defaultSize)` | [RocketUI.luau:39](reference/source/shared/RocketUI.luau) |
| `util.applyCorner(object, radius)` | [RocketUI.luau:45](reference/source/shared/RocketUI.luau) |
| `util.applyStroke(object, style)` | [RocketUI.luau:50](reference/source/shared/RocketUI.luau) |
| `util.applyGradient(object, def)` | [RocketUI.luau:58](reference/source/shared/RocketUI.luau) |
| `decorate(object, props, gradient)` | [RocketUI.luau:64](reference/source/shared/RocketUI.luau) |
| `label(parent, name, text, style, size, position)` | [RocketUI.luau:74](reference/source/shared/RocketUI.luau) |
| `icon(parent, image, color, size, position)` | [RocketUI.luau:80](reference/source/shared/RocketUI.luau) |
| `tween(object, properties, speed)` | [RocketUI.luau:87](reference/source/shared/RocketUI.luau) |
| `util.tweenHover(button, enterScale, leaveScale, speed)` | [RocketUI.luau:92](reference/source/shared/RocketUI.luau) |
| `update()` | [RocketUI.luau:96](reference/source/shared/RocketUI.luau) |
| `connect(signal, callback)` | [RocketUI.luau:104](reference/source/shared/RocketUI.luau) |
| `cleanup()` | [RocketUI.luau:116](reference/source/shared/RocketUI.luau) |
| `util.formatNumber(value)` | [RocketUI.luau:126](reference/source/shared/RocketUI.luau) |
| `util.formatCurrency(value, currencyName)` | [RocketUI.luau:134](reference/source/shared/RocketUI.luau) |
| `create.panel(props)` | [RocketUI.luau:137](reference/source/shared/RocketUI.luau) |
| `create.button(props)` | [RocketUI.luau:145](reference/source/shared/RocketUI.luau) |
| `util.setProgress(bar, value)` | [RocketUI.luau:163](reference/source/shared/RocketUI.luau) |
| `create.progressBar(props)` | [RocketUI.luau:171](reference/source/shared/RocketUI.luau) |
| `create.currencyBadge(props)` | [RocketUI.luau:183](reference/source/shared/RocketUI.luau) |
| `create.statBadge(props)` | [RocketUI.luau:193](reference/source/shared/RocketUI.luau) |
| `create.objectiveBanner(props)` | [RocketUI.luau:202](reference/source/shared/RocketUI.luau) |
| `util.closePopup(popup)` | [RocketUI.luau:213](reference/source/shared/RocketUI.luau) |
| `create.popup(props)` | [RocketUI.luau:217](reference/source/shared/RocketUI.luau) |
| `create.upgradeButton(props)` | [RocketUI.luau:252](reference/source/shared/RocketUI.luau) |
| `RocketUI.applyResponsiveScale(screenGui)` | [RocketUI.luau:263](reference/source/shared/RocketUI.luau) |
| `update()` | [RocketUI.luau:272](reference/source/shared/RocketUI.luau) |
| `bindCamera()` | [RocketUI.luau:279](reference/source/shared/RocketUI.luau) |
| `cleanup()` | [RocketUI.luau:285](reference/source/shared/RocketUI.luau) |
| `C.Slot(kind,index)` | [ShowroomConfig.luau:13](reference/source/shared/ShowroomConfig.luau) |
| `C.Near(localPosition,exit)` | [ShowroomConfig.luau:22](reference/source/shared/ShowroomConfig.luau) |
| `HUD.text(label, size, color)` | [SimulatorHUD.luau:13](reference/source/shared/SimulatorHUD.luau) |
| `HUD.screen(gui, order)` | [SimulatorHUD.luau:24](reference/source/shared/SimulatorHUD.luau) |
| `HUD.surface(frame, color)` | [SimulatorHUD.luau:31](reference/source/shared/SimulatorHUD.luau) |
| `HUD.button(button, color)` | [SimulatorHUD.luau:40](reference/source/shared/SimulatorHUD.luau) |
| `HUD.fit(panel, width, height, onViewport)` | [SimulatorHUD.luau:50](reference/source/shared/SimulatorHUD.luau) |
| `update()` | [SimulatorHUD.luau:58](reference/source/shared/SimulatorHUD.luau) |
| `bind()` | [SimulatorHUD.luau:64](reference/source/shared/SimulatorHUD.luau) |
| `HUD.leftDockTop(viewport)` | [SimulatorHUD.luau:84](reference/source/shared/SimulatorHUD.luau) |
| `HUD.currency(gui)` | [SimulatorHUD.luau:87](reference/source/shared/SimulatorHUD.luau) |
| `sync()` | [SimulatorHUD.luau:95](reference/source/shared/SimulatorHUD.luau) |
| `HUD.shop(gui, frame)` | [SimulatorHUD.luau:104](reference/source/shared/SimulatorHUD.luau) |
| `HUD.result(gui, frame)` | [SimulatorHUD.luau:126](reference/source/shared/SimulatorHUD.luau) |
| `HUD.altitude(gui, targetLabel)` | [SimulatorHUD.luau:158](reference/source/shared/SimulatorHUD.luau) |
| `HUD.fuel(gui, frame, status, note, bonus, button, track, fill)` | [SimulatorHUD.luau:175](reference/source/shared/SimulatorHUD.luau) |
| `T.Surface(frame,studs)` | [SimulatorTheme.luau:7](reference/source/shared/SimulatorTheme.luau) |
| `T.Button(button)` | [SimulatorTheme.luau:13](reference/source/shared/SimulatorTheme.luau) |
| `recenter()` | [SimulatorTheme.luau:17](reference/source/shared/SimulatorTheme.luau) |
| `play(value)` | [SimulatorTheme.luau:28](reference/source/shared/SimulatorTheme.luau) |
| `Zones.Layer(index)` | [TrophyZoneConfig.luau:3](reference/source/shared/TrophyZoneConfig.luau) |
| `Zones.Recommended(height)` | [TrophyZoneConfig.luau:7](reference/source/shared/TrophyZoneConfig.luau) |
| `I.Image(parent,key,position,size)` | [UIIcons.luau:3](reference/source/shared/UIIcons.luau) |

## 이벤트/핸들러 연결

| 위치 | 실제 연결 코드 |
|---|---|
| [AltitudeLandscape.client.luau:64](reference/source/client/AltitudeLandscape.client.luau) | `player.CharacterRemoving:Connect(clear)` |
| [AltitudeLandscape.client.luau:65](reference/source/client/AltitudeLandscape.client.luau) | `game:GetService("RunService").Heartbeat:Connect(function(dt)` |
| [ClickerClient.client.luau:45](reference/source/client/ClickerClient.client.luau) | `for _,name in {"RocketSkinEquipped","RocketTrailEquipped"}do equipment:WaitForChild(name).Changed:Connect(update)end` |
| [ClickerClient.client.luau:54](reference/source/client/ClickerClient.client.luau) | `free.Button.Activated:Connect(function()selectMode("Free")end);op.Button.Activated:Connect(function()selectMode("OP")end)` |
| [ClickerClient.client.luau:59](reference/source/client/ClickerClient.client.luau) | `UIS.InputBegan:Connect(function(input,processed)if input.UserInputType==Enum.UserInputType.MouseButton1 then manual(processed)end end)` |
| [ClickerClient.client.luau:61](reference/source/client/ClickerClient.client.luau) | `UIS.TouchTapInWorld:Connect(function(_,processed)manual(processed)end)` |
| [ClickerClient.client.luau:62](reference/source/client/ClickerClient.client.luau) | `for _,name in {"TrainingLevel","TrainingXP","Rebirths"}do stats:WaitForChild(name).Changed:Connect(update)end` |
| [CloudGateChasers.client.luau:41](reference/source/client/CloudGateChasers.client.luau) | `player.CharacterRemoving:Connect(clear)` |
| [CloudGateLightning.client.luau:10](reference/source/client/CloudGateLightning.client.luau) | `Run.Heartbeat:Connect(function()` |
| [CloudGateLightning.client.luau:31](reference/source/client/CloudGateLightning.client.luau) | `player.CharacterRemoving:Connect(hide)` |
| [ConsumedButter.client.luau:15](reference/source/client/ConsumedButter.client.luau) | `event.OnClientEvent:Connect(function(data)` |
| [ConsumedButter.client.luau:21](reference/source/client/ConsumedButter.client.luau) | `RunService.Heartbeat:Connect(function(dt)` |
| [ConsumedButter.client.luau:36](reference/source/client/ConsumedButter.client.luau) | `player.CharacterRemoving:Connect(restore)` |
| [CurrencyHud.luau:27](reference/source/client/CurrencyHud.luau) | `trophies.Changed:Connect(sync);sync();return` |
| [CurrencyHud.luau:34](reference/source/client/CurrencyHud.luau) | `gold.Changed:Connect(updateBalances)` |
| [CurrencyHud.luau:35](reference/source/client/CurrencyHud.luau) | `trophies.Changed:Connect(updateBalances)` |
| [DescentChallenge.client.luau:41](reference/source/client/DescentChallenge.client.luau) | `RS:WaitForChild("FireCannon").OnClientEvent:Connect(function(velocity,id,char)` |
| [DescentChallenge.client.luau:45](reference/source/client/DescentChallenge.client.luau) | `RS:WaitForChild("FlightState").OnClientEvent:Connect(function(value,id,char,data)` |
| [DescentChallenge.client.luau:61](reference/source/client/DescentChallenge.client.luau) | `player.CharacterRemoving:Connect(clear)` |
| [DestructionFX.client.luau:286](reference/source/client/DestructionFX.client.luau) | `motionConnection = RunService.Heartbeat:Connect(function()` |
| [DestructionFX.client.luau:343](reference/source/client/DestructionFX.client.luau) | `local eventConnection = event.OnClientEvent:Connect(function(data)` |
| [DestructionFX.client.luau:404](reference/source/client/DestructionFX.client.luau) | `local characterConnection = player.CharacterRemoving:Connect(clearEffects)` |
| [ExperiencePopup.client.luau:40](reference/source/client/ExperiencePopup.client.luau) | `RS:WaitForChild("ExperienceGained").OnClientEvent:Connect(function(gain,character)` |
| [ExperiencePopup.client.luau:50](reference/source/client/ExperiencePopup.client.luau) | `player.CharacterRemoving:Connect(function()` |
| [FlightClient.luau:68](reference/source/client/FlightClient.luau) | `aim.OnClientEvent:Connect(function(enable, cannon, id, character)` |
| [FlightClient.luau:104](reference/source/client/FlightClient.luau) | `table.insert(run.aimConnections, UserInputService.InputBegan:Connect(function(input, processed)` |
| [FlightClient.luau:111](reference/source/client/FlightClient.luau) | `fire.OnClientEvent:Connect(function(velocity, id, character, saved, steeringSettings, objectiveMeta)` |
| [FlightClient.luau:159](reference/source/client/FlightClient.luau) | `state.OnClientEvent:Connect(function(value, id, character, reason)` |
| [FlightClient.luau:195](reference/source/client/FlightClient.luau) | `result.OnClientEvent:Connect(function(distance, gold, trophies, record, id, character, metrics)` |
| [FlightClient.luau:234](reference/source/client/FlightClient.luau) | `resultGui.MainFrame.ReturnButton.Activated:Connect(function()` |
| [FlightClient.luau:241](reference/source/client/FlightClient.luau) | `player.CharacterRemoving:Connect(function(character)` |
| [FlightSummary.client.luau:46](reference/source/client/FlightSummary.client.luau) | `RS:WaitForChild("FireCannon").OnClientEvent:Connect(function(_,id,character)` |
| [FlightSummary.client.luau:49](reference/source/client/FlightSummary.client.luau) | `RS:WaitForChild("FlightState").OnClientEvent:Connect(function(state,id,character,reason)` |
| [FlightSummary.client.luau:54](reference/source/client/FlightSummary.client.luau) | `RS:WaitForChild("FlightResult").OnClientEvent:Connect(function(_,gold,trophies,record,id,character,metrics)` |
| [LandingFX.client.luau:6](reference/source/client/LandingFX.client.luau) | `game.ReplicatedStorage:WaitForChild("FlightState").OnClientEvent:Connect(function(state,id,character)` |
| [MobileControls.luau:16](reference/source/client/MobileControls.luau) | `connect(b.InputBegan,function(input)` |
| [MobileControls.luau:36](reference/source/client/MobileControls.luau) | `connect(launch.Activated,fire)` |
| [MobileControls.luau:45](reference/source/client/MobileControls.luau) | `connect(RunService.Heartbeat,function() setAxis(active("right")-active("left")) end)` |
| [ProgressionHud.client.luau:40](reference/source/client/ProgressionHud.client.luau) | `trails.Activated:Connect(function()if player:GetAttribute("FlightState")~="Flying"then player:SetAttribute("RocketEquipmentTab","Trails");player:SetAttribute("RocketSkinShopOpen",true)end end)` |
| [ProgressionHud.client.luau:41](reference/source/client/ProgressionHud.client.luau) | `skins.Activated:Connect(function() if player:GetAttribute("FlightState")~="Flying" then player:SetAttribute("RocketEquipmentTab","Rockets");player:SetAttribute("RocketSkinShopOpen",true) end end)` |
| [ProgressionHud.client.luau:146](reference/source/client/ProgressionHud.client.luau) | `open.Activated:Connect(function()show("Rebirth")end);gift.Activated:Connect(function()show("Community")end)` |
| [ProgressionHud.client.luau:147](reference/source/client/ProgressionHud.client.luau) | `close.Activated:Connect(function()popup.Visible=false;shade.Visible=false;player:SetAttribute("ProgressionModalOpen",false) end)` |
| [ProgressionHud.client.luau:148](reference/source/client/ProgressionHud.client.luau) | `confirm.Activated:Connect(function()` |
| [ProgressionHud.client.luau:153](reference/source/client/ProgressionHud.client.luau) | `tierButton.Activated:Connect(function()` |
| [ProgressionHud.client.luau:159](reference/source/client/ProgressionHud.client.luau) | `for _,b in {skip,like,join,claim} do b.Activated:Connect(prepare) end` |
| [ProgressionHud.client.luau:161](reference/source/client/ProgressionHud.client.luau) | `op.Activated:Connect(function()` |
| [ProgressionHud.client.luau:166](reference/source/client/ProgressionHud.client.luau) | `tap.Activated:Connect(function()click:FireServer()end)` |
| [ProgressionHud.client.luau:167](reference/source/client/ProgressionHud.client.luau) | `for _,name in {"TrainingLevel","TrainingXP","Rebirths","TrainingTier","Trophies","XPGearLvl"} do local s=stats:WaitForChild(name,15);if s then s.Changed:Connect(update) end end` |
| [ProgressionHud.client.luau:176](reference/source/client/ProgressionHud.client.luau) | `close.Activated:Connect(function()player:SetAttribute("HUDPage",nil)end)` |
| [ProgressionHud.client.luau:177](reference/source/client/ProgressionHud.client.luau) | `shade.Activated:Connect(function()popup.Visible=false;shade.Visible=false;player:SetAttribute("HUDPage",nil)end)` |
| [ProtoFuelClient.client.luau:72](reference/source/client/ProtoFuelClient.client.luau) | `powerUp.Activated:Connect(function()` |
| [ProtoFuelClient.client.luau:102](reference/source/client/ProtoFuelClient.client.luau) | `player.CharacterRemoving:Connect(function()` |
| [ProtoFuelClient.client.luau:110](reference/source/client/ProtoFuelClient.client.luau) | `updateRemote.OnClientEvent:Connect(function(value)` |
| [ProtoFuelClient.client.luau:113](reference/source/client/ProtoFuelClient.client.luau) | `ReplicatedStorage:WaitForChild("FireCannon").OnClientEvent:Connect(function(_, id, character)` |
| [ProtoFuelClient.client.luau:117](reference/source/client/ProtoFuelClient.client.luau) | `ReplicatedStorage:WaitForChild("FlightResult").OnClientEvent:Connect(function(_, _, _, _, id, character, metrics)` |
| [ProtoFuelClient.client.luau:119](reference/source/client/ProtoFuelClient.client.luau) | `or type(metrics) ~= "table" or metrics.nearMissTriggered ~= true` |
| [ProtoFuelClient.client.luau:131](reference/source/client/ProtoFuelClient.client.luau) | `RunService.Heartbeat:Connect(function(dt)` |
| [RocketClient.luau:101](reference/source/client/RocketClient.luau) | `diveButton.Activated:Connect(toggleDive)` |
| [RocketClient.luau:103](reference/source/client/RocketClient.luau) | `explodeButton.Activated:Connect(function()act("Explode")end)` |
| [RocketClient.luau:104](reference/source/client/RocketClient.luau) | `abortButton.Activated:Connect(function()act("Abort")end)` |
| [RocketClient.luau:106](reference/source/client/RocketClient.luau) | `UIS.InputBegan:Connect(function(input,processed)` |
| [RocketClient.luau:111](reference/source/client/RocketClient.luau) | `RunService.Heartbeat:Connect(function(dt)` |
| [RocketClient.luau:132](reference/source/client/RocketClient.luau) | `remotes.FireCannon.OnClientEvent:Connect(function(velocity,id,character,_,settings,meta)` |
| [RocketClient.luau:204](reference/source/client/RocketClient.luau) | `remotes.FlightState.OnClientEvent:Connect(function(value,id,character,detail)` |
| [RocketClient.luau:220](reference/source/client/RocketClient.luau) | `player.CharacterRemoving:Connect(clear)` |
| [RocketInput.luau:8](reference/source/client/RocketInput.luau) | `table.insert(connections,RunService.Heartbeat:Connect(function(dt)` |
| [RocketSkinShop.client.luau:63](reference/source/client/RocketSkinShop.client.luau) | `action.Activated:Connect(function()` |
| [RocketSkinShop.client.luau:76](reference/source/client/RocketSkinShop.client.luau) | `for kind,b in tabs do b.Activated:Connect(function()p:SetAttribute("RocketEquipmentTab",kind);choose(kind)end)end` |
| [RocketSkinShop.client.luau:83](reference/source/client/RocketSkinShop.client.luau) | `close.Activated:Connect(dismiss);shade.Activated:Connect(dismiss)` |
| [RocketSkinShop.client.luau:87](reference/source/client/RocketSkinShop.client.luau) | `for _,v in {skinMask,skinEquip,trailMask,trailEquip,stats.Trophies,stats.Rebirths}do v.Changed:Connect(update)end` |
| [RocketUISamples.client.luau:76](reference/source/client/RocketUISamples.client.luau) | `local inputConnection = UserInputService.InputBegan:Connect(function(input, processed)` |
| [Showroom.client.luau:9](reference/source/client/Showroom.client.luau) | `UIS.InputBegan:Connect(function(input,processed)` |
| [Showroom.client.luau:44](reference/source/client/Showroom.client.luau) | `for _,name in {"TrainingTier","Trophies","Rebirths"}do stats:WaitForChild(name).Changed:Connect(update)end` |
| [Showroom.client.luau:45](reference/source/client/Showroom.client.luau) | `for _,name in {"RocketSkinMask","RocketSkinEquipped"}do private:WaitForChild(name).Changed:Connect(update)end` |
| [SkyController.luau:188](reference/source/client/SkyController.luau) | `player.CharacterRemoving:Connect(Sky.Reset)` |
| [SkyController.luau:194](reference/source/client/SkyController.luau) | `RunService.Heartbeat:Connect(function()` |
| [SkyEnemyFX.client.luau:4](reference/source/client/SkyEnemyFX.client.luau) | `game:GetService("RunService").Heartbeat:Connect(function(dt)` |
| [StageCurtains.luau:46](reference/source/client/StageCurtains.luau) | `player.CharacterRemoving:Connect(function()clear();launchOrigin=nil end)` |
| [StageCurtains.luau:48](reference/source/client/StageCurtains.luau) | `Run.Heartbeat:Connect(function(dt)` |
| [SteeringInput.luau:50](reference/source/client/SteeringInput.luau) | `table.insert(connections, RunService.Heartbeat:Connect(function(dt)` |
| [StudioProgressTest.client.luau:27](reference/source/client/StudioProgressTest.client.luau) | `b.Activated:Connect(function()` |
| [TotalHud.client.luau:35](reference/source/client/TotalHud.client.luau) | `store.Activated:Connect(function()open("Store")end)` |
| [TotalHud.client.luau:37](reference/source/client/TotalHud.client.luau) | `local b=button(left,row[1],row[2],row[3],row[4],106,98,row[5],row[6]);b.Activated:Connect(function()open(row[1]=="WorldTravel"and "World"or row[1])end)` |
| [TotalHud.client.luau:56](reference/source/client/TotalHud.client.luau) | `wins.Activated:Connect(function()local _,note=request("Boost","Wins2");winsTime.Text=note end)` |
| [TotalHud.client.luau:57](reference/source/client/TotalHud.client.luau) | `power.Activated:Connect(function()local _,note=request("Boost","Power2");powerTime.Text=note end)` |
| [TotalHud.client.luau:63](reference/source/client/TotalHud.client.luau) | `Icons.Image(b,key,UDim2.fromOffset(10,10),UDim2.fromOffset(24,24));b.Activated:Connect(function()open(key)end)` |
| [TotalHud.client.luau:77](reference/source/client/TotalHud.client.luau) | `b.Activated:Connect(callback);return b` |
| [TotalHud.client.luau:113](reference/source/client/TotalHud.client.luau) | `close.Activated:Connect(function()p:SetAttribute("HUDPage",nil)end);shade.Activated:Connect(function()p:SetAttribute("HUDPage",nil)end)` |
| [TrainingFX.client.luau:44](reference/source/client/TrainingFX.client.luau) | `p.CharacterRemoving:Connect(stop)` |
| [TrainingFX.client.luau:67](reference/source/client/TrainingFX.client.luau) | `xp.Changed:Connect(function(value)` |
| [CannonServer.server.luau:23](reference/source/reference/CannonServer.server.luau) | `Players.PlayerRemoving:Connect(function(player)` |
| [CannonServer.server.luau:27](reference/source/reference/CannonServer.server.luau) | `aimRemote.OnServerEvent:Connect(function(player: Player, yaw: number, pitch: number)` |
| [CannonServer.server.luau:34](reference/source/reference/CannonServer.server.luau) | `proximityPrompt.Triggered:Connect(function(player: Player)` |
| [CannonServer.server.luau:62](reference/source/reference/CannonServer.server.luau) | `fireRemote.OnServerEvent:Connect(function(player: Player, timingMultiplier: number)` |
| [CannonServer.server.luau:172](reference/source/reference/CannonServer.server.luau) | `returnToSpawnRemote.OnServerEvent:Connect(function(player: Player)` |
| [BarrierSpawner.server.luau:151](reference/source/server/BarrierSpawner.server.luau) | `player.CharacterRemoving:Connect(function() runTokens[player] = nil; resetIfDirty() end),` |
| [BarrierSpawner.server.luau:169](reference/source/server/BarrierSpawner.server.luau) | `Players.PlayerRemoving:Connect(function(player)` |
| [ClickerService.server.luau:13](reference/source/server/ClickerService.server.luau) | `Players.PlayerRemoving:Connect(function(player)balances[player]=nil;lastToggle[player]=nil end)` |
| [ClickerService.server.luau:14](reference/source/server/ClickerService.server.luau) | `remotes.ClickTraining.OnServerEvent:Connect(function(player)Data.ClickXP(player)end)` |
| [ClickerService.server.luau:15](reference/source/server/ClickerService.server.luau) | `remotes.ToggleAutoClick.OnServerInvoke=function(player,mode)` |
| [ClickerService.server.luau:26](reference/source/server/ClickerService.server.luau) | `RunService.Heartbeat:Connect(function(dt)` |
| [DataManager.server.luau:4](reference/source/server/DataManager.server.luau) | `remotes.BuyUpgrade.OnServerInvoke = function(player, kind) return Data.Buy(player, kind) end` |
| [DataManager.server.luau:5](reference/source/server/DataManager.server.luau) | `remotes.ResetData.OnServerInvoke = function() return false end` |
| [FlightService.luau:201](reference/source/server/FlightService.luau) | `metrics.nearMissTriggered = metrics.MaxAltitude >= targetAltitude * proto.NearMissThreshold` |
| [FlightService.luau:378](reference/source/server/FlightService.luau) | `prompt.Triggered:Connect(begin)` |
| [FlightService.luau:379](reference/source/server/FlightService.luau) | `aimRemote.OnServerEvent:Connect(function(player, yaw, pitch, id)` |
| [FlightService.luau:389](reference/source/server/FlightService.luau) | `fireRemote.OnServerEvent:Connect(fire)` |
| [FlightService.luau:390](reference/source/server/FlightService.luau) | `remotes.SteerFlight.OnServerEvent:Connect(function(player, axis, id)` |
| [FlightService.luau:396](reference/source/server/FlightService.luau) | `remotes.ReturnToSpawn.OnServerEvent:Connect(function(player, id)` |
| [FlightService.luau:404](reference/source/server/FlightService.luau) | `playerConnections[player] = player.CharacterRemoving:Connect(function(character)` |
| [FlightService.luau:411](reference/source/server/FlightService.luau) | `Players.PlayerRemoving:Connect(function(player)` |
| [FlightService.luau:416](reference/source/server/FlightService.luau) | `RunService.Heartbeat:Connect(function(dt)` |
| [GoldRingEvent.luau:60](reference/source/server/GoldRingEvent.luau) | `game:GetService("RunService").Heartbeat:Connect(function(dt)elapsed+=dt;if elapsed>=.5 then elapsed=0;Event.Update(workspace:GetServerTimeNow())end end)` |
| [GoldRingEvent.luau:61](reference/source/server/GoldRingEvent.luau) | `Players.PlayerRemoving:Connect(function(p)claims[p]=nil end)` |
| [LegacyGimmicks.luau:135](reference/source/server/LegacyGimmicks.luau) | `RunService.Heartbeat:Connect(function()` |
| [PlayerData.luau:422](reference/source/server/PlayerData.luau) | `Players.PlayerRemoving:Connect(function(player)` |
| [PlayerData.luau:430](reference/source/server/PlayerData.luau) | `game:BindToClose(function() closing = true; table.clear(profiles) end)` |
| [PlayerData.luau:442](reference/source/server/PlayerData.luau) | `game:BindToClose(function()` |
| [PowerBoostServer.server.luau:6](reference/source/server/PowerBoostServer.server.luau) | `remote.OnServerInvoke=function(p,action,id)return Boosts.Request(p,action,id)end` |
| [PowerBoosts.luau:74](reference/source/server/PowerBoosts.luau) | `Players.PlayerRemoving:Connect(function(p)` |
| [ProtoFuelServer.server.luau:15](reference/source/server/ProtoFuelServer.server.luau) | `powerUp.OnServerInvoke = function(player)` |
| [ProtoFuelService.luau:101](reference/source/server/ProtoFuelService.luau) | `startRemote.OnServerEvent:Connect(function(player) request(player, true) end)` |
| [ProtoFuelService.luau:102](reference/source/server/ProtoFuelService.luau) | `stopRemote.OnServerEvent:Connect(function(player) request(player, false) end)` |
| [ProtoFuelService.luau:118](reference/source/server/ProtoFuelService.luau) | `Players.PlayerRemoving:Connect(function(player)` |
| [ProtoFuelService.luau:125](reference/source/server/ProtoFuelService.luau) | `RunService.Heartbeat:Connect(function(dt)` |
| [Remotes.luau:40](reference/source/server/Remotes.luau) | `found.ResetData.OnServerInvoke = function() return false end` |
| [RocketFlightService.luau:179](reference/source/server/RocketFlightService.luau) | `Players.PlayerRemoving:Connect(function(p)if runs[p]then cleanup(runs[p]);runs[p]=nil end;cooldowns[p]=nil end)` |
| [RocketFlightService.luau:186](reference/source/server/RocketFlightService.luau) | `remotes.SteerFlight.OnServerEvent:Connect(function(p,axis,id,cameraRight)` |
| [RocketFlightService.luau:193](reference/source/server/RocketFlightService.luau) | `remotes.ReturnToSpawn.OnServerEvent:Connect(function(p,id,action)` |
| [RocketFlightService.luau:202](reference/source/server/RocketFlightService.luau) | `RunService.Heartbeat:Connect(function(dt)` |
| [RocketSkinService.server.luau:4](reference/source/server/RocketSkinService.server.luau) | `require(script.Parent.Remotes).Ensure().SelectRocketTrail.OnServerInvoke=function(player,index)return Data.SelectRocketTrail(player,index)end` |
| [RocketSkinService.server.luau:5](reference/source/server/RocketSkinService.server.luau) | `require(script.Parent.Remotes).Ensure().SelectRocketSkin.OnServerInvoke=function(player,index)` |
| [SharedTraining.luau:35](reference/source/server/SharedTraining.luau) | `table.insert(s.connections,player.CharacterRemoving:Connect(function()Service.Leave(player)end))` |
| [SharedTraining.luau:62](reference/source/server/SharedTraining.luau) | `Players.PlayerRemoving:Connect(function(player)Service.Leave(player);autoBlocked[player]=nil end)` |
| [ShowroomService.server.luau:8](reference/source/server/ShowroomService.server.luau) | `leave.OnServerEvent:Connect(function(player)` |
| [ShowroomService.server.luau:14](reference/source/server/ShowroomService.server.luau) | `p.Triggered:Connect(function(player)` |
| [ShowroomService.server.luau:26](reference/source/server/ShowroomService.server.luau) | `game:GetService("RunService").Heartbeat:Connect(function(dt)` |
| [SkyLife.luau:180](reference/source/server/SkyLife.luau) | `game:GetService("RunService").Heartbeat:Connect(function(dt)` |
| [SpawnService.luau:31](reference/source/server/SpawnService.luau) | `Players.PlayerRemoving:Connect(function(player)` |
| [StudioProgressTest.server.luau:15](reference/source/server/StudioProgressTest.server.luau) | `remote.OnServerInvoke=function(player,action)` |
| [StudioProgressTest.server.luau:40](reference/source/server/StudioProgressTest.server.luau) | `Players.PlayerRemoving:Connect(function(player)lastRequest[player]=nil end)` |
| [TrainingService.server.luau:12](reference/source/server/TrainingService.server.luau) | `remote("RequestRebirth").OnServerInvoke=function(p,expected)` |
| [TrainingService.server.luau:15](reference/source/server/TrainingService.server.luau) | `remote("BuyTrainingTier").OnServerInvoke=function(p,expected)` |
| [TrainingService.server.luau:18](reference/source/server/TrainingService.server.luau) | `remote("BuyXPItem").OnServerInvoke=function(p,expected)return Data.BuyXPItem(p,expected)end` |
| [TrainingService.server.luau:20](reference/source/server/TrainingService.server.luau) | `RunService.Heartbeat:Connect(function(dt)` |
| [WorldService.luau:67](reference/source/server/WorldService.luau) | `RunService.Heartbeat:Connect(function(dt)` |
| [ClickerUI.luau:61](reference/source/shared/ClickerUI.luau) | `button.Activated:Connect(function()game:GetService("Players").LocalPlayer:SetAttribute("HUDPage","Store")end)` |
| [ClickerUI.luau:64](reference/source/shared/ClickerUI.luau) | `plus.Activated:Connect(function()game:GetService("Players").LocalPlayer:SetAttribute("HUDPage","Store")end)` |
| [RocketUI.luau:107](reference/source/shared/RocketUI.luau) | `connect(button.InputBegan, function(input)` |
| [RocketUI.luau:159](reference/source/shared/RocketUI.luau) | `if props.OnClick then button.Activated:Connect(function() if button.Interactable then props.OnClick() end end) end` |
| [SimulatorHUD.luau:46](reference/source/shared/SimulatorHUD.luau) | `-- Retain the original TextButton and Activated handlers.` |
| [SimulatorHUD.luau:96](reference/source/shared/SimulatorHUD.luau) | `stats.Rebirths.Changed:Connect(sync);stats.Trophies.Changed:Connect(sync);sync()` |
| [SimulatorTheme.luau:30](reference/source/shared/SimulatorTheme.luau) | `button.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then play(.95)end end)` |

## require 의존성

| 위치 | 실제 의존 코드 |
|---|---|
| [AltitudeLandscape.client.luau:3](reference/source/client/AltitudeLandscape.client.luau) | `local Config=require(game.ReplicatedStorage:WaitForChild("CloudConfig",15)).HeightPresentation` |
| [AltitudeMood.client.luau:4](reference/source/client/AltitudeMood.client.luau) | `local HUD=require(game.ReplicatedStorage:WaitForChild("SimulatorHUD",15))` |
| [AltitudeMood.client.luau:5](reference/source/client/AltitudeMood.client.luau) | `local C=require(game.ReplicatedStorage:WaitForChild("CloudConfig",15)).HeightPresentation` |
| [Audio.luau:2](reference/source/client/Audio.luau) | `local Config = require(script.Parent.PresentationConfig)` |
| [ClickerClient.client.luau:4](reference/source/client/ClickerClient.client.luau) | `local UI=require(RS:WaitForChild("ClickerUI"));local Config=require(RS:WaitForChild("ClickerConfig"));local Growth=require(RS:WaitForChild("ProgressionConfig"))` |
| [ClickerClient.client.luau:5](reference/source/client/ClickerClient.client.luau) | `local HUD=require(RS:WaitForChild("SimulatorHUD"))` |
| [ClickerClient.client.luau:26](reference/source/client/ClickerClient.client.luau) | `local skins=require(RS:WaitForChild("RocketSkinCatalog"));local trails=require(RS:WaitForChild("RocketTrailCatalog"))` |
| [ClickerClient.client.luau:28](reference/source/client/ClickerClient.client.luau) | `local flat,growth=require(RS:WaitForChild("EquipmentPower")).Bonuses(skins.Items[skin and skin.Value or 1],trails.Items[trail and trail.Value or 1])` |
| [ClickerClient.client.luau:31](reference/source/client/ClickerClient.client.luau) | `local power=string.format("%.0f",require(RS.PowerBoostConfig).Apply(raw,mult,food,friend))` |
| [CloudGateChasers.client.luau:3](reference/source/client/CloudGateChasers.client.luau) | `local player=Players.LocalPlayer;local gates=require(RS:WaitForChild("CloudConfig")).HeightPresentation.Gates` |
| [CloudGateChasers.client.luau:4](reference/source/client/CloudGateChasers.client.luau) | `local config=require(RS:WaitForChild("GateEncounterConfig"))` |
| [CurrencyHud.luau:3](reference/source/client/CurrencyHud.luau) | `local rocket=rocketModule and require(rocketModule).Enabled` |
| [DescentChallenge.client.luau:2](reference/source/client/DescentChallenge.client.luau) | `if rocketMode and require(rocketMode).Enabled then return end` |
| [DescentChallenge.client.luau:3](reference/source/client/DescentChallenge.client.luau) | `local Cloud=require(game.ReplicatedStorage:WaitForChild("CloudConfig"))` |
| [DescentChallenge.client.luau:8](reference/source/client/DescentChallenge.client.luau) | `local HUD=require(RS:WaitForChild("SimulatorHUD"))` |
| [DestructionFX.client.luau:7](reference/source/client/DestructionFX.client.luau) | `if not require(flagModule).Enabled then return end` |
| [DestructionFX.client.luau:9](reference/source/client/DestructionFX.client.luau) | `local Butter=require(ReplicatedStorage:WaitForChild("CourseVisualConfig"))` |
| [DestructionFX.client.luau:73](reference/source/client/DestructionFX.client.luau) | `local presentation = require(script.Parent.PresentationConfig)` |
| [DestructionFX.client.luau:360](reference/source/client/DestructionFX.client.luau) | `noticeSerial+=1;local serial=noticeSerial;chainLabel.Visible=not require(script.Parent.StageCurtains).WarningOnScreen()` |
| [ExperiencePopup.client.luau:5](reference/source/client/ExperiencePopup.client.luau) | `local Projection=require(script.Parent.XPProjection)` |
| [FlightCamera.luau:5](reference/source/client/FlightCamera.luau) | `local Balance = require(balanceModule)` |
| [FlightCamera.luau:7](reference/source/client/FlightCamera.luau) | `local Feedback = require(script.Parent.PresentationConfig).RingFeedback` |
| [FlightClient.luau:4](reference/source/client/FlightClient.luau) | `local SteeringInput = require(script.Parent.SteeringInput)` |
| [FlightClient.luau:5](reference/source/client/FlightClient.luau) | `local Audio = require(script.Parent.Audio)` |
| [FlightClient.luau:6](reference/source/client/FlightClient.luau) | `local Presentation = require(script.Parent.PresentationConfig)` |
| [FlightClient.luau:7](reference/source/client/FlightClient.luau) | `local FlightCamera = require(script.Parent.FlightCamera)` |
| [FlightClient.luau:8](reference/source/client/FlightClient.luau) | `local Sky = require(script.Parent.SkyController)` |
| [FlightSummary.client.luau:4](reference/source/client/FlightSummary.client.luau) | `local Cloud=require(RS:WaitForChild("CloudConfig"))` |
| [LandingFX.client.luau:2](reference/source/client/LandingFX.client.luau) | `if rocketMode and require(rocketMode).Enabled then return end` |
| [Main.client.luau:8](reference/source/client/Main.client.luau) | `require(script.Parent.SkyController).Start()` |
| [Main.client.luau:9](reference/source/client/Main.client.luau) | `local Audio=require(script.Parent.Audio);Audio.Preload()` |
| [Main.client.luau:10](reference/source/client/Main.client.luau) | `local remotes=require(script.Parent.RemoteClient).Wait(15);if not remotes then return end` |
| [Main.client.luau:11](reference/source/client/Main.client.luau) | `require(script.Parent.CurrencyHud).Start(player)` |
| [Main.client.luau:12](reference/source/client/Main.client.luau) | `require(RS:WaitForChild("SimulatorHUD")).currency(gui:FindFirstChild("CurrencyHud"))` |
| [Main.client.luau:13](reference/source/client/Main.client.luau) | `local objective=require(script.Parent.ObjectiveHud).new(gui)` |
| [Main.client.luau:14](reference/source/client/Main.client.luau) | `require(script.Parent.RocketClient).Start(remotes,objective)` |
| [ObjectiveHud.luau:3](reference/source/client/ObjectiveHud.luau) | `local Cloud=require(game:GetService("ReplicatedStorage"):WaitForChild("CloudConfig",15))` |
| [ObjectiveHud.luau:5](reference/source/client/ObjectiveHud.luau) | `local SimulatorHUD = require(game:GetService("ReplicatedStorage"):WaitForChild("SimulatorHUD", 15))` |
| [ProgressionHud.client.luau:4](reference/source/client/ProgressionHud.client.luau) | `local C=require(RS:WaitForChild("ProgressionConfig",15));local HUD=require(RS:WaitForChild("SimulatorHUD",15))` |
| [ProgressionHud.client.luau:8](reference/source/client/ProgressionHud.client.luau) | `local Icons=require(RS:WaitForChild("UIIcons"))` |
| [ProgressionHud.client.luau:9](reference/source/client/ProgressionHud.client.luau) | `local Audio=require(script.Parent.Audio);local purple=Color3.fromRGB(171,98,245)` |
| [ProgressionHud.client.luau:175](reference/source/client/ProgressionHud.client.luau) | `title.Text="Rebirth";require(RS.MenuOverlay).Attach(popup)` |
| [ProtoFuelClient.client.luau:2](reference/source/client/ProtoFuelClient.client.luau) | `if rocketMode and require(rocketMode).Enabled then return end` |
| [ProtoFuelClient.client.luau:8](reference/source/client/ProtoFuelClient.client.luau) | `local SimulatorHUD = require(ReplicatedStorage:WaitForChild("SimulatorHUD", 15))` |
| [ProtoFuelClient.client.luau:9](reference/source/client/ProtoFuelClient.client.luau) | `local Constants = require(ReplicatedStorage:WaitForChild("ProtoFuelConstants"))` |
| [RocketClient.luau:4](reference/source/client/RocketClient.luau) | `local Input=require(script.Parent.RocketInput)` |
| [RocketClient.luau:5](reference/source/client/RocketClient.luau) | `local Audio=require(script.Parent.Audio)` |
| [RocketClient.luau:6](reference/source/client/RocketClient.luau) | `local Sky=require(script.Parent.SkyController)` |
| [RocketClient.luau:9](reference/source/client/RocketClient.luau) | `local Rewards=require(RS:WaitForChild("DestructionRewardConfig"))` |
| [RocketClient.luau:10](reference/source/client/RocketClient.luau) | `local Icons=require(RS:WaitForChild("UIIcons"))` |
| [RocketClient.luau:11](reference/source/client/RocketClient.luau) | `local SpeedFX=require(script.Parent.RocketSpeedFX)` |
| [RocketClient.luau:15](reference/source/client/RocketClient.luau) | `local clouds=require(script.Parent.StageCurtains);clouds.Start()` |
| [RocketClient.luau:180](reference/source/client/RocketClient.luau) | `local gates=require(RS.CloudConfig).HeightPresentation.Gates` |
| [RocketSkinShop.client.luau:2](reference/source/client/RocketSkinShop.client.luau) | `if not require(RS:WaitForChild("RocketModeConfig")).Enabled then return end` |
| [RocketSkinShop.client.luau:5](reference/source/client/RocketSkinShop.client.luau) | `local Skins=require(RS:WaitForChild("RocketSkinCatalog"));local Trails=require(RS:WaitForChild("RocketTrailCatalog"))` |
| [RocketSkinShop.client.luau:6](reference/source/client/RocketSkinShop.client.luau) | `local Equipment=require(RS:WaitForChild("EquipmentPower"))` |
| [RocketSkinShop.client.luau:7](reference/source/client/RocketSkinShop.client.luau) | `local Icons=require(RS:WaitForChild("UIIcons"));local HUD=require(RS:WaitForChild("SimulatorHUD"))` |
| [RocketSkinShop.client.luau:114](reference/source/client/RocketSkinShop.client.luau) | `require(RS.MenuOverlay).Attach(panel)` |
| [RocketTrailStreams.client.luau:2](reference/source/client/RocketTrailStreams.client.luau) | `local Players=game:GetService("Players");local Run=game:GetService("RunService");local Catalog=require(game.ReplicatedStorage:WaitForChild("RocketTrailCatalog"))` |
| [RocketUISamples.client.luau:7](reference/source/client/RocketUISamples.client.luau) | `local RocketUI = require(ReplicatedStorage:WaitForChild("RocketUI"))` |
| [Showroom.client.luau:12](reference/source/client/Showroom.client.luau) | `local Skins=require(RS:WaitForChild("RocketSkinCatalog"));local Growth=require(RS:WaitForChild("ProgressionConfig"));local HUD=require(RS:WaitForChild("SimulatorHUD"))` |
| [SkyController.luau:7](reference/source/client/SkyController.luau) | `local Config = require(module)` |
| [SkyController.luau:8](reference/source/client/SkyController.luau) | `local GateRules=require(ReplicatedStorage:WaitForChild("CloudGateRules"))` |
| [SkyController.luau:9](reference/source/client/SkyController.luau) | `local PresentationConfig = require(script.Parent.PresentationConfig)` |
| [StageCurtains.luau:25](reference/source/client/StageCurtains.luau) | `local gates=require(game:GetService("ReplicatedStorage"):WaitForChild("CloudConfig")).HeightPresentation.Gates` |
| [StudioProgressTest.client.luau:3](reference/source/client/StudioProgressTest.client.luau) | `local TestConfig=require(game:GetService("ReplicatedStorage"):WaitForChild("PowerBoostConfig"))` |
| [TotalHud.client.luau:2](reference/source/client/TotalHud.client.luau) | `local p=Players.LocalPlayer;local HUD=require(RS:WaitForChild("SimulatorHUD"));local Icons=require(RS:WaitForChild("UIIcons"))` |
| [TotalHud.client.luau:3](reference/source/client/TotalHud.client.luau) | `local C=require(RS:WaitForChild("PowerBoostConfig"));local remote=RS:WaitForChild("UsePowerBoost")` |
| [TotalHud.client.luau:128](reference/source/client/TotalHud.client.luau) | `HUD.fit(panel,560,470);require(RS.MenuOverlay).Attach(panel)` |
| [BackRocket.luau:1](reference/source/server/BackRocket.luau) | `local Styles=require(game:GetService("ReplicatedStorage"):WaitForChild("RocketStyles"))` |
| [BackRocket.luau:2](reference/source/server/BackRocket.luau) | `local Trails=require(game:GetService("ReplicatedStorage"):WaitForChild("RocketTrailCatalog"))` |
| [BackRocket.luau:3](reference/source/server/BackRocket.luau) | `local Shapes=require(script.Parent.RocketShapes)` |
| [BarrierSpawner.server.luau:7](reference/source/server/BarrierSpawner.server.luau) | `if not require(flagModule).Enabled then return end` |
| [BarrierSpawner.server.luau:8](reference/source/server/BarrierSpawner.server.luau) | `if require(flagModule).WorldTargetsOnly then return end` |
| [BarrierSpawner.server.luau:11](reference/source/server/BarrierSpawner.server.luau) | `local Config = require(script.Parent.DestructibleConfig)` |
| [BarrierSpawner.server.luau:12](reference/source/server/BarrierSpawner.server.luau) | `local Trajectory = require(script.Parent.LaunchTrajectory)` |
| [BreakCourse.luau:3](reference/source/server/BreakCourse.luau) | `local Gates=require(RS:WaitForChild("CloudConfig")).HeightPresentation.Gates` |
| [BreakCourse.luau:4](reference/source/server/BreakCourse.luau) | `local Visual=require(RS:WaitForChild("CourseVisualConfig"))` |
| [CampShowroom.luau:4](reference/source/server/CampShowroom.luau) | `local Skins=require(RS:WaitForChild("RocketSkinCatalog"))` |
| [CampShowroom.luau:5](reference/source/server/CampShowroom.luau) | `local Growth=require(RS:WaitForChild("ProgressionConfig"))` |
| [CampShowroom.luau:6](reference/source/server/CampShowroom.luau) | `local Config=require(RS:WaitForChild("ShowroomConfig"))` |
| [CampShowroom.luau:7](reference/source/server/CampShowroom.luau) | `local Rocket=require(script.Parent.BackRocket)` |
| [CampShowroom.luau:8](reference/source/server/CampShowroom.luau) | `local Styles=require(RS:WaitForChild("RocketStyles"))` |
| [CampShowroom.luau:9](reference/source/server/CampShowroom.luau) | `local Effects=require(script.Parent.ShowroomEffects)` |
| [Cannon.server.luau:1](reference/source/server/Cannon.server.luau) | `require(script.Parent.Remotes).Ensure()` |
| [Cannon.server.luau:15](reference/source/server/Cannon.server.luau) | `require(script.Parent.RocketFlightService).Start(cannon)` |
| [ClickerService.server.luau:4](reference/source/server/ClickerService.server.luau) | `local Config=require(RS:WaitForChild("ClickerConfig"))` |
| [ClickerService.server.luau:5](reference/source/server/ClickerService.server.luau) | `local Data=require(script.Parent.PlayerData)` |
| [ClickerService.server.luau:6](reference/source/server/ClickerService.server.luau) | `local remotes=require(script.Parent.Remotes).Ensure()` |
| [CliffCamp.luau:2](reference/source/server/CliffCamp.luau) | `local C=require(RS:WaitForChild("ProgressionConfig",15))` |
| [CliffCamp.luau:51](reference/source/server/CliffCamp.luau) | `if not require(RS:WaitForChild("RocketModeConfig")).Enabled then` |
| [CliffCamp.luau:80](reference/source/server/CliffCamp.luau) | `task.defer(function()require(script.Parent.CampShowroom).Build(folder)end)` |
| [CloudDiscovery.luau:1](reference/source/server/CloudDiscovery.luau) | `local Config = require(script.Parent.LevelConfig).Clouds` |
| [CloudSection.luau:1](reference/source/server/CloudSection.luau) | `local Coordinates = require(script.Parent.WorldCoordinates)` |
| [CloudSection.luau:2](reference/source/server/CloudSection.luau) | `local Assets = require(script.Parent.AssetRegistry)` |
| [CourseSection.luau:1](reference/source/server/CourseSection.luau) | `local Coordinates = require(script.Parent.WorldCoordinates)` |
| [CourseSection.luau:2](reference/source/server/CourseSection.luau) | `local Trajectory = require(script.Parent.LaunchTrajectory)` |
| [DataManager.server.luau:2](reference/source/server/DataManager.server.luau) | `local remotes = require(script.Parent.Remotes).Ensure()` |
| [DataManager.server.luau:3](reference/source/server/DataManager.server.luau) | `local Data = require(script.Parent.PlayerData)` |
| [Destination.luau:1](reference/source/server/Destination.luau) | `local Coordinates = require(script.Parent.WorldCoordinates)` |
| [Destination.luau:2](reference/source/server/Destination.luau) | `local Assets = require(script.Parent.AssetRegistry)` |
| [DiveBreakZone.luau:3](reference/source/server/DiveBreakZone.luau) | `local Visual=require(RS:WaitForChild("CourseVisualConfig"))` |
| [DiveBreakZone.luau:4](reference/source/server/DiveBreakZone.luau) | `local Rewards=require(RS:WaitForChild("DestructionRewardConfig"))` |
| [DiveBreakZone.luau:5](reference/source/server/DiveBreakZone.luau) | `local Gates=require(RS:WaitForChild("CloudConfig")).HeightPresentation.Gates` |
| [DiveBreakZone.luau:6](reference/source/server/DiveBreakZone.luau) | `local Families=require(RS:WaitForChild("GateEncounterConfig"))` |
| [DiveBreakZone.luau:7](reference/source/server/DiveBreakZone.luau) | `local Rules=require(script.Parent.RocketRules)` |
| [FlightMetrics.luau:1](reference/source/server/FlightMetrics.luau) | `local Coordinates = require(script.Parent.WorldCoordinates)` |
| [FlightService.luau:4](reference/source/server/FlightService.luau) | `local Balance = require(balanceModule)` |
| [FlightService.luau:24](reference/source/server/FlightService.luau) | `local Remotes = require(script.Parent.Remotes)` |
| [FlightService.luau:25](reference/source/server/FlightService.luau) | `local Data = require(script.Parent.PlayerData)` |
| [FlightService.luau:26](reference/source/server/FlightService.luau) | `local Policy = require(script.Parent.RunPolicy)` |
| [FlightService.luau:27](reference/source/server/FlightService.luau) | `local Steering = require(script.Parent.HorizontalSteering)` |
| [FlightService.luau:28](reference/source/server/FlightService.luau) | `local SteeringConfig = require(script.Parent.SteeringConfig)` |
| [FlightService.luau:29](reference/source/server/FlightService.luau) | `local Metrics = require(script.Parent.FlightMetrics)` |
| [FlightService.luau:30](reference/source/server/FlightService.luau) | `local Discovery = require(script.Parent.CloudDiscovery)` |
| [FlightService.luau:31](reference/source/server/FlightService.luau) | `local Trajectory = require(script.Parent.LaunchTrajectory)` |
| [FlightService.luau:32](reference/source/server/FlightService.luau) | `local World = require(script.Parent.WorldService)` |
| [FlightService.luau:34](reference/source/server/FlightService.luau) | `local Course=courseModule and require(courseModule)` |
| [FlightService.luau:36](reference/source/server/FlightService.luau) | `local FlightStreaming=streamingModule and require(streamingModule)` |
| [FlightService.luau:38](reference/source/server/FlightService.luau) | `local LimbLanding=landingModule and require(landingModule)` |
| [FlightService.luau:41](reference/source/server/FlightService.luau) | `local Descent=descentModule and require(descentModule)` |
| [FlightService.luau:43](reference/source/server/FlightService.luau) | `local Fuel = fuelModule and require(fuelModule)` |
| [FlightService.luau:197](reference/source/server/FlightService.luau) | `local proto = require(protoModule)` |
| [GoldRingEvent.luau:4](reference/source/server/GoldRingEvent.luau) | `local Data=require(script.Parent.PlayerData)` |
| [HorizontalSteering.luau:1](reference/source/server/HorizontalSteering.luau) | `local Config = require(script.Parent.SteeringConfig)` |
| [LaunchTrajectory.luau:3](reference/source/server/LaunchTrajectory.luau) | `local Balance = require(module)` |
| [LevelBuilder.luau:1](reference/source/server/LevelBuilder.luau) | `local Coordinates = require(script.Parent.WorldCoordinates)` |
| [LevelBuilder.luau:2](reference/source/server/LevelBuilder.luau) | `local Course = require(script.Parent.CourseSection)` |
| [LevelBuilder.luau:3](reference/source/server/LevelBuilder.luau) | `local Assets = require(script.Parent.AssetRegistry)` |
| [LevelBuilder.luau:4](reference/source/server/LevelBuilder.luau) | `local Obstacles = require(script.Parent.ObstaclePatterns)` |
| [LevelBuilder.luau:5](reference/source/server/LevelBuilder.luau) | `local Clouds = require(script.Parent.CloudSection)` |
| [LevelBuilder.luau:6](reference/source/server/LevelBuilder.luau) | `local Destination = require(script.Parent.Destination)` |
| [LevelConfig.luau:5](reference/source/server/LevelConfig.luau) | `local rocket=rocketModule and require(rocketModule).Enabled` |
| [LevelConfig.luau:7](reference/source/server/LevelConfig.luau) | `Clouds = require(cloudModule),` |
| [ObstaclePatterns.luau:1](reference/source/server/ObstaclePatterns.luau) | `local Assets = require(script.Parent.AssetRegistry)` |
| [ObstaclePatterns.luau:2](reference/source/server/ObstaclePatterns.luau) | `local Coordinates = require(script.Parent.WorldCoordinates)` |
| [PlayerData.luau:4](reference/source/server/PlayerData.luau) | `local Balance = require(balanceModule)` |
| [PlayerData.luau:6](reference/source/server/PlayerData.luau) | `local Growth = growthModule and require(growthModule)` |
| [PlayerData.luau:9](reference/source/server/PlayerData.luau) | `local Policy = require(script.Parent.RunPolicy)` |
| [PlayerData.luau:14](reference/source/server/PlayerData.luau) | `local RocketMode=rocketModeModule and require(rocketModeModule).Enabled` |
| [PlayerData.luau:15](reference/source/server/PlayerData.luau) | `local RocketEconomy=RocketMode and require(script.Parent.RocketEconomy)` |
| [PlayerData.luau:17](reference/source/server/PlayerData.luau) | `local Clicker=ClickerModule and require(ClickerModule)` |
| [PlayerData.luau:19](reference/source/server/PlayerData.luau) | `local Skins=SkinModule and require(SkinModule)` |
| [PlayerData.luau:21](reference/source/server/PlayerData.luau) | `local Trails=TrailModule and require(TrailModule)` |
| [PlayerData.luau:106](reference/source/server/PlayerData.luau) | `local Equipment=require(game:GetService("ReplicatedStorage"):WaitForChild("EquipmentPower"))` |
| [PowerBoostServer.server.luau:2](reference/source/server/PowerBoostServer.server.luau) | `if not require(RS:WaitForChild("RocketModeConfig")).Enabled then return end` |
| [PowerBoostServer.server.luau:3](reference/source/server/PowerBoostServer.server.luau) | `local Boosts=require(script.Parent.PowerBoosts)` |
| [PowerBoosts.luau:3](reference/source/server/PowerBoosts.luau) | `local C=require(game:GetService("ReplicatedStorage"):WaitForChild("PowerBoostConfig"))` |
| [ProtoFuelServer.server.luau:2](reference/source/server/ProtoFuelServer.server.luau) | `if rocketMode and require(rocketMode).Enabled then return end` |
| [ProtoFuelServer.server.luau:4](reference/source/server/ProtoFuelServer.server.luau) | `local Fuel = require(script.Parent.ProtoFuelService)` |
| [ProtoFuelService.luau:5](reference/source/server/ProtoFuelService.luau) | `local Constants = require(ReplicatedStorage:WaitForChild("ProtoFuelConstants"))` |
| [RocketFlightService.luau:4](reference/source/server/RocketFlightService.luau) | `local Data=require(script.Parent.PlayerData)` |
| [RocketFlightService.luau:5](reference/source/server/RocketFlightService.luau) | `local World=require(script.Parent.WorldService)` |
| [RocketFlightService.luau:6](reference/source/server/RocketFlightService.luau) | `local Balance=require(RS:WaitForChild("BalanceConfig"))` |
| [RocketFlightService.luau:7](reference/source/server/RocketFlightService.luau) | `local Config=require(RS:WaitForChild("RocketModeConfig"))` |
| [RocketFlightService.luau:8](reference/source/server/RocketFlightService.luau) | `local Motion=require(RS:WaitForChild("RocketMotion"))` |
| [RocketFlightService.luau:9](reference/source/server/RocketFlightService.luau) | `local Rules=require(script.Parent.RocketRules)` |
| [RocketFlightService.luau:10](reference/source/server/RocketFlightService.luau) | `local Rocket=require(script.Parent.BackRocket)` |
| [RocketFlightService.luau:11](reference/source/server/RocketFlightService.luau) | `local Course=require(script.Parent.BreakCourse)` |
| [RocketFlightService.luau:12](reference/source/server/RocketFlightService.luau) | `local DiveZone=require(script.Parent.DiveBreakZone)` |
| [RocketFlightService.luau:13](reference/source/server/RocketFlightService.luau) | `local GoldRings=require(script.Parent.GoldRingEvent)` |
| [RocketFlightService.luau:14](reference/source/server/RocketFlightService.luau) | `local Impact=require(script.Parent.DiveImpact)` |
| [RocketFlightService.luau:15](reference/source/server/RocketFlightService.luau) | `local Rewards=require(RS:WaitForChild("DestructionRewardConfig"))` |
| [RocketFlightService.luau:16](reference/source/server/RocketFlightService.luau) | `local Requirements=require(RS:WaitForChild("GateRequirements"))` |
| [RocketFlightService.luau:17](reference/source/server/RocketFlightService.luau) | `local GateRules=require(RS:WaitForChild("CloudGateRules"))` |
| [RocketFlightService.luau:18](reference/source/server/RocketFlightService.luau) | `local Gates=require(RS:WaitForChild("CloudConfig")).HeightPresentation.Gates` |
| [RocketFlightService.luau:19](reference/source/server/RocketFlightService.luau) | `local Pose=require(script.Parent.RocketPose)` |
| [RocketFlightService.luau:20](reference/source/server/RocketFlightService.luau) | `local Streaming=require(script.Parent.FlightStreaming)` |
| [RocketFlightService.luau:21](reference/source/server/RocketFlightService.luau) | `local Limbs=require(script.Parent.LimbLanding)` |
| [RocketFlightService.luau:22](reference/source/server/RocketFlightService.luau) | `local Boosts=require(script.Parent.PowerBoosts)` |
| [RocketFlightService.luau:83](reference/source/server/RocketFlightService.luau) | `local growth=require(RS.ProgressionConfig);local rebirths=Data.GetLevel(player,"Rebirths")or 0` |
| [RocketFlightService.luau:154](reference/source/server/RocketFlightService.luau) | `remotes=require(script.Parent.Remotes).Ensure()` |
| [RocketSkinService.server.luau:2](reference/source/server/RocketSkinService.server.luau) | `if not require(RS:WaitForChild("RocketModeConfig")).Enabled then return end` |
| [RocketSkinService.server.luau:3](reference/source/server/RocketSkinService.server.luau) | `local Data=require(script.Parent.PlayerData)` |
| [RocketSkinService.server.luau:4](reference/source/server/RocketSkinService.server.luau) | `require(script.Parent.Remotes).Ensure().SelectRocketTrail.OnServerInvoke=function(player,index)return Data.SelectRocketTrail(player,index)end` |
| [RocketSkinService.server.luau:5](reference/source/server/RocketSkinService.server.luau) | `require(script.Parent.Remotes).Ensure().SelectRocketSkin.OnServerInvoke=function(player,index)` |
| [RocketSkinService.server.luau:7](reference/source/server/RocketSkinService.server.luau) | `local item=require(RS.RocketSkinCatalog).Items[index];local display=item and displays and displays:FindFirstChild(item.Id)` |
| [RocketSkinService.server.luau:11](reference/source/server/RocketSkinService.server.luau) | `local private=player:FindFirstChild("ProgressStats");if not item or not private or not require(RS.RocketSkinCatalog).Owns(private.RocketSkinMask.Value,index)then return false,"Only displayed rockets can be purchased"end` |
| [RocketSkinService.server.luau:17](reference/source/server/RocketSkinService.server.luau) | `local Rocket=require(script.Parent.BackRocket)` |
| [RocketSkinService.server.luau:18](reference/source/server/RocketSkinService.server.luau) | `local Catalog=require(RS:WaitForChild("RocketSkinCatalog"))` |
| [RunPolicy.luau:4](reference/source/server/RunPolicy.luau) | `local Balance = require(balanceModule)` |
| [SessionSetup.server.luau:1](reference/source/server/SessionSetup.server.luau) | `require(script.Parent.SpawnService).Start()` |
| [SharedTraining.luau:4](reference/source/server/SharedTraining.luau) | `local Data=require(script.Parent.PlayerData)` |
| [SharedTraining.luau:6](reference/source/server/SharedTraining.luau) | `local Config=require(game.ReplicatedStorage:WaitForChild("ShowroomConfig"))` |
| [ShowroomService.server.luau:2](reference/source/server/ShowroomService.server.luau) | `if not require(RS:WaitForChild("RocketModeConfig")).Enabled then return end` |
| [ShowroomService.server.luau:3](reference/source/server/ShowroomService.server.luau) | `local Data=require(script.Parent.PlayerData)` |
| [ShowroomService.server.luau:4](reference/source/server/ShowroomService.server.luau) | `local Training=require(script.Parent.SharedTraining)` |
| [SkyIslandSpawner.server.luau:4](reference/source/server/SkyIslandSpawner.server.luau) | `if rocket and require(rocket).Enabled then return end -- No legacy landing island in rocket/dive mode.` |
| [SkyIslandSpawner.server.luau:10](reference/source/server/SkyIslandSpawner.server.luau) | `local Config = require(configModule)` |
| [SkyIslandSpawner.server.luau:11](reference/source/server/SkyIslandSpawner.server.luau) | `local LevelConfig = require(script.Parent.LevelConfig)` |
| [SkyIslandSpawner.server.luau:12](reference/source/server/SkyIslandSpawner.server.luau) | `local Coordinates = require(script.Parent.WorldCoordinates)` |
| [SkyLife.luau:4](reference/source/server/SkyLife.luau) | `local Visuals=require(script.Parent.BrainrotVisuals)` |
| [SkyLife.luau:5](reference/source/server/SkyLife.luau) | `local Patrol=require(script.Parent.SkyPatrol)` |
| [SkyLife.luau:6](reference/source/server/SkyLife.luau) | `local Butter=require(game:GetService("ReplicatedStorage"):WaitForChild("CourseVisualConfig"))` |
| [SkyLife.luau:7](reference/source/server/SkyLife.luau) | `local gates=require(game:GetService("ReplicatedStorage"):WaitForChild("CloudConfig")).HeightPresentation.Gates` |
| [SkyLife.luau:12](reference/source/server/SkyLife.luau) | `local biomes=require(game:GetService("ReplicatedStorage"):WaitForChild("CloudConfig",15)).HeightPresentation.Biomes` |
| [StudioProgressTest.server.luau:4](reference/source/server/StudioProgressTest.server.luau) | `local TestConfig=require(game:GetService("ReplicatedStorage"):WaitForChild("PowerBoostConfig"))` |
| [StudioProgressTest.server.luau:8](reference/source/server/StudioProgressTest.server.luau) | `local Data=require(script.Parent.PlayerData)` |
| [StudioProgressTest.server.luau:9](reference/source/server/StudioProgressTest.server.luau) | `local Growth=require(RS:WaitForChild("ProgressionConfig"))` |
| [StudioProgressTest.server.luau:10](reference/source/server/StudioProgressTest.server.luau) | `local Skins=require(RS:WaitForChild("RocketSkinCatalog"))` |
| [TrainingService.server.luau:4](reference/source/server/TrainingService.server.luau) | `local C=require(RS:WaitForChild("ProgressionConfig",15))` |
| [TrainingService.server.luau:5](reference/source/server/TrainingService.server.luau) | `local Data=require(script.Parent.PlayerData)` |
| [TrainingService.server.luau:6](reference/source/server/TrainingService.server.luau) | `local Shared=require(script.Parent.SharedTraining)` |
| [TrophyZones.luau:1](reference/source/server/TrophyZones.luau) | `local Config=require(game:GetService("ReplicatedStorage"):WaitForChild("TrophyZoneConfig"))` |
| [TrophyZones.luau:2](reference/source/server/TrophyZones.luau) | `local Impact=require(script.Parent.DiveImpact)` |
| [WorldService.luau:3](reference/source/server/WorldService.luau) | `local Config = require(script.Parent.LevelConfig)` |
| [WorldService.luau:4](reference/source/server/WorldService.luau) | `local Coordinates = require(script.Parent.WorldCoordinates)` |
| [WorldService.luau:5](reference/source/server/WorldService.luau) | `local Builder = require(script.Parent.LevelBuilder)` |
| [WorldService.luau:6](reference/source/server/WorldService.luau) | `local Legacy = require(script.Parent.LegacyGimmicks)` |
| [WorldService.luau:7](reference/source/server/WorldService.luau) | `local Trajectory = require(script.Parent.LaunchTrajectory)` |
| [WorldService.luau:8](reference/source/server/WorldService.luau) | `local Destination = require(script.Parent.Destination)` |
| [WorldService.luau:9](reference/source/server/WorldService.luau) | `local Camp = script.Parent.CliffCamp and require(script.Parent.CliffCamp)` |
| [WorldService.luau:10](reference/source/server/WorldService.luau) | `local SkyLife = script.Parent.SkyLife and require(script.Parent.SkyLife)` |
| [ClickerUI.luau:4](reference/source/shared/ClickerUI.luau) | `local Theme=require(script.Parent:WaitForChild("SimulatorTheme"))` |
| [ClickerUI.luau:6](reference/source/shared/ClickerUI.luau) | `local Icons=require(script.Parent:WaitForChild("UIIcons"))` |
| [SimulatorHUD.luau:3](reference/source/shared/SimulatorHUD.luau) | `local RocketUI = require(script.Parent:WaitForChild("RocketUI"))` |
| [SimulatorHUD.luau:9](reference/source/shared/SimulatorHUD.luau) | `local Theme=require(script.Parent:WaitForChild("SimulatorTheme"))` |
| [SimulatorHUD.luau:11](reference/source/shared/SimulatorHUD.luau) | `local Icons=require(script.Parent:WaitForChild("UIIcons"))` |
