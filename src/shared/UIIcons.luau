-- Reviewed decals from the user's Simulator Icon Pack. No pack scripts execute.
local I={Assets={Cursor="rbxassetid://13443203578",OPCursor="rbxassetid://135569585073294",Rocket="rbxassetid://16670799841",Trophy="rbxassetid://12129301834",Rebirth="rbxassetid://17368214873",Shop="rbxassetid://17368188494",Gift="rbxassetid://15402967660",Power="rbxassetid://17368210998",Trail="rbxassetid://15403144723",Upgrade="rbxassetid://17368045028",Down="rbxassetid://17368169201",Bomb="rbxassetid://15403027709",Close="rbxassetid://17368208554",Star="rbxassetid://17368097932"}}
function I.Image(parent,key,position,size)
 local v=Instance.new("ImageLabel");v.Name=key.."Icon";v.BackgroundTransparency=1;v.BorderSizePixel=0;v.Image=assert(I.Assets[key],key);v.ScaleType=Enum.ScaleType.Fit;v.Position=position;v.Size=size;v.ZIndex=parent:IsA("GuiObject")and parent.ZIndex+1 or 2;v.Parent=parent;return v
end
return I
