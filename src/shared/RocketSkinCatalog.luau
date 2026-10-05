-- Rocket equipment ownership is a saved bit mask. IDs/order are permanent save keys.
local C={Items={
 {Id="Starter",FlatThrust=0,GrowthBoost=0,Name="스타터",Cost=0,Rebirths=0,Icon="🚀"},
 {Id="Ion",FlatThrust=8,GrowthBoost=0.03,Name="이온",Cost=0,Rebirths=1,Icon="⚡"},
 {Id="Bat",FlatThrust=10,GrowthBoost=0.04,Name="방망이 로켓",Cost=5,Rebirths=0,Icon="🏏"},
 {Id="Mala",FlatThrust=16,GrowthBoost=0.07,Name="마라탕 로켓",Cost=15,Rebirths=1,Icon="🍜"},
 {Id="Nova",FlatThrust=25,GrowthBoost=0.1,Name="노바",Cost=40,Rebirths=3,Icon="🌌"},
 {Id="Sausage",Name="소세지 로켓",Icon="🌭",Cost=80,FlatThrust=18,GrowthBoost=0.06,Rebirths=0},
 {Id="Keyboard",Name="키보드 로켓",Icon="⌨️",Cost=120,FlatThrust=20,GrowthBoost=0.07,Rebirths=0},
 {Id="Pencil",Name="연필 로켓",Icon="✏️",Cost=180,FlatThrust=22,GrowthBoost=0.08,Rebirths=0},
 {Id="Banana",Name="바나나 로켓",Icon="🍌",Cost=260,FlatThrust=23,GrowthBoost=0.09,Rebirths=0},
 {Id="Donut",Name="도넛 로켓",Icon="🍩",Cost=360,FlatThrust=25,GrowthBoost=0.1,Rebirths=0},
 {Id="Fish",Name="물고기 로켓",Icon="🐟",Cost=500,FlatThrust=27,GrowthBoost=0.1,Rebirths=0},
 {Id="Soda",Name="소다캔 로켓",Icon="🥤",Cost=700,FlatThrust=29,GrowthBoost=0.11,Rebirths=0},
 {Id="Pizza",Name="피자 로켓",Icon="🍕",Cost=950,FlatThrust=31,GrowthBoost=0.12,Rebirths=0},
 {Id="Cloud",Name="구름 로켓",Icon="☁️",Cost=1300,FlatThrust=33,GrowthBoost=0.13,Rebirths=0},
 {Id="Satellite",Name="위성 로켓",Icon="🛰️",Cost=1700,FlatThrust=35,GrowthBoost=0.14,Rebirths=0},
}}
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
