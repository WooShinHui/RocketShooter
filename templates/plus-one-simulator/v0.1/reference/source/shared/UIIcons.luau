-- Reviewed decals from the user's Simulator Icon Pack. No pack scripts execute.
local I={Assets={Guide="rbxassetid://15403140844",Settings="rbxassetid://17368089841",Friends="rbxassetid://17368071983",Robux="rbxassetid://17368048685",Training="rbxassetid://15403007921",Inventory="rbxassetid://15402958715",AdminClose="rbxassetid://103717003921399",Lock="rbxassetid://17368080973",Unlock="rbxassetid://17368081924",RainbowCursor="rbxassetid://135569585073294",Cursor="rbxassetid://13443203578",OPCursor="rbxassetid://135569585073294",Rocket="rbxassetid://16670799841",Trophy="rbxassetid://12129301834",Rebirth="rbxassetid://17368214873",Shop="rbxassetid://17368217589",Gift="rbxassetid://15402967660",Power="rbxassetid://17368210998",Trail="rbxassetid://15403144723",Upgrade="rbxassetid://17368045028",Down="rbxassetid://17368169201",Bomb="rbxassetid://15403027709",Close="rbxassetid://17368208554",Star="rbxassetid://17368097932"}}
function I.Image(parent,key,position,size)
 local v=Instance.new("ImageLabel");v.Name=key.."Icon";v.BackgroundTransparency=1;v.BorderSizePixel=0;v.Image=assert(I.Assets[key],key);v.ScaleType=Enum.ScaleType.Fit;v.Position=position;v.Size=size;v.ZIndex=parent:IsA("GuiObject")and parent.ZIndex+1 or 2;v.Parent=parent
 if key=="OPCursor"then
  v.Image=I.Assets.RainbowCursor
  local gradient=Instance.new("UIGradient");gradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,75,112)),ColorSequenceKeypoint.new(.25,Color3.fromRGB(255,222,65)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(75,255,174)),ColorSequenceKeypoint.new(.75,Color3.fromRGB(81,155,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(211,94,255))});gradient.Rotation=35;gradient.Parent=v
 elseif key=="Cursor"then v.Image=I.Assets.OPCursor end
 return v
end
return I
