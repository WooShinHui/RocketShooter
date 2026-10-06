do
 local env=environment()
 for name,module in {ProgressionConfig=Growth,RocketModeConfig={Enabled=true}}do local m=env.Instance.new("ModuleScript");m.Name=name;m.__module=module;m.Parent=env.rs end
 local data=newPlayerData(env,{RunPolicy=Policy,RocketEconomy=newRocketEconomy(env)})
 data.Start();local p=env.player(9812);env.players.PlayerAdded:Fire(p)
 p.leaderstats.TrainingLevel.Value=1
 check(data.PassiveXP(p,2)==0,"loading cannot grant catch-up passive XP")
 env.time+=.5;data.PassiveXP(p,.5)
 check(p.leaderstats.TrainingXP.Value==0,"fractional baseline XP is retained without rounding up")
 check(data.PassiveXP(p,1)==0,"repeated passive calls cannot create clock budget")
 env.time+=.5;data.PassiveXP(p,.5)
 check(p.leaderstats.TrainingXP.Value==1,"idle unseated player gains XP each second")
 p:SetAttribute("FlightState","Flying");env.time+=1;data.PassiveXP(p,1)
 check(p.leaderstats.TrainingXP.Value==2,"baseline continues during flight independently of flight bonus")
 p:SetAttribute("FlightState","Returning");env.time+=1;data.PassiveXP(p,1)
 check(p.leaderstats.TrainingXP.Value==3,"baseline continues during death and respawn")
 for _,bad in {0,-1,3,math.huge,0/0}do check(data.PassiveXP(p,bad)==0,"invalid passive duration rejected")end
 p:SetAttribute("FlightState","Idle");data.Train(p,1,1)
 env.time+=1;data.PassiveXP(p,1);data.Train(p,1,1)
 check(p.leaderstats.TrainingXP.Value==5,"toilet bonus stacks on baseline instead of replacing it")
 p.leaderstats.TrainingXP.Value=Growth.RequiredXP(1)-1;env.time+=1;data.PassiveXP(p,1)
 check(p.leaderstats.TrainingLevel.Value==2 and p.leaderstats.TrainingXP.Value==0,"baseline alone can level up and carry remainder")
 check(Growth.PassiveXPRate(0)==1 and Growth.PassiveXPRate(20)==1 and Growth.PassiveXPRate(1000)==1,"level never inflates the one XP per second baseline")
 p.leaderstats.XPGearLvl.Value=3;p.leaderstats.Trophies.Value=15;p:SetAttribute("TrainingBuffIndex",3)
 env.time+=2;local gain=data.PassiveXP(p,2)
 check(gain==12,"XP equipment and eligible trophy pad multiply baseline")
 p.leaderstats.TrainingLevel.Value=20;p.leaderstats.TrainingXP.Value=0;env.time+=2
 check(data.PassiveXP(p,2)>0 and p.leaderstats.TrainingXP.Value>0,"baseline continues above the former maximum level")
 check(data.Rebirth(p,0),"baseline player can rebirth normally")
 check(data.PassiveXP(p,2)==0,"rebirth resets passive clock and fractional budget")
 env.time+=2
 check(data.PassiveXP(p,2)==18,"rebirth multiplier applies after reset while retaining equipment")
end
do
 local env=environment();local V=env.Vector3
 V.yAxis=V.new(0,1,0);V.one=V.new(1,1,1);env.Enum.ModelStreamingMode={Persistent="Persistent"}
 env.CFrame.lookAt=function(position,target,up)
  local r=env.CFrame.new(position);r.LookVector=(target-position).Unit
  r.RightVector=r.LookVector:Cross(up or V.yAxis).Unit;r.UpVector=r.RightVector:Cross(r.LookVector)
  return r
 end
 local course=newBreakCourse(env)
 local p=Motion.Create(260*math.sin(math.rad(65)),196.2)
 local c=course.Create(env.player(9813),1,V.new(0,9,0),V.zero,196.2,1,{Profile=p,Sample=Motion.Sample,Elapsed=0})
 check(#c.Rows==0,"rocket ignition creates no objects over the launch pad")
 course.Update(c,V.new(0,43,0),V.new(0,40,0),1.6,nil)
 check(#c.Rows==0,"course stays absent below 35m rise")
 course.Update(c,V.new(0,44,0),V.new(0,40,0),1.65,nil)
 check(#c.Rows==2 and c.Rows[1].Position.Y>=68,"first chain appears only aloft and at least 24m ahead")
 check(not course.Touches(c.Rows[1],V.new(0,43,0),V.new(0,44,0)),"new first chain does not immediately hit its spawning player")
 course.Update(c,V.new(0,90,0),V.new(0,40,0),2.84,nil)
 check(#c.Rows==2,"next pack has a spacing cooldown")
 course.Update(c,V.new(0,96,0),V.new(0,40,0),2.86,nil)
 check(#c.Rows==4,"later chain still provides beginner repeat destruction")
 course.Destroy(c)
end

