-- Notion clicker reference: power above a level/XP bar, white and rainbow cursors.
-- Reusable presentation only; no networking, rewards, ownership or purchasing here.
local UI={Version="reference-bottom-upgrades-v4",Colors={Ink=Color3.fromRGB(15,16,22),Track=Color3.fromRGB(57,57,51),Gold=Color3.fromRGB(255,191,32),Yellow=Color3.fromRGB(255,221,48),White=Color3.new(1,1,1)}}
local Theme=require(script.Parent:WaitForChild("SimulatorTheme"))
local C=UI.Colors
local Icons=require(script.Parent:WaitForChild("UIIcons"))
local function text(parent,name,size,color)
 local l=Instance.new("TextLabel");l.Name=name;l.BackgroundTransparency=1;l.BorderSizePixel=0;l.Font=Enum.Font.GothamBlack;l.TextSize=size;l.TextColor3=color or C.White;l.TextStrokeColor3=C.Ink;l.TextStrokeTransparency=0;l.ZIndex=3;l.Parent=parent;return l
end
local function surface(frame,color,radius)
 frame.BackgroundColor3=color;frame.BorderSizePixel=0
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,radius or 8);corner.Parent=frame
 local stroke=Instance.new("UIStroke");stroke.Color=C.Ink;stroke.Thickness=4;stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;stroke.Parent=frame
 if frame.Name~="XPBar"then Theme.Surface(frame)end
end
function UI.Cursor(parent,op)
 return Icons.Image(parent,op and "OPCursor"or "Cursor",UDim2.fromOffset(10,10),UDim2.fromOffset(50,50))
end
function UI.Progress(parent)
 local frame=Instance.new("Frame");frame.Name="ClickerProgress";frame.Size=UDim2.fromOffset(560,130);frame.AnchorPoint=Vector2.new(.5,1);frame.Position=UDim2.new(.5,0,1,-16);frame.BackgroundTransparency=1;frame.Parent=parent
 local power=text(frame,"Power",38,Color3.fromRGB(115,235,255));power.Size=UDim2.new(1,0,0,44)
 local track=Instance.new("Frame");track.Name="XPBar";track.Position=UDim2.fromOffset(0,48);track.Size=UDim2.new(1,0,0,58);surface(track,C.Track,5);track.ClipsDescendants=true;track.Parent=frame
 local fill=Instance.new("Frame");fill.Name="XPFill";fill.BackgroundColor3=C.Gold;fill.BorderSizePixel=0;fill.Size=UDim2.fromScale(0,1);fill.ZIndex=1;fill.Parent=track
 local level=text(track,"Level",30);level.Position=UDim2.fromOffset(14,0);level.Size=UDim2.new(.45,-14,1,0);level.TextXAlignment=Enum.TextXAlignment.Left
 local amount=text(track,"XPValue",32);amount.Position=UDim2.new(.45,0,0,0);amount.Size=UDim2.new(.55,-14,1,0);amount.TextXAlignment=Enum.TextXAlignment.Right
 local rate=text(frame,"ClickHint",20,Color3.fromRGB(218,228,244));rate.Position=UDim2.fromOffset(0,110);rate.Size=UDim2.new(1,0,0,24)
 local scale=Instance.new("UIScale");scale.Name="ResponsiveScale";scale.Parent=frame
 return {Frame=frame,Scale=scale,Power=power,Level=level,Amount=amount,Fill=fill,Hint=rate}
end
function UI.Button(parent,mode)
 local op=mode=="OP";local button=Instance.new("TextButton");button.Name=op and "OPAutoClick"or "FreeAutoClick";button.Size=UDim2.fromOffset(228,70);button.Text="";surface(button,op and Color3.fromRGB(204,91,248)or Color3.fromRGB(255,206,40),8);button.AutoButtonColor=false;button.Parent=parent;Theme.Button(button)
 button.BackgroundColor3=Color3.new(1,1,1)
 local gradient=button:FindFirstChild("SimulatorGradient");gradient.Rotation=20
 local vivid={Color3.fromRGB(255,84,120),Color3.fromRGB(255,213,62),Color3.fromRGB(71,233,163),Color3.fromRGB(72,177,255),Color3.fromRGB(182,98,255)}
 if op then
  local keys={};for i,color in vivid do table.insert(keys,ColorSequenceKeypoint.new((i-1)/(#vivid-1),color))end;gradient.Color=ColorSequence.new(keys)
 else gradient:Destroy()end
 UI.Cursor(button,op)
 local caption=text(button,"Caption",20,C.Ink);caption.TextColor3=C.White;caption.TextStrokeTransparency=0;caption.Position=UDim2.fromOffset(64,5);caption.Size=UDim2.fromOffset(156,28);caption.Text=op and "OP Auto Click"or "Auto Click"
 local action=text(button,"Action",25,C.Ink);action.TextColor3=C.White;action.TextStrokeTransparency=0;action.Position=UDim2.fromOffset(64,32);action.Size=UDim2.fromOffset(156,32)
 return {Button=button,Action=action,Rate=op and 6 or 3}
end
-- One shared responsive layout keeps the bar, bonuses and controls together.
function UI.BottomLayout(gui,view)
 local root=Instance.new("Frame");root.Name="BottomHUD";root.BackgroundTransparency=1;root.Size=UDim2.fromOffset(1040,192);root.AnchorPoint=Vector2.new(.5,1);root.Position=UDim2.new(.5,0,1,-12);root.Parent=gui
 local scale=Instance.new("UIScale");scale.Name="ResponsiveScale";scale.Parent=root
 view.Frame.Parent=root;view.Frame.AnchorPoint=Vector2.zero;view.Frame.Position=UDim2.fromOffset(172,0);view.Frame.Size=UDim2.fromOffset(560,190)
 local bonuses=Instance.new("Frame");bonuses.Name="EquipmentBonuses";bonuses.BackgroundTransparency=1;bonuses.Position=UDim2.fromOffset(0,48);bonuses.Size=UDim2.fromOffset(156,110);bonuses.Parent=root
 local flat=text(bonuses,"Thrust",20,Color3.fromRGB(160,215,255));flat.Size=UDim2.fromOffset(156,36);flat.TextXAlignment=Enum.TextXAlignment.Right
 local growth=text(bonuses,"Growth",20,Color3.fromRGB(134,255,184));growth.Position=UDim2.fromOffset(0,36);growth.Size=UDim2.fromOffset(156,36);growth.TextXAlignment=Enum.TextXAlignment.Right
 local upgrades=Instance.new("Frame");upgrades.Name="UpgradeOffers";upgrades.BackgroundTransparency=1;upgrades.Position=UDim2.fromOffset(0,114);upgrades.Size=UDim2.fromOffset(560,74);upgrades.Parent=view.Frame
 -- Temporary free duration offers; future Robux receipt integration is separate.
 local offers={{Multiplier=2,PreviewPrice=99,Color=Color3.fromRGB(255,215,48)},{Multiplier=4,PreviewPrice=199,Color=Color3.fromRGB(255,146,38)},{Multiplier=8,PreviewPrice=349,Color=Color3.fromRGB(250,73,83)}}
 for i,offer in offers do
  local button=Instance.new("TextButton");button.Name="Offer"..i;button.Text="";button.Size=UDim2.fromOffset(154,74);button.Position=UDim2.fromOffset((i-1)*164,0);button.AutoButtonColor=false;button:SetAttribute("DisplayOnly",false);surface(button,offer.Color,8);button.Parent=upgrades;Theme.Button(button)
  Icons.Image(button,"Rocket",UDim2.fromOffset(8,13),UDim2.fromOffset(53,53))
  Icons.Image(button,"Robux",UDim2.fromOffset(91,5),UDim2.fromOffset(17,17))
  local price=text(button,"PreviewPrice",15);price.Position=UDim2.fromOffset(111,3);price.Size=UDim2.fromOffset(43,22);price.Text=tostring(offer.PreviewPrice)
  local multiplier=text(button,"Multiplier",36);multiplier.Position=UDim2.fromOffset(65,24);multiplier.Size=UDim2.fromOffset(84,40);multiplier.Text="x"..offer.Multiplier
  local caption=text(button,"Preview",10);caption.Position=UDim2.fromOffset(63,61);caption.Size=UDim2.fromOffset(85,12);caption.Text="FREE TEST"
  button.Activated:Connect(function()game:GetService("Players").LocalPlayer:SetAttribute("HUDPage","Store")end)
 end
 local plus=Instance.new("TextButton");plus.Name="MoreUpgrades";plus.Text="+";plus.Size=UDim2.fromOffset(58,74);plus.Position=UDim2.fromOffset(502,0);plus.TextSize=42;plus.Font=Enum.Font.GothamBlack;plus.TextColor3=C.White;surface(plus,Color3.fromRGB(65,215,145),8);plus.Parent=upgrades;Theme.Button(plus)
 plus.Activated:Connect(function()game:GetService("Players").LocalPlayer:SetAttribute("HUDPage","Store")end)
 view.Power.Size=UDim2.fromOffset(365,44);view.Power.TextXAlignment=Enum.TextXAlignment.Center
 local mult=text(view.Frame,"PowerMultiplier",18,Color3.fromRGB(197,171,255));mult.Position=UDim2.fromOffset(370,0);mult.Size=UDim2.fromOffset(190,22);mult.TextXAlignment=Enum.TextXAlignment.Right
 local food=text(view.Frame,"FoodPercent",18,Color3.fromRGB(134,255,184));food.Position=UDim2.fromOffset(370,22);food.Size=UDim2.fromOffset(190,22);food.TextXAlignment=Enum.TextXAlignment.Right
 return {Root=root,Scale=scale,Thrust=flat,Growth=growth,Multiplier=mult,Food=food}
end
function UI.ResizeProgress(view,width,compact)
 view.Scale.Scale=1
end
function UI.UpdateProgress(view,level,xp,required,power)
 view.Power.Text="Power: "..power;view.Level.Text="Level "..level;view.Amount.Text=xp.." / "..required
 view.Fill.Size=UDim2.fromScale(math.clamp(xp/math.max(1,required),0,1),1)
end
function UI.UpdateButton(view,selected)
 view.Button.BackgroundColor3=Color3.new(1,1,1)
 local stroke=view.Button:FindFirstChildOfClass("UIStroke");stroke.Color=selected and Color3.fromRGB(74,255,132)or C.Ink;stroke.Thickness=selected and 5 or 4
 view.Button:SetAttribute("Selected",selected)
 view.Action.Text=(selected and "ON"or "OFF")
end
return UI
