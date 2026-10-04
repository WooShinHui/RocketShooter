-- Server world targets: spaced altitude zones, bonuses and irregular local patrols.
local Life={};local movers={};local started=false;local remote
local Players=game:GetService("Players")
local Visuals=require(script.Parent.BrainrotVisuals)
local Patrol=require(script.Parent.SkyPatrol)
local biomes=require(game:GetService("ReplicatedStorage"):WaitForChild("CloudConfig",15)).HeightPresentation.Biomes
local bands={
 {Min=32,Max=145,Count=8,Reach=220,Spread=90,Score=15,Names={"만두 말랑이","왁뿌볼"},Color=Color3.fromRGB(255,225,123)},
 {Min=160,Max=340,Count=12,Reach=350,Spread=110,Score=40,Names={"구구가가","브레인롯","퉁퉁퉁 사후르","왁뿌볼"},Color=Color3.fromRGB(255,134,174)},
 {Min=360,Max=850,Count=30,Reach=600,Spread=140,Score=100,Names={"트랄랄레로 트랄랄라","페비쵸비","발레리나 카푸치나","버섯 말랑이"},Color=Color3.fromRGB(185,127,255)},
 {Min=900,Max=1800,Count=36,Reach=900,Spread=170,Score=250,Names={"왁뿌볼","별사탕 말랑이","퉁퉁퉁 사후르","슬라임 말랑이"},Color=Color3.fromRGB(99,246,255)},
 {Min=1830,Max=3600,Count=30,Reach=1150,Spread=190,Score=250,Names={"꿀벌 말랑이","왁뿌볼","67 밈"},Color=Color3.fromRGB(163,245,222)},
 {Min=3630,Max=7200,Count=36,Reach=1500,Spread=220,Score=250,Names={"별사탕 말랑이","토끼 말랑이","브레인롯"},Color=Color3.fromRGB(185,127,255)},
 {Min=7230,Max=16000,Count=42,Reach=1900,Spread=240,Score=250,Names={"토끼 말랑이","왁뿌볼","67 밈"},Color=Color3.fromRGB(99,246,255)},
}
local function part(m,name,pos,size,color,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Shape=shape or Enum.PartType.Ball
 p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=m;return p
end
local function badge(m,text,color,radius)
 local g=Instance.new("BillboardGui");g.Name="ValueBadge";g.Size=UDim2.fromOffset(220,54);g.StudsOffset=Vector3.new(0,radius+4,0);g.MaxDistance=if m:GetAttribute("SkyKind")=="Enemy" then 140 else 200;g.Parent=m.PrimaryPart
 local l=Instance.new("TextLabel");l.Size=UDim2.fromScale(1,1);l.BackgroundColor3=if m:GetAttribute("SkyKind")=="Enemy" then Color3.fromRGB(61,19,29) else Color3.fromRGB(22,65,51);l.BackgroundTransparency=1;l.Text=text;l.TextColor3=color;l.TextStrokeTransparency=0;l.Font=Enum.Font.GothamBlack;l.TextSize=24;l.Parent=g
end
local function hide(m,hidden)
 if not hidden and m:GetAttribute("PartyEndsAt") and workspace:GetServerTimeNow()>=m:GetAttribute("PartyEndsAt") then hidden=true end
 for _,p in m:GetDescendants() do
  if p:IsA("BasePart") then p.Transparency=if hidden or p:GetAttribute("CollisionProxy") then 1 else 0 elseif p:IsA("BillboardGui") then p.Enabled=not hidden end
 end
end
function Life.Start(frame)
 if started then return end;started=true
 local RS=game:GetService("ReplicatedStorage");remote=RS:FindFirstChild("BarrierDestroyed") or Instance.new("RemoteEvent");remote.Name="BarrierDestroyed";remote.Parent=RS
 local folder=Instance.new("Folder");folder.Name="SkyLife";folder:SetAttribute("Owner","SkyLife");folder.Parent=workspace
 local random=Random.new(672026);local origin=Vector3.new(frame.Origin.X,frame.GroundY,frame.Origin.Z)
 local function at(f,r,y)return origin+frame.Forward*f+frame.Right*r+Vector3.new(0,y,0)end
 local function spawnBand(b,band)
  for i=1,band.Count do
   local name=band.Names[(i-1)%#band.Names+1];local enemy=name=="브레인롯" or name=="67 밈" or name=="퉁퉁퉁 사후르" or name=="트랄랄레로 트랄랄라" or name=="발레리나 카푸치나"
   if enemy and (b==1 or i%6~=0) then name="만두 말랑이";enemy=false end
   local nearLaunch=b==1 and i<=3
   -- Stratified height beats random low-heavy scatter. Three lanes stay near steep flights.
   local slice=math.floor((i-1)/2);local slices=math.ceil(band.Count/2)
   local y=band.Min+(band.Max-band.Min)*(slice+.35+(i%2)*.22)/slices
   local lane=(math.floor((i-1)/2)%3)
   local f=if lane==0 then 25+y*.025 elseif lane==1 then 35+y*.08 else 50+y*.13
   if band.AnchorForward then f=band.AnchorForward+(lane-1)*110 end
   local side=if i%2==0 then 1 else -1
   local pos=at(f+random:NextNumber(-12,12),side*(if enemy then 175 else 32)+random:NextNumber(-12,12),y)
   if nearLaunch then pos=at(random:NextNumber(10,80),random:NextNumber(-45,45),y) end
   if nearLaunch then name="만두 말랑이" end
   local radius=if enemy then 8 else random:NextNumber(17,22)
   local color=if enemy then Color3.fromRGB(55,25,40) elseif string.find(name,"왁뿌") then Color3.fromRGB(240,97,107) elseif string.find(name,"페비") then Color3.fromRGB(255,175,73) else band.Color
   local m=Instance.new("Model");m.Name=name;m:SetAttribute("SkyKind",if enemy then "Enemy" else "Bonus");m:SetAttribute("AltitudeBand",b)
   m:SetAttribute("HitRadius",radius);m:SetAttribute("HazardRadius",if enemy then radius else nil);m:SetAttribute("Score",band.Score);m:SetAttribute("TargetId",b*1000+i)
   m:SetAttribute("MinAltitude",band.Min)
   m.PrimaryPart=part(m,"Body",pos,Vector3.one*radius*2,color)
   for _,s in {-1,1} do
    part(m,"Eye",pos+Vector3.new(s*radius*.38,radius*.15,-radius*.85),Vector3.one*radius*.35,Color3.new(1,1,1))
    part(m,"Pupil",pos+Vector3.new(s*radius*.38,radius*.15,-radius),Vector3.one*radius*.16,Color3.fromRGB(28,34,48))
   end
   if string.find(name,"만두") then
    m.PrimaryPart.Size=Vector3.new(radius*2.3,radius*1.4,radius*1.7)
    for n=-2,2 do part(m,"Fold",pos+Vector3.new(n*radius*.3,radius*.6,0),Vector3.new(radius*.35,radius*.5,radius*.5),Color3.fromRGB(255,249,223)) end
   elseif name=="브레인롯" then
    for n=1,6 do part(m,"BrainLobe",pos+Vector3.new(math.cos(n)*radius*.65,radius*.45,math.sin(n)*radius*.65),Vector3.one*radius*.8,Color3.fromRGB(225,73,144)) end
   elseif string.find(name,"페비") then
    for _,s in {-1,1} do part(m,"Wing",pos+Vector3.new(s*radius*1.3,0,0),Vector3.new(radius*1.6,radius*.4,radius),band.Color) end
   elseif name=="구구가가" then part(m,"Pacifier",pos+Vector3.new(0,-radius*.3,-radius),Vector3.one*radius*.6,Color3.fromRGB(87,224,250)) end
   if string.find(name,"토끼") then
    for _,side in {-1,1} do part(m,"Ear",pos+Vector3.new(side*radius*.4,radius*1.2,0),Vector3.new(radius*.45,radius*1.4,radius*.4),Color3.fromRGB(255,230,235)) end
   elseif string.find(name,"꿀벌") then
    part(m,"Stripe",pos,Vector3.new(radius*2.1,radius*.5,radius*2.1),Color3.fromRGB(59,48,39),Enum.PartType.Block)
    for _,side in {-1,1} do part(m,"Wing",pos+Vector3.new(side*radius, radius*.7,0),Vector3.new(radius*.8,radius*.25,radius*1.2),Color3.fromRGB(216,246,255)) end
   elseif string.find(name,"버섯") then
    part(m,"MushroomCap",pos+Vector3.new(0,radius*.7,0),Vector3.new(radius*2.7,radius*.9,radius*2.5),Color3.fromRGB(156,100,225))
    for n=-1,1 do part(m,"Spot",pos+Vector3.new(n*radius*.7,radius*1.05,-radius*.6),Vector3.one*radius*.35,Color3.new(1,1,1)) end
   elseif string.find(name,"슬라임") then m.PrimaryPart.Size=Vector3.new(radius*2.3,radius*1.3,radius*2.3);m.PrimaryPart.Color=Color3.fromRGB(112,239,156)
   elseif string.find(name,"별사탕") then
    for n=1,5 do local a=n*math.pi*2/5;part(m,"StarPoint",pos+Vector3.new(math.cos(a)*radius,math.sin(a)*radius,0),Vector3.one*radius*.7,Color3.fromRGB(255,235,128)) end
   end
   if enemy then
    Visuals.Apply(m,name,pos,radius)
    for n=1,3 do
     local angle=n*math.pi*2/3;local spike=Instance.new("WedgePart");spike.Name="DangerSpike";spike.Size=Vector3.new(radius*.25,radius*.45,radius*.35)
     spike.CFrame=CFrame.new(pos+Vector3.new(math.cos(angle)*radius*1.25,radius*.5,math.sin(angle)*radius*1.25))*CFrame.Angles(0,-angle,0)
     spike.Color=Color3.fromRGB(255,53,75);spike.Material=Enum.Material.Neon;spike.Anchored=true;spike.CanCollide=false;spike.CanTouch=false;spike.CanQuery=false;spike.Parent=m
    end
    for _,eye in m:GetChildren() do if eye.Name=="Pupil" then eye.Color=Color3.fromRGB(255,53,75) end end
   else
    local star=part(m,"BonusStar",pos+Vector3.new(0,radius+3,0),Vector3.new(4,4,1.2),Color3.fromRGB(255,225,66),Enum.PartType.Block)
    star.CFrame=star.CFrame*CFrame.Angles(0,0,math.pi/4);star.Material=Enum.Material.Neon
   end
   badge(m,if enemy then "⚠" else "+"..band.Score.."점",if enemy then Color3.fromRGB(255,98,112) else Color3.fromRGB(255,238,105),radius)
   m.Parent=folder;table.insert(movers,{Model=m,Origin=pos,Center=pos,Phase=random:NextNumber(0,6.28),Enemy=enemy,AcquiredAt=0})
  end
  local islandCount=if b==1 then 1 elseif b<=4 then 2 else 3
  for i=1,islandCount do
   local baseHeight=if b==1 then 96 else band.Min+36
   local y=baseHeight+(band.Max-band.Min-36)*(i-1)/islandCount
   local lane=(i-1)%3;local f=if lane==0 then 30+y*.025 elseif lane==1 then 35+y*.08 else 50+y*.13
   if band.AnchorForward then f=band.AnchorForward+(lane-1)*110 end
   local pos=at(f+95,(-1)^i*115,y)
   local m=Instance.new("Model");m.Name="하늘섬";m:SetAttribute("SkyKind","Island");m:SetAttribute("AltitudeBand",b);m:SetAttribute("HitRadius",21);m:SetAttribute("HitBoxSize",Vector3.new(120,64,90));m:SetAttribute("Score",band.Score*4);m:SetAttribute("TargetId",b*1000+100+i)
   m.PrimaryPart=part(m,"Body",pos,Vector3.new(120,64,90),Color3.fromRGB(111,111,123),Enum.PartType.Block)
   m.PrimaryPart.Transparency=1;m.PrimaryPart:SetAttribute("CollisionProxy",true)
   local definition=biomes[1]
   for _,region in biomes do if y>=region.Min then definition=region end end
   local candy={Color3.fromRGB(table.unpack(definition.Color)),Color3.fromRGB(table.unpack(definition.Rock)),Color3.fromRGB(235,244,255)}
   m:SetAttribute("Biome",definition.Kind)
   for row=0,2 do for column=0,5 do for depth=0,1 do
    local p=part(m,"Brick",pos+Vector3.new((column-2.5)*20,(row-1)*21,(depth-.5)*44),Vector3.new(17,17,38),candy[(row+column+b)%3+1],Enum.PartType.Block)
    p.Material=Enum.Material.SmoothPlastic
   end end end
   for column=0,5 do part(m,"ToyStud",pos+Vector3.new((column-2.5)*20,32,0),Vector3.new(9,6,9),candy[(column+b)%3+1]) end
   part(m,"BreakCore",pos+Vector3.new(0,-32,0),Vector3.new(22,7,22),Color3.fromRGB(255,241,92)).Material=Enum.Material.Neon
   m.Name="하늘 보너스 블록"
   badge(m,"+"..(band.Score*4).."점",Color3.fromRGB(255,241,92),36);m.Parent=folder
  end
 end
 for b,band in bands do spawnBand(b,band) end
 local streamed={}
 local groundTiles={}
 for i=1,1 do
  local pos=at(650,210,1200);local m=Instance.new("Model");m.Name="하늘 버스";m:SetAttribute("SkyKind","Enemy");m:SetAttribute("HazardRadius",13);m:SetAttribute("HitRadius",13)
  m.PrimaryPart=part(m,"Body",pos,Vector3.new(17,12,38),Color3.fromRGB(255,196,54),Enum.PartType.Block)
  for n=-1,1 do part(m,"Window",pos+Vector3.new(0,2,n*11),Vector3.new(17.2,6,7),Color3.fromRGB(100,214,255),Enum.PartType.Block) end
  m.PrimaryPart.Color=Color3.fromRGB(55,25,40)
  for _,v in m:GetChildren() do if v.Name=="Window" then v.Color=Color3.fromRGB(255,53,75);v.Material=Enum.Material.Neon end end
  badge(m,"⚠",Color3.fromRGB(255,98,112),15);m.Parent=folder;table.insert(movers,{Model=m,Origin=pos,Center=pos,Phase=i,Bus=true})
 end
 for i=1,18 do
  local m=Instance.new("Model");m.Name="CloudCluster";m:SetAttribute("SkyKind","Decoration");m.Parent=folder;local center=at(random:NextNumber(-100,1100),(i%2==0 and 1 or -1)*random:NextNumber(1000,1300),150+(i%5)*135)
  for n=-1,1 do part(m,"Cloud",center+Vector3.new(n*19,0,0),Vector3.new(45,10,26),Color3.fromRGB(245,248,255)).Transparency=.45 end
 end
 for i=1,3 do
  local m=Instance.new("Model");m.Name="SkyPlanet";m:SetAttribute("SkyKind","Decoration");m.Parent=folder
  local pos=at(320+i*190,(-1)^i*1300,100000+i*1200)
  part(m,"Planet",pos,Vector3.one*(70+i*25),bands[4].Color)
  for n=1,12 do local a=n*math.pi/6;part(m,"Orbit",pos+Vector3.new(math.cos(a)*90,math.sin(a)*22,math.sin(a)*90),Vector3.one*8,bands[3].Color).Material=Enum.Material.Neon end
 end
 -- Seven reusable dumplings; new event ids prevent old runs farming a recycled wave.
 local party={};local template=folder:FindFirstChild("만두 말랑이")
 if template then for i=1,7 do
  local m=template:Clone();m.Name="만두 말랑이 파티"..i;m:SetAttribute("HitRadius",24);m:SetAttribute("Score",15)
  m:SetAttribute("PartyGroup",1);m:SetAttribute("PartyEndsAt",0);m:SetAttribute("AvailableAt",math.huge)
  local g=m.PrimaryPart:FindFirstChild("ValueBadge");if g then g:Destroy() end
  if i==1 then badge(m,"만두 파티! 하나 맞추면 7연쇄",Color3.fromRGB(255,241,92),24) end
  m.Parent=folder;hide(m,true)
  local o={Model=m,Origin=origin,Center=origin,Phase=i,Party=true};table.insert(movers,o);table.insert(party,o)
 end end
 local nextParty=workspace:GetServerTimeNow()+5;local wave=0;local partyEnd=0
 local elapsed=0
 game:GetService("RunService").Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.1 then return end;local step=math.min(elapsed,.25);elapsed=0;local now=workspace:GetServerTimeNow()
  if now>=nextParty and #party>0 then
   wave+=1;nextParty=now+40;partyEnd=now+20
   local center=at(14,if wave%2==0 then -12 else 12,100)
   local highest=0
   for _,p in Players:GetPlayers() do
    local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if root and p:GetAttribute("FlightState")=="Flying" and root.Position.Y-origin.Y>highest then
     highest=root.Position.Y-origin.Y
     center=root.Position+frame.Forward*24+frame.Right*(if wave%2==0 then -18 else 18)+Vector3.new(0,if root.AssemblyLinearVelocity.Y>0 then 60 else -35,0)
    end
   end
   for i,o in party do
    local angle=(i-1)*math.pi/3
    o.Origin=center+Vector3.new(math.cos(angle)*9,math.sin(angle)*7,(i%3-1)*6);o.Center=o.Origin
    o.Model:SetAttribute("TargetId",100000+wave*10+i);o.Model:SetAttribute("AvailableAt",0);o.Model:SetAttribute("PartyEndsAt",partyEnd)
    hide(o.Model,false)
   end
  end
  local roots={};local wanted={}
  for _,p in Players:GetPlayers() do
   local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
   if root then
    table.insert(roots,root)
    if p:GetAttribute("FlightState")=="Flying" and root.Position.Y-origin.Y>=14000 then
     local section=math.floor((root.Position.Y-origin.Y-16000)/2000)
     for index=math.max(0,section-1),math.min(71,section+1) do
      local center=17000+index*2000;local estimate=math.clamp((center-root.Position.Y)/math.max(100,math.abs(root.AssemblyLinearVelocity.Y)),-2,6)
      wanted[index]=(root.Position-origin):Dot(frame.Forward)+root.AssemblyLinearVelocity:Dot(frame.Forward)*estimate
     end
    end
   end
  end
  for index,forward in wanted do if not streamed[index] then
   local band={Min=16030+index*2000,Max=17980+index*2000,Count=18,Reach=2000,Spread=240,Score=250,
    Names={"토끼 말랑이","퉁퉁퉁 사후르","별사탕 말랑이","트랄랄레로 트랄랄라","버섯 말랑이","발레리나 카푸치나"},Color=Color3.fromRGB(164,223,255),AnchorForward=forward}
   spawnBand(8+index,band);streamed[index]=true
  end end
  -- Extend the existing grass datum under long flights; no new launch station or field mechanic.
  local groundWanted={}
  for _,root in roots do if root.Position.Y-origin.Y<6000 then
   local center=root.Position+Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z)*1.5
   local gx,gz=math.floor(center.X/1024),math.floor(center.Z/1024)
   for x=gx-1,gx+1 do for z=gz-1,gz+1 do
    local key=x..":"..z;groundWanted[key]=true
    if not groundTiles[key] then
     local tile=part(folder,"ExtendedMeadow",Vector3.new((x+.5)*1024,frame.GroundY-6.15,(z+.5)*1024),Vector3.new(1024,12,1024),Color3.fromRGB(108,176,106),Enum.PartType.Block)
     tile.Material=Enum.Material.Grass;tile.CanCollide=true;tile.CanQuery=true;groundTiles[key]=tile
    end
   end end
  end end
  for key,tile in groundTiles do if not groundWanted[key] then tile:Destroy();groundTiles[key]=nil end end
  local removed=false
  for index in streamed do if not wanted[index] then
   for _,m in folder:GetChildren() do if m:GetAttribute("AltitudeBand")==8+index then m:Destroy() end end
   streamed[index]=nil;removed=true
  end end
  if removed then for i=#movers,1,-1 do if not movers[i].Model.Parent then table.remove(movers,i) end end end
  for _,o in movers do
   if not o.Model.Parent then continue end
   if o.Party and now>=partyEnd then hide(o.Model,true);o.Model:SetAttribute("AvailableAt",math.huge);continue end
   local active=false;for _,root in roots do if math.abs(root.Position.Y-o.Origin.Y)<1000 then active=true;break end end
   if not active then o.Model:SetAttribute("PreviousCenter",nil);o.Model:SetAttribute("Targeted",false);o.Model:SetAttribute("Attacking",false);continue end
   local a=now*.5+o.Phase;local center=o.Origin+Vector3.new(math.sin(a)*12,math.cos(a*.7)*4,math.cos(a)*10)
   if o.Enemy or o.Bus then
    if not o.Patrol then o.Patrol=Patrol.New(o.Origin,o.Phase) end
    center=Patrol.Step(o.Patrol,step,now)
    -- Contact hazards stay in their altitude pocket, independent of player direction/speed.
    o.Model:SetAttribute("Targeted",false);o.Model:SetAttribute("Attacking",false)
   end
   o.Model:SetAttribute("PreviousCenter",o.Center)
   local delta=center-o.Center;local planar=Vector3.new(delta.X,0,delta.Z)
   if planar.Magnitude>.05 then
    local target=math.atan2(-planar.X,-planar.Z);local yaw=o.Yaw or target
    local change=math.atan2(math.sin(target-yaw),math.cos(target-yaw))
    o.Yaw=yaw+change*math.min(1,step*5)
   end
   o.Center=center;o.Model:PivotTo(CFrame.new(center)*CFrame.Angles(0,o.Yaw or 0,0))
  end
 end)
end
local function touches(m,from,to,radius)
 if not m:IsA("Model") or not m.PrimaryPart then return false end
 local box=m:GetAttribute("HitBoxSize")
 if box then
  local origin=m.PrimaryPart.CFrame:PointToObjectSpace(from);local finish=m.PrimaryPart.CFrame:PointToObjectSpace(to)
  local delta=finish-origin;local extent=box/2+Vector3.one*2.5;local low,high=0,1
  for _,axis in {"X","Y","Z"} do
   if math.abs(delta[axis])<.0001 then if math.abs(origin[axis])>extent[axis] then return false end
   else local a=(-extent[axis]-origin[axis])/delta[axis];local b=(extent[axis]-origin[axis])/delta[axis]
    low=math.max(low,math.min(a,b));high=math.min(high,math.max(a,b));if low>high then return false end
   end
  end
  return true
 end
 local center=m.PrimaryPart.Position;local d=to-from;local len=d:Dot(d);local t=if len>0 then math.clamp((center-from):Dot(d)/len,0,1) else 0
 return (from+d*t-center).Magnitude<radius+2.5
end
function Life.Hit(from,to)
 local folder=workspace:FindFirstChild("SkyLife");if not folder then return nil end
 for _,m in folder:GetChildren() do
  local r=m:GetAttribute("HazardRadius")
  if r and (m:GetAttribute("AvailableAt") or 0)<=workspace:GetServerTimeNow() and m:IsA("Model") and m.PrimaryPart then
   local previous=m:GetAttribute("PreviousCenter");local start=from
   if previous and (m.PrimaryPart.Position-previous).Magnitude<40 then start=from+(m.PrimaryPart.Position-previous) end
   if touches(m,start,to,r) then return m.Name,m end
  end
 end
 return nil
end
function Life.Collect(player,from,to,visited)
 local folder=workspace:FindFirstChild("SkyLife");if not folder then return 0 end
 local now=workspace:GetServerTimeNow();local score=0
 local partyHit=false
 for _,m in folder:GetChildren() do
  local id=m:GetAttribute("TargetId")
  if m:GetAttribute("PartyGroup") and id and not visited[id] and (m:GetAttribute("AvailableAt") or 0)<=now
   and (m:GetAttribute("PartyEndsAt") or 0)>now and touches(m,from,to,m:GetAttribute("HitRadius") or 18) then partyHit=true;break end
 end
 for _,m in folder:GetChildren() do
  local kind=m:GetAttribute("SkyKind");local id=m:GetAttribute("TargetId");local r=m:GetAttribute("HitRadius")
  if (kind~="Bonus" and kind~="Island") or not id or visited[id] or (m:GetAttribute("AvailableAt") or 0)>now then continue end
  if not r or (not (partyHit and m:GetAttribute("PartyGroup")) and not touches(m,from,to,r)) then continue end
  visited[id]=true;local award=m:GetAttribute("Score") or 0;score+=award;m:SetAttribute("AvailableAt",now+12)
  local cells={};for _,p in m:GetChildren() do if p:IsA("BasePart") and not p:GetAttribute("CollisionProxy") then table.insert(cells,{Position=p.Position,Size=p.Size,Color=p.Color}) end end
  hide(m,true);local running=(player:GetAttribute("DestructionRunScore") or 0)+score
  local character=player.Character;local runToken=visited
  for i,cell in cells do
   task.delay((i-1)*.018,function()
    if player.Parent==Players and player.Character==character and player:GetAttribute("FlightState")=="Flying" and player:GetAttribute("SkyRunSerial")==runToken.serial then
     remote:FireClient(player,{Position=cell.Position,Size=cell.Size,Color=cell.Color,MaterialTag=if kind=="Island" then "FloatingIsland" else "Slime",Index=i,RunScore=running,Award=if i==1 then award else 0})
    end
   end)
  end
  task.delay(12,function()if m.Parent then hide(m,false) end end)
 end
 return score
end
function Life.BreakEnemy(player,m,visited)
 if not m or not m.Parent or m:GetAttribute("SkyKind")~="Enemy" then return 0 end
 local now=workspace:GetServerTimeNow();if (m:GetAttribute("AvailableAt") or 0)>now or visited[m] then return 0 end
 visited[m]=true;m:SetAttribute("AvailableAt",now+12);hide(m,true)
 local score=120;remote:FireClient(player,{Position=m.PrimaryPart.Position,Size=Vector3.one*35,Color=Color3.fromRGB(255,197,64),MaterialTag="Ruin",Index=1,Award=score,Pierce=true,Character=player.Character,RunId=visited.serial})
 task.delay(12,function()if m.Parent then hide(m,false) end end);return score
end
return Life
