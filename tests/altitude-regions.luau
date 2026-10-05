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
  if index>=3 then check(env.lighting.ClockTime==14,"successive upper regions retain neutral lighting") end
  previousClock=env.lighting.ClockTime
 end
 for index=#CloudConfig.HeightPresentation.Biomes,2,-1 do
  local region=CloudConfig.HeightPresentation.Biomes[index]
  p.Character.HumanoidRootPart.Position=env.Vector3.new(0,region.Min-4,0);env.step(.1)
  check(env.lighting:GetAttribute("AltitudeBiome")==index,"regional boundary resists altitude jitter")
  p.Character.HumanoidRootPart.Position=env.Vector3.new(0,CloudConfig.HeightPresentation.Gates[index-1].Bottom-1,0);env.step(.1)
  check(env.lighting:GetAttribute("AltitudeBiome")==index-1,"descending restores the previous region")
 end
 sky.Reset();check(env.lighting:GetAttribute("AltitudeBiome")==1,"return resets regional presentation")
end

do
 local env=environment();local p=env.player(6913);env.players.LocalPlayer=p
 function p:GetAttributeChangedSignal() return event() end
 local sky=newSkyController(env);sky.Start();p:SetAttribute("FlightState","Flying")
 local bands=CloudConfig.HeightPresentation.SkyBands
 for i,band in bands do
  p.Character.HumanoidRootPart.Position=env.Vector3.new(0,band.Min,0);env.step(.1)
  check(env.lighting:GetAttribute("AltitudeSky")==band.Name,"exact upward boundary selects requested sky: "..band.Name)
  check(env.lighting.FlightSky.SkyboxBk==band.Properties.SkyboxBk,"sky faces match inspected inventory asset")
  check(env.lighting:GetAttribute("AltitudeSkyAsset")==band.AssetId,"sky identity follows the exact requested asset")
  check(env.lighting.FlightSky.CelestialBodiesShown==band.Properties.CelestialBodiesShown,"inventory celestial settings are preserved")
  local current=env.lighting.FlightSky;env.step(.1)
  check(env.lighting.FlightSky==current,"unchanged altitude does not recreate sky")
 end
 for i=#bands,2,-1 do
  p.Character.HumanoidRootPart.Position=env.Vector3.new(0,bands[i].Min-4,0);env.step(.1)
  check(env.lighting:GetAttribute("AltitudeSky")==bands[i].Name,"sky boundary hysteresis prevents flicker")
  p.Character.HumanoidRootPart.Position=env.Vector3.new(0,CloudConfig.HeightPresentation.Gates[i-1].Bottom-1,0);env.step(.1)
  check(env.lighting:GetAttribute("AltitudeSky")==bands[i-1].Name,"descent restores previous sky")
 end
 p.Character.HumanoidRootPart.Position=env.Vector3.new(0,CloudConfig.HeightPresentation.Gates[#CloudConfig.HeightPresentation.Gates].Top+60000,0);env.step(.1)
 check(env.lighting:GetAttribute("AltitudeSky")==bands[#bands].Name,"large altitude jump selects final space sky")
 p:SetAttribute("FlightState","Idle");sky.Reset()
 check(env.lighting:GetAttribute("AltitudeSky")==bands[1].Name,"return resets sky to mountains")
end

do
 local env=environment();local life=newSkyLife(env)
 for _,height in {14000,150000,200000,300000,1000000,5000000}do
  for _,speed in {-3600,0,25000}do
   local first,last=life.StreamSectionRange(height,speed)
   check(first>=0 and last-first<=10,"high-altitude object window remains bounded without an altitude cap")
   if height>=200000 then check(last>71,"object generation continues beyond the former final section")end
  end
 end
 local p=env.player(8919);env.players.LocalPlayer=p
 function p:GetAttributeChangedSignal()return event()end
 local sky=newSkyController(env);sky.Start();p:SetAttribute("FlightState","Flying")
 for _,height in {300,5000,17000,45000,75000,150000,300000,1000000}do
  p.Character.HumanoidRootPart.Position=env.Vector3.new(0,height,0);env.step(.1)
  check(env.lighting.ClockTime==14 and env.lighting.Brightness==CloudConfig.Ground.Brightness,"altitude does not darken or tint lighting")
  for _,v in env.lighting:GetChildren()do if v:IsA("Atmosphere")then check(v.Density==0 and v.Haze==0,"sky remains visible without altitude atmosphere haze")end end
  check(env.lighting.FogEnd==1000000000,"fog does not hide distant sky")
 end
end
