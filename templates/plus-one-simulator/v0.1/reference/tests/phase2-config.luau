-- All lengths are studs. Layout progress is separate from the legacy reward distance.
return table.freeze({
	LegacyGimmicks = "Preserve", -- "Disabled": archive the entire legacy folder for this session.
	GroundY = 0, -- Audited Baseplate surface. nil uses SpawnLocation top.
	Streaming = {Ahead = 900, Behind = 300, LookAheadSeconds = 2, MaxLookAhead = 2500,
		UnloadDelay = 15, UpdateInterval = 0.25},
	Bounds = {BelowGround = 100, DestroyMargin = 80, PredictionSeconds = 0.2,
		BehindOrigin = 512, LateralBase = 600, LateralPerForward = 0.8},
	Sections = {
		{Id = "TestLane", Kind = "LandingLane", Start = 100, Length = 512,
			Width = 512, TileLength = 64, Height = 4.5, RepeatCount = 1}, -- Above the audited lobby floor (4.25).
	},
})
