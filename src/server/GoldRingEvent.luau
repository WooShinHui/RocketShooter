-- One server-wide wave every thirty minutes; rewards require real swept crossings.
local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Data=require(script.Parent.PlayerData)
local Event={Interval=1800,Duration=180,MaxClaims=3,Radius=26}
local started=false;local nextAt=0;local endsAt=0;local wave=0
local folder;local origin;local rings={};local claims={}
function Event.Crosses(center,from,to,radius)
 local dy=to.Y-from.Y
 if math.abs(dy)<.00001 then return false end
 local t=(center.Y-from.Y)/dy
 if t<0 or t>1 then return false end
 local p=from+(to-from)*t
 return Vector3.new(p.X-center.X,0,p.Z-center.Z).Magnitude<=radius+2.5
end
function Event.CanClaim(record,id)
 return not record or (record.Count<Event.MaxClaims and not record.Ids[id])
end
local function ring(position,index)
 local m=Instance.new("Model");m.Name="골드 링 "..index;m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
 m:SetAttribute("GoldRingId",index);m:SetAttribute("GoldRingWave",wave);m:SetAttribute("SkyKind","GoldRing")
 for i=1,24 do
  local a=i*math.pi*2/24;local p=Instance.new("Part");p.Name="GoldArc";p.Size=Vector3.new(8,3,4)
  p.CFrame=CFrame.new(position+Vector3.new(math.cos(a)*Event.Radius,0,math.sin(a)*Event.Radius))*CFrame.Angles(0,-a,0)
  p.Color=Color3.fromRGB(255,204,34);p.Material=Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=m
  if i==1 then m.PrimaryPart=p end
 end
 local g=Instance.new("BillboardGui");g.Name="GoldReward";g.Size=UDim2.fromOffset(240,54);g.StudsOffset=Vector3.new(0,12,0);g.MaxDistance=1800;g.Parent=m.PrimaryPart
 local l=Instance.new("TextLabel");l.Size=UDim2.fromScale(1,1);l.BackgroundTransparency=1;l.Text="✦ 골드 링 · 대량 XP ✦";l.TextColor3=Color3.fromRGB(255,231,79);l.TextStrokeTransparency=0;l.Font=Enum.Font.GothamBlack;l.TextSize=24;l.Parent=g
 m.Parent=folder;table.insert(rings,{Position=position,Id=index,Model=m})
end
function Event.Update(now)
 if not started then return end
 if endsAt>0 and now>=endsAt then
  folder:ClearAllChildren();table.clear(rings);table.clear(claims);endsAt=0;workspace:SetAttribute("GoldRingEndsAt",0)
 end
 if now<nextAt then return end
 nextAt=now+Event.Interval;endsAt=now+Event.Duration;wave+=1
 folder:ClearAllChildren();table.clear(rings);table.clear(claims)
 local random=Random.new()
 for i,height in {75,120,220,550,1300,2800,8000,20000,50000,85000,105000,135000}do
  ring(Vector3.new(origin.X+random:NextNumber(-18,18),height,origin.Z+random:NextNumber(-18,18)),i)
 end
 -- Include currently occupied remote air lanes, bounded by the current player count.
 for _,p in Players:GetPlayers()do
  local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
  if root and p:GetAttribute("FlightState")=="Flying" then
   local v=root.AssemblyLinearVelocity
   local y=math.clamp(root.Position.Y+(v.Y>=0 and 1 or -1)*math.max(35,math.abs(v.Y)*.7),45,140000)
   ring(Vector3.new(root.Position.X+v.X*.7,y,root.Position.Z+v.Z*.7),#rings+1)
  end
 end
 workspace:SetAttribute("GoldRingNextAt",nextAt);workspace:SetAttribute("GoldRingEndsAt",endsAt);workspace:SetAttribute("GoldRingWave",wave)
end
function Event.Start(position)
 if started then return end;started=true;origin=position
 folder=Instance.new("Folder");folder.Name="GoldRingEvent";folder.Parent=workspace
 nextAt=workspace:GetServerTimeNow()+Event.Interval;workspace:SetAttribute("GoldRingNextAt",nextAt);workspace:SetAttribute("GoldRingEndsAt",0)
 local elapsed=0
 game:GetService("RunService").Heartbeat:Connect(function(dt)elapsed+=dt;if elapsed>=.5 then elapsed=0;Event.Update(workspace:GetServerTimeNow())end end)
 Players.PlayerRemoving:Connect(function(p)claims[p]=nil end)
end
function Event.Collect(player,from,to)
 if not started or endsAt==0 or workspace:GetServerTimeNow()>=endsAt or not Data.IsReady(player) or player:GetAttribute("FlightState")~="Flying" then return 0,0,0 end
 local record=claims[player];local xp,score,count=0,0,0
 for _,r in rings do
  if Event.CanClaim(record,r.Id) and Event.Crosses(r.Position,from,to,Event.Radius) then
   if not record then record={Count=0,Ids={}};claims[player]=record end
   record.Ids[r.Id]=true;record.Count+=1
   local gain=Data.AwardGoldRingXP(player);xp+=gain;score+=250;count+=1
   local remote=RS:FindFirstChild("FlightState")
   if remote then remote:FireClient(player,"GoldRing",player:GetAttribute("SkyRunSerial"),player.Character,gain)end
  end
 end
 return xp,score,count
end
return Event
