local rocketMode=game:GetService("ReplicatedStorage"):FindFirstChild("RocketModeConfig")
if rocketMode and require(rocketMode).Enabled then return end
-- Studio의 FuelStation은 후속 MCP 단계에서 배치한다.
local Fuel = require(script.Parent.ProtoFuelService)
Fuel.Start()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local powerUp = ReplicatedStorage:FindFirstChild("RequestPowerUp")
if powerUp then
	assert(powerUp:IsA("RemoteFunction"), "RequestPowerUp은 RemoteFunction이어야 합니다")
else
	powerUp = Instance.new("RemoteFunction")
	powerUp.Name = "RequestPowerUp"
	powerUp.Parent = ReplicatedStorage
end
powerUp.OnServerInvoke = function(player)
	return Fuel.consumeFuelForPowerUp(player)
end
