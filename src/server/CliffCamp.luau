local RS=game:GetService("ReplicatedStorage")
local C=require(RS:WaitForChild("ProgressionConfig",15))
local Camp={}
local function part(parent,name,size,position,color,material,shape)
	local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=position
	p.Anchored=true;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
	if shape then p.Shape=shape end
	p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
	return p
end
local function sign(parent,text,pos,width,color)
	local post=part(parent,"Sign",Vector3.new(width or 28,6,1),pos,color or Color3.fromRGB(31,54,76))
	post.CanCollide=false
	local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Back;gui.CanvasSize=Vector2.new(800,170);gui.Parent=post
	local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1
	label.Text=text;label.TextColor3=Color3.new(1,1,1);label.TextScaled=true;label.Font=Enum.Font.GothamBlack;label.Parent=gui
	return post
end
function Camp.Start(frame)
	if workspace:FindFirstChild("CliffCamp") then return end
	local folder=Instance.new("Folder");folder.Name="CliffCamp";folder:SetAttribute("Owner","CliffCamp");folder.Parent=workspace
	local archive=Instance.new("Folder");archive.Name="CliffMapArchive";archive.Parent=game.ServerStorage
	-- Runtime-only archive: saved Studio originals survive Stop and can be restored.
	local base=workspace:FindFirstChild("Baseplate");if base then base.Parent=archive end
	local old=workspace:FindFirstChild("DestructionSpikeBarriers");if old then old.Parent=archive end
	local oldFuel=workspace:FindFirstChild("FuelStation");if oldFuel then oldFuel.Parent=archive end
    local origin=Vector3.new(frame.Origin.X,0,frame.Origin.Z)
	local function at(forward,right,y)return origin+frame.Forward*forward+frame.Right*right+Vector3.new(0,y,0)end
	local grass=Color3.fromRGB(97,166,88);local rock=Color3.fromRGB(74,90,105)
	part(folder,"LaunchHill",Vector3.new(220,16,240),at(-80,0,-2.5),grass,Enum.Material.Grass)
	-- Ground surface at zero: ascend from a small clearing, without a deep valley drop.
	part(folder,"Meadow",Vector3.new(3600,12,3600),at(800,0,-6),Color3.fromRGB(108,176,106),Enum.Material.Grass)
	part(folder,"CampPath",Vector3.new(80,.2,85),at(-145,0,5.6),Color3.fromRGB(222,201,156),Enum.Material.Sand)
	local random=Random.new(102026)
	for i=1,32 do
		local center=at(random:NextNumber(-210,80),if i%2==0 then random:NextNumber(145,235) else random:NextNumber(-235,-145),0)
		part(folder,"MeadowBush",Vector3.new(9,6,9),center+Vector3.new(0,2,0),Color3.fromRGB(60,146,91),Enum.Material.Grass,Enum.PartType.Ball)
		for n=1,3 do part(folder,"Flower",Vector3.new(1.2,1.2,1.2),center+Vector3.new(n*2,4,(n%2)*3),if i%3==0 then Color3.fromRGB(255,194,222) else Color3.fromRGB(255,226,87),nil,Enum.PartType.Ball).CanCollide=false end
	end
	part(folder,"PondSand",Vector3.new(65,.5,48),at(-230,160,.25),Color3.fromRGB(218,201,151),Enum.Material.Sand)
	local water=part(folder,"Pond",Vector3.new(57,.4,40),at(-230,160,.6),Color3.fromRGB(93,201,227),Enum.Material.Glass);water.Transparency=.3
    -- A distant mountain range in the cannon's forward view. Scenery never blocks flight.
    local horizon=Instance.new("Model");horizon.Name="HorizonRange"
    horizon.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;horizon.Parent=folder
    for i=1,9 do
        local height=420+(i%4)*160
        local center=at(2400+math.abs(i-5)*135,(i-5)*340,height/2-25)
        for _,side in {-1,1} do
            local peak=Instance.new("WedgePart");peak.Name="HorizonMountain";peak.Size=Vector3.new(360,height,400)
            local rotation=CFrame.fromMatrix(Vector3.zero,frame.Forward,Vector3.yAxis)*CFrame.Angles(0,if side==1 then math.pi else 0,0)
            peak.CFrame=CFrame.new(center+frame.Right*(side*200))*rotation
            peak.Anchored=true;peak.CanCollide=false;peak.CanTouch=false;peak.CanQuery=false
            peak.Material=Enum.Material.Slate;peak.Color=Color3.fromRGB(91+i%3*12,122+i%3*10,142+i%3*9);peak.Parent=horizon
            local snow=peak:Clone();snow.Name="MountainSnow";snow.Size=Vector3.new(365,height*.22,90)
            snow.CFrame=CFrame.new(center+frame.Right*(side*45)+Vector3.new(0,height*.39,0))*rotation;snow.Color=Color3.fromRGB(222,239,248);snow.Material=Enum.Material.Snow;snow.Parent=horizon
        end
    end
	for i=1,12 do
		local center=at(-175+(i%4)*45,if i%2==0 then -102 else 102,7)
		part(folder,"TreeTrunk",Vector3.new(3,14,3),center+Vector3.new(0,7,0),Color3.fromRGB(108,76,50),Enum.Material.Wood)
		part(folder,"TreeCrown",Vector3.new(17,21,17),center+Vector3.new(0,19,0),Color3.fromRGB(50,139,94),Enum.Material.Grass,Enum.PartType.Ball)
	end
	sign(folder,"SKYBOUND ↑",at(-65,0,19),46)
	sign(folder,"변기에 앉기 → 추진력 성장\n레벨 20 환생 → 다음 변기 도전",at(-135,-35,24),56,Color3.fromRGB(51,155,255))
    local stations=Instance.new("Folder");stations.Name="TrainingStations";stations.Parent=folder
	for i,t in C.Tiers do
		local m=Instance.new("Model");m.Name="Toilet"..i;m:SetAttribute("TrainingTier",i);m.Parent=stations
		local center=at(-90-(math.floor((i-1)/4))*42,-65+((i-1)%4)*40,7)
		part(m,"Base",Vector3.new(17,2,21),center,t.Color,Enum.Material.Metal)
		local belt=part(m,"Belt",Vector3.new(13,1,16),center+Vector3.new(0,1.5,0),t.Color)
		belt.Transparency=1;belt.CanCollide=false
		belt:SetAttribute("TrainingTier",i)
		part(m,"Bowl",Vector3.new(7,4,9),center+Vector3.new(0,2,0),t.Color,nil,Enum.PartType.Ball)
		part(m,"Tank",Vector3.new(7,8,3),center+Vector3.new(0,4,-5),t.Color)
		local seat=Instance.new("Seat");seat.Name="ToiletSeat";seat.Size=Vector3.new(6,1,6);seat.Position=center+Vector3.new(0,4,0);seat.Anchored=true;seat.Color=Color3.fromRGB(255,248,229);seat.Parent=m
		part(m,"SeatOpening",Vector3.new(3,.1,3),center+Vector3.new(0,4.55,0),Color3.fromRGB(52,61,80))
		part(m,"Flush",Vector3.new(1.5,1,1),center+Vector3.new(4,6,-5),Color3.fromRGB(244,245,251))
		-- Food prop echoes the existing AFK food-growth brief without copying third-party assets.
		part(m,"FoodTable",Vector3.new(4,1,4),center+Vector3.new(11,4,0),t.Color)
		part(m,"DumplingSnack",Vector3.new(2,1.4,2),center+Vector3.new(11,5,0),Color3.fromRGB(255,226,165),nil,Enum.PartType.Ball)
		part(m,"FoodBurger",Vector3.new(2.3,1.5,2.3),center+Vector3.new(11,5,2),Color3.fromRGB(214,145,67),nil,Enum.PartType.Ball)
		sign(m,string.format("%s 변기 · 수련 %s배\n레벨 %d · 환생 %d회 · 트로피 %d 필요",t.Name,tostring(t.Rate),t.Level,t.Rebirths or 0,t.Cost),center+Vector3.new(0,15,-9),30,t.Color)
	end
	local pads=Instance.new("Folder");pads.Name="TrophyPads";pads.Parent=folder
	for i,p in C.TrophyPads do
		local center=at(-175,-75+(i-1)*30,6)
		local tile=part(pads,"Pad"..i,Vector3.new(24,1,24),center,p.Color,Enum.Material.Neon)
		tile:SetAttribute("RequiredTrophies",p.Required);tile:SetAttribute("XPMultiplier",p.Multiplier)
		sign(pads,string.format("수련 경험치 %s배\n트로피 %d 보유 필요",p.Multiplier,p.Required),center+Vector3.new(0,8,-10),24,p.Color)
	end
	return folder
end
return Camp
