local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local RS=game:GetService("ReplicatedStorage")
local Config=require(RS:WaitForChild("ClickerConfig"))
local Data=require(script.Parent.PlayerData)
local remotes=require(script.Parent.Remotes).Ensure()
local balances,lastToggle={},{}
local function watch(player)
 player:SetAttribute("AutoClickMode","Off");player:SetAttribute("AutoClickEnabled",false)
 player:SetAttribute("OPAutoClickAvailable",Config.PreviewOP);player:SetAttribute("OPAutoClickPreview",Config.PreviewOP)
end
Players.PlayerAdded:Connect(watch);for _,player in Players:GetPlayers()do watch(player)end
Players.PlayerRemoving:Connect(function(player)balances[player]=nil;lastToggle[player]=nil end)
remotes.ClickTraining.OnServerEvent:Connect(function(player)Data.ClickXP(player)end)
remotes.ToggleAutoClick.OnServerInvoke=function(player,mode)
 if not Data.IsReady(player)or not Config.ValidMode(mode)then return false,"상태를 다시 확인해 주세요"end
 if mode=="OP"and not Config.PreviewOP then return false,"OP 자동 클릭커는 출시 준비 중입니다"end
 if player:GetAttribute("AutoClickMode")==mode then return true,mode end
 local now=os.clock()
 if now-(lastToggle[player]or -math.huge)<.15 then return false,"잠시 후 다시 눌러 주세요"end
 lastToggle[player]=now;balances[player]=0
 player:SetAttribute("AutoClickMode",mode);player:SetAttribute("AutoClickEnabled",mode~="Off")
 return true,mode
end
-- The server schedules rewards; clients never send automatic clicks or reward counts.
RunService.Heartbeat:Connect(function(dt)
 for _,player in Players:GetPlayers()do
  local mode=player:GetAttribute("AutoClickMode")or "Off"
  local remainder,clicks=Config.Step(balances[player]or 0,dt,mode);balances[player]=remainder
  if clicks>0 then Data.AwardAutoClickXP(player,clicks,mode)end
 end
end)
