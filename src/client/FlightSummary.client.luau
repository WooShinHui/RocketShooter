-- Reward burst follows the player's head across automatic respawn; no screen panel.
local RS=game:GetService("ReplicatedStorage")
local player=game:GetService("Players").LocalPlayer
local Cloud=require(RS:WaitForChild("CloudConfig"))
local Tween=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local activeId,activeCharacter
local serial=0;local popups={}
local layer=Instance.new("ScreenGui");layer.Name="HeadRewardBurstGui";layer.ResetOnSpawn=false;layer.IgnoreGuiInset=true;layer.DisplayOrder=55;layer.Parent=player.PlayerGui
local goldColor=Color3.fromRGB(255,225,66);local green=Color3.fromRGB(110,255,164)
local function clear()
 serial+=1
 for popup in popups do popup:Destroy() end;table.clear(popups)
end
local function burst(rows,afterReturn)
 clear();local token=serial
 task.spawn(function()
 if afterReturn then
  local deadline=os.clock()+6
  repeat task.wait(.05) until token~=serial or (player.Character and player.Character:FindFirstChild("Head") and player:GetAttribute("FlightState")=="Idle") or os.clock()>deadline
  if token~=serial then return end
 end
 for index,row in rows do
  task.delay((index-1)*.12,function()
   if token~=serial then return end
   local popup=Instance.new("TextLabel");popup.Name="FlightRewardPop";popup.Size=UDim2.fromOffset(360,32);popup.AnchorPoint=Vector2.new(.5,1)
   popup.BackgroundTransparency=1;popup.Font=Enum.Font.GothamBlack;popup.TextSize=23;popup.TextColor3=row[2];popup.TextStrokeTransparency=0;popup.Text=row[1];popup.Parent=layer
   popups[popup]={Started=os.clock(),Row=index}
   Tween:Create(popup,TweenInfo.new(1.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In,0,false,1.1),{TextTransparency=1,TextStrokeTransparency=1}):Play()
   task.delay(2.6,function()popups[popup]=nil;popup:Destroy() end)
  end)
 end
 end)
end
RunService.RenderStepped:Connect(function()
 local head=player.Character and player.Character:FindFirstChild("Head")
 local camera=workspace.CurrentCamera
 for popup,info in popups do
  if head and camera then
   local point,onScreen=camera:WorldToViewportPoint(head.Position+Vector3.new(0,2.5,0))
   popup.Visible=onScreen and point.Z>0
   popup.Position=UDim2.fromOffset(point.X,point.Y-(info.Row-1)*27-(os.clock()-info.Started)*22)
  else popup.Visible=false end
 end
end)
RS:WaitForChild("FireCannon").OnClientEvent:Connect(function(_,id,character)
 clear();activeId=id;activeCharacter=character
end)
RS:WaitForChild("FlightState").OnClientEvent:Connect(function(state,id,character,reason)
 if state=="Effect" and reason=="SkyHazard" and id==activeId and character==activeCharacter and character==player.Character then
  burst({{"위험 충돌! 이번 비행 보상 없음",Color3.fromRGB(255,98,112)}})
 end
end)
RS:WaitForChild("FlightResult").OnClientEvent:Connect(function(_,gold,trophies,record,id,character,metrics)
 if id~=activeId or character~=activeCharacter then return end
 activeId=nil;metrics=metrics or {}
 -- Tutorial (deferred): "트로피는 하늘의 트로피 존에 착지해서 획득"
 local rows={{"비행 경험치 +"..(metrics.XPGain or 0).." XP",goldColor},{trophies>0 and ("🏆 트로피 존 착지! +"..trophies.." 트로피")or "트로피 +0",green},
 {string.format("최고 높이 %s · 파괴 %d점",Cloud.FormatAltitude(metrics.MaxAltitude or 0),metrics.SkyScore or 0),Color3.fromRGB(133,222,255)}}
 if metrics.GoldRings and metrics.GoldRings>0 then table.insert(rows,{"골드 링 "..metrics.GoldRings.."개 · 대량 경험치 획득!",goldColor}) end
 if metrics.DiveHits and metrics.DiveHits>0 then table.insert(rows,{"다이빙 파괴 "..metrics.DiveHits.."회",green}) end
 if metrics.DescentRings then table.insert(rows,{string.format("링 %d/3 · %s",metrics.DescentRings,metrics.LandingGrade or "표적 밖"),green}) end
 if record or metrics.AltitudeRecord then table.insert(rows,{"새 최고 기록!",goldColor}) end
 burst(rows,true)
end)
