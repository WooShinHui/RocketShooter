-- Rear-left rocket grid and rear-right toilet row relative to the spawn. Saved indices stay unchanged.
local RS=game:GetService("ReplicatedStorage")
local SS=game:GetService("ServerStorage")
local Skins=require(RS:WaitForChild("RocketSkinCatalog"))
local Growth=require(RS:WaitForChild("ProgressionConfig"))
local Config=require(RS:WaitForChild("ShowroomConfig"))
local Rocket=require(script.Parent.BackRocket)
local Styles=require(RS:WaitForChild("RocketStyles"))
local Effects=require(script.Parent.ShowroomEffects)
local Showroom={}
local function part(parent,name,size,cf,color)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Anchored=true;p.Material=Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function prompt(anchor,kind,index,name)
 local p=Instance.new("ProximityPrompt");p.Name="UseDisplay";p.KeyboardKeyCode=Enum.KeyCode.E;p.GamepadKeyCode=Enum.KeyCode.ButtonX;p.HoldDuration=.15;p.MaxActivationDistance=12;p.RequiresLineOfSight=false;p.ObjectText=name;p.ActionText=kind=="Rocket"and "Unlock / Equip"or "Unlock / Train";p:SetAttribute("DisplayKind",kind);p:SetAttribute("DisplayIndex",index);p.Parent=anchor
end
local function badge(anchor,title)
 local b=Instance.new("BillboardGui");b.Name="DisplayInfo";b.Size=UDim2.fromScale(12,6.5);b.StudsOffsetWorldSpace=Vector3.new(0,11,0);b.MaxDistance=85;b.AlwaysOnTop=false;b.Adornee=anchor;b.Parent=anchor
 for i,name in {"Status","Name","Ability","Requirement"}do
  local t=Instance.new("TextLabel");t.Name=name;t.Size=UDim2.fromScale(1,.25);t.Position=UDim2.fromScale(0,(i-1)*.25);t.BackgroundTransparency=1;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextSize=i==1 and 19 or 22;t.TextStrokeTransparency=0;t.TextStrokeColor3=Color3.fromRGB(16,18,24);t.TextColor3=i==4 and Color3.fromRGB(255,222,45)or Color3.new(1,1,1);t.TextWrapped=true;t.Text=name=="Name"and title or "";t.Parent=b
  local limit=Instance.new("UITextSizeConstraint");limit.MinTextSize=8;limit.MaxTextSize=i==1 and 22 or 26;limit.Parent=t
 end
end
function Showroom.Build(camp)
 local spawn=workspace:FindFirstChild("SpawnLocation");assert(spawn,"SpawnLocation required")
 local look=spawn.CFrame.LookVector;local forward=Vector3.new(look.X,0,look.Z).Unit;local right=Vector3.new(-forward.Z,0,forward.X)
 local origin=Vector3.new(spawn.Position.X,spawn.Position.Y+spawn.Size.Y/2,spawn.Position.Z)
 local function cf(x,z,y,facing)local p=origin+right*x+forward*z+Vector3.yAxis*y;return CFrame.lookAt(p,p+right*(facing or 1))end
 camp:SetAttribute("ShowroomVersion",Config.Version)
 local templates=SS:FindFirstChild("ShowroomAssetTemplates")
 local toilet=templates and templates:FindFirstChild("Toilet2091145711")
 assert(toilet,"Missing reviewed toilet2091145711 template in ServerStorage.ShowroomAssetTemplates")
 local rockets=Instance.new("Folder");rockets.Name="RocketDisplays";rockets.Parent=camp
 local columns=math.min(Config.RocketColumns,#Skins.DisplayIndices)
 local rows=math.ceil(#Skins.DisplayIndices/Config.RocketColumns)
 local width=(columns-1)*Config.RocketSpacing;local depth=(rows-1)*Config.RocketSpacing
 -- cf faces inward: local X follows spawn-forward, local Z spans left/right.
 part(rockets,"ShowroomDeck",Vector3.new(width+24,.6,depth+24),cf(Config.RocketSide-depth/2,-Config.RearOffset-width/2,.3,1),Color3.fromRGB(212,227,244))
 for slot,index in Skins.DisplayIndices do
  local item=Skins.Items[index];local x,z,facing=Config.Slot("Rocket",slot)
  local m=Instance.new("Model");m.Name=item.Id;m:SetAttribute("RocketIndex",index);m:SetAttribute("DisplaySlot",slot);m.Parent=rockets
  local base=part(m,"Pedestal",Vector3.new(11,1.5,11),cf(x,z,1.15,facing),Color3.fromRGB(235,244,255));m.PrimaryPart=base
  part(m,"Inset",Vector3.new(9,.2,9),cf(x,z,2,facing),Styles[item.Id].Accent)
  local dummy=Instance.new("Model");local torso=Instance.new("Part");torso.Name="UpperTorso";torso.Anchored=true;torso.Parent=dummy;Rocket.Attach(dummy,item.Id)
  local model=dummy.BackRocket
  for _,v in model:GetDescendants()do if v:IsA("WeldConstraint")then v:Destroy()elseif v:IsA("BasePart")then v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false end end
  model.Parent=m;model:ScaleTo(1.7);local box,size=model:GetBoundingBox();-- BackRocket art sits on torso local +Z: rotate it so the art, not harness, faces the aisle.
  local target=cf(x,z,2.1+size.Y/2,-facing);model:PivotTo(target*CFrame.new(box.Position):Inverse()*model:GetPivot());dummy:Destroy()
  Effects.Pedestal(base,Styles[item.Id].Accent)
  badge(base,item.Name);prompt(base,"Rocket",index,item.Name)
 end
 local stations=camp:FindFirstChild("TrainingStations")or Instance.new("Folder");stations.Name="TrainingStations";stations.Parent=camp
 local length=(#Growth.Tiers-1)*Config.ToiletSpacing
 part(stations,"TrainingDeck",Vector3.new(length+24,.6,25),cf(Config.ToiletSide,-Config.RearOffset-length/2,.3,-1),Color3.fromRGB(211,235,222))
 for i,t in Growth.Tiers do
  local old=stations:FindFirstChild("Toilet"..i);if old then old:Destroy()end
  local style=Config.ToiletStyles[i];local x,z,facing=Config.Slot("Training",i)
  local m=Instance.new("Model");m.Name="Toilet"..i;m:SetAttribute("TrainingTier",i);m:SetAttribute("SourceAssetId",Config.ToiletAsset);m.Parent=stations
  local base=part(m,"Base",Vector3.new(17,1.5,18),cf(x,z,1.15,facing),style.Color);m.PrimaryPart=base
  local visual=toilet:Clone();visual.Name="ToiletVisual"
  for _,v in visual:GetDescendants()do if v:IsA("BasePart")then
   v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false
   if v:IsA("Seat")then v.Disabled=true;v.Transparency=1
   elseif string.find(v.Name,"Water")then v.Color=style.Accent;v.Material=Enum.Material.Glass;v.Transparency=.25
   else v.Color=(v.Name=="Handle"or v.Name=="Hinges")and style.Accent or style.Color;v.Material=Enum.Material[style.Material];if v:IsA("UnionOperation")then v.UsePartColor=true end end
  end end
  -- The template floor is identity, with its chair facing local -Z.
  local target=cf(x,z,1.95,facing);visual:PivotTo(target*visual:GetPivot());visual.Parent=m
  local seat=visual:FindFirstChild("ToiletSeat",true);assert(seat,"Reviewed toilet has no seat marker");seat.Parent=m
  Effects.Toilet(m,base,style)
  badge(base,t.Name.." Toilet");prompt(base,"Training",i,t.Name.." Toilet")
  local number=Instance.new("SurfaceGui");number.Name="TierNumber";number.Face=Enum.NormalId.Top;number.CanvasSize=Vector2.new(512,512);number.Parent=base
  local label=Instance.new("TextLabel");label.BackgroundTransparency=1;label.Size=UDim2.fromScale(1,1);label.Font=Enum.Font.GothamBlack;label.TextSize=140;label.Text=tostring(i);label.TextColor3=Color3.new(1,1,1);label.TextStrokeTransparency=0;label.Parent=number
 end
 local function heading(name,x,title,color)
  local p=part(camp,name,Vector3.one,cf(x,-Config.RearOffset+18,5,x<0 and 1 or -1),color);p.Transparency=1;p.CanCollide=false
  local b=Instance.new("BillboardGui");b.Size=UDim2.fromOffset(390,80);b.StudsOffsetWorldSpace=Vector3.new(0,5,0);b.MaxDistance=100;b.Parent=p
  local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=title;t.Font=Enum.Font.GothamBlack;t.TextSize=27;t.TextColor3=color;t.TextStrokeTransparency=0;t.Parent=b
 end
 heading("RocketHeading",Config.RocketSide-depth/2,"ROCKET SHOWROOM\nE · Buy with Trophies / Equip",Color3.fromRGB(255,221,45))
 heading("TrainingHeading",Config.ToiletSide,"AFK TRAINING\nE to Unlock · Approach to Sit",Color3.fromRGB(70,255,155))
end
return Showroom
