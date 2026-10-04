do
 local env=environment();local V=env.Vector3
 env.Enum.PartType={Ball="Ball"};env.Enum.Font.GothamBlack="GothamBlack";env.UDim2.fromOffset=env.UDim2.new
 local service=env.game.GetService
 function env.game:GetService(name)if name=="PhysicsService"then return {RegisterCollisionGroup=function()end,CollisionGroupSetCollidable=function()end}end;return service(self,name)end
 local config=env.Instance.new("ModuleScript");config.Name="TrophyZoneConfig";config.__module=TrophyConfig;config.Parent=env.rs
 local zones=newTrophyZones(env);zones.Start(V.new(10,6,20),0)
 local char=env.Instance.new("Model");char.Parent=env.workspace
 local root=env.Instance.new("Part");root.Parent=char;root.Size=V.new(2,2,2);root.CFrame=env.CFrame.new(150.6,110,20);root.CanCollide=true
 local deck=env.workspace.RocketTrophyZones.TrophyLayer1.LandingDeck
 local layer,contact,point=zones.Sweep(char,root,V.new(150.6,110,20),V.new(150.6,85,20))
 check(layer and layer.Index==1 and contact.X==149 and point.X==150,"body top-edge overlap lands safely even when center ray misses")
 root.CFrame=env.CFrame.new(150.6,110,54.6)
 check(zones.Sweep(char,root,root.Position,V.new(150.6,85,54.6))~=nil,"corner overlap counts as a top landing")
 root.CFrame=env.CFrame.new(152,110,20)
 check(zones.Sweep(char,root,root.Position,V.new(152,85,20))==nil,"genuine miss outside the solid body footprint does not award trophies")
 root.CFrame=env.CFrame.new(120,85,20)
 check(zones.Sweep(char,root,root.Position,V.new(120,80,20))==nil,"below-top side touch is not a landing")
 check(zones.Sweep(char,root,root.Position,V.new(120,110,20))==nil,"upward underside crossing cannot earn trophies")
 root.CFrame=env.CFrame.new(120,200,20)
 local high=zones.Sweep(char,root,root.Position,V.new(120,1,20))
 check(high and high.Index==2,"fast sweep spanning multiple layers selects the first deck crossed")
 check(zones.IsDeck(deck)and not zones.IsDeck(root),"only server registered decks can be recognized as trophy contacts")
 local rocket=env.Instance.new("Part");rocket.Parent=char;rocket.Size=V.new(200,200,200);rocket.CanCollide=false;rocket.CFrame=root.CFrame
 root.CFrame=env.CFrame.new(160,110,20)
 check(zones.Sweep(char,root,root.Position,V.new(160,85,20))==nil,"decorative rocket bounds cannot manufacture a safe landing")
end
do
 local env=environment()
 for name,module in {ProgressionConfig=Growth,RocketModeConfig={Enabled=true}}do local m=env.Instance.new("ModuleScript");m.Name=name;m.__module=module;m.Parent=env.rs end
 local notifications={};local remote=env.Instance.new("RemoteEvent");remote.Name="ExperienceGained";remote.Parent=env.rs
 rawset(remote,"FireClient",function(self,player,amount,character,source)table.insert(notifications,{amount=amount,source=source,character=character})end)
 local data=newPlayerData(env,{RunPolicy=Policy,RocketEconomy=newRocketEconomy(env)})
 data.Start();local player=env.player(9930);env.players.PlayerAdded:Fire(player)
 env.time+=.5;data.PassiveXP(player,.5)
 check(#notifications==0,"fractional uncredited XP produces no popup")
 env.time+=.5;data.PassiveXP(player,.5)
 check(#notifications==1 and notifications[1].amount==1 and notifications[1].source=="Passive","idle baseline sends the actual credited XP")
 data.PassiveXP(player,1)
 check(#notifications==1,"repeated calls without a clock budget cannot create fake XP popups")
 player:SetAttribute("FlightState","Flying");local awarded=data.AwardFlightXP(player,1)
 check(notifications[2].amount==awarded and notifications[2].source=="Flight","flight notifications reflect actual server awards")
 player.leaderstats.Rebirths.Value=1
 env.time+=1;local first=data.PassiveXP(player,1);env.time+=1;local second=data.PassiveXP(player,1)
 check(first==1 and second==2 and notifications[3].amount==1 and notifications[4].amount==2,"rebirth fractions display actual one/two XP without rounding extra gains")
 check(data.AwardFlightXP(player,math.huge)==0 and #notifications==4,"invalid awards never produce a success popup")
end
