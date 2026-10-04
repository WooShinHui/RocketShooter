-- Cosmetic ownership is a saved bit mask. IDs/order are permanent save keys.
local C={Items={
 {Id="Starter",Name="스타터",Cost=0,Rebirths=0,Icon="🚀"},
 {Id="Ion",Name="이온",Cost=0,Rebirths=1,Icon="⚡"},
 {Id="Bat",Name="방망이 로켓",Cost=5,Rebirths=0,Icon="🏏"},
 {Id="Mala",Name="마라탕 로켓",Cost=15,Rebirths=1,Icon="🍜"},
 {Id="Nova",Name="노바",Cost=40,Rebirths=3,Icon="🌌"},
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
