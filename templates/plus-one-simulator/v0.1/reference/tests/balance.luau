-- Analytic ballistics, not Studio physics. Historical cannon geometry, gravity
-- 196.2, landing root Y=7.5, no rings/steering/collisions/ground slide.
local function prediction(level, old, pitch, timing)
 pitch,timing=math.rad(pitch or 25),timing or 1
 local s,c,g=math.sin(pitch),math.cos(pitch),196.2
 local originY=9.247150+7.991204*s
 local startY=originY+8*s
 local h,v=Balance.LaunchComponents(level,s,timing)
 if old then h=(240+14*(level-1)^0.72)*c*timing; v=math.clamp(260*s*(1+(timing-1)*0.2),-35,135) end
 local t=(v+math.sqrt(v*v+2*g*(startY-7.5)))/g
 local x=8*c+h*t
 local distance=math.sqrt(x*x+(7.5-originY)^2)
 local cost=old and math.floor(120+30*(level-1)+2*(level-1)^1.4) or Balance.PowerCost(level)
 local gold=Balance.GoldReward(distance)
 return {x=x,apex=startY+math.max(0,v)^2/(2*g),time=t,h=h,v=v,startY=startY,gold=gold,cost=cost,runs=cost/gold}
end
print('A+B: level | before/after | pitch | forward | apex Y | seconds | Gold | cost | run equivalents')
for _,level in ipairs({1,5,10,20,50}) do
 for _,old in ipairs({true,false}) do
  for _,pitch in ipairs({15,25,45}) do
   local p=prediction(level,old,pitch)
   print(string.format('%d | %s | %d | %.1f | %.1f | %.2f | %d | %d | %.2f',level,old and 'before' or 'after',pitch,p.x,p.apex,p.time,p.gold,p.cost,p.runs))
  end
 end
end
local previous=prediction(1,false)
check(prediction(1,false,45,1.5).apex<CloudConfig.EnterAltitude,'L1 cannot reach Clouds with timing alone')
check(prediction(10,false,45,1.5).apex>=CloudConfig.EnterAltitude
 and prediction(15,false,45).apex>=CloudConfig.EnterAltitude,'early steep-angle growth unlocks first cloud attempts')
check(prediction(20,false,45).apex>CloudConfig.EnterAltitude+20
 and prediction(50,false,25).apex<CloudConfig.EnterAltitude,'Clouds reward height choice, not horizontal Power alone')
local growth,effort,step=true,true,true
for level=2,200 do
 local p=prediction(level,false)
 growth=growth and p.x>previous.x and p.apex>previous.apex and p.time>previous.time
 effort=effort and p.cost/p.x^0.85>previous.cost/previous.x^0.85
 step=step and p.x/previous.x<1.1
 previous=p
end
check(growth,'levels 1-200 increase range, apex and airtime')
check(effort,'levels 1-200 increase unrounded upgrade effort')
check(step,'single-level baseline range gain below ten percent')
check(prediction(1,false).gold==46 and Balance.PowerCost(1)==120,'first baseline upgrade still needs three successful runs')
for _,level in ipairs({1,5,10,20,50,200}) do
 local low,mid,high=prediction(level,false,15),prediction(level,false,25),prediction(level,false,45)
 check(low.x>high.x and low.apex<mid.apex and mid.apex<high.apex and mid.x>high.x,'aim trades reach for height at level '..level)
 local before=prediction(level,true)
 check(mid.runs>=before.runs*0.95 and mid.runs<=before.runs*1.1,'baseline upgrade effort stays within -5/+10 percent at level '..level)
end
check(prediction(200,false,45).apex>1500,'long-term growth allows future altitude layers')
for _,timing in ipairs({0.7,1,1.5}) do
 local h,v=Balance.LaunchComponents(2^53-1,math.sin(math.rad(45)),timing)
 check(h<=20000 and v<=Balance.Vertical.MaxUp and h==h and v==v,'extreme legacy levels remain finite')
end
check(Balance.PowerCost(2^53-1)==2^53-1,'safe integer price ceiling retained')
local h,v=Balance.LaunchComponents(50,math.sin(math.rad(45)),1)
local budget=Balance.RingLiftBudget(v)
local rh,rv,remaining=h,v,budget
for _=1,100 do
 local lift
 rh,rv,lift=Balance.RingComponents(rh,rv,50,h,remaining)
 remaining-=lift
end
check(near(rh,h*1.35) and near(rv-v,budget) and remaining>=0,'repeated rings obey horizontal and total run lift budgets')
local _,kept,lift=Balance.RingComponents(h,400,1,h,0)
check(kept==400 and lift==0,'spent ring budget preserves high-altitude upward momentum')
local _,raised=Balance.RingComponents(h,400,1,h,25)
check(raised==425,'ring can lift above former altitude cap')
check(Balance.RingComponents(h,0,5,h,budget)>Balance.RingComponents(h,0,1,h,budget),'Boost still improves horizontal gain')
check(Balance.RingComponents(h*2,0,1,h,budget)==h*2,'ring preserves external forward momentum')
local worst=1
for _,level in ipairs({1,5,10,20,50}) do
 for _,angle in ipairs({15,25,45}) do
  local p=prediction(level,false,angle)
  for _,fraction in ipairs({0,0.25,0.5,0.75}) do
   local t=p.time*fraction
   local y=p.startY+p.v*t-196.2*t*t/2
   local vy=(p.v-196.2*t)*Balance.Bomb.SpeedFactor-Balance.Bomb.DownwardImpulse
   local remain=(vy+math.sqrt(vy*vy+392.4*(y-7.5)))/196.2
   local x=8*math.cos(math.rad(angle))+p.h*t+p.h*Balance.Bomb.SpeedFactor*remain
   worst=math.min(worst,x/p.x)
  end
 end
end
check(worst>0.75,'single collision retains over 75 percent of representative ballistic range')
print(string.format('Worst collision retained range: %.1f%%',worst*100))
for _,p in ipairs(newObstaclePatterns(environment()).Placements(GameLevelConfig.Obstacles)) do
 check(math.abs(p.Lateral)-p.Size.X/2>45 and p.Height+p.Size.Y/2<=45,'open center corridor and fixed low obstacles')
end
do
 local env=flightEnvironment(); local a,b=env.player(901),env.player(902)
 local id=env.enter(a); env.fire(a,id)
 local root=a.Character.HumanoidRootPart
 local function ringFor(r)
  local part=env.Instance.new('Part'); part.CFrame=env.CFrame.new(r.Position)
  part.Size=env.Vector3.new(42,42,5); return part
 end
 local ring=ringFor(root)
 for _=1,20 do env.time+=1; env.flight.ApplyGimmick(ring,root,'Ring') end
 check(near(root.AssemblyLinearVelocity.Y,25),'service limits zero-pitch run total lift to 25')
 local bid=env.enter(b); env.fire(b,bid)
 local br=b.Character.HumanoidRootPart; env.flight.ApplyGimmick(ringFor(br),br,'Ring')
 check(near(br.AssemblyLinearVelocity.Y,25),'players have independent ring budgets')
 env.rs.ReturnToSpawn.OnServerEvent:Fire(a,id); env.step(0)
 local nextId=env.enter(a); env.fire(a,nextId); root=a.Character.HumanoidRootPart
 env.flight.ApplyGimmick(ringFor(root),root,'Ring')
 check(near(root.AssemblyLinearVelocity.Y,25),'new run receives fresh ring budget')
 a.Character.Humanoid.Died:Fire(); local velocity=root.AssemblyLinearVelocity
 env.flight.ApplyGimmick(ringFor(root),root,'Ring')
 check(root.AssemblyLinearVelocity==velocity,'cancelled run ignores late ring contact')
end

do
 local _,up=Balance.LaunchComponents(10000,math.sin(math.rad(65)),1)
 check(up*up/(2*196.2)>100000,"late progression can actually reach the 100km space threshold")
 check(up/196.2+35+up/196.2<120,"100km ascent and bounded descent fit the run timeout")
end
