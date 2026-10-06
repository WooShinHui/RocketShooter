-- Rocket equipment ownership is a saved bit mask. IDs/order are permanent save keys.
local C={Items={
 {Id="Starter",FlatThrust=0,GrowthBoost=0,Name="Starter",Cost=0,Rebirths=0,Icon="🚀"},
 {Id="Ion",FlatThrust=8,GrowthBoost=0.03,Name="Ion",Cost=0,Rebirths=1,Icon="⚡"},
 {Id="Bat",FlatThrust=10,GrowthBoost=0.04,Name="Bat Rocket",Cost=5,Rebirths=0,Icon="🏏"},
 {Id="Mala",FlatThrust=16,GrowthBoost=0.07,Name="Mala Rocket",Cost=15,Rebirths=1,Icon="🍜"},
 {Id="Nova",FlatThrust=25,GrowthBoost=0.1,Name="Nova",Cost=40,Rebirths=3,Icon="🌌"},
 {Id="Sausage",Name="Sausage Rocket",Icon="🌭",Cost=80,FlatThrust=18,GrowthBoost=0.06,Rebirths=0},
 {Id="Keyboard",Name="Keyboard Rocket",Icon="⌨️",Cost=120,FlatThrust=20,GrowthBoost=0.07,Rebirths=0},
 {Id="Pencil",Name="Pencil Rocket",Icon="✏️",Cost=180,FlatThrust=22,GrowthBoost=0.08,Rebirths=0},
 {Id="Banana",Name="Banana Rocket",Icon="🍌",Cost=260,FlatThrust=23,GrowthBoost=0.09,Rebirths=0},
 {Id="Donut",Name="Donut Rocket",Icon="🍩",Cost=360,FlatThrust=25,GrowthBoost=0.1,Rebirths=0},
 {Id="Fish",Name="Fish Rocket",Icon="🐟",Cost=500,FlatThrust=27,GrowthBoost=0.1,Rebirths=0},
 {Id="Soda",Name="Soda Rocket",Icon="🥤",Cost=700,FlatThrust=29,GrowthBoost=0.11,Rebirths=0},
 {Id="Pizza",Name="Pizza Rocket",Icon="🍕",Cost=950,FlatThrust=31,GrowthBoost=0.12,Rebirths=0},
 {Id="Cloud",Name="Cloud Rocket",Icon="☁️",Cost=1300,FlatThrust=33,GrowthBoost=0.13,Rebirths=0},
 {Id="Satellite",Name="Satellite Rocket",Icon="🛰️",Cost=1700,FlatThrust=35,GrowthBoost=0.14,Rebirths=0},
}}
C.DisplayIndices=table.freeze({1,2,3,4,5,6,7,8,9,10})
function C.Owns(mask,index) return bit32.band(mask,bit32.lshift(1,index-1))~=0 end
function C.Valid(mask,index)
 return type(mask)=="number" and mask==math.floor(mask) and mask>=1 and mask<2^#C.Items
  and bit32.band(mask,1)==1 and type(index)=="number" and index==math.floor(index)
  and index>=1 and index<=#C.Items and C.Owns(mask,index)
end
function C.Grant(mask,index) return bit32.bor(mask,bit32.lshift(1,index-1)) end
function C.Milestones(mask,rebirths)
 for i,item in C.Items do if item.Cost==0 and rebirths>=item.Rebirths then mask=C.Grant(mask,i) end end
 return mask
end
for _,item in C.Items do table.freeze(item) end;table.freeze(C.Items)
return table.freeze(C)
