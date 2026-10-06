-- Pure conversion; returns a fresh value table and never mutates a failed load.
local Economy={}
function Economy.Migrate(values,itemCount)
 local nextValues=table.clone(values)
 if (values.EconomyVersion or 0)>1 or (values.XPGearLvl or 1)>itemCount then return nil end
 if (values.EconomyVersion or 0)==0 then
  local total=values.Trophies+values.Gold
  if total>2^53-1 then return nil end
  nextValues.Trophies=total;nextValues.Gold=0;nextValues.EconomyVersion=1
  nextValues.XPGearLvl=math.max(values.XPGearLvl or 1,math.min(itemCount,values.BoostLvl))
 end
 return nextValues
end
return Economy
