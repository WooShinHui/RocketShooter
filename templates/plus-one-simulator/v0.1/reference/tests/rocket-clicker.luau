do
 for _,entry in {{"Off",0},{"Free",30},{"OP",60}}do
  local remainder,total=0,0
  for i=1,600 do local clicks;remainder,clicks=ClickerConfig.Step(remainder,1/60,entry[1]);total+=clicks end
  check(total==entry[2],"server clock produces exact ten-second rate for "..entry[1])
 end
 local _,lag=ClickerConfig.Step(0,10,"OP")
 check(lag==1,"lag catch-up cannot create an uncontrolled reward burst")
 check(not ClickerConfig.ValidMode("Paid")and not ClickerConfig.ValidMode({})and ClickerConfig.Rate("Paid")==0,"unknown mode cannot spoof click speed")
 for _,dt in {0,-1,0/0,math.huge}do local _,clicks=ClickerConfig.Step(0,dt,"OP");check(clicks==0,"invalid auto clock intervals produce no XP")end
end
do
 local env=environment()
 for name,module in {ProgressionConfig=Growth,RocketModeConfig={Enabled=true},ClickerConfig=ClickerConfig}do local m=env.Instance.new("ModuleScript");m.Name=name;m.__module=module;m.Parent=env.rs end
 local data=newPlayerData(env,{RunPolicy=Policy,RocketEconomy=newRocketEconomy(env)})
 data.Start();local p=env.player(9931);env.players.PlayerAdded:Fire(p);p.Character.Parent=env.workspace
 local notification=env.Instance.new("RemoteEvent");notification.Name="ExperienceGained";notification.Parent=env.rs
 check(data.ClickXP(p)and p.leaderstats.TrainingXP.Value==1,"rocket mode screen click credits +1 XP")
 check(data.ClickXP(p)and not data.ClickXP(p),"manual burst accepts normal double clicks and rejects an immediate flood")
 env.time+=.1;p:SetAttribute("FlightState","Flying")
 check(data.ClickXP(p),"manual clicks remain available during rocket flight")
 local s=p.leaderstats;s.Rebirths.Value=1;env.time+=.1
 check(data.ClickXP(p)and notification.sent[#notification.sent][2]==1,"manual rebirth award reports only its credited integer")
 env.time+=.1;data.ClickXP(p)
 check(notification.sent[#notification.sent][2]==2,"manual XP preserves fractional rebirth gains between clicks")
 check(data.AwardAutoClickXP(p,1,"Free")==0,"auto rewards require matching server selected mode")
 p:SetAttribute("AutoClickMode","Free")
 check(data.AwardAutoClickXP(p,1,"Free")>0,"server free-auto click awards use the shared XP pipeline")
 check(data.AwardAutoClickXP(p,1,"OP")==0 and data.AwardAutoClickXP(p,7,"Free")==0 and data.AwardAutoClickXP(p,math.huge,"Free")==0,"wrong modes and malformed automatic awards cannot grant XP")
 p.Character:FindFirstChildOfClass("Humanoid").Health=0;env.time+=1
 check(not data.ClickXP(p)and data.AwardAutoClickXP(p,1,"Free")==0,"dead characters cannot farm manual or automatic clicks")
end
do
 local env=environment();local config=env.Instance.new("ModuleScript");config.Name="ClickerConfig";config.__module=ClickerConfig;config.Parent=env.rs
 local calls=0;local awards=0
 local data={IsReady=function()return true end,ClickXP=function()calls+=1 end,AwardAutoClickXP=function(_,count)awards+=count end}
 runClickerService(env,data)
 local p=env.player(9932);env.players.PlayerAdded:Fire(p)
 check(p:GetAttribute("AutoClickMode")=="Off","new players never start an automatic clicker implicitly")
 check(env.rs.ToggleAutoClick.OnServerInvoke(p,"Free"),"free automatic clicker can be selected")
 for i=1,600 do env.heartbeat:Fire(1/60)end
 check(awards==30,"real server scheduler grants three free clicks per second")
 env.time+=.2;check(env.rs.ToggleAutoClick.OnServerInvoke(p,"OP"),"OP trial can be selected without a fake purchase")
 awards=0;for i=1,600 do env.heartbeat:Fire(1/60)end
 check(awards==60,"changing to OP replaces free mode instead of stacking both rates")
 env.time+=.2;env.rs.ToggleAutoClick.OnServerInvoke(p,"Off");awards=0;env.heartbeat:Fire(1)
 check(awards==0,"off mode stops automatic rewards")
 check(not env.rs.ToggleAutoClick.OnServerInvoke(p,"Hacked"),"malformed mode request is rejected")
 env.rs.ClickTraining.OnServerEvent:Fire(p,100000)
 check(calls==1,"manual remote ignores client supplied reward counts")
end
