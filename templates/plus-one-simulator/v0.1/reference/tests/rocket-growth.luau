do
 local function setup(saved)
  local env=environment();env.saved=saved
  for name,module in {ProgressionConfig=Growth,RocketModeConfig={Enabled=true}}do local m=env.Instance.new("ModuleScript");m.Name=name;m.__module=module;m.Parent=env.rs end
  local data=newPlayerData(env,{RunPolicy=Policy,RocketEconomy=newRocketEconomy(env)});data.Start()
  local p=env.player(9876);env.players.PlayerAdded:Fire(p)
  return env,data,p
 end
 for _,mode in {"Idle","Flight","Toilet"}do
  local env,data,p=setup();local times={}
  for second=1,3600 do
   local flying=mode=="Flight"and second%13<8
   p:SetAttribute("FlightState",flying and "Flying"or "Idle")
   if mode=="Toilet" then data.Train(p,1,1)end
   env.time+=1;data.PassiveXP(p,1)
   if flying then data.AwardFlightXP(p,1)end
   local s=p.leaderstats
   if not flying and s.TrainingLevel.Value>=Growth.RebirthRequired(s.Rebirths.Value)then
    check(data.Rebirth(p,s.Rebirths.Value),"early rebirth simulation uses the real server progression path")
    table.insert(times,second)
    if #times==2 then break end
   end
  end
  print(string.format("PACE %s first=%ds second=%ds (cumulative; no gear/pad/event bonuses)",mode,times[1],times[2]))
  check(#times==2 and times[1]>=240 and times[1]<=600 and times[2]>=780 and times[2]<=2400,"first two rebirths complete in a measured beginner learning window without purchased gear or trophy buffs")
  if mode=="Flight"then check(times[2]>=1000 and times[2]<=1500,"repeated beginner flights reach two rebirths in approximately twenty-five minutes with the harder second band")end
 end
 local env,data,p=setup({EconomyVersion=1,TrainingLevel=5,TrainingXP=99,Trophies=123,XPGearLvl=2})
 check(data.IsReady(p) and not p.kicked and p.leaderstats.TrainingLevel.Value==9 and p.leaderstats.TrainingXP.Value==15,"previous slower-curve saved XP carries into levels without rejecting the save")
 check(p.leaderstats.Trophies.Value==123 and p.leaderstats.XPGearLvl.Value==2,"growth retuning preserves trophies and purchased equipment")
 check(data.Save(p) and env.saved.TrainingLevel==9 and env.saved.TrainingXP==15,"normalized saved XP persists under the new curve")
 local badEnv,badData,bad=setup({EconomyVersion=1,TrainingLevel=5,TrainingXP=100})
 check(not badData.IsReady(bad) and bad.kicked~=nil and badEnv.writes==0,"invalid XP outside the old valid range still fails safely")
 check(Growth.Tiers[2].Rebirths==1 and Growth.Tiers[2].Level==5 and Growth.Tiers[2].Cost==5,"stone toilet remains a separate unlock milestone")
end
