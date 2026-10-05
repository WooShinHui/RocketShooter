-- Peripheral presentation only. No character effects, camera shake or physics changes.
local FX={}
function FX.Create(gui)
 local effect={intensity=0,vignette=0,phase=0}
 local overlay=Instance.new("ScreenGui");overlay.Name="RocketSpeedOverlay";overlay.IgnoreGuiInset=true;overlay.ScreenInsets=Enum.ScreenInsets.None;overlay.ClipToDeviceSafeArea=false;overlay.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None;overlay.ResetOnSpawn=false;overlay.DisplayOrder=gui.DisplayOrder-1;overlay.Parent=gui.Parent
 local layer=Instance.new("Frame");layer.Name="RocketSpeedFX";layer.Size=UDim2.fromScale(1,1);layer.BackgroundTransparency=1;layer.ClipsDescendants=true;layer.Visible=false;layer.Parent=overlay;effect.layer=layer
 local colors={Color3.fromRGB(137,227,255),Color3.fromRGB(189,176,255),Color3.fromRGB(231,249,255)}
 local lines={}
 for i=1,40 do
  local row={angle=(i-.5)*math.pi*2/40,seed=i*.618,parts={}}
  for ghost=0,1 do
   local p=Instance.new("Frame");p.Name=(ghost==0 and "SpeedLine"or "SpeedAfterimage")..i;p.AnchorPoint=Vector2.new(.5,.5);p.BorderSizePixel=0;p.Active=false;p.Parent=layer
   local g=Instance.new("UIGradient");g.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.55,.45),NumberSequenceKeypoint.new(1,0)});g.Parent=p;row.parts[ghost+1]=p
  end
  lines[i]=row
 end
 local edges={}
 for i,rotation in {90,270,0,180}do
  local p=Instance.new("Frame");p.Name="DiveVignette"..i;p.BorderSizePixel=0;p.BackgroundColor3=Color3.fromRGB(226,243,255);p.BackgroundTransparency=1;p.Active=false;p.Parent=layer
  if i==1 then p.Size=UDim2.fromScale(1,.1)
  elseif i==2 then p.Position=UDim2.fromScale(0,.9);p.Size=UDim2.fromScale(1,.1)
  elseif i==3 then p.Size=UDim2.fromScale(.07,1)
  else p.Position=UDim2.fromScale(.93,0);p.Size=UDim2.fromScale(.07,1)end
  local g=Instance.new("UIGradient");g.Rotation=rotation;g.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.35),NumberSequenceKeypoint.new(.35,.75),NumberSequenceKeypoint.new(1,1)});g.Parent=p;edges[i]=p
 end
 function effect.Clear()
  effect.intensity=0;effect.vignette=0;effect.phase=0;layer.Visible=false
  layer:SetAttribute("SpeedIntensity",0);layer:SetAttribute("DiveVignetteIntensity",0)
  for _,p in edges do p.BackgroundTransparency=1 end
 end
 function effect.Attach(_root)effect.Clear()end
 function effect.Update(speed,diving,dt,_point,boosting)
  local smooth=1-math.exp(-math.min(dt,.1)*7)
  local goal=math.clamp(math.log(math.max(1,speed/180))/math.log(5000/180),0,1)*(diving and .75 or 1)
  effect.intensity+=(goal-effect.intensity)*smooth
  local intensity=effect.intensity
  local edgeGoal=diving and math.clamp(speed/24000+(boosting and .045 or 0),0,.14)or 0
  effect.vignette+=(edgeGoal-effect.vignette)*smooth
  for _,p in edges do p.BackgroundTransparency=1-effect.vignette end
  layer.Visible=intensity>.015 or effect.vignette>.015
  layer:SetAttribute("SpeedIntensity",intensity);layer:SetAttribute("DiveVignetteIntensity",effect.vignette)
  effect.phase+=math.min(dt,.1)*(1.8+intensity*7)
  local scale=math.clamp(layer.AbsoluteSize.X/1200,.65,1.6)
  for _,line in lines do
   local progress=(effect.phase+line.seed)%1
   for index,p in line.parts do
    local ghost=index==2;local radius=.48+progress*.3-(ghost and .035 or 0)
    p.Position=UDim2.fromScale(.5+math.cos(line.angle)*radius,.5+math.sin(line.angle)*radius)
    p.Rotation=math.deg(math.atan2(math.sin(line.angle)*layer.AbsoluteSize.Y,math.cos(line.angle)*layer.AbsoluteSize.X))
    p.Size=UDim2.fromOffset((45+intensity*280)*scale*(ghost and 1.15 or 1),ghost and 1.5 or 1+intensity*3)
    p.BackgroundTransparency=1-intensity*(ghost and .22 or .9)*(.3+.7*progress)
    p.BackgroundColor3=diving and colors[3]or colors[math.floor(line.seed*10)%#colors+1]
   end
  end
  return intensity
 end
 return effect
end
return FX
