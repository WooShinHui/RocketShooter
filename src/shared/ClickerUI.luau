-- Notion clicker reference: power above a level/XP bar, white and rainbow cursors.
-- Reusable presentation only; no networking, rewards, ownership or purchasing here.
local UI={Version="notion-clicker-compact-v3",Colors={Ink=Color3.fromRGB(15,16,22),Track=Color3.fromRGB(57,57,51),Gold=Color3.fromRGB(255,191,32),Yellow=Color3.fromRGB(255,221,48),White=Color3.new(1,1,1)}}
local C=UI.Colors
local function text(parent,name,size,color)
 local l=Instance.new("TextLabel");l.Name=name;l.BackgroundTransparency=1;l.BorderSizePixel=0;l.Font=Enum.Font.GothamBlack;l.TextSize=size;l.TextColor3=color or C.White;l.TextStrokeColor3=C.Ink;l.TextStrokeTransparency=0;l.ZIndex=3;l.Parent=parent;return l
end
local function surface(frame,color,radius)
 frame.BackgroundColor3=color;frame.BorderSizePixel=0
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,radius or 8);corner.Parent=frame
 local stroke=Instance.new("UIStroke");stroke.Color=C.Ink;stroke.Thickness=4;stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;stroke.Parent=frame
end
-- Crisp code-built cursor artwork scales with the component, with no upload dependency.
function UI.Cursor(parent,rainbow)
 local frame=Instance.new("Frame");frame.Name=rainbow and "RainbowCursor"or "WhiteCursor";frame.BackgroundTransparency=1;frame.Size=UDim2.fromOffset(64,70);frame.Position=UDim2.fromOffset(8,6);frame.ZIndex=2;frame.Parent=parent
 local polygon={{2,1},{23,15},{15,17},{19,24},{13,27},{9,20},{4,25}}
 local function inside(x,y)
  local result=false;local j=#polygon
  for i=1,#polygon do local a,b=polygon[i],polygon[j];if (a[2]>y)~=(b[2]>y)and x<(b[1]-a[1])*(y-a[2])/(b[2]-a[2])+a[1]then result=not result end;j=i end
  return result
 end
 for y=0,27 do
  local first,last
  for x=0,25 do if inside(x+.5,y+.5)then first=first or x;last=x end end
  if not first then continue end
  local row=Instance.new("Frame");row.Name="Outline"..y;row.BackgroundColor3=C.Ink;row.BorderSizePixel=0;row.Position=UDim2.fromScale(first/26,y/28);row.Size=UDim2.fromScale((last-first+1)/26,1.02/28);row.ZIndex=2;row.Parent=frame
  local a,b
  for x=first,last do if inside(x-1,y+.5)and inside(x+2,y+.5)and inside(x+.5,y-1)and inside(x+.5,y+2)then a=a or x;b=x end end
  if a then
   local fill=Instance.new("Frame");fill.Name="Color"..y;fill.BackgroundColor3=C.White;fill.BorderSizePixel=0;fill.Position=UDim2.fromScale(a/26,y/28);fill.Size=UDim2.fromScale((b-a+1)/26,1.02/28);fill.ZIndex=3;fill.Parent=frame
   if rainbow then
    local keys={};for k=0,6 do table.insert(keys,ColorSequenceKeypoint.new(k/6,Color3.fromHSV((a+(b-a)*k/6)/26*.85,.9,1)))end
    local gradient=Instance.new("UIGradient");gradient.Color=ColorSequence.new(keys);gradient.Parent=fill
   else fill.BackgroundColor3=Color3.fromRGB(235,250,255)end
  end
 end
 return frame
end
function UI.Progress(parent)
 local frame=Instance.new("Frame");frame.Name="ClickerProgress";frame.Size=UDim2.fromOffset(560,130);frame.AnchorPoint=Vector2.new(.5,1);frame.Position=UDim2.new(.5,0,1,-16);frame.BackgroundTransparency=1;frame.Parent=parent
 local power=text(frame,"Power",38,C.Gold);power.Size=UDim2.new(1,0,0,44)
 local track=Instance.new("Frame");track.Name="XPBar";track.Position=UDim2.fromOffset(0,48);track.Size=UDim2.new(1,0,0,58);surface(track,C.Track,5);track.ClipsDescendants=true;track.Parent=frame
 local fill=Instance.new("Frame");fill.Name="XPFill";fill.BackgroundColor3=C.Gold;fill.BorderSizePixel=0;fill.Size=UDim2.fromScale(0,1);fill.ZIndex=1;fill.Parent=track
 local level=text(track,"Level",30);level.Position=UDim2.fromOffset(14,0);level.Size=UDim2.new(.45,-14,1,0);level.TextXAlignment=Enum.TextXAlignment.Left
 local amount=text(track,"XPValue",32);amount.Position=UDim2.new(.45,0,0,0);amount.Size=UDim2.new(.55,-14,1,0);amount.TextXAlignment=Enum.TextXAlignment.Right
 local rate=text(frame,"ClickHint",20,Color3.fromRGB(218,228,244));rate.Position=UDim2.fromOffset(0,110);rate.Size=UDim2.new(1,0,0,24)
 local scale=Instance.new("UIScale");scale.Name="ResponsiveScale";scale.Parent=frame
 return {Frame=frame,Scale=scale,Power=power,Level=level,Amount=amount,Fill=fill,Hint=rate}
end
function UI.Button(parent,mode)
 local op=mode=="OP";local button=Instance.new("TextButton");button.Name=op and "OPAutoClick"or "FreeAutoClick";button.Size=UDim2.fromOffset(228,84);button.Text="";surface(button,op and C.Yellow or C.White,16);button.Parent=parent
 UI.Cursor(button,op)
 local caption=text(button,"Caption",20,op and Color3.fromRGB(241,76,255)or C.White);caption.Position=UDim2.fromOffset(74,4);caption.Size=UDim2.fromOffset(148,28);caption.Text=op and "OP 자동 클릭커"or "자동 클릭커"
 local action=text(button,"Action",36,op and Color3.fromRGB(255,116,85)or Color3.fromRGB(129,217,255));action.Position=UDim2.fromOffset(74,30);action.Size=UDim2.fromOffset(148,48)
 return {Button=button,Action=action}
end
function UI.ResizeProgress(view,width,compact)
 view.Scale.Scale=1;view.Frame.Size=UDim2.fromOffset(math.min(560,math.max(240,width-32)),compact and 110 or 130)
 view.Power.TextSize=compact and 32 or 38
 view.Level.TextSize=compact and 26 or 30;view.Amount.TextSize=compact and 28 or 32
 view.Fill.Parent.Position=UDim2.fromOffset(0,compact and 42 or 48);view.Fill.Parent.Size=UDim2.new(1,0,0,compact and 48 or 58)
 view.Hint.Position=UDim2.fromOffset(0,compact and 94 or 110);view.Hint.TextSize=compact and 17 or 20
end
function UI.UpdateProgress(view,level,xp,required,power)
 view.Power.Text="추진력: "..power;view.Level.Text="레벨 "..level;view.Amount.Text=xp.." / "..required
 view.Fill.Size=UDim2.fromScale(math.clamp(xp/math.max(1,required),0,1),1)
end
function UI.UpdateButton(view,selected)
 view.Action.Text=selected and "끄기"or "켜기"
end
return UI
