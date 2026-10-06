-- Temporary free playtest catalogue. Disable before monetization/release.
local C={TemporaryFreeTesting=true,Duration=900,FriendPercent=.1,
 Foods={{Name="None",Percent=0},{Name="Snack",Percent=.05},{Name="Meal",Percent=.1},{Name="Feast",Percent=.2}},
 Products={Wins2={Name="x2 Wins",Multiplier=2,Kind="Wins"},Power2={Name="x2 Power",Multiplier=2,Kind="Power"},Power4={Name="x4 Power",Multiplier=4,Kind="Power"},Power8={Name="x8 Power",Multiplier=8,Kind="Power"}}}
function C.Apply(base,multiplier,foodPercent,friendPercent)
 return math.min(2^53-1,base*multiplier*(1+foodPercent)*(1+friendPercent))
end
function C.Active(multiplier,expires,now)
 return if expires>now then multiplier else 1
end
return C
