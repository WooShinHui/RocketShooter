return {
	InitialAimPitch = 65,
	Sky = {ClockTime = 14}, -- Ground/Cloud appearance is centralized in CloudConfig.
	-- Client-only Studio preview; no real discovery/progression thresholds.
	DestructionPreview = {GroundY = 0, Enter = {45, 90, 120}, Hysteresis = 4, TransitionSeconds = 0.45},
	-- User-supplied Creator Store candidates; availability/listening still needs Studio.
	DestructionSounds = {
  Slime={Impact={Id="rbxassetid://9113263454",Volume=.65,Speed=1,Seconds=.55},Chain={{Id="rbxassetid://9113263454",Volume=.48,Speed=1.05,Seconds=.55},{Id="rbxassetid://9113263454",Volume=.46,Speed=1.15,Seconds=.55}},Finish={Id="rbxassetid://9113263647",Volume=.52,Speed=1,Seconds=.95}},
		Impact = {Id = "rbxassetid://9113568487", Volume = 0.6, Speed = 1, Seconds = 1.05},
		Chain = {
			{Id = "rbxassetid://9113263454", Volume = 0.38, Speed = 1, Seconds = 0.55},
			{Id = "rbxassetid://9113263454", Volume = 0.36, Speed = 1.12, Seconds = 0.55},
		},
		Finish = {Id = "rbxassetid://9113263647", Volume = 0.45, Speed = 1, Seconds = 0.95},
	},
	-- 새 음원을 확보하기 전까지 실제 기존 impact 계열을 사용하는 안전한 변형입니다.
	-- TODO: Studio 청취 후 흙 붕괴/석조 붕괴 전용 음원의 필요성을 판단합니다.
 WaxCrack={Cooldown=.12,Cues={
  {Id="rbxassetid://82830482880732",Volume=.28,Speed=1,Seconds=.75},
  {Id="rbxassetid://140472251389702",Volume=.26,Speed=1,Seconds=.75},
 }},
 ObjectCrack={Cooldown=.06,Cues={
  {Id="rbxassetid://82830482880732",Volume=.55,Speed=1,Seconds=.6},
  {Id="rbxassetid://140472251389702",Volume=.52,Speed=1,Seconds=.75},
  {Id="rbxassetid://138269510979347",Volume=.5,Speed=1,Seconds=.75},
 }},
	DestructionProfiles = {
  Slime={Speed=1,Volume=1,Material="SmoothPlastic",Lifetime=.8,FragmentScale=.7},
		Rock = {Speed = 1, Volume = 1, Material = "Rock", Lifetime = 1, FragmentScale = 1},
		FloatingIsland = {Speed = 0.88, Volume = 0.8, Material = "Ground", Lifetime = 1.25, FragmentScale = 0.8},
		Ruin = {Speed = 0.78, Volume = 0.95, Material = "Concrete", Lifetime = 1.5, FragmentScale = 1.3},
	},
	RingFeedback = {Seconds = 0.28, FovDegrees = 3},
	-- Creator Store sources/comparisons and runtime verification: docs/E_PRESENTATION.md.
	Sounds = {
  SpeedRush={Id="rbxassetid://77862630063982",Volume=.22,Speed=1.8,Looped=true},
  Engine={Id="rbxassetid://77862630063982",Volume=.22,Speed=1,Looped=true},
		Launch = {Id = "rbxassetid://9120705982", Volume = 0.45, Speed = 1},
		Ring = {Id = "rbxassetid://9120704522", Volume = 0.35, Speed = 1},
		Bomb = {Id = "rbxassetid://9113476681", Volume = 0.25, Speed = 1},
		Discovery = {Id = "rbxassetid://9125644410", Volume = 0.5, Speed = 1},
		Result = {Id = "rbxassetid://9119802009", Volume = 0.35, Speed = 1},
		Upgrade = {Id = "rbxassetid://127645268874265", Volume = 0.3, Speed = 1},
	},
}
