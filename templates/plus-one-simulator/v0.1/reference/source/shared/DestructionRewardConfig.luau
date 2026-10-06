-- One logical destructible = one trophy base; debris fragments and XP rings do not count.
local C={BaseTrophies=1,Bands={{Height=0,Multiplier=1},{Height=260,Multiplier=2},{Height=850,Multiplier=3},{Height=3500,Multiplier=5},{Height=16000,Multiplier=8},{Height=40000,Multiplier=12},{Height=70000,Multiplier=20},{Height=100000,Multiplier=30},{Height=140000,Multiplier=40}}}
local function finite(v)return type(v)=="number" and v==v and math.abs(v)<math.huge end
function C.Multiplier(height)
 if not finite(height)then return 1 end
 local result=1;for _,band in C.Bands do if height<band.Height then break end;result=band.Multiplier end;return result
end
function C.Reward(count,height)
 if not finite(count)or count<0 or count%1~=0 or count>1000000 or not finite(height)then return 0 end
 return count*C.BaseTrophies*C.Multiplier(math.max(0,height))
end
for _,b in C.Bands do table.freeze(b)end;table.freeze(C.Bands);return table.freeze(C)
