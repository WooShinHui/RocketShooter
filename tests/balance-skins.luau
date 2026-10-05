do
 local expected={[0]=8,[19]=46,[20]=72,[39]=129,[40]=176,[60]=640,[100]=2912}
 for level,cost in expected do check(Growth.RequiredXP(level)==cost,"level band cost matches tuned curve")end
 check(Growth.XPBetween(0,20)==540,"first rebirth learning curve remains unchanged")
 for _,start in {0,19,20,39,40,99,999,4039,4040,4059,4060,20000000} do
  local total=0
  for i=0,65 do
   if total>2^53-1 then check(Growth.XPBetween(start,start+i)==math.huge,"unrepresentable totals compare above any valid XP award");break end
   check(Growth.XPBetween(start,start+i)==total,"closed form conserves XP across band boundaries "..start.." / "..i)
   local l,x=Growth.Advance(start,total);check(l==start+i and x==0,"exact band boundary award normalizes")
   total+=Growth.RequiredXP(start+i)
  end
 end
 for _,start in {0,19,10000,20000000} do
  local l,x=Growth.Advance(start,2^53-1);check(l>=start and x>=0 and x<Growth.RequiredXP(l),"maximum accepted integer reward normalizes safely")
 end
 local saturated=100000000
 check(Growth.RequiredXP(saturated)==2^53-1 and Growth.XPBetween(saturated,saturated+1)==2^53-1,"numeric saturation keeps single-level cumulative cost consistent")
 local saturatedLevel,saturatedXP=Growth.Advance(saturated,2^53-1)
 check(saturatedLevel==saturated+1 and saturatedXP==0,"numeric storage limit does not create an artificial gameplay level cap")
 local previous=0
 for _,r in {0,1,2,3,5,10,30,100,1000,1000000}do
  local target=Growth.RebirthRequired(r);local rate=(1+6+10+15)*20*10*Growth.Multiplier(r)
  local seconds=Growth.RequiredXP(target-1)/rate
  check(seconds>previous,"max equipment OP manual toilet terminal level cannot accelerate with higher rebirths")
  previous=seconds
  print(string.format("BALANCE r=%d target=%d lastXP=%.0f allBonusesSeconds=%.3f",r,target,Growth.RequiredXP(target-1),seconds))
 end
 check(Growth.PowerMultiplier(2)==2.25 and Growth.PowerBonus(40,2)==263,"rocket power preserves prior tuning independently of XP")
 local env=environment();env.saved={EconomyVersion=1,TrainingLevel=80,TrainingXP=130,Trophies=100,Rebirths=2}
 for name,module in {ProgressionConfig=Growth,RocketModeConfig={Enabled=true},RocketSkinCatalog=Skins}do local m=env.Instance.new("ModuleScript");m.Name=name;m.__module=module;m.Parent=env.rs end
 local data=newPlayerData(env,{RunPolicy=Policy,RocketEconomy=newRocketEconomy(env)});data.Start();local p=env.player(9891);env.players.PlayerAdded:Fire(p)
 check(data.IsReady(p) and p.leaderstats.TrainingLevel.Value==80 and p.leaderstats.TrainingXP.Value==130,"old trained levels and remainder survive higher costs")
 local s=p.ProgressStats;check(s.RocketSkinMask.Value==3 and s.RocketSkinEquipped.Value==1 and p:GetAttribute("RocketStyle")=="Starter","legacy players receive starter and earned free milestone skins")
 check(not data.SelectRocketSkin(p,5) and p.leaderstats.Trophies.Value==100,"locked skin cannot spend trophies")
 env.time+=1;check(data.SelectRocketSkin(p,3) and p.leaderstats.Trophies.Value==95 and p:GetAttribute("RocketStyle")=="Bat","validated purchase charges catalog price and equips funny rocket")
 env.time+=1;check(data.SelectRocketSkin(p,3) and p.leaderstats.Trophies.Value==95,"owned skin cannot charge twice")
 p:SetAttribute("FlightState","Flying");env.time+=1;check(not data.SelectRocketSkin(p,4) and p.leaderstats.Trophies.Value==95,"flight cannot change appearance or buy skin")
 p:SetAttribute("FlightState","Idle");check(data.Rebirth(p,2) and s.RocketSkinMask.Value==7 and s.RocketSkinEquipped.Value==3,"rebirth keeps owned skins and selection")
 check(data.Save(p) and env.saved.RocketSkinMask==7 and env.saved.RocketSkinEquipped==3,"skin ownership and equipped choice persist in normal snapshot")
 env.time+=1;check(data.SelectRocketSkin(p,5) and p.leaderstats.Trophies.Value==55,"new milestone unlock allows trophy purchase")
 check(not data.SelectRocketSkin(p,0) and not data.SelectRocketSkin(p,0/0) and not data.SelectRocketSkin(p,"Bat"),"forged skin indices rejected")
 check(Skins.Valid(1,1) and not Skins.Valid(1,2) and not Skins.Valid(2^#Skins.Items,1) and not Skins.Valid(2,2),"saved masks require starter ownership and valid equipped skin")
end
