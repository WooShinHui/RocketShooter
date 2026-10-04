do
 local env=environment();local patrol=newSkyPatrol(env);local V=env.Vector3
 local origin=V.new(0,1200,0);local state=patrol.New(origin,4.1)
 local minSpeed,maxSpeed=100,0;local reversals=0;local previous=state.Center;local last
 local bounded,motionBounded=true,true
 for i=1,900 do
  local center=patrol.Step(state,.1,i*.1);local delta=center-previous
  bounded=bounded and math.abs(center.Y-origin.Y)<=18.01 and (center-origin).Magnitude<82
  motionBounded=motionBounded and delta.Magnitude<=4.201
  if last and last:Dot(delta)<0 then reversals+=1 end
  minSpeed=math.min(minSpeed,state.Speed);maxSpeed=math.max(maxSpeed,state.Speed);previous=center;last=delta
 end
 check(bounded,"patrol stays in its original altitude pocket over 90 seconds")
 check(motionBounded,"patrol movement is bounded during long frames")
 check(maxSpeed-minSpeed>15 and state.Leg>20,"patrol changes speed and heading rather than following a fixed circle")
 local other=patrol.New(origin,5.2);patrol.Step(other,.1,90)
 check((other.Goal-state.Goal).Magnitude>10,"different enemies have independent patrol paths")
end
do
 local env=environment();local p=env.player(6912);env.players.LocalPlayer=p
 function p:GetAttributeChangedSignal() return event() end
 local sky=newSkyController(env);sky.Start();p:SetAttribute("FlightState","Flying")
 local previousClock
 for index,region in CloudConfig.HeightPresentation.Biomes do
  p.Character.HumanoidRootPart.Position=env.Vector3.new(0,region.Min+30,0);env.step(.1)
  check(env.lighting:GetAttribute("AltitudeBiome")==index,"ascending selects each regional environment")
  if index>=3 then check(env.lighting.ClockTime~=previousClock,"successive upper regions have distinct lighting") end
  previousClock=env.lighting.ClockTime
 end
 for index=#CloudConfig.HeightPresentation.Biomes,2,-1 do
  local region=CloudConfig.HeightPresentation.Biomes[index]
  p.Character.HumanoidRootPart.Position=env.Vector3.new(0,region.Min-4,0);env.step(.1)
  check(env.lighting:GetAttribute("AltitudeBiome")==index,"regional boundary resists altitude jitter")
  p.Character.HumanoidRootPart.Position=env.Vector3.new(0,region.Min-10,0);env.step(.1)
  check(env.lighting:GetAttribute("AltitudeBiome")==index-1,"descending restores the previous region")
 end
 sky.Reset();check(env.lighting:GetAttribute("AltitudeBiome")==1,"return resets regional presentation")
end
