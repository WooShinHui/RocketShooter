do
 local env=environment();local originalType=env.typeof
 env.typeof=function(v)return if type(v)=="table"and getmetatable(v)and getmetatable(v).__type=="Vector2"then "Vector2"else originalType(v)end
 local rules=newRocketRules(env);local V=env.Vector3
 local function input(x,y)return setmetatable({X=x,Y=y,Magnitude=math.sqrt(x*x+y*y)},{__type="Vector2"})end
 check(rules.Input(input(.7,-.7))~=nil,"rocket accepts normalized four-direction movement")
 check(rules.Input(input(1,1))==nil and rules.Input(input(2,0))==nil,"rocket rejects diagonal speed inflation and excessive input")
 check(rules.Input(input(0/0,0))==nil and rules.Input(1)==nil,"rocket rejects nonfinite and legacy scalar control packets")
 check(not rules.Fallen(100,93, -20,8)and rules.Fallen(100,92,-20,8),"rocket respawns only after the configured small apex drop")
 check(not rules.Fallen(100,90,20,8),"ascending player cannot trigger apex fall")
 check(rules.Step(V.zero,V.new(90,0,90),240,.05).Magnitude<=12.001,"rocket horizontal acceleration is bounded across both axes")
 check(rules.Trophies(0)==0 and rules.Trophies(4)==4,"only verified trophy zone reward grants trophy currency")
 local economy=newRocketEconomy(env)
 local legacy={Gold=100,Trophies=7,BoostLvl=3,PowerLvl=50,EconomyVersion=0,XPGearLvl=1}
 local upgraded=economy.Migrate(legacy,7)
 check(upgraded.Trophies==107 and upgraded.Gold==0 and upgraded.EconomyVersion==1,"old gold converts into trophies once")
 check(upgraded.PowerLvl==50 and upgraded.XPGearLvl==3 and legacy.Gold==100,"conversion preserves purchased propulsion and boost investment without mutating input")
 check(economy.Migrate(upgraded,7).Trophies==107,"rejoining cannot convert gold twice")
 check(economy.Migrate({Gold=2^53-1,Trophies=1,BoostLvl=1,EconomyVersion=0},7)==nil,"currency conversion rejects integer overflow")
 check(economy.Migrate({Gold=0,Trophies=0,BoostLvl=1,EconomyVersion=2},7)==nil,"newer save version cannot be silently downgraded")
end
do
 local env=environment()
 for name,module in {ProgressionConfig=Growth,RocketModeConfig={Enabled=true}}do local m=env.Instance.new("ModuleScript");m.Name=name;m.__module=module;m.Parent=env.rs end
 env.saved={Gold=100,Trophies=7,PowerLvl=50,BoostLvl=3,UnknownPreserved=99}
 local data=newPlayerData(env,{RunPolicy=Policy,RocketEconomy=newRocketEconomy(env)})
 data.Start();local p=env.player(9801);env.players.PlayerAdded:Fire(p)
 check(data.IsReady(p)and p.leaderstats.Trophies.Value==107,"rocket data load commits migration only after a valid profile")
 check(p.leaderstats:FindFirstChild("Gold")==nil and p.ProgressStats.Gold.Value==0,"gold is removed from visible rocket currencies")
 check(data.GetLevel(p,"PowerLvl")==50 and p.leaderstats.XPGearLvl.Value==3,"rocket data preserves legacy propulsion and maps boost to XP equipment")
 check(not data.Buy(p,"Gold")and not data.Buy(p,"Trophy")and not data.ClickXP(p),"obsolete direct-power purchases and free ground clicks are rejected in rocket mode")
 p:SetAttribute("TrainingBuffIndex",3);p:SetAttribute("FlightState","Flying")
 check(data.AwardFlightXP(p,1)==6 and p.leaderstats.TrainingXP.Value==6,"one base flight XP is amplified by equipped item and selected trophy pad")
 check(not data.BuyXPItem(p,4),"XP equipment purchase cannot mutate an active flight")
 p:SetAttribute("FlightState","Idle");p:SetAttribute("TrainingBuffIndex",4)
 check(data.TrophyMultiplier(p)==5,"current trophy holdings activate the configured buff")
 check(data.BuyXPItem(p,4)and p.leaderstats.Trophies.Value==47 and p.leaderstats.XPGearLvl.Value==4,"XP equipment charges trophies and advances equipment exactly once")
 check(data.TrophyMultiplier(p)==1,"spending below a trophy requirement immediately relocks its XP buff")
 check(not data.BuyXPItem(p,4)and p.leaderstats.Trophies.Value==47,"stale equipment request cannot double spend trophies")
 check(data.Award(p,1,1,1,1)==nil,"rocket reward path cannot reintroduce gold")
 p.leaderstats.TrainingLevel.Value=20
 check(data.Rebirth(p,0)and p.leaderstats.TrainingLevel.Value==0 and p.leaderstats.XPGearLvl.Value==4 and p.leaderstats.Trophies.Value==47,"rebirth resets level while retaining XP equipment and trophy purchases")
 check(data.Save(p)and env.saved.EconomyVersion==1 and env.saved.Gold==0 and env.saved.Trophies==47 and env.saved.UnknownPreserved==99,"rocket save preserves unknown fields and commits one-time currency conversion")
end
