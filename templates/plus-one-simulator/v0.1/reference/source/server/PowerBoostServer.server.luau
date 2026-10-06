local RS=game:GetService("ReplicatedStorage")
if not require(RS:WaitForChild("RocketModeConfig")).Enabled then return end
local Boosts=require(script.Parent.PowerBoosts)
assert(not RS:FindFirstChild("UsePowerBoost"),"Duplicate UsePowerBoost remote")
local remote=Instance.new("RemoteFunction");remote.Name="UsePowerBoost"
remote.OnServerInvoke=function(p,action,id)return Boosts.Request(p,action,id)end
remote.Parent=RS;Boosts.Start()
