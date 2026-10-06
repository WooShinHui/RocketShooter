# 에셋·Studio 소유 장면 재사용

UIIcons의정확한키/ID와색상은동결소스가원본이다. UI아이콘에공개모델의Script를실행하지않는다. 외부ID는다음게임에서도사용권한/로딩이성공하는지확인한다. 실패한AdminClose103717003921399대신Close17368208554를사용하는현재결정도유지한다.

## Studio 소유 템플릿

- ServerStorage.ShowroomAssetTemplates.Toilet2091145711: Model,15 BaseParts,실행Script0. Union 지오메트리라소스전용Rojo빌드에포함되지않는다.
- ServerStorage.ShowroomAssetTemplates.PedestalSparkle90896557694774: 정리된Attachment/2 ParticleEmitters. texture1084961641/1053548563,4corner×2emitters×10pedestals.
- 요청된lobby16112265383은롤백되었고현재Workspace에없다. ServerStorage 보관/검토 사본을활성맵으로복원하지않는다.
- reference/scene-checkpoint.rbxl은디스크체크포인트다. 복사본에동결source를동기화하고템플릿/필드모델을검사한다. 현재라이브맵을덮지않는다.
- 최근경고문FixedEntryWarning/발사대Billboard/구름/고도팔레트는로켓행동예제다. 공통UI/훈련소/쇼룸슬롯규격과구분한다.

## 쇼룸 공통 배치

최종Spawn의방향이기준이다. 좌측장비2줄×5개,측면−56/−80,뒤쪽24/48/72/96/120stud. 우측훈련7개,측면+56,뒤쪽24부터22stud간격. 마주보는방향/번호1~7/영구카탈로그인덱스를유지한다. Spawn 이동완료후생성한다. 장비아트의180도회전은현재BackRocket장착축보정이며다른모델에서는자기축을검증한다. 보이는하나의훈련소에개인Seat를여러개생성하는규칙은공통이다.

## 코드에서 참조하는 이미지/메시/사운드 ID

| ID | 소스 위치 |
|---|---|
| 722336801 | [CloudConfig.luau:17](reference/source/shared/CloudConfig.luau) |
| 722336936 | [CloudConfig.luau:17](reference/source/shared/CloudConfig.luau) |
| 722336997 | [CloudConfig.luau:17](reference/source/shared/CloudConfig.luau) |
| 722337048 | [CloudConfig.luau:17](reference/source/shared/CloudConfig.luau) |
| 722337166 | [CloudConfig.luau:17](reference/source/shared/CloudConfig.luau) |
| 722340315 | [CloudConfig.luau:17](reference/source/shared/CloudConfig.luau) |
| 1075087760 | [CloudConfig.luau:22](reference/source/shared/CloudConfig.luau) |
| 1084351190 | [CloudConfig.luau:22](reference/source/shared/CloudConfig.luau) |
| 1189339155 | [CloudConfig.luau:22](reference/source/shared/CloudConfig.luau) |
| 1189339378 | [CloudConfig.luau:22](reference/source/shared/CloudConfig.luau) |
| 1189339550 | [CloudConfig.luau:22](reference/source/shared/CloudConfig.luau) |
| 1189339741 | [CloudConfig.luau:22](reference/source/shared/CloudConfig.luau) |
| 1189340203 | [CloudConfig.luau:22](reference/source/shared/CloudConfig.luau) |
| 1189340601 | [CloudConfig.luau:22](reference/source/shared/CloudConfig.luau) |
| 6196665106 | [CloudConfig.luau:23](reference/source/shared/CloudConfig.luau) |
| 6444320592 | [CloudConfig.luau:23](reference/source/shared/CloudConfig.luau) |
| 7884421883 | [CloudConfig.luau:17](reference/source/shared/CloudConfig.luau) |
| 9113263454 | [PresentationConfig.luau:8](reference/source/client/PresentationConfig.luau), [PresentationConfig.luau:11](reference/source/client/PresentationConfig.luau), [PresentationConfig.luau:12](reference/source/client/PresentationConfig.luau) |
| 9113263647 | [PresentationConfig.luau:8](reference/source/client/PresentationConfig.luau), [PresentationConfig.luau:14](reference/source/client/PresentationConfig.luau) |
| 9113476681 | [PresentationConfig.luau:40](reference/source/client/PresentationConfig.luau) |
| 9113568487 | [PresentationConfig.luau:9](reference/source/client/PresentationConfig.luau) |
| 9119802009 | [PresentationConfig.luau:42](reference/source/client/PresentationConfig.luau) |
| 9120704522 | [PresentationConfig.luau:39](reference/source/client/PresentationConfig.luau) |
| 9120705982 | [PresentationConfig.luau:38](reference/source/client/PresentationConfig.luau) |
| 9125644410 | [PresentationConfig.luau:41](reference/source/client/PresentationConfig.luau) |
| 12129301834 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 13443203578 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 15402958715 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 15402967660 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 15403007921 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 15403027709 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 15403140844 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 15403144723 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 16670799841 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368045028 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368048685 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368071983 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368080973 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368081924 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368089841 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368097932 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368169201 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368208554 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368210998 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368214873 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 17368217589 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 77161916398296 | [BrainrotVisuals.luau:16](reference/source/server/BrainrotVisuals.luau) |
| 77862630063982 | [PresentationConfig.luau:36](reference/source/client/PresentationConfig.luau), [PresentationConfig.luau:37](reference/source/client/PresentationConfig.luau) |
| 80145679593246 | [GateEncounterConfig.luau:9](reference/source/shared/GateEncounterConfig.luau) |
| 80351797193483 | [GateEncounterConfig.luau:14](reference/source/shared/GateEncounterConfig.luau) |
| 81891240709428 | [GateEncounterConfig.luau:13](reference/source/shared/GateEncounterConfig.luau) |
| 82278067509295 | [GateEncounterConfig.luau:16](reference/source/shared/GateEncounterConfig.luau) |
| 82464974337955 | [BrainrotVisuals.luau:4](reference/source/server/BrainrotVisuals.luau) |
| 82830482880732 | [PresentationConfig.luau:19](reference/source/client/PresentationConfig.luau), [PresentationConfig.luau:23](reference/source/client/PresentationConfig.luau) |
| 83573042900595 | [CourseVisualConfig.luau:13](reference/source/shared/CourseVisualConfig.luau) |
| 84982639767507 | [BrainrotVisuals.luau:15](reference/source/server/BrainrotVisuals.luau) |
| 85114169318270 | [GateEncounterConfig.luau:5](reference/source/shared/GateEncounterConfig.luau) |
| 85369542874074 | [GateEncounterConfig.luau:7](reference/source/shared/GateEncounterConfig.luau) |
| 85735925995041 | [CourseVisualConfig.luau:14](reference/source/shared/CourseVisualConfig.luau) |
| 86841683622981 | [GateEncounterConfig.luau:12](reference/source/shared/GateEncounterConfig.luau) |
| 87013145260875 | [GateEncounterConfig.luau:15](reference/source/shared/GateEncounterConfig.luau) |
| 88552868232210 | [GateEncounterConfig.luau:12](reference/source/shared/GateEncounterConfig.luau) |
| 89592676843349 | [LaunchPadGuide.client.luau:19](reference/source/client/LaunchPadGuide.client.luau) |
| 90257837878159 | [GateEncounterConfig.luau:11](reference/source/shared/GateEncounterConfig.luau) |
| 91215790821175 | [BrainrotVisuals.luau:12](reference/source/server/BrainrotVisuals.luau) |
| 91818640034843 | [CourseVisualConfig.luau:13](reference/source/shared/CourseVisualConfig.luau) |
| 92009012259544 | [GateEncounterConfig.luau:13](reference/source/shared/GateEncounterConfig.luau) |
| 95334903016944 | [BrainrotVisuals.luau:7](reference/source/server/BrainrotVisuals.luau) |
| 96342746946140 | [BrainrotVisuals.luau:13](reference/source/server/BrainrotVisuals.luau) |
| 97780786497924 | [BrainrotVisuals.luau:11](reference/source/server/BrainrotVisuals.luau) |
| 98146924095290 | [GateEncounterConfig.luau:11](reference/source/shared/GateEncounterConfig.luau) |
| 98783340525031 | [BrainrotVisuals.luau:15](reference/source/server/BrainrotVisuals.luau) |
| 100507425145825 | [GateEncounterConfig.luau:8](reference/source/shared/GateEncounterConfig.luau) |
| 103717003921399 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 105445253181063 | [BrainrotVisuals.luau:4](reference/source/server/BrainrotVisuals.luau) |
| 107129431019633 | [GateEncounterConfig.luau:7](reference/source/shared/GateEncounterConfig.luau) |
| 109064107200773 | [GateEncounterConfig.luau:6](reference/source/shared/GateEncounterConfig.luau) |
| 110356585242168 | [CourseVisualConfig.luau:14](reference/source/shared/CourseVisualConfig.luau) |
| 113266009243876 | [GateEncounterConfig.luau:5](reference/source/shared/GateEncounterConfig.luau) |
| 113482070800284 | [BrainrotVisuals.luau:7](reference/source/server/BrainrotVisuals.luau) |
| 114029733376487 | [GateEncounterConfig.luau:6](reference/source/shared/GateEncounterConfig.luau) |
| 114343988119693 | [GateEncounterConfig.luau:15](reference/source/shared/GateEncounterConfig.luau) |
| 117956531039517 | [GateEncounterConfig.luau:10](reference/source/shared/GateEncounterConfig.luau) |
| 121410519717160 | [GateEncounterConfig.luau:16](reference/source/shared/GateEncounterConfig.luau) |
| 121510353195924 | [GateEncounterConfig.luau:10](reference/source/shared/GateEncounterConfig.luau) |
| 123603023572192 | [GateEncounterConfig.luau:8](reference/source/shared/GateEncounterConfig.luau) |
| 124432184038410 | [BrainrotVisuals.luau:14](reference/source/server/BrainrotVisuals.luau) |
| 126031734174893 | [BrainrotVisuals.luau:10](reference/source/server/BrainrotVisuals.luau) |
| 127645268874265 | [PresentationConfig.luau:43](reference/source/client/PresentationConfig.luau) |
| 135379403285598 | [GateEncounterConfig.luau:4](reference/source/shared/GateEncounterConfig.luau) |
| 135569585073294 | [UIIcons.luau:2](reference/source/shared/UIIcons.luau) |
| 137108822293648 | [GateEncounterConfig.luau:4](reference/source/shared/GateEncounterConfig.luau) |
| 138269510979347 | [PresentationConfig.luau:25](reference/source/client/PresentationConfig.luau) |
| 138545159723963 | [GateEncounterConfig.luau:14](reference/source/shared/GateEncounterConfig.luau) |
| 140472251389702 | [PresentationConfig.luau:20](reference/source/client/PresentationConfig.luau), [PresentationConfig.luau:24](reference/source/client/PresentationConfig.luau) |
| 140614663869243 | [GateEncounterConfig.luau:9](reference/source/shared/GateEncounterConfig.luau) |

숫자형AssetRegistry/카탈로그상수와동적asset생성은소스도참조한다. 위표는rbxassetid문자열색인이며소유권허가목록이나현재UI노출목록이아니다.
