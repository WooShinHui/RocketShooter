local Coordinates = {}

function Coordinates.Create(muzzleFrame, groundY)
	local look = muzzleFrame.LookVector
	local planar = Vector3.new(look.X, 0, look.Z)
	assert(planar.Magnitude > 0.01, "[World] Cannon must have a horizontal launch direction")
	local forward = planar.Unit
	return {Origin = muzzleFrame.Position, Forward = forward,
		Right = Vector3.new(-forward.Z, 0, forward.X), GroundY = groundY}
end

function Coordinates.Project(frame, position)
	local delta = position - frame.Origin
	return delta:Dot(frame.Forward), delta:Dot(frame.Right)
end

-- Current coordinates, not independent run maxima: future spatial checks must
-- evaluate forward AND altitude at the same sample.
function Coordinates.Measure(frame, position)
	local forward, lateral = Coordinates.Project(frame, position)
	return forward, position.Y - frame.GroundY, lateral
end

function Coordinates.Position(frame, distance, lateral, height)
	local origin = Vector3.new(frame.Origin.X, frame.GroundY, frame.Origin.Z)
	return origin + frame.Forward * distance + frame.Right * lateral + Vector3.new(0, height, 0)
end

function Coordinates.RewardDistance(position, launchOrigin)
	return (position - launchOrigin).Magnitude -- PHASE 0: 3D radial, not path length or projected progress.
end

function Coordinates.ExitReason(frame, position, velocity, destroyHeight, bounds)
	local floor = math.max(frame.GroundY - bounds.BelowGround, destroyHeight + bounds.DestroyMargin)
	local predictedY = position.Y + math.min(velocity.Y, 0) * bounds.PredictionSeconds
	if position.Y < floor or predictedY < destroyHeight + bounds.DestroyMargin then return "WorldFall" end
	local forward, lateral = Coordinates.Project(frame, position)
	if forward < -bounds.BehindOrigin
		or math.abs(lateral) > bounds.LateralBase + math.max(0, forward) * bounds.LateralPerForward then
		return "OutOfFlightArea"
	end
	return nil -- No forward wall at the end of the demonstration section.
end

return Coordinates
