-- Uses the same trajectory as server flight. Numbers refer to HUD training power.
local R={}
function R.Crossing(profile,height,sample)
 local lo,hi=0,profile.Burn
 for _=1,28 do local mid=(lo+hi)/2;local _,y=sample(profile,mid);if y>=height then hi=mid else lo=mid end end
 return hi
end
function R.CanPass(gate,originY,profile,sample)
 local margin=math.max(14,gate.Top*.005)
 if profile.TargetHeight+originY<gate.Top+margin then return false end
 local entered=R.Crossing(profile,math.max(0,gate.Bottom-originY),sample)
 local escaped=R.Crossing(profile,gate.Top-originY,sample)
 local speed=sample(profile,escaped)
 return escaped-entered<gate.Grace-.18 and speed>=35
end
function R.Power(gate,originY,makeProfile,sample)
 local lo,hi=0,64
 while not R.CanPass(gate,originY,makeProfile(hi),sample)do hi*=2 end
 while hi-lo>1 do local mid=math.floor((lo+hi)/2);if R.CanPass(gate,originY,makeProfile(mid),sample)then hi=mid else lo=mid end end
 return hi
end
return table.freeze(R)
