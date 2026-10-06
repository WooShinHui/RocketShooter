-- Tuning lives here; clients display it, servers validate every mutation.
local C = {RebirthGain = 0.5, MaxRebirths = 1000000,
	TrophyPads={
		{Required=0,Multiplier=1,Color=Color3.fromRGB(94,223,113)},
		{Required=3,Multiplier=2,Color=Color3.fromRGB(87,223,240)},
		{Required=15,Multiplier=3,Color=Color3.fromRGB(251,210,65)},
		{Required=100,Multiplier=5,Color=Color3.fromRGB(195,130,252)},
		{Required=500,Multiplier=10,Color=Color3.fromRGB(255,135,88)},
	},
	Tiers = {
		{Name="Wood", Level=1, Cost=0, Rate=1, Color=Color3.fromRGB(147,98,62)},
		{Name="Stone", Rebirths=1, Level=5, Cost=5, Rate=1.5, Color=Color3.fromRGB(148,158,168)},
		{Name="Iron", Rebirths=2, Level=10, Cost=15, Rate=3, Color=Color3.fromRGB(90,135,162)},
		{Name="Gold", Rebirths=3, Level=15, Cost=40, Rate=5, Color=Color3.fromRGB(255,201,52)},
		{Name="Diamond", Rebirths=4, Level=20, Cost=80, Rate=7.5, Color=Color3.fromRGB(65,225,255)},
		{Name="Emerald", Level=20, Rebirths=5, Cost=160, Rate=10, Color=Color3.fromRGB(54,240,130)},
		{Name="Divine", Level=20, Rebirths=6, Cost=320, Rate=15, Color=Color3.fromRGB(206,130,255)},
	}}
C.XPItems={
 {Name="Basic Gloves",Multiplier=1,Cost=0},
 {Name="Training Gloves",Multiplier=1.5,Cost=5},
 {Name="Enhanced Gloves",Multiplier=2,Cost=20},
 {Name="Golden Gloves",Multiplier=3,Cost=60},
 {Name="Crystal Gloves",Multiplier=5,Cost=200},
 {Name="Space Gloves",Multiplier=10,Cost=700},
 {Name="Legendary Gloves",Multiplier=20,Cost=2500},
}
for _,item in C.XPItems do table.freeze(item) end;table.freeze(C.XPItems)
function C.PassiveXPRate(_level) return 1 end
-- Twenty-level bands increase the slope; from level60 an extra factor counters late bonuses.
-- No level cap. Saturation only protects Roblox's exact integer storage limit.
local MAX=2^53-1
local function lateBand(b) return 1+math.max(0,math.min(b,202)-2) end
function C.RequiredXP(level)
 local l=math.max(0,level);return math.min(MAX,(4+l)*(2+math.floor(l/20))*lateBand(math.floor(l/20)))
end
function C.RebirthRequired(rebirths) return 20*(rebirths+1) end
-- Locate numeric saturation once; cumulative XP must use the same clamped cost.
local saturation=1
while C.RequiredXP(saturation)<MAX do saturation*=2 end
do
 local lo,hi=0,saturation
 while hi-lo>1 do local mid=math.floor((lo+hi)/2);if C.RequiredXP(mid)<MAX then lo=mid else hi=mid end end
 saturation=hi
end
function C.XPBetween(from,to)
 if to<=from then return 0 end
 if from>=saturation then return if to-from==1 then MAX else math.huge end
 if to>saturation then local total=C.XPBetween(from,saturation)+(to-saturation)*MAX;return if total>MAX then math.huge else total end
 local first,last=math.floor(from/20),math.floor((to-1)/20)
 local function partial(start,finish,band)
  local n=finish-start;return n*(4+start+(n-1)/2)*(2+band)*lateBand(band)
 end
 if first==last then local cost=partial(from,to,first);return if cost>MAX then math.huge else cost end
 local total=partial(from,(first+1)*20,first)+partial(last*20,to,last)
 local function complete(a,b)
  local n=b-a+1;if n<=0 then return 0 end
  local s1=n*a+n*(n-1)/2
  local s2=n*a*a+a*n*(n-1)+n*(n-1)*(2*n-1)/6
  if a>=3 and b<=202 then
   local k=n*(n-1)/2
   local s3=n*a^3+3*a*a*k+3*a*n*(n-1)*(2*n-1)/6+k*k
   return 400*s3+670*s2-530*s1-540*n
  end
  return (400*s2+1070*s1+540*n)*lateBand(a)
 end
 local a,b=first+1,last-1
 total+=complete(a,math.min(b,2))+complete(math.max(a,3),math.min(b,202))+complete(math.max(a,203),b)
 -- Above the exact range must compare greater than any accepted XP award.
 return if total>MAX then math.huge else total
end
-- Binary search handles event awards across bands without a per-level loop.
function C.Advance(level,xp)
 if xp<C.RequiredXP(level) then return level,xp end
 local lo,hi=0,math.floor(xp/C.RequiredXP(level))+1
 while hi-lo>1 do
  local mid=math.floor(lo+(hi-lo)/2)
  if C.XPBetween(level,level+mid)<=xp then lo=mid else hi=mid end
 end
 return level+lo,xp-C.XPBetween(level,level+lo)
end
function C.GoldRingXP(level) return math.min(2^53-1,math.max(200,C.XPBetween(level,level+4))) end
function C.Multiplier(rebirths) return 1+C.RebirthGain*math.clamp(rebirths,0,C.MaxRebirths) end
-- Keep the previously tuned rocket acceleration/height independent of XP pacing.
function C.PowerMultiplier(rebirths) return (1+C.RebirthGain)^math.clamp(rebirths,0,30)*(1+math.max(0,rebirths-30)*.02) end
function C.PowerBonus(level,rebirths) return math.floor(math.max(0,level-1)*3*C.PowerMultiplier(rebirths)) end
for _,t in C.Tiers do table.freeze(t) end
table.freeze(C.Tiers)
for _,p in C.TrophyPads do table.freeze(p) end
table.freeze(C.TrophyPads)
return table.freeze(C)
