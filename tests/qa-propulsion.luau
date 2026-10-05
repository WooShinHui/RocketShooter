do
 check(DestructionRewards.Reward(7,259)==7 and DestructionRewards.Reward(7,260)==14,"height boundaries multiply logical object count")
 for _,b in DestructionRewards.Bands do check(DestructionRewards.Reward(11,b.Height)==11*b.Multiplier,"all reward tier boundaries")end
 for _,n in {0/0,math.huge,-1,1.5,1000001}do check(DestructionRewards.Reward(n,500)==0,"invalid object counts never grant trophies")end
 check(DestructionRewards.Reward(0,200000)==0 and DestructionRewards.Reward(1,math.huge)==0,"empty run and invalid height grant nothing")
 local env=environment();env.saved={EconomyVersion=1,TrainingLevel=80,TrainingXP=130,Trophies=500,Rebirths=2,RocketSkinMask=7,RocketSkinEquipped=3,LegacyExtra="keep"}
 for name,module in {ProgressionConfig=Growth,RocketModeConfig={Enabled=true},RocketSkinCatalog=Skins,RocketTrailCatalog=Trails}do local m=env.Instance.new("ModuleScript");m.Name=name;m.__module=module;m.Parent=env.rs end
 local data=newPlayerData(env,{RunPolicy=Policy,RocketEconomy=newRocketEconomy(env)});data.Start();local p=env.player(9850);env.players.PlayerAdded:Fire(p)
 local s=p.ProgressStats
 check(data.IsReady(p)and s.RocketTrailMask.Value==1 and s.RocketTrailEquipped.Value==1,"legacy save gains default trail without resetting progress")
 check(p.leaderstats.Trophies.Value==500 and s.RocketSkinMask.Value==7 and s.RocketSkinEquipped.Value==3,"old currency and rocket ownership preserved")
 check(near(data.LaunchVertical(p,300,235),312.6),"equipped Bat now grants actual propulsion")
 check(data.SelectRocketTrail(p,3)and p.leaderstats.Trophies.Value==440 and p:GetAttribute("RocketTrail")=="Mint","purchase spends exact server catalog cost")
 check(near(data.LaunchVertical(p,300,235),324.2),"rocket and trail propulsion bonuses add")
 env.time+=1;check(data.SelectRocketTrail(p,3)and p.leaderstats.Trophies.Value==440,"owned trail re-equip is free")
 env.time+=1;check(not data.SelectRocketTrail(p,6)and p.leaderstats.Trophies.Value==440,"insufficient balance cannot unlock trail")
 for _,index in {0,-1,7,1.5,0/0,math.huge,"Prism"}do check(not data.SelectRocketTrail(p,index),"forged trail indices rejected")end
 p:SetAttribute("FlightState","Flying");env.time+=1
 check(not data.SelectRocketTrail(p,2),"equipment cannot change during flight")
 check(data.AwardDestructionTrophies(p,28)==28 and p.leaderstats.Trophies.Value==468,"validated destruction award credits immediately")
 for _,gain in {0,-1,.5,0/0,math.huge,40000001}do check(data.AwardDestructionTrophies(p,gain)==0,"malformed server reward rejected")end
 p.leaderstats.Trophies.Value=2^53-2;check(data.AwardDestructionTrophies(p,40)==1 and p.leaderstats.Trophies.Value==2^53-1,"reward saturates exact integer storage safely")
 check(data.AwardDestructionTrophies(p,40)==0,"full balance neither overflows nor duplicates rewards")
 p:SetAttribute("FlightState","Idle");check(data.AwardDestructionTrophies(p,40)==0,"nonflight calls cannot farm trophies")
 check(data.Rebirth(p,2)and s.RocketTrailMask.Value==5 and s.RocketTrailEquipped.Value==3,"rebirth preserves purchased and selected trail")
 check(data.Save(p)and env.saved.RocketTrailMask==5 and env.saved.RocketTrailEquipped==3 and env.saved.LegacyExtra=="keep","save stores trail fields and preserves unknown legacy metadata")
 for _,fields in {{1,2},{2,2},{127,1},{1.5,1}}do check(not Trails.Valid(fields[1],fields[2]),"invalid persisted trail combinations rejected")end
 check(Trails.Valid(63,6),"full trail collection remains valid")
 local base=Balance.VerticalPower(100)*math.sin(math.rad(65));local normal=Motion.CreateRocket(base,196.2);local boosted=Motion.CreateRocket(base*1.35,196.2)
 check(boosted.TargetHeight>normal.TargetHeight and boosted.Peak>normal.Peak,"actual motion gains height and speed from equipment")
end
