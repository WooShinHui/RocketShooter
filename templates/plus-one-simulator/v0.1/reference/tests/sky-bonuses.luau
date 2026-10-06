do
 local env=environment();env.workspace.GetServerTimeNow=function()return env.time end
 local V=env.Vector3;V.one=V.new(1,1,1);local life=newSkyLife(env)
 local folder=env.Instance.new("Folder");folder.Name="SkyLife";folder.Parent=env.workspace
 local p=env.player(6900);local visited={serial=1}
 local models={}
 for i=1,7 do
  local m=env.Instance.new("Model");m.Parent=folder;m:SetAttribute("SkyKind","Bonus");m:SetAttribute("TargetId",100+i)
  m:SetAttribute("PartyGroup",1);m:SetAttribute("PartyEndsAt",env.time+20);m:SetAttribute("Score",15);m:SetAttribute("HitRadius",24)
  local body=env.Instance.new("Part");body.Parent=m;body.Position=V.new((i-1)*20,100,0);m.PrimaryPart=body;table.insert(models,m)
 end
 local rewarded=0
 check(life.Collect(p,V.new(0,90,0),V.new(0,110,0),visited,function()rewarded+=1 end)==105,"one party contact chains all seven dumplings")
 check(rewarded==7,"seven logical party targets trigger seven trophy awards")
 check(models[7].PrimaryPart.Transparency==1 and models[7]:GetAttribute("AvailableAt")==env.time+12,"chain hides and cools down every member, including distant ones")
 check(life.Collect(p,V.new(0,90,0),V.new(0,110,0),visited,function()rewarded+=1 end)==0,"same party wave cannot duplicate run score")
 check(rewarded==7,"repeat party sweep cannot duplicate trophies")
 env.time+=21;for _,job in env.queued do job[1]() end
 check(models[1].PrimaryPart.Transparency==1,"expired party cannot be resurrected by delayed respawn")
 for i,m in models do m:SetAttribute("TargetId",200+i);m:SetAttribute("PartyEndsAt",env.time+20);m:SetAttribute("AvailableAt",0) end
 check(life.Collect(p,V.new(0,90,0),V.new(0,110,0),visited)==105,"next wave has independent ids even within one long run")
end
do
 local env=environment();env.workspace.GetServerTimeNow=function()return env.time end
 local V=env.Vector3;V.one=V.new(1,1,1);local life=newSkyLife(env)
 local folder=env.Instance.new("Folder");folder.Name="SkyLife";folder.Parent=env.workspace
 local m=env.Instance.new("Model");m.Parent=folder;m:SetAttribute("SkyKind","Island");m:SetAttribute("TargetId",1);m:SetAttribute("Score",60)
 m:SetAttribute("HitRadius",21);m:SetAttribute("HitBoxSize",V.new(120,64,90))
 local body=env.Instance.new("Part");body.CFrame=env.CFrame.new(0,100,0);body.Parent=m;body:SetAttribute("CollisionProxy",true);m.PrimaryPart=body
 local cell=env.Instance.new("Part");cell.Parent=m
 local p=env.player(6901);local visited={serial=1}
 local rewarded=0
 check(life.Collect(p,V.new(55,0,0),V.new(55,200,0),visited,function()rewarded+=1 end)==60,"large block uses swept box extent, including wide edges")
 check(rewarded==1,"large multi-part island counts as one logical object")
 check(life.Collect(p,V.new(55,0,0),V.new(55,200,0),visited,function()rewarded+=1 end)==0,"large block awards exactly once per run")
 check(rewarded==1,"repeated island crossing cannot duplicate trophy reward")
 env.time+=12;for _,job in env.queued do job[1]() end
 check(body.Transparency==1 and cell.Transparency==0,"respawn restores candy cells while keeping the invisible proxy hidden")
end
