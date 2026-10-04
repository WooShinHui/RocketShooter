-- Temporary testing controls. Remove this file and StudioProgressTest.client.luau together.
local RunService=game:GetService("RunService")
-- Match PlayerData's temporary-memory environment; never mutate persistent profiles.
if not RunService:IsStudio() or (game.GameId~=0 and game.PlaceId~=0) then return end
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
 if not RunService:IsStudio() or player:GetAttribute("DataMode")~="StudioMemory" or not Data.IsReady(player) then return false,"테스트 데이터가 준비되지 않았습니다" end
 if action~="Level" and action~="Rebirth" then return false,"알 수 없는 테스트 요청" end
 local state=player:GetAttribute("FlightState")
 if state~=nil and state~="Idle" then return false,"귀환 후 사용하세요" end
 local now=os.clock()
 if now-(lastRequest[player] or -math.huge)<.2 then return false,"잠시 후 다시 누르세요" end
 lastRequest[player]=now
 local stats=player:FindFirstChild("leaderstats")
 local level=stats and stats:FindFirstChild("TrainingLevel")
 local rebirth=stats and stats:FindFirstChild("Rebirths")
 if not level or not rebirth then return false,"성장 데이터가 없습니다" end
 if action=="Level" then
  if level.Value>=2^53-1 then return false,"레벨 수치 상한입니다" end
  level.Value+=1
 else
  if rebirth.Value>=Growth.MaxRebirths then return false,"환생 수치 상한입니다" end
  rebirth.Value+=1
  local private=player:FindFirstChild("ProgressStats")
  local mask=private and private:FindFirstChild("RocketSkinMask")
  if mask then mask.Value=Skins.Milestones(mask.Value,rebirth.Value) end
 end
 -- Direct test increment: preserve current level/XP and purchases when adding rebirths.
 return true,string.format("환생 %d · 레벨 %d",rebirth.Value,level.Value)
end
Players.PlayerRemoving:Connect(function(player)lastRequest[player]=nil end)
remote.Parent=RS
