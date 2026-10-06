-- Altitude comes from progression. Time controls pacing independently of altitude.
local Motion={}
function Motion.Create(vertical,gravity)
 local base=260*math.sin(math.rad(65))
 local height=vertical*vertical/(2*gravity)
 local duration=5+math.min(7,math.log(math.max(1,vertical/base))*2)
 local peak=height*1.875/duration
 local ignitionU=.65/duration
 return {LaunchSpeed=vertical,Ignition=.65,Peak=peak,PeakTime=duration/2,Burn=duration,Gravity=gravity,
  Idle=height/duration*30*ignitionU^2*(1-ignitionU)^2,BurnHeight=height,ApexTime=duration,TargetHeight=height}
end
-- Rocket-only progression bypasses the legacy cannon speed clamp.
-- Logarithmic growth beyond the former ceiling prevents exponential rebirth power
-- from producing astronomical coordinates while still increasing reachable height.
function Motion.CreateRocket(vertical,gravity)
 local p=Motion.Create(vertical,gravity)
 local formerHeight=7500^2/(2*gravity)
 if p.TargetHeight>formerHeight then
  local height=formerHeight*(1+math.log(p.TargetHeight/formerHeight))
  local duration=math.max(p.Burn,height*1.875/25000)
  local ignitionU=p.Ignition/duration
  p.LaunchSpeed=math.sqrt(2*gravity*height)
  p.TargetHeight=height;p.BurnHeight=height;p.Burn=duration;p.ApexTime=duration
  p.PeakTime=duration/2;p.Peak=height*1.875/duration
  p.Idle=height/duration*30*ignitionU^2*(1-ignitionU)^2
 end
 return p
end
function Motion.Sample(p,time)
 local t=math.max(0,time);local velocity,height,throttle,phase
 if t<p.Burn then
  local u=t/p.Burn
  velocity=p.TargetHeight/p.Burn*30*u^2*(1-u)^2
  height=p.TargetHeight*(6*u^5-15*u^4+10*u^3)
  throttle=.12+.88*16*u^2*(1-u)^2
  phase=if t<p.Ignition then "Ignition"elseif t<p.PeakTime then "Boost"else "Burnout"
 else
  local coast=t-p.Burn;velocity=-p.Gravity*coast;height=p.TargetHeight-p.Gravity*coast*coast/2
  throttle=0;phase="Empty"
 end
 return velocity,height,throttle,phase,math.clamp(1-t/p.ApexTime,0,1)
end
return table.freeze(Motion)
