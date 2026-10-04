do
 local lastHeight,lastGap=0,0
 for i=1,TrophyConfig.Count do
  local layer=TrophyConfig.Layer(i);local gap=layer.Height-lastHeight
  check(layer.Reward==2^(i-1) and (i<=2 or gap>=lastGap*2),"higher trophy layers have exponentially spaced heights and increasing rewards")
  check(layer.Offset-TrophyConfig.Width/2>65,"automatic flight and spawn cannot accidentally land in a trophy zone")
  lastHeight,lastGap=layer.Height,gap
 end
 check(TrophyConfig.Recommended(148).Index==1 and TrophyConfig.Recommended(400).Index==3,"guide picks the highest genuinely reachable layer with clearance")
 check(TrophyConfig.Recommended(90)==nil and TrophyConfig.Layer(0)==nil and TrophyConfig.Layer(1.5)==nil,"unreachable and invalid layers are rejected")
 local env=environment();env.Enum.PartType={Ball="Ball"};env.Enum.Font.GothamBlack="GothamBlack";env.UDim2.fromOffset=env.UDim2.new
 local getService=env.game.GetService;local collision
 function env.game:GetService(name)if name=="PhysicsService"then return {RegisterCollisionGroup=function()end,CollisionGroupSetCollidable=function(_,a,b,enabled)collision=enabled end}end;return getService(self,name)end
 local config=env.Instance.new("ModuleScript");config.Name="TrophyZoneConfig";config.__module=TrophyConfig;config.Parent=env.rs
 local zones=newTrophyZones(env);local V=env.Vector3
 zones.Start(V.new(10,6,20),0)
 local character=env.Instance.new("Model");local body=env.Instance.new("Part");body.CollisionGroup="CustomRig";body.Parent=character
 local saved=zones.Ascend(character)
 check(collision==false and body.CollisionGroup=="RocketAscentBody","rockets pass upwards through trophy decks instead of hitting a ceiling")
 zones.Restore(saved);check(body.CollisionGroup=="CustomRig","dive and cleanup restore the rig collision settings for landing")
 local deck=env.workspace.RocketTrophyZones.TrophyLayer1.LandingDeck
 check(zones.Resolve(deck,V.new(120,90,20),V.new(0,1,0)).Reward==1,"real registered top-face contact grants the first trophy zone reward")
 check(zones.Resolve(deck,V.new(120,90,20),V.new(1,0,0))==nil,"side contact does not count as landing")
 check(zones.Resolve(deck,V.new(151,90,20),V.new(0,1,0))==nil,"missing deck footprint cannot award trophies")
 local fake=env.Instance.new("Part");fake:SetAttribute("TrophyReward",2048)
 check(zones.Resolve(fake,V.new(120,90,20),V.new(0,1,0))==nil,"unregistered parts with copied attributes cannot award trophies")
 local rules=newRocketRules(env)
 check(rules.Trophies(0)==0 and rules.Trophies(nil)==0 and rules.Trophies(math.huge)==0 and rules.Trophies(1.5)==0,"ordinary flights and invalid zone rewards pay no trophies")
 check((zones.Target(148).Position-V.new(120,90,20)).Magnitude==0,"target guide uses the actual displaced world platform")
 zones.Start(V.new(10,6,20),0)
 check(zones.Resolve(deck,V.new(120,90,20),V.new(0,1,0))==nil,"replaced world zones cannot be used to claim an old reward")
end
