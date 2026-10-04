-- Run-local prototype. Server positions, swept-plane hits and landing rewards only.
local Challenge={RingRadius=22,TargetRadius=30,PerfectRadius=10}
function Challenge.FallSpeed(route,height)
 return math.min(route.Speed,math.max(100,math.max(0,height)/1.25))
end
function Challenge.TimeToFall(distance,gravity,speed,height)
 if height and speed>100 then
  local remaining=height;local target=math.max(0,height-distance);local velocity=speed;local elapsed=0
  while remaining>target and elapsed<120 do
   velocity=math.min(velocity+gravity*.025,math.min(speed,math.max(100,remaining/1.25)))
   local step=math.min(.025,(remaining-target)/math.max(1,velocity));remaining-=velocity*step;elapsed+=step
  end
  return elapsed
 end
 local ramp=speed/gravity;local rampDistance=speed*speed/(2*gravity)
 return if distance<=rampDistance then math.sqrt(2*math.max(0,distance)/gravity) else ramp+(distance-rampDistance)/speed
end
function Challenge.Create(position,velocity,groundY,gravity,id)
 local height=position.Y-groundY
 if height<25 or gravity<=0 then return nil end
 local speed=math.max(180,height/6)
 local direction=Vector3.new(velocity.X,0,velocity.Z)
 local flat=Vector3.zero
 local forward=if direction.Magnitude>.01 then direction.Unit else Vector3.new(0,0,-1)
 local right=Vector3.new(-forward.Z,0,forward.X)
 local route={Rings={},Count=0,Speed=speed,GroundY=groundY,Dive=true,Forward=forward}
 for i,fraction in {.75,.48,.22} do
  local y=groundY+height*fraction
  local time=Challenge.TimeToFall(position.Y-y,gravity,speed,height)
  local side=if id%2==0 then -1 else 1
  local offset=({0,24,48})[i]*side
  local center=position+flat*time+right*offset
  route.Rings[i]={Position=Vector3.new(center.X,y,center.Z),Hit=false,Passed=false}
 end
 local target=position+flat*Challenge.TimeToFall(height,gravity,speed,height)+right*(if id%2==0 then -50 else 50)
 route.Target=Vector3.new(target.X,groundY+.25,target.Z)
 return route
end
function Challenge.Sample(route,from,to)
 if not route or to.Y>=from.Y then return false end
 local changed=false
 for _,ring in route.Rings do
  if not ring.Passed and from.Y>=ring.Position.Y and to.Y<=ring.Position.Y then
   ring.Passed=true;changed=true
   local t=(from.Y-ring.Position.Y)/(from.Y-to.Y)
   local delta=from+(to-from)*t-ring.Position
   if Vector3.new(delta.X,0,delta.Z).Magnitude<=Challenge.RingRadius then ring.Hit=true;route.Count+=1 end
  end
 end
 return changed
end
function Challenge.Reward(route,position,landingType)
 if not route then return 0,"표적 밖",0 end
 local delta=position-route.Target;local radius=Vector3.new(delta.X,0,delta.Z).Magnitude
 local target=0;local grade="표적 밖"
 if landingType=="Ground" and math.abs(position.Y-route.GroundY)<12 then
  if radius<=Challenge.PerfectRadius then target=3;grade="정중앙!"
  elseif radius<=Challenge.TargetRadius then target=1;grade="표적 안!" end
 end
 return route.Count+target,grade,target
end
function Challenge.Payload(route)
 local rings={};for i,r in route.Rings do rings[i]={Position=r.Position,Hit=r.Hit,Passed=r.Passed} end
 return {Rings=rings,Target=route.Target,Count=route.Count,RingRadius=Challenge.RingRadius,TargetRadius=Challenge.TargetRadius,PerfectRadius=Challenge.PerfectRadius,Dive=route.Dive}
end
return Challenge
