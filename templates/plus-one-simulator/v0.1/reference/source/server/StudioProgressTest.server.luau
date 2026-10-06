-- Temporary testing controls. Remove this file and StudioProgressTest.client.luau together.
local RunService=game:GetService("RunService")
-- User-authorized public playtest controls. Changes follow normal profile saving.
local TestConfig=require(game:GetService("ReplicatedStorage"):WaitForChild("PowerBoostConfig"))
if not TestConfig.TemporaryFreeTesting then return end
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Data=require(script.Parent.PlayerData)
local Growth=require(RS:WaitForChild("ProgressionConfig"))
local Skins=require(RS:WaitForChild("RocketSkinCatalog"))
assert(not RS:FindFirstChild("StudioProgressTest"),"Duplicate StudioProgressTest remote")
local remote=Instance.new("RemoteFunction")
remote.Name="StudioProgressTest"
local lastRequest={}
remote.OnServerInvoke=function(player,action)
 if not TestConfig.TemporaryFreeTesting or not Data.IsReady(player) then return false,"Test data is not ready" end
 if action~="Level" and action~="Rebirth" then return false,"Unknown test request" end
 local state=player:GetAttribute("FlightState")
 if state~=nil and state~="Idle" then return false,"Return before using" end
 local now=os.clock()
 if now-(lastRequest[player] or -math.huge)<.2 then return false,"Please try again shortly" end
 lastRequest[player]=now
 local stats=player:FindFirstChild("leaderstats")
 local level=stats and stats:FindFirstChild("TrainingLevel")
 local rebirth=stats and stats:FindFirstChild("Rebirths")
 if not level or not rebirth then return false,"Progress data missing" end
 if action=="Level" then
  if level.Value>=2^53-1 then return false,"Level limit reached" end
  level.Value+=1
 else
  if rebirth.Value>=Growth.MaxRebirths then return false,"Rebirth limit reached" end
  rebirth.Value+=1
  local private=player:FindFirstChild("ProgressStats")
  local mask=private and private:FindFirstChild("RocketSkinMask")
  if mask then mask.Value=Skins.Milestones(mask.Value,rebirth.Value) end
 end
 -- Direct test increment: preserve current level/XP and purchases when adding rebirths.
 return true,string.format("Rebirths %d · Level %d",rebirth.Value,level.Value)
end
Players.PlayerRemoving:Connect(function(player)lastRequest[player]=nil end)
remote.Parent=RS
