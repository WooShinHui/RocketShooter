-- Local scenery has no collision or reward role. Fixed cells are recycled around flight.
local player=game.Players.LocalPlayer
local Config=require(game.ReplicatedStorage:WaitForChild("CloudConfig",15)).HeightPresentation
local folder=Instance.new("Folder");folder.Name="AltitudeLandscape";folder.Parent=workspace
local cells={};local elapsed=0
local function part(parent,name,pos,size,color,material,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Color=color
 p.Material=material or Enum.Material.Slate;p.Shape=Enum.PartType.Block;p.Anchored=true
 if shape==Enum.PartType.Ball then local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p end
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Position=pos;p.Parent=parent;return p
end
local function build(key,center,region,seed)
 local m=Instance.new("Model");m.Name=region.Kind.."Landscape";m:SetAttribute("Biome",region.Kind);m:SetAttribute("SkyKind","Decoration")
 local rng=Random.new(seed);local color=Color3.fromRGB(table.unpack(region.Color));local rock=Color3.fromRGB(table.unpack(region.Rock))
 for side=-1,1,2 do
  local pos=center+Vector3.new(side*rng:NextNumber(900,1100),rng:NextNumber(-30,30),rng:NextNumber(-100,100))
  if region.Kind=="Orbit" then
   part(m,"OrbitalHull",pos,Vector3.new(42,18,26),rock,Enum.Material.Metal)
   for wing=-1,1,2 do
    part(m,"SolarPanel",pos+Vector3.new(wing*58,0,0),Vector3.new(65,2,42),Color3.fromRGB(39,99,171),Enum.Material.Metal)
    part(m,"PanelRail",pos+Vector3.new(wing*58,2,0),Vector3.new(65,2,3),color,Enum.Material.Neon)
   end
   part(m,"Beacon",pos+Vector3.new(0,20,0),Vector3.new(8,22,8),color,Enum.Material.Neon)
  elseif region.Kind=="Space" then
   for n=1,4 do
    local asteroid=part(m,"Asteroid",pos+Vector3.new(rng:NextNumber(-90,90),rng:NextNumber(-70,70),rng:NextNumber(-90,90)),Vector3.new(60+n*12,42+n*8,55+n*9),rock,Enum.Material.Slate,Enum.PartType.Ball)
    asteroid.CFrame*=CFrame.Angles(rng:NextNumber(0,3),rng:NextNumber(0,3),rng:NextNumber(0,3))
    part(m,"Ore",asteroid.Position+Vector3.new(0,asteroid.Size.Y*.4,0),Vector3.new(12,17,12),color,Enum.Material.Neon)
   end
  else
   part(m,"FloatingRock",pos,Vector3.new(165,62,125),rock,Enum.Material.Slate,Enum.PartType.Ball)
   local material=if region.Kind=="Snow" then Enum.Material.Snow elseif region.Kind=="Cloud" then Enum.Material.Grass else Enum.Material.Slate
   part(m,"Surface",pos+Vector3.new(0,26,0),Vector3.new(158,15,118),color,material,Enum.PartType.Ball)
   if region.Kind=="Cloud" then
    for n=-1,1 do
     part(m,"CloudBank",pos+Vector3.new(n*55,-35,15),Vector3.new(130,28,90),Color3.fromRGB(243,250,255),Enum.Material.SmoothPlastic,Enum.PartType.Ball).Transparency=.25
    end
    for n=-1,1 do
     part(m,"Tree",pos+Vector3.new(n*43,43,0),Vector3.new(6,34,6),rock,Enum.Material.Wood)
     part(m,"Canopy",pos+Vector3.new(n*43,64,0),Vector3.new(35,40,35),Color3.fromRGB(69,184,146),Enum.Material.Grass,Enum.PartType.Ball)
    end
   elseif region.Kind=="Snow" then
    for n=-1,1 do
     part(m,"IceSpire",pos+Vector3.new(n*42,62,n*15),Vector3.new(24,90,24),Color3.fromRGB(133,219,250),Enum.Material.Ice).CFrame*=CFrame.Angles(0,0,n*.18)
    end
   elseif region.Kind=="Crystal" then
    for n=-1,1 do
     part(m,"CrystalSpire",pos+Vector3.new(n*45,60,n*22),Vector3.new(22,80+n*15,22),color,Enum.Material.Neon).CFrame*=CFrame.Angles(0,.5,n*.25)
    end
   elseif region.Kind=="Storm" then
    for n=-1,1 do part(m,"StormCloud",pos+Vector3.new(n*60,58,0),Vector3.new(130,38,85),rock,Enum.Material.SmoothPlastic,Enum.PartType.Ball) end
    for n=1,3 do part(m,"Lightning",pos+Vector3.new((n%2)*12,45-n*24,-60),Vector3.new(4,31,4),color,Enum.Material.Neon).CFrame*=CFrame.Angles(0,0,(-1)^n*.4) end
   elseif region.Kind=="Ember" then
    for n=-1,1 do part(m,"CopperSpire",pos+Vector3.new(n*42,68,n*15),Vector3.new(35,100,35),rock,Enum.Material.Sandstone).CFrame*=CFrame.Angles(0,0,n*.2) end
    part(m,"EmberSeam",pos+Vector3.new(0,38,0),Vector3.new(105,3,9),color,Enum.Material.Neon)
   end
  end
 end
 m.Parent=folder;return m
end
local function clear()
 for key,m in cells do m:Destroy();cells[key]=nil end
end
player.CharacterRemoving:Connect(clear)
game:GetService("RunService").Heartbeat:Connect(function(dt)
 elapsed+=dt;if elapsed<.15 then return end;elapsed=0
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not root or player:GetAttribute("FlightState")~="Flying" then clear();return end
 local height=root.Position.Y-Config.GroundY;local wanted={}
 -- Vertical cells remain stationary. Adjacent region cells coexist at boundaries.
 for biome,region in Config.Biomes do
  if biome==1 then continue end
  local spacing=region.Spacing
  local top=Config.Biomes[biome+1] and Config.Biomes[biome+1].Min or 180000
  if height<region.Min-spacing or height>top+spacing then continue end
  local index=math.floor((height-region.Min)/spacing)
  local gx,gz=math.floor(root.Position.X/600),math.floor(root.Position.Z/600)
  for level=index-1,index+1 do
   local y=region.Min+(level+.5)*spacing
   if y<region.Min or y>=top then continue end
   for z=gz,gz do
    local key=biome..":"..level..":"..gx..":"..z;wanted[key]=true
    if not cells[key] then cells[key]=build(key,Vector3.new((gx+.5)*600,y,(z+.5)*600),region,math.abs((level*571+gx*137+z*97+biome*31)%1000000)) end
   end
  end
 end
 for key,m in cells do if not wanted[key] then m:Destroy();cells[key]=nil end end
end)
