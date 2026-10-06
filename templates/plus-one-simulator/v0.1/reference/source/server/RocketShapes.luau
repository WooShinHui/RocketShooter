-- Small procedural wearables; no external model scripts. Existing saved IDs stay stable.
local S={}
function S.Build(part,style)
 local kind=style.Kind;local B=style.Body;local A=style.Accent;local ball=Enum.PartType.Ball;local cyl=Enum.PartType.Cylinder
 local function p(name,size,x,y,z,color,shape,angle)return part(name,size,CFrame.new(x,y,z or 1.4)*CFrame.Angles(0,0,angle or 0),color or B,shape)end
 if kind=="Sausage"then
  for _,x in {-.75,.75}do p("Sausage",Vector3.new(3.7,1.12,1.12),x,.2,1.5,B,cyl,math.pi/2);for _,y in {-1.65,2.05}do p("RoundedSausage",Vector3.one*1.12,x,y,1.5,B,ball)end
   for i=1,7 do p("Mustard",Vector3.new(.65,.13,.12),x,(i-4)*.38,2.08,A,nil,(i%2==0 and 1 or -1)*.4)end end
 elseif kind=="Keyboard"then
  p("KeyboardCase",Vector3.new(3.8,2.6,.45),0,.35,1.3);for row=1,4 do for col=1,10 do p("Keycap",Vector3.new(.27,.4,.13),(col-5.5)*.34,(row-2.5)*.5+.4,1.61,(row+col)%4==0 and A or Color3.fromRGB(228,232,240))end end
  p("Spacebar",Vector3.new(1.9,.26,.15),0,-.78,1.62,A)
 elseif kind=="Pencil"then
  for _,x in {-.75,.75}do p("YellowPencil",Vector3.new(3.4,.75,.75),x,.25,1.4,B,cyl,math.pi/2);p("Eraser",Vector3.new(.6,.82,.82),x,-1.8,1.4,A,cyl,math.pi/2);p("WoodTip",Vector3.new(.66,.82,.66),x,2.28,1.4,Color3.fromRGB(223,170,107),ball);p("Graphite",Vector3.one*.28,x,2.75,1.4,Color3.fromRGB(33,35,40),ball)end
 elseif kind=="Banana"then
  for i=0,8 do local angle=-1.1+i*.25;p("BananaCurve",Vector3.new(.75,.85,.85),math.cos(angle)*1.5-.45,math.sin(angle)*1.6+.5,1.5,B,ball)end;p("BananaStem",Vector3.new(.35,.7,.4),.1,2.4,1.5,A)
 elseif kind=="Donut"then
  for i=1,16 do local a=i*math.pi/8;local x,y=math.cos(a)*1.3,math.sin(a)*1.3+.35;p("DonutBread",Vector3.new(.85,.85,1),x,y,1.35,B,ball);p("PinkIcing",Vector3.new(.76,.76,.35),x,y,1.9,A,ball);if i%2==0 then p("Sprinkle",Vector3.new(.3,.08,.12),x,y,2.11,Color3.fromHSV(i/16,.7,1),nil,a)end end
 elseif kind=="Fish"then
  p("FishBody",Vector3.new(2.25,3.4,1.2),0,.35,1.4,B,ball);p("FishTail",Vector3.new(2.3,.65,.35),0,-1.5,1.4,A,nil,.2);for _,x in {-.48,.48}do p("FishEye",Vector3.one*.4,x,1.35,2.02,Color3.new(1,1,1),ball);p("Pupil",Vector3.one*.19,x,1.35,2.21,Color3.new(0,0,0),ball)end
 elseif kind=="Soda"then
  p("SodaCan",Vector3.new(3.5,2.4,2.4),0,.2,1.5,B,cyl,math.pi/2);for _,y in {-1.58,1.98}do p("MetalRim",Vector3.new(.15,2.48,2.48),0,y,1.5,A,cyl,math.pi/2)end;p("CanLabel",Vector3.new(1.8,1.4,.1),0,.25,2.71,A);p("PullTab",Vector3.new(.4,.13,.75),0,2.08,1.5,A)
 elseif kind=="Pizza"then
  for i=1,7 do local y=1.85-(i-1)*.47;p("PizzaSlice",Vector3.new(.5+i*.4,.49,.5),0,y,1.4,B)end;p("PizzaCrust",Vector3.new(3.5,.6,.65),0,-1.47,1.4,Color3.fromRGB(191,122,60),cyl)
  for i=1,6 do p("Pepperoni",Vector3.new(.42,.42,.15),math.sin(i*2)*(.2+i*.1),1.5-i*.4,1.76,A,ball)end
 elseif kind=="Cloud"then
  for i=1,5 do p("CloudPuff",Vector3.new(1.5,1.7,1.2),(i-3)*.65,.8+math.sin(i)*.4,1.5,B,ball)end;for i=1,7 do p("RainbowDrop",Vector3.new(.25,1.6,.2),(i-4)*.35,-.8,1.5,Color3.fromHSV(i/7,.65,1))end
 elseif kind=="Satellite"then
  p("SatelliteCore",Vector3.new(1.6,2.4,1.1),0,.25,1.4,B);for _,side in {-1,1}do p("SolarPanel",Vector3.new(1.8,2.9,.18),side*1.7,.4,1.4,A);for i=1,4 do p("SolarGrid",Vector3.new(1.85,.04,.08),side*1.7,(i-2.5)*.6+.4,1.52,Color3.fromRGB(205,229,255))end end;p("Antenna",Vector3.new(.13,1,.13),0,2.05,1.4,B);p("SignalTip",Vector3.one*.28,0,2.65,1.4,A,ball)
 else return false end
 return true
end
return S
