do
 for _,v in {235,1050,7500}do
  local p=Motion.Create(v,196.2)
  local v0,h0=Motion.Sample(p,0)
  check(v0==0 and h0==0,"rocket starts at rest instead of a cannon impulse")
  local vi,hi=Motion.Sample(p,p.Ignition)
  local vb,hb=Motion.Sample(p,p.Burn);local peak=Motion.Sample(p,p.PeakTime)
  check(math.abs(vi-p.Idle)<.001 and peak>vi,"ignition builds slowly before the boost peak")
  local _,apex=Motion.Sample(p,p.ApexTime)
  check(math.abs(apex-p.TargetHeight)<.001,"smooth rocket reaches its configured progression height at power "..v)
  local vl,hl=Motion.Sample(p,p.Burn-1e-5)
  check(math.abs(vl-vb)<p.Peak*.0001 and math.abs(hl-hb)<.1,"rocket burnout has no velocity or position discontinuity")
  local va,ha,throttle,phase,fuel=Motion.Sample(p,p.ApexTime+.3)
  check(va<0 and ha<apex and throttle==0 and phase=="Empty"and fuel==0,"empty rocket falls and shuts off exhaust")
  local previous=-1
  for i=0,30 do local speed=Motion.Sample(p,p.PeakTime*i/30);check(speed>=previous,"powered ascent accelerates monotonically");previous=speed end
 end
end
