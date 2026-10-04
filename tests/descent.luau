do
 local env=environment();local V=env.Vector3;local d=newDescentChallenge(env)
 check(d.Create(V.new(0,15,0),V.new(0,0,-20),0,196.2,1)==nil,"low flights safely skip descent challenge")
 local route=d.Create(V.new(0,180,0),V.new(0,0,-25),0,196.2,1)
 check(#route.Rings==3 and route.Rings[1].Position.Y>route.Rings[2].Position.Y and route.Rings[2].Position.Y>route.Rings[3].Position.Y,"descent route has three descending gates")
 for _,r in route.Rings do d.Sample(route,r.Position+V.new(0,40,0),r.Position-V.new(0,40,0)) end
 check(route.Count==3,"swept hits detect gates even between physics samples")
 for _,r in route.Rings do d.Sample(route,r.Position+V.new(0,40,0),r.Position-V.new(0,40,0)) end
 check(route.Count==3,"repeated crossing cannot farm ring reward")
 local reward,grade=d.Reward(route,route.Target+V.new(0,3,0),"Ground")
 check(reward==6 and grade=="정중앙!","three rings and perfect landing give six bonus trophies")
 local outer=d.Reward(route,route.Target+V.new(20,3,0),"Ground")
 check(outer==4,"outer landing gives one trophy plus ring rewards")
 check(d.Reward(route,route.Target+V.new(0,80,0),"Ground")==3,"landing on elevated scenery cannot earn ground target reward")
 check(d.Reward(route,route.Target,"SkyIsland")==3,"sky landing cannot earn ground bullseye reward")
 local miss=d.Create(V.new(0,180,0),V.new(0,0,-25),0,196.2,2)
 local r=miss.Rings[1];d.Sample(miss,r.Position+V.new(50,30,0),r.Position+V.new(50,-30,0))
 check(miss.Count==0 and r.Passed,"missed rings close without award")
 local rise=d.Create(V.new(0,180,0),V.new(0,0,-25),0,196.2,3)
 r=rise.Rings[1];d.Sample(rise,r.Position-V.new(0,30,0),r.Position+V.new(0,30,0))
 check(rise.Count==0 and not r.Passed,"ascending crosses cannot count as descent hits")
 local high=d.Create(V.new(0,16000,0),V.new(0,0,-25),0,196.2,4)
 check(d.TimeToFall(16000,196.2,high.Speed)<40,"extreme height descent stays bounded below flight timeout")
 local independent=d.Create(V.new(100,180,0),V.new(0,0,-25),0,196.2,5)
 check(independent.Count==0 and independent.Rings[1]~=route.Rings[1],"players and repeated flights have independent challenge state")
end
do
 local env=flightEnvironment();local p=env.player(6800);local id=env.enter(p);env.fire(p,id)
 p.Character.Humanoid.FloorMaterial="Grass";env.step(1);env.step(.2)
 check(#env.awards==1 and p:GetAttribute("FlightState")=="Result","landing awards once before automatic return")
 env.step(.4);for _,job in env.queued do job[1]() end
 check(p:GetAttribute("FlightState")=="Idle" and p.loadCount==1,"landing automatically respawns without client button")
 check(#env.awards==1,"automatic return cannot duplicate reward")
end

do
 local route={Speed=4000}
 check(newDescentChallenge(environment()).FallSpeed(route,100)==100,"high-flight descent brakes near the ground")
 local challenge=newDescentChallenge(environment());local seconds=challenge.TimeToFall(140000,196.2,4000,140000)
 check(seconds>5 and seconds<45,"100km-plus descent has a bounded and landable duration")
end
