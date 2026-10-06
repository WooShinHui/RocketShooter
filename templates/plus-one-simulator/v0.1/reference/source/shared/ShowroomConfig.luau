-- Spawn-relative rear displays. Negative forward offsets are behind the spawn. Asset templates are reviewed Studio-owned geometry.
local C={Version=4,RocketSide=-56,ToiletSide=56,RocketSpacing=24,ToiletSpacing=22,RearOffset=24,RocketColumns=5,AutoSitRadius=6,AutoExitRadius=9,
 ToiletAsset=2091145711,SparkleAsset=90896557694774,
 ToiletStyles={
  {Color=Color3.fromRGB(139,87,46),Accent=Color3.fromRGB(191,132,71),Material="Wood"},
  {Color=Color3.fromRGB(147,155,163),Accent=Color3.fromRGB(204,215,221),Material="Slate"},
  {Color=Color3.fromRGB(84,117,140),Accent=Color3.fromRGB(187,223,240),Material="Metal"},
  {Color=Color3.fromRGB(255,191,45),Accent=Color3.fromRGB(255,234,137),Material="Metal"},
  {Color=Color3.fromRGB(80,218,255),Accent=Color3.fromRGB(210,250,255),Material="Glass",Glow=true},
  {Color=Color3.fromRGB(40,213,125),Accent=Color3.fromRGB(176,255,214),Material="Glass",Glow=true},
  {Color=Color3.fromRGB(239,228,255),Accent=Color3.fromRGB(255,214,99),Material="Marble",Glow=true,Divine=true},
 }}
function C.Slot(kind,index)
 if kind=="Rocket"then
  local column=(index-1)%C.RocketColumns;local row=math.floor((index-1)/C.RocketColumns)
  -- Five across along the spawn-forward axis; two deep away from spawn.
  return C.RocketSide-row*C.RocketSpacing,-C.RearOffset-column*C.RocketSpacing,1
 end
 return C.ToiletSide,-C.RearOffset-(index-1)*C.ToiletSpacing,-1
end
-- Check the horizontal approach and height independently so raised seats work.
function C.Near(localPosition,exit)
 local radius=exit and C.AutoExitRadius or C.AutoSitRadius
 local horizontal=localPosition.X^2+localPosition.Z^2<=radius^2
 -- Jumping straight up must not clear the re-entry block before landing.
 return horizontal and (exit or (localPosition.Y>=-2 and localPosition.Y<=8))
end
for _,style in C.ToiletStyles do table.freeze(style)end;table.freeze(C.ToiletStyles)
return table.freeze(C)
