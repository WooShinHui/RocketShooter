local Coordinates = require(script.Parent.WorldCoordinates)
local Metrics = {}

function Metrics.Create(origin, launchDirection, groundY, startedAt)
	return {
		Frame = Coordinates.Create({Position = origin, LookVector = launchDirection}, groundY),
		StartedAt = startedAt, RewardDistance = 0, ForwardDistance = 0,
		MaxAltitude = 0, FlightTime = 0,
	}
end

-- Call only with server-validated positions belonging to this live run.
function Metrics.Sample(metrics, position, now)
	local forward, altitude = Coordinates.Measure(metrics.Frame, position)
	metrics.CurrentForward, metrics.CurrentAltitude = forward, altitude
	metrics.RewardDistance = math.max(metrics.RewardDistance,
		Coordinates.RewardDistance(position, metrics.Frame.Origin))
	metrics.ForwardDistance = math.max(metrics.ForwardDistance, forward)
	metrics.MaxAltitude = math.max(metrics.MaxAltitude, altitude)
	metrics.FlightTime = math.max(metrics.FlightTime, now - metrics.StartedAt)
end

function Metrics.Snapshot(metrics)
	return {RewardDistance = math.floor(metrics.RewardDistance),
		ForwardDistance = math.floor(metrics.ForwardDistance),
		MaxAltitude = math.floor(metrics.MaxAltitude), FlightTime = metrics.FlightTime}
end

return Metrics
