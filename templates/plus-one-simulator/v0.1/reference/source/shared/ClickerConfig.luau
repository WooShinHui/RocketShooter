-- Prototype: OP is a clearly labelled free trial until a paid entitlement is connected.
local C={ManualXP=1,ManualRate=10,ManualBurst=2,PreviewOP=true,MaxCatchUp=.25}
function C.Rate(mode) return if mode=="Free"then 3 elseif mode=="OP"then 6 else 0 end
function C.ValidMode(mode) return mode=="Off"or mode=="Free"or mode=="OP"end
function C.Step(balance,dt,mode)
 local rate=C.Rate(mode)
 if rate==0 or dt~=dt or dt<=0 or dt==math.huge then return 0,0 end
 local total=balance+math.min(dt,C.MaxCatchUp)*rate
 local clicks=math.floor(total+1e-8)
 return total-clicks,clicks
end
return table.freeze(C)
