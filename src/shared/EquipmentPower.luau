-- Flat thrust helps early purchases; percentages affect trained thrust only.
-- Never snapshots the level at purchase, never multiplies the starting engine.
local E={}
function E.Bonuses(skin,trail)
 return (skin.FlatThrust or 0)+(trail.FlatThrust or 0),math.min(.25,(skin.GrowthBoost or 0)+(trail.GrowthBoost or 0))
end
function E.Vertical(base,starter,skin,trail)
 local flat,growth=E.Bonuses(skin,trail)
 return base+flat+math.max(0,base-starter)*growth
end
function E.Description(item)
 return string.format("기본 추력 +%d · 성장분 +%d%%",item.FlatThrust or 0,math.floor((item.GrowthBoost or 0)*100+.5))
end
return table.freeze(E)
