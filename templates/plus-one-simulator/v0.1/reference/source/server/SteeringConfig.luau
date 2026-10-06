-- PHASE 1 tuning. Server owns all physical values; only transport cadence is sent to clients.
return table.freeze({
	Acceleration = 75, -- studs/s^2, approach the requested lateral velocity
	ReleaseDeceleration = 12, -- gentle drift decay after letting go
	MaxLateralSpeed = 75, -- studs/s, never accelerate toward a larger steering target
	ForwardSpeedFraction = 0.35, -- target also limited by remaining forward momentum
	MinForwardSpeed = 5, -- no sideways propulsion when forward motion is effectively gone
	MaxStepSeconds = 0.10, -- prevent a large corrective impulse after a stalled frame
	InputTimeout = 0.35, -- stale input becomes neutral
	MinPacketInterval = 0.04, -- at most 25 accepted input packets/sec
	Client = table.freeze({SendInterval = 0.10}), -- 10 Hz while Flying
})
