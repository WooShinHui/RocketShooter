do
 check(Growth.RebirthRequired(0)==20 and Growth.RebirthRequired(1)==40 and Growth.RebirthRequired(2)==60,"rebirth requirements grow 20/40/60")
 check(Growth.RequiredXP(0)==8 and Growth.RequiredXP(20)==72,"early level costs support quick beginner growth")
 for _,start in {0,1,20,100,10000}do
  for _,gain in {0,1,40,100,10000,1000000000}do
   local level,xp=Growth.Advance(start,gain)
   check(level>=start and xp>=0 and xp<Growth.RequiredXP(level),"large rewards leave normalized XP without a per-level loop")
   check(Growth.XPBetween(start,level)+xp==gain,"closed-form level conversion conserves every XP")
  end
 end
 local level,xp=Growth.Advance(20,Growth.RequiredXP(20))
 check(level==21 and xp==0,"level twenty is not a cap")
 local high=Motion.Create(7500,196.2);local low=Motion.Create(260*math.sin(math.rad(65)),196.2)
 check(high.ApexTime<=12 and low.ApexTime==5,"high ascent is softened within twelve seconds while beginner ascent remains five")
 check(Motion.Sample(high,.3)>Motion.Sample(low,.3)*50,"growth increases initial acceleration as well as height")
 local env=environment();local event=newGoldRingEvent(env,{PlayerData={}});local V=env.Vector3;local c=V.new(0,100,0)
 local rules=newRocketRules(env);local speed=0;local early,late
 for i=1,240 do local age=i/60;speed=rules.DiveSpeed(speed,14000,196.2,age,1/60);if i==60 then early=speed elseif i==180 then late=speed end end
 check(early<50 and late>early*20,"dive starts gently for a second and then accelerates progressively")
 check(speed<=14000,"dive acceleration never exceeds its terminal speed")
 check(Motion.Sample(high,high.Burn-.5)<high.Peak*.05,"high rocket slows nearly to rest before fuel depletion")
 check(event.Interval==1800 and event.Duration==180,"gold rings have thirty-minute server cadence and bounded lifetime")
 check(event.Crosses(c,V.new(0,70,0),V.new(0,130,0),26),"gold ring accepts real upward swept crossing")
 check(event.Crosses(c,V.new(0,130,0),V.new(0,70,0),26),"gold ring accepts real downward swept crossing")
 check(not event.Crosses(c,V.new(40,70,0),V.new(40,130,0),26),"missing the ring does not pay")
 check(not event.Crosses(c,V.new(0,99,0),V.new(20,99,0),26),"nearby horizontal movement cannot farm a ring")
 check(not event.Crosses(c,V.new(0,110,0),V.new(0,130,0),26),"same side of a ring plane cannot pay")
 check(not event.CanClaim({Count=1,Ids={[1]=true}},1) and event.CanClaim({Count=1,Ids={[1]=true}},2),"same player cannot farm one ring repeatedly")
 check(not event.CanClaim({Count=3,Ids={}},4),"event-wide reward claim budget remains bounded across respawns")
end
do
 local env=environment()
 for name,module in {ProgressionConfig=Growth,RocketModeConfig={Enabled=true}}do local m=env.Instance.new("ModuleScript");m.Name=name;m.__module=module;m.Parent=env.rs end
 local data=newPlayerData(env,{RunPolicy=Policy,RocketEconomy=newRocketEconomy(env)})
 data.Start();local p=env.player(9850);env.players.PlayerAdded:Fire(p);local s=p.leaderstats
 check(s.TrainingLevel.Value==0 and s.TrainingXP.Value==0,"new growth track starts at zero")
 check(data.AwardGoldRingXP(p)==0,"idle players cannot request event XP")
 p:SetAttribute("FlightState","Flying");s.TrainingLevel.Value=20
 local gain=data.AwardGoldRingXP(p)
 check(gain==Growth.GoldRingXP(20) and s.TrainingLevel.Value>20,"real event reward gives multiple levels past twenty")
 check(not data.Rebirth(p,0),"active ascent or dive cannot rebirth")
 p:SetAttribute("FlightState","Idle");check(data.Rebirth(p,0) and s.TrainingLevel.Value==0,"first rebirth resets level to zero")
 s.TrainingLevel.Value=39;check(not data.Rebirth(p,1),"second rebirth is locked below forty")
 s.TrainingLevel.Value=40;check(data.Rebirth(p,1) and s.TrainingLevel.Value==0,"second rebirth unlocks at forty")
 check(data.Save(p) and env.saved.TrainingLevel==0,"rebirth level zero is valid persistent data")
end
