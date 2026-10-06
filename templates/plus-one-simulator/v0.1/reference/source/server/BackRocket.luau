local Styles=require(game:GetService("ReplicatedStorage"):WaitForChild("RocketStyles"))
local Trails=require(game:GetService("ReplicatedStorage"):WaitForChild("RocketTrailCatalog"))
local Shapes=require(script.Parent.RocketShapes)
local Rocket={}
function Rocket.Attach(character,styleId,trailId)
 local torso=character:FindFirstChild("UpperTorso")or character:FindFirstChild("Torso")
 if not torso or character:FindFirstChild("BackRocket")then return end
 local style=Styles[styleId]or Styles.Starter
 local trail=Trails.Find(trailId)
 local m=Instance.new("Model");m.Name="BackRocket";m:SetAttribute("Trail",trail.Id);m:SetAttribute("Style",Styles[styleId]and styleId or "Starter")
 local function part(name,size,offset,color,shape)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Color=color;p.Shape=shape or Enum.PartType.Block
  p.Material=Enum.Material.SmoothPlastic;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true
  p.CFrame=torso.CFrame*offset;p.Parent=m
  local weld=Instance.new("WeldConstraint");weld.Part0=torso;weld.Part1=p;weld.Parent=p
  return p
 end
 part("Harness",Vector3.new(1.9,1.8,.35),CFrame.new(0,0,.7),Color3.fromRGB(35,45,65))
 local core=part("EngineCore",Vector3.new(.35,1.3,.35),CFrame.new(0,0,1),style.Accent);core.Material=Enum.Material.Neon
 local custom=Shapes.Build(part,style)
 if style.Kind=="Mala"then
  part("MalaPot",Vector3.new(1.2,3.9,3.9),CFrame.new(0,.35,1.7)*CFrame.Angles(0,0,math.pi/2),style.Body,Enum.PartType.Cylinder)
  part("PotRim",Vector3.new(.16,4.1,4.1),CFrame.new(0,.96,1.7)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(50,53,59),Enum.PartType.Cylinder)
  part("SpicySoup",Vector3.new(.13,3.65,3.65),CFrame.new(0,1.02,1.7)*CFrame.Angles(0,0,math.pi/2),style.Accent,Enum.PartType.Cylinder)
  for i=1,8 do
   local x=math.cos(i*2.3)*1.2;local z=1.7+math.sin(i*2.3)*1.2
   part("Noodles",Vector3.new(.18,.18,1.1),CFrame.new(x,1.16,z)*CFrame.Angles(0,i*.9,0),Color3.fromRGB(255,224,158))
   if i%2==0 then part("SoupIngredient",Vector3.new(.5,.35,.55),CFrame.new(x,1.32,z),if i%4==0 then Color3.fromRGB(61,160,61)else Color3.fromRGB(220,72,43),Enum.PartType.Ball)end
  end
  for _,x in {1.15,1.4}do part("Chopstick",Vector3.new(.12,2.8,.12),CFrame.new(x,2.15,2.5)*CFrame.Angles(0,0,-.25),Color3.fromRGB(105,63,33))end
 end
 for _,x in {-.7,.7}do
  if style.Kind=="Bat"then
   part("BatBarrel",Vector3.new(3.5,.95,.95),CFrame.new(x,1.05,1.25)*CFrame.Angles(0,0,math.pi/2),style.Body,Enum.PartType.Cylinder)
   part("BatCap",Vector3.one*.95,CFrame.new(x,2.78,1.25),style.Body,Enum.PartType.Ball)
   part("BatGrip",Vector3.new(1.6,.32,.32),CFrame.new(x,-1.5,1.25)*CFrame.Angles(0,0,math.pi/2),style.Accent,Enum.PartType.Cylinder)
  elseif style.Kind~="Mala"and not custom then
  part("RocketBody",Vector3.new(3,1.05,1.05),CFrame.new(x,.15,1.25)*CFrame.Angles(0,0,math.pi/2),style.Body,Enum.PartType.Cylinder)
  part("NoseCone",Vector3.new(.95,1.3,.95),CFrame.new(x,1.85,1.25),style.Accent,Enum.PartType.Ball)
  part("Trim",Vector3.new(.22,1.12,1.12),CFrame.new(x,.8,1.25)*CFrame.Angles(0,0,math.pi/2),style.Accent,Enum.PartType.Cylinder)
  for _,side in {-1,1}do part("StabilizerFin",Vector3.new(.45,.9,.22),CFrame.new(x+side*.6,-.9,1.25)*CFrame.Angles(0,0,side*.3),style.Accent)end
  end
  local nozzleY=if style.Kind=="Bat"then -2.5 else -1.45
  local nozzle=part("Nozzle",Vector3.new(.5,.85,.85),CFrame.new(x,nozzleY,1.25)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(34,40,50),Enum.PartType.Cylinder)
  local glow=part("NozzleGlow",Vector3.new(.08,.65,.65),CFrame.new(x,nozzleY-.27,1.25)*CFrame.Angles(0,0,math.pi/2),style.Flame,Enum.PartType.Cylinder);glow.Material=Enum.Material.Neon
  local a=Instance.new("Attachment");a.Name="Exhaust";a.CFrame=CFrame.new(-.25,0,0)*CFrame.Angles(0,0,-math.pi/2);a.Parent=nozzle
  local b=Instance.new("Attachment");b.Name="FlameTip";b.CFrame=a.CFrame*CFrame.new(0,-1,0);b.Parent=nozzle
  local beam=Instance.new("Beam");beam.Name="EnginePlume";beam.Attachment0=a;beam.Attachment1=b;beam.Enabled=false;beam.FaceCamera=true;beam.Width0=.7;beam.Width1=.05
  beam.Color=ColorSequence.new(Color3.new(1,1,1),style.Flame);beam.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.05),NumberSequenceKeypoint.new(.5,.15),NumberSequenceKeypoint.new(1,1)});beam.LightEmission=1;beam.Parent=a
  local fire=Instance.new("ParticleEmitter");fire.Name="RocketFlame";fire.Texture="rbxasset://textures/particles/fire_main.dds";fire.Enabled=false;fire.Rate=120;fire.Lifetime=NumberRange.new(.12,.3);fire.Speed=NumberRange.new(10,20)
  fire.EmissionDirection=Enum.NormalId.Bottom;fire.SpreadAngle=Vector2.new(5,5);fire.LightEmission=1;fire.Color=ColorSequence.new(Color3.new(1,1,1),style.Flame);fire.Size=NumberSequence.new(1.1,0);fire.Parent=a
  local smoke=Instance.new("ParticleEmitter");smoke.Name="ExhaustSmoke";smoke.Texture="rbxasset://textures/particles/smoke_main.dds";smoke.Enabled=false;smoke.Rate=20;smoke.Lifetime=NumberRange.new(.35,.6);smoke.Speed=NumberRange.new(8,16);smoke.EmissionDirection=Enum.NormalId.Bottom;smoke.Color=ColorSequence.new(Color3.fromRGB(190,202,220));smoke.Size=NumberSequence.new(1.2,3);smoke.Transparency=NumberSequence.new(.7,1);smoke.Parent=a
  if trail.Id~="None"then
   local a0=Instance.new("Attachment");a0.Name="TrailEdge0";a0.Position=Vector3.new(-.25,0,-trail.Width/2);a0.Parent=nozzle
   local a1=Instance.new("Attachment");a1.Name="TrailEdge1";a1.Position=Vector3.new(-.25,0,trail.Width/2);a1.Parent=nozzle
   local ribbon=Instance.new("Trail");ribbon.Name="PurchasedExhaustTrail";ribbon.Attachment0=a0;ribbon.Attachment1=a1;ribbon.Enabled=false;ribbon.FaceCamera=true;ribbon.Lifetime=trail.Lifetime;ribbon.MaxLength=180;ribbon.MinLength=.1;ribbon.LightEmission=1;ribbon.Color=Trails.Sequence(trail);ribbon.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.12),NumberSequenceKeypoint.new(.65,.35),NumberSequenceKeypoint.new(1,1)});ribbon.WidthScale=NumberSequence.new(1,0);ribbon.Parent=nozzle
   local sparks=Instance.new("ParticleEmitter");sparks.Name="TrailSparkles";sparks.Texture="rbxasset://textures/particles/sparkles_main.dds";sparks.Color=Trails.Sequence(trail);sparks.LightEmission=1;sparks.Lifetime=NumberRange.new(.15,.3);sparks.Rate=18;sparks.Speed=NumberRange.new(5,12);sparks.Size=NumberSequence.new(.3,0);sparks.Transparency=NumberSequence.new(.2,1);sparks.EmissionDirection=Enum.NormalId.Bottom;sparks.Enabled=false;sparks.Parent=a
  end
  local light=Instance.new("PointLight");light.Name="EngineLight";light.Enabled=false;light.Color=style.Flame;light.Range=10;light.Parent=nozzle
 end
 m.Parent=character;Rocket.Set(character,false)
end
function Rocket.Pulse(character,throttle,phase,fuel)
 local m=character:FindFirstChild("BackRocket");if not m then return end
 throttle=math.clamp(throttle,0,1);character:SetAttribute("RocketPhase",phase);character:SetAttribute("RocketFuel",fuel);character:SetAttribute("RocketThrust",throttle)
 for _,p in m:GetDescendants()do
  if p:IsA("ParticleEmitter")then p.Enabled=throttle>.01 and (p.Name~="TrailSparkles"or phase~="Diving");if p.Name=="RocketFlame"then p.Rate=40+throttle*120;p.Speed=NumberRange.new(15+throttle*25,22+throttle*35)end
  elseif p:IsA("Trail")then p.Enabled=throttle>.01 and phase~="Diving";if not p.Enabled then p:Clear()end
  elseif p:IsA("Beam")then p.Enabled=throttle>.01;p.Width0=.4+throttle*.6
  elseif p:IsA("Attachment")and p.Name=="FlameTip"then p.CFrame=p.Parent.Exhaust.CFrame*CFrame.new(0,-(1+throttle*8),0)
  elseif p:IsA("PointLight")then p.Enabled=throttle>.01;p.Brightness=throttle*2
  elseif p:IsA("BasePart")and p.Name=="NozzleGlow"then p.Transparency=if throttle>.01 then 0 else .65 end
 end
end
function Rocket.Set(character,enabled)Rocket.Pulse(character,if enabled then .12 else 0,if enabled then "Ignition"else "Idle",if enabled then 1 else 0)end
return Rocket
