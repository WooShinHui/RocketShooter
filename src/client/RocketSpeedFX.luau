-- Bounded local presentation. Never alters camera orbit, physics, rewards or purchases.
local Tween=game:GetService("TweenService")
local FX={}
function FX.Create(gui)
 local effect={intensity=0,armed=true}
 local layer=Instance.new("Frame");layer.Name="RocketSpeedFX";layer.Size=UDim2.fromScale(1,1);layer.BackgroundTransparency=1;layer.ClipsDescendants=true;layer.Visible=false;layer.Parent=gui;effect.layer=layer
 local lines={}
 for i=1,24 do
  local p=Instance.new("Frame");p.Name="SpeedLine"..i;p.AnchorPoint=Vector2.new(.5,.5);p.BorderSizePixel=0;p.BackgroundColor3=i%3==0 and Color3.fromRGB(104,239,255)or Color3.fromRGB(231,255,255);p.Parent=layer
  table.insert(lines,{part=p,angle=(i-.5)*math.pi*2/24,seed=i*.618})
 end
 local banner=Instance.new("TextLabel");banner.Name="Overdrive";banner.AnchorPoint=Vector2.new(.5,0);banner.Position=UDim2.new(.5,0,0,144);banner.Size=UDim2.new(.7,0,0,30);banner.BackgroundTransparency=1;banner.TextColor3=Color3.fromRGB(137,249,255);banner.Font=Enum.Font.GothamBlack;banner.TextSize=22;banner.TextStrokeTransparency=.2;banner.Parent=layer
 function effect.Clear()
  effect.intensity=0;effect.armed=true;layer.Visible=false
  if effect.rootFX then effect.rootFX:Destroy();effect.rootFX=nil end
  if effect.pulse then effect.pulse:Destroy();effect.pulse=nil end
 end
 function effect.Attach(root)
  effect.Clear();local f=Instance.new("Folder");f.Name="RocketVelocityWake";f.Parent=root;effect.rootFX=f
  local a=Instance.new("Attachment");a.Position=Vector3.new(-.7,0,1.5);a.Parent=root
  local b=Instance.new("Attachment");b.Position=Vector3.new(.7,0,1.5);b.Parent=root
  local trail=Instance.new("Trail");trail.Name="IonWake";trail.Attachment0=a;trail.Attachment1=b;trail.Enabled=false;trail.FaceCamera=true;trail.LightEmission=1;trail.Color=ColorSequence.new(Color3.fromRGB(225,255,255),Color3.fromRGB(69,214,255));trail.Transparency=NumberSequence.new(.25,1);trail.WidthScale=NumberSequence.new(1,0);trail.Parent=f
  effect.trail=trail;effect.a=a;effect.b=b
  f.Destroying:Once(function()a:Destroy();b:Destroy()end)
 end
 function effect.Update(speed,diving,dt,point)
  local goal=math.clamp(math.log(math.max(1,speed/180))/math.log(5000/180),0,1)*(diving and .65 or 1)
  effect.intensity+=(goal-effect.intensity)*(1-math.exp(-math.min(dt,.1)*7))
  local intensity=effect.intensity;layer.Visible=intensity>.015
  local now=os.clock()
  for _,line in lines do
   local progress=(now*(1+intensity*2.5)+line.seed)%1;local radius=.43+progress*.3
   local p=line.part;p.Position=UDim2.fromScale(.5+math.cos(line.angle)*radius,.5+math.sin(line.angle)*radius)
   p.Rotation=math.deg(math.atan2(math.sin(line.angle)*layer.AbsoluteSize.Y,math.cos(line.angle)*layer.AbsoluteSize.X))
   p.Size=UDim2.fromOffset(15+intensity*90,1+intensity*2);p.BackgroundTransparency=1-intensity*(.2+.6*progress)
  end
  banner.Visible=not diving and intensity>.35;banner.Text=string.format("초고속 추진!  %s m/s",tostring(math.floor(speed)))
  if effect.trail then effect.trail.Enabled=intensity>.04;effect.trail.Lifetime=math.clamp(120/math.max(180,speed),.015,.28)end
  if intensity<.15 then effect.armed=true end
  if not diving and intensity>.35 and effect.armed then
   effect.armed=false
   if effect.pulse then effect.pulse:Destroy()end
   local pulse=Instance.new("Frame");pulse.Name="AccelerationShockwave";pulse.AnchorPoint=Vector2.new(.5,.5);pulse.Position=UDim2.fromOffset(point.X,point.Y);pulse.Size=UDim2.fromOffset(90,90);pulse.BackgroundTransparency=1;pulse.Parent=layer;effect.pulse=pulse
   local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(1,0);corner.Parent=pulse
   local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(132,249,255);stroke.Thickness=3;stroke.Transparency=.25;stroke.Parent=pulse
   Tween:Create(pulse,TweenInfo.new(.45),{Size=UDim2.fromOffset(420,420)}):Play();Tween:Create(stroke,TweenInfo.new(.45),{Transparency=1}):Play()
  end
  return intensity
 end
 return effect
end
return FX
