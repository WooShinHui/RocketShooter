-- Permanent mask indices. None is always owned; five trophy-purchased exhaust trails.
local C={Items={
 {Id="None",Name="Default Exhaust",Cost=0,FlatThrust=0,GrowthBoost=0,Colors={{255,255,255},{255,255,255}},Lifetime=.0,Width=0},
 {Id="Ember",Name="Ember Flame",Cost=15,FlatThrust=5,GrowthBoost=0.02,Colors={{255,235,100},{255,96,36}},Lifetime=.32,Width=.9},
 {Id="Mint",Name="Mint Stream",Cost=60,FlatThrust=9,GrowthBoost=0.04,Colors={{196,255,250},{40,230,188}},Lifetime=.38,Width=1.1},
 {Id="Violet",Name="Violet Pulse",Cost=180,FlatThrust=14,GrowthBoost=0.07,Colors={{250,208,255},{160,80,255}},Lifetime=.44,Width=1.25},
 {Id="Aurora",Name="Aurora Wave",Cost=600,FlatThrust=20,GrowthBoost=0.1,Colors={{73,255,188},{80,170,255},{205,110,255}},Lifetime=.5,Width=1.4},
 {Id="Prism",Name="Prism Rush",Cost=1800,FlatThrust=25,GrowthBoost=0.15,Colors={{255,100,115},{255,220,70},{80,255,205},{110,170,255},{230,130,255}},Lifetime=.55,Width=1.6},
}}
function C.Owns(mask,index)return bit32.band(mask,bit32.lshift(1,index-1))~=0 end
function C.Grant(mask,index)return bit32.bor(mask,bit32.lshift(1,index-1))end
function C.Valid(mask,index)
 return type(mask)=="number"and mask%1==0 and mask>=1 and mask<2^#C.Items and bit32.band(mask,1)==1 and type(index)=="number"and index%1==0 and index>=1 and index<=#C.Items and C.Owns(mask,index)
end
function C.Find(id)for _,item in C.Items do if item.Id==id then return item end end;return C.Items[1]end
function C.Sequence(item)
 local keys={};for i,rgb in item.Colors do table.insert(keys,ColorSequenceKeypoint.new((i-1)/(#item.Colors-1),Color3.fromRGB(rgb[1],rgb[2],rgb[3])))end;return ColorSequence.new(keys)
end
for _,item in C.Items do for _,rgb in item.Colors do table.freeze(rgb)end;table.freeze(item.Colors);table.freeze(item)end;table.freeze(C.Items);return table.freeze(C)
