local balanceModule = game:GetService("ReplicatedStorage"):WaitForChild("BalanceConfig", 15)
assert(balanceModule and balanceModule:IsA("ModuleScript"),
	"[Setup] ReplicatedStorage.BalanceConfig must be a ModuleScript. Stop Play, restart rojo serve with default.project.json, reconnect and accept sync.")
local Balance = require(balanceModule)
-- Pure rules shared by the server lifecycle and local regression tests.
local Policy = {}

function Policy.finite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end

function Policy.validAim(yaw, pitch)
	return Policy.finite(yaw) and Policy.finite(pitch)
		and yaw >= -30 and yaw <= 30 and pitch >= -5 and pitch <= 75
end

function Policy.validMultiplier(value)
	return Policy.finite(value) and value == 1 -- No timing reward or penalty.
end

function Policy.reward(distance, targetCount)
	return Balance.Reward(distance, targetCount)
end

function Policy.isCurrent(run, id, character)
	return run ~= nil and run.id == id and run.character == character
		and not run.cancelled
end

return Policy
