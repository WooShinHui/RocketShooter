-- Pure rules shared by the server lifecycle and local regression tests.
local Policy = {}

function Policy.finite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end

function Policy.validAim(yaw, pitch)
	return Policy.finite(yaw) and Policy.finite(pitch)
		and yaw >= -30 and yaw <= 30 and pitch >= -5 and pitch <= 45
end

function Policy.validMultiplier(value)
	return Policy.finite(value) and (value == 0.7 or value == 1 or value == 1.5)
end

function Policy.reward(distance, targetCount)
	local whole = math.floor(distance)
	return whole, math.floor(whole * 1.5), math.floor(whole / 300) + targetCount * 5
end

function Policy.isCurrent(run, id, character)
	return run ~= nil and run.id == id and run.character == character
		and not run.cancelled
end

return Policy
