do
 local env=environment();local V=env.Vector3;V.one=V.new(1,1,1);V.yAxis=V.new(0,1,0)
 env.Color3.new=function(r,g,b)return env.Color3.fromRGB(r*255,g*255,b*255)end
 local zone=newDiveBreakZone(env);local course=newBreakCourse(env);local p=env.player(9991);local parent=env.Instance.new("Folder");parent.Parent=env.workspace
 local z=zone.Create(p,777,parent,60);z.FlightExtras=true;zone.Update(z,V.new(0,600,0),V.new(0,-90,0),true)
 local function noop()end
 zone.Sample(z,V.new(0,500,0),V.new(0,400,0),true,course.Touches,noop)
 check(z.Rows[1].Model:GetAttribute("Broken")and not z.Rows[2].Model:GetAttribute("Broken"),"center hit leaves untouched side targets visible")
 zone.Sample(z,V.new(-230,500,0),V.new(-230,400,0),true,course.Touches,noop)
 check(z.BonusHits==1,"a separately crossed side target still grants its own reward")
 local score=zone.Sample(z,V.new(-230,500,0),V.new(-230,400,0),true,course.Touches,noop)
 check(score==0,"same side target cannot pay twice")
 local turned=zone.Create(p,779,parent,60)
 zone.Update(turned,V.new(0,600,0),V.new(0,-90,0),true,V.new(0,0,-1))
 check(turned.Rows[3].Position.Z==-200 and turned.Rows[3].Position.X==0,"side targets align to the frozen camera right rather than world X")
 zone.Update(turned,V.new(0,550,0),V.new(0,-90,0),true,V.new(1,0,0))
 check(turned.Basis.Z==-1,"looking around does not move an already spawned lane")
 local row=course.Plan(V.new(0,10000,0),V.new(0,-1200,0),196.2,190,true)[1]
 row.Frame=env.CFrame.new(row.Position)
 check(row.Size.X==360 and row.Size.Y==280 and course.Touches(row,row.Position+V.new(170,100,50),row.Position+V.new(170,-100,-50)),"wide descending course tolerates large aim errors")
 local extra=zone.Create(p,778,parent,60);zone.Extras(extra,V.new(0,12575,0))
 check(#extra.Rings==10 and #extra.Enemies==18,"high flight contains ten rings and two enemy rows per crossed cloud")
 check(#zone.RingPlan(149)<10 and #zone.RingPlan(149)>0,"short beginner flight clips the ring sequence above ground")
 check(zone.Crosses(V.new(0,100,0),V.new(160,150,0),V.new(160,50,0),170),"large ring accepts an off-center descent")
 check(not zone.Crosses(V.new(0,100,0),V.new(0,50,0),V.new(0,150,0),170),"ascending flight cannot claim descent rings")
 extra.Rows={};local enemies=extra.Enemies;extra.Enemies={};local events=0
 score=zone.Sample(extra,V.new(0,13000,0),V.new(0,0,0),true,course.Touches,function(d)check(d.DiveRing,"ring crossings emit dedicated feedback");events+=1 end)
 check(events==10 and extra.RingHits==10 and score==600,"high-speed segment claims every ring once")
 check(zone.Sample(extra,V.new(0,13000,0),V.new(0,0,0),true,course.Touches,noop)==0,"ring repeat does not duplicate awards")
 extra.Enemies=enemies;score=zone.Sample(extra,V.new(0,13000,0),V.new(0,0,0),true,course.Touches,function(d)check(d.DiveEnemy and d.Pierce,"cloud enemy emits harmless pierce feedback")end)
 check(extra.EnemyHits==6 and score==360,"descending player pierces two enemies in each of three clouds")
 local state={Active=1,Age=99,Slow=2};local result=GateRules.Step(state,CloudConfig.HeightPresentation.Gates,650,550,10,true,-1)
 check(result=="Diving"and state.Age==0 and state.Slow==0,"descending inside cloud never catches or kills regardless of dwell")
 check(GateRules.Step(state,CloudConfig.HeightPresentation.Gates,550,450,10,true,-1)==nil and state.Active==nil,"descent clears cloud state below its floor")
end
