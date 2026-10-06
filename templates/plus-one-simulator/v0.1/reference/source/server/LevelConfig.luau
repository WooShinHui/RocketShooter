-- All lengths are studs. Layout progress is separate from the legacy reward distance.
local cloudModule = game:GetService("ReplicatedStorage"):WaitForChild("CloudConfig", 15)
assert(cloudModule and cloudModule:IsA("ModuleScript"), "[World] Missing CloudConfig ModuleScript; reconnect Rojo")
local rocketModule=game:GetService("ReplicatedStorage"):FindFirstChild("RocketModeConfig")
local rocket=rocketModule and require(rocketModule).Enabled
return table.freeze({
	Clouds = require(cloudModule),
	LegacyGimmicks = "Disabled", -- "Disabled": archive the entire legacy folder for this session.
	ArchiveHandmadeMap = true, -- Session-only: original stays in saved rbxl.
	GroundY = 0, -- Audited Baseplate surface. nil uses SpawnLocation top.
	Destinations = if rocket then {} else {
		{Id = "CloudOutpost", DisplayName = "Cloud Outpost", Region = "Clouds",
			Key = "Landmark.CloudOutpost", Forward = 300, Lateral = 65, Altitude = 210,
			HalfForward = 45, HalfLateral = 60, HalfAltitude = 30, RequiredAltitude = 180,
			CloudClearance = 190},
	},
	Streaming = {Ahead = 900, Behind = 300, LookAheadSeconds = 2, MaxLookAhead = 2500,
		UnloadDelay = 15, UpdateInterval = 0.25},
	Bounds = {BelowGround = 40, DestroyMargin = 80, PredictionSeconds = 0.2,
		BehindOrigin = 512, LateralBase = 600, LateralPerForward = 0.8},
	Course = {
		RingRadius = 23,
		RingTrajectory = {PowerLevel = 20, Pitch = 45, Timing = 1,
			Distances = {45, 90, 140, 175, 230, 285}},
		BombStart = 1700, BombEnd = 2900, BombSpacing = 1200, BombHeight = 20,
		TargetStart = 300, TargetEnd = 1800, TargetSpacing = 500,
	},
	Sections = {
	-- See Obstacles below for global distance placements (not repeated per section).
		-- CliffCamp replaces the repeated road with a finite hill above a valley.
	},
	-- Optional low side pockets; never scaled with Power. Center flight remains open.
	Obstacles = {
		{Id = "FirstDodge", Pattern = "Single", Key = "Test.Obstacle", Start = 600,
			Lateral = 65, Height = 16.5, Width = 8, HeightSize = 24, Depth = 16,
			Count = 1, Spacing = 420, SideOffset = 0, Gap = 24},
		{Id = "Weave", Pattern = "Alternating", Key = "Test.Obstacle", Start = 1200,
			Lateral = 100, Height = 20.5, Width = 42, HeightSize = 32, Depth = 16,
			Count = 2, Spacing = 1000, SideOffset = 20, Gap = 24},
		{Id = "ChooseLane", Pattern = "Choice", Key = "Test.Obstacle", Start = 3400,
			Lateral = -120, Height = 24.5, Width = 12, HeightSize = 40, Depth = 16,
			Count = 1, Spacing = 420, SideOffset = 0, Gap = 28},
	},
})
