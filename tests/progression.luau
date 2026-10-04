do
	local env=environment()
	local m=env.Instance.new("ModuleScript");m.Name="ProgressionConfig";m.__module=Growth;m.Parent=env.rs
	local data=newPlayerData(env);data.Start();local p=env.player(6701);env.players.PlayerAdded:Fire(p)
	local s=p.leaderstats
	check(s.TrainingLevel.Value==0 and s.Rebirths.Value==0,"old saves initialize new training fields")
	check(not data.Rebirth(p,0),"rebirth rejects insufficient level")
	check(not data.Train(p,100000,1),"training rejects forged time budget")
	data.Train(p,1,1);env.step(1);data.Train(p,1,1)
	check(s.TrainingXP.Value==1,"server elapsed time awards training XP")
	data.Train(p,1,1);check(s.TrainingXP.Value==1,"repeated same-time call cannot inflate XP")
	p:SetAttribute("FlightState","Flying");env.step(1)
	check(not data.Train(p,1,1) and not data.Rebirth(p,0),"training and rebirth reject active flight")
	p:SetAttribute("FlightState","Idle");s.TrainingLevel.Value=20;s.Gold.Value=321;s.Trophies.Value=80;s.PowerLvl.Value=4;s.MaxAltitude.Value=210
	check(data.GetTrainingPower(p)==57,"training levels contribute server launch power")
	check(not data.Rebirth(p,1),"stale rebirth serial rejected")
	check(not data.BuyTrainingTier(p,2),"next toilet requires rebirth even at level20")
    s.Rebirths.Value=1
    check(data.BuyTrainingTier(p,2) and s.TrainingTier.Value==2 and s.Trophies.Value==75,"tier validates and charges server price")
	check(not data.BuyTrainingTier(p,2) and s.Trophies.Value==75,"duplicate tier request cannot double charge")
	s.TrainingLevel.Value=40
 check(data.Rebirth(p,1),"second rebirth requires level40 and commits")
	check(s.Rebirths.Value==2 and s.TrainingLevel.Value==0 and s.TrainingXP.Value==0,"rebirth resets only training track")
	check(s.Gold.Value==321 and s.Trophies.Value==75 and s.PowerLvl.Value==4 and s.MaxAltitude.Value==210 and s.TrainingTier.Value==2,"rebirth preserves legacy currency purchases records and unlocked tiers")
	check(not data.Rebirth(p,0),"duplicate rebirth cannot increment twice")
	check(Growth.Multiplier(1)==1.5 and Growth.Multiplier(2)==2,"rebirth XP growth is additive")
	data.Train(p,1,2);env.step(2);data.Train(p,2,2)
	check(s.TrainingXP.Value==6,"unlocked tier and rebirth increase actual XP rate")
	s.TrainingXP.Value=0;env.step(1)
	check(data.ClickXP(p),"idle manual click earns server XP")
	local clicked=s.TrainingXP.Value
	check(not data.ClickXP(p) and s.TrainingXP.Value==clicked,"click flood rejected by server clock")
	p:SetAttribute("FlightState","Flying");env.step(1)
	check(not data.ClickXP(p),"airborne click cannot farm progression")
	p:SetAttribute("FlightState","Idle");p:SetAttribute("TrainingBuffIndex",3);s.Trophies.Value=15
	check(data.TrophyMultiplier(p)==3,"owned trophy threshold activates selected buff")
	s.Trophies.Value=14
	check(data.TrophyMultiplier(p)==1,"spending below trophy threshold relocks selected buff")
	check(data.Save(p),"new progression saves through existing persistence")
end

do
	local env=flightEnvironment(true);local p=env.player(6703)
	env.world.CollectSky=function(_,_,_,visited)
		if visited.target then return 0 end;visited.target=true;return 120
	end
	local id=env.enter(p);env.fire(p,id);env.step(.5);env.step(.5)
	check(p:GetAttribute("DestructionRunScore")==120,"swept bonus cannot repeat in same flight")
	p.Character.Humanoid.FloorMaterial="Grass";env.step(.2);env.step(.2)
	check(#env.awards==1 and env.awards[1][4]>=2,"sky score awards bonus trophies only on successful landing")
	local result=env.rs.FlightResult.sent[1]
	check(result and result[8].SkyScore==120,"result carries authoritative sky bonus score")
end

do
	check(Policy.validAim(0,75) and not Policy.validAim(0,76),"vertical aiming keeps a strict server ceiling")
	local env=flightEnvironment();local p=env.player(6704);local id=env.enter(p)
	env.rs.AimCannon.OnServerEvent:Fire(p,0,75,id)
	check(env.model.Cylinder.CFrame.LookVector.Y>.9,"high aim changes the occupied cannon")
	env.fire(p,id)
	check(math.abs(env.model.Cylinder.CFrame.LookVector.Y)<.0001 and env.prompt.Enabled,"launch resets boarding point while preserving active flight")
	check(env.rs.FireCannon.sent[1][2].Y>200 and p:GetAttribute("FlightState")=="Flying","boarding reset cannot alter frozen launch velocity")
end

do
	local env=flightEnvironment(true);local p=env.player(6702)
	env.world.HazardHit=function()return "test sky creature"end
	local id=env.enter(p);env.fire(p,id);env.step(1.1)
	check(p:GetAttribute("LastSkyHazard")=="test sky creature" and p.Character.HumanoidRootPart.AssemblyLinearVelocity.Y==-150,"swept sky collision starts authoritative fall")
	p.Character.Humanoid.FloorMaterial="Grass";env.step(.2);env.step(.2)
	check(#env.awards==0 and #env.rs.FlightResult.sent==0 and p:GetAttribute("FlightState")=="Returning","hazard landing loses run rewards and recovers")
end
