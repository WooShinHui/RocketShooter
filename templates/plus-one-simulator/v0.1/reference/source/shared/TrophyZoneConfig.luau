-- Fixed world layers: growth opens higher destinations without moving a player's goal.
local Zones={Count=12,FirstHeight=90,HeightRatio=2,Width=60,Depth=68}
function Zones.Layer(index)
 if type(index)~="number" or index%1~=0 or index<1 or index>Zones.Count then return nil end
 return {Index=index,Height=Zones.FirstHeight*Zones.HeightRatio^(index-1),Offset=110+(index-1)*8,Reward=2^(index-1)}
end
function Zones.Recommended(height)
 local chosen
 for i=1,Zones.Count do local layer=Zones.Layer(i);if layer.Height+12<=height then chosen=layer else break end end
 return chosen
end
return Zones
