do
 local env=environment();local V=env.Vector3;local impact=newDiveImpact(env)
 local char=env.Instance.new("Model")
 local root=env.Instance.new("Part");root.CFrame=env.CFrame.new(0,20,0);root.Size=V.new(2,2,2);root.Parent=char
 local foot=env.Instance.new("Part");foot.CFrame=env.CFrame.new(0,17,0);foot.Size=V.new(2,2,2);foot.Parent=char
 local rocket=env.Instance.new("Part");rocket.CFrame=env.CFrame.new(0,0,0);rocket.Size=V.new(20,20,20);rocket.CanCollide=false;rocket.Parent=char
 check(impact.BottomOffset(char,root)==4,"ground contact follows the solid body, ignoring decorative rocket extent")
 local calls=0;local paramsSeen
 local world={Raycast=function(_,from,delta,params)
  calls+=1;paramsSeen=params
  if from.Y>=6 and from.Y+delta.Y<=6 then
   local t=(6-from.Y)/delta.Y
   return {Position=from+delta*t,Instance=foot}
  end
  return nil
 end}
 local hit,contact=impact.Sweep(world,char,root,V.new(10,-10000,0),.05)
 check(hit~=nil and contact.Y==10,"fast dives stop at actual body contact without tunneling through ground")
 check(math.abs(contact.X-.01)<.00001,"impact position follows horizontal steering along the swept path")
 check(paramsSeen.RespectCanCollide and paramsSeen.FilterDescendantsInstances[1]==char,"ground sweep ignores own character and noncolliding scenery")
 check(impact.Sweep(world,char,root,V.new(0,-90,0),.05)==nil,"nearby ground does not trigger an early landing before contact")
 local prior=calls
 check(impact.Sweep(world,char,root,V.new(0,90,0),.05)==nil and calls==prior,"ascent cannot trigger a dive ground impact")
 root.CFrame=env.CFrame.new(0,-100,0);foot.CFrame=env.CFrame.new(0,-103,0)
 local crossed,exact=impact.Sweep(world,char,root,V.new(0,-10000,0),.02,V.new(0,20,0))
 check(crossed~=nil and exact.Y==10,"sweep catches a floor crossing between physics frames even after overshoot")
 local rules=newRocketRules(env);local speed=0
 for i=1,600 do
  local nextSpeed=rules.DiveSpeed(speed,1000,196.2,i/60,1/60)
  if i==60 or i==240 or i==600 then check(nextSpeed>=speed,"descent retains speed as it approaches the floor")end
  speed=nextSpeed
 end
 check(speed==1000,"long descent reaches terminal speed without floor braking")
end
