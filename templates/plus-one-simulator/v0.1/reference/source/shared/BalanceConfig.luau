-- PHASE 2 progression tuning. Pure math, used by server, shop and prediction tests.
local Balance = {
	Power = {Base = 240, Gain = 14, Exponent = 0.72, MaxHorizontalSpeed = 20000,
		ReferencePitch = 25, AimExponent = 4},
	Vertical = {Base = 260, Gain = 10, Exponent = 0.85, TimingInfluence = 0.2,
		MaxUp = 7500, MaxDown = 35}, -- Technical safety ceiling, not an early progression cap.
	Gold = {Scale = 0.4, Exponent = 0.85},
	Upgrade = {Base = 120, Linear = 30, Curve = 2, Exponent = 1.4, BoostCostPerLevel = 2},
	Trophies = {DistancePerTrophy = 300, PerTarget = 5},
	Ring = {BaseGain = 18, GainPerDoubling = 6, MaxLaunchGainFraction = 0.35,
		Lift = 25, RunLiftBase = 25, RunLiftFraction = 0.35, Cooldown = 0.8},
	Bomb = {SpeedFactor = 0.9, DownwardImpulse = 5, Cooldown = 1},
	Camera = {Behind = 26, Height = 12, LookAhead = 65, LookDown = 14},
}
local MAX_SAFE_INTEGER = 2 ^ 53 - 1

function Balance.PowerValue(level)
	return Balance.Power.Base + Balance.Power.Gain * math.max(0, level - 1) ^ Balance.Power.Exponent
end

function Balance.VerticalPower(level)
	local c = Balance.Vertical
	return c.Base + c.Gain * math.max(0, level - 1) ^ c.Exponent
end

function Balance.LaunchComponents(level, aimY, timing)
	aimY = math.clamp(aimY, -1, 1)
	local cosine = math.sqrt(math.max(0, 1 - aimY * aimY))
	-- Keep the 25-degree baseline; steep shots exchange forward reach for altitude.
	local aimScale = cosine ^ Balance.Power.AimExponent
		/ math.cos(math.rad(Balance.Power.ReferencePitch)) ^ (Balance.Power.AimExponent - 1)
	local horizontal = math.min(Balance.Power.MaxHorizontalSpeed, Balance.PowerValue(level) * aimScale * timing)
	local vertical = math.clamp(Balance.VerticalPower(level) * aimY
		* (1 + (timing - 1) * Balance.Vertical.TimingInfluence), -Balance.Vertical.MaxDown, Balance.Vertical.MaxUp)
	return horizontal, vertical
end

function Balance.PowerCost(level)
	local n = math.max(0, level - 1)
	local c = Balance.Upgrade
	-- Compensate extra airtime/Gold while retaining the previous price curve and L1 cost.
	local timeGrowth = math.min(Balance.VerticalPower(level), 2500) / Balance.Vertical.Base
	return math.min(MAX_SAFE_INTEGER, math.floor((c.Base + c.Linear * n + c.Curve * n ^ c.Exponent)
		* timeGrowth ^ Balance.Gold.Exponent))
end

function Balance.BoostCost(level)
	return math.min(MAX_SAFE_INTEGER, level * Balance.Upgrade.BoostCostPerLevel)
end

function Balance.GoldReward(distance)
	return math.floor(Balance.Gold.Scale * math.floor(math.max(0, distance)) ^ Balance.Gold.Exponent)
end

function Balance.Reward(distance, targets)
	local whole = math.floor(math.max(0, distance))
	return whole, Balance.GoldReward(whole), math.floor(whole / Balance.Trophies.DistancePerTrophy)
		+ targets * Balance.Trophies.PerTarget
end

function Balance.RingLiftBudget(launchVertical)
	return Balance.Ring.RunLiftBase + math.max(0, launchVertical) * Balance.Ring.RunLiftFraction
end

function Balance.RingComponents(horizontal, vertical, boostLevel, launchHorizontal, remainingLift)
	local settings = Balance.Ring
	local gain = settings.BaseGain + settings.GainPerDoubling * math.log(math.max(1, boostLevel), 2)
	local cap = launchHorizontal * (1 + settings.MaxLaunchGainFraction)
	-- Additive gain with a run-relative ceiling; never reduce existing external momentum.
	local nextHorizontal = horizontal + math.min(gain, math.max(0, cap - horizontal))
	-- Total extra upward impulse is run-owned. Never remove existing upward momentum.
	local lift = math.min(settings.Lift, math.max(0, remainingLift), math.max(0, Balance.Vertical.MaxUp - vertical))
	return nextHorizontal, vertical + lift, lift
end

for _, value in pairs(Balance) do if type(value) == "table" then table.freeze(value) end end
return table.freeze(Balance)
