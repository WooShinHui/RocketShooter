local Config=require(game:GetService("ReplicatedStorage"):WaitForChild("TrophyZoneConfig"))
local Impact=require(script.Parent.DiveImpact)
local Physics=game:GetService("PhysicsService")
-- Tutorial (deferred): "착지하면 +%d 트로피"
local Zones={};local registered={};local origin;local folder
local function part(name,size,position,color,solid,parent)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=position;p.Color=color;p.Anchored=true;p.CanCollide=solid;p.CanTouch=solid;p.CanQuery=solid;p.Material=Enum.Material.SmoothPlastic;p.Parent=parent;return p
end
function Zones.Start(launchPosition,ground)
 for _,name in {"RocketTrophyDeck","RocketAscentBody"}do pcall(function()Physics:RegisterCollisionGroup(name)end)end
 Physics:CollisionGroupSetCollidable("RocketTrophyDeck","RocketAscentBody",false)
 if folder then folder:Destroy()end;table.clear(registered);origin=Vector3.new(launchPosition.X,ground,launchPosition.Z)
 folder=Instance.new("Folder");folder.Name="RocketTrophyZones";folder.Parent=workspace
 for i=1,Config.Count do
  local layer=Config.Layer(i);local center=origin+Vector3.new(layer.Offset,layer.Height,0)
  local model=Instance.new("Model");model.Name="TrophyLayer"..i;model.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;model.Parent=folder
  local deck=part("LandingDeck",Vector3.new(Config.Width,4,Config.Depth),center-Vector3.new(0,2,0),Color3.fromRGB(48,124,131),true,model)
  deck:SetAttribute("TrophyZoneIndex",i);deck:SetAttribute("TrophyReward",layer.Reward);registered[deck]=layer
  deck.CollisionGroup="RocketTrophyDeck"
  local rim=part("GoldRim",Vector3.new(Config.Width+3,.6,Config.Depth+3),center-Vector3.new(0,3.4,0),Color3.fromRGB(255,209,63),false,model);rim.Material=Enum.Material.Neon
  local mark=part("SafeLandingMark",Vector3.new(22,.08,26),center+Vector3.new(0,.06,0),Color3.fromRGB(129,255,211),false,model);mark.Material=Enum.Material.Neon
  local base=center+Vector3.new(0,2,-Config.Depth/2+8)
  part("TrophyBase",Vector3.new(8,1,6),base,Color3.fromRGB(255,196,44),false,model)
  part("TrophyStem",Vector3.new(2,5,2),base+Vector3.new(0,3,0),Color3.fromRGB(255,215,64),false,model)
  local cup=part("TrophyCup",Vector3.new(8,6,7),base+Vector3.new(0,7,0),Color3.fromRGB(255,215,64),false,model);cup.Shape=Enum.PartType.Ball
  for _,side in {-1,1}do local handle=part("TrophyHandle",Vector3.new(3,5,2),base+Vector3.new(side*5,7,0),Color3.fromRGB(255,215,64),false,model);handle.Shape=Enum.PartType.Ball end
  local gui=Instance.new("BillboardGui");gui.Name="ZoneSign";gui.Size=UDim2.fromOffset(330,100);gui.StudsOffset=Vector3.new(0,16,0);gui.MaxDistance=450;gui.AlwaysOnTop=false;gui.Parent=deck
  local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.BackgroundColor3=Color3.fromRGB(15,55,64);label.TextColor3=Color3.fromRGB(255,229,91);label.Font=Enum.Font.GothamBlack;label.TextSize=20;label.TextStrokeTransparency=.25;label.TextWrapped=true;label.Text=string.format("🏆 Trophy Zone %d · %dm\n+%d Trophies",i,layer.Height,layer.Reward);label.Parent=gui
 end
end
-- One-way landing decks let rockets pass upwards without hitting their underside.
function Zones.Ascend(character)
 local saved={}
 for _,p in character:GetDescendants()do if p:IsA("BasePart")then saved[p]=p.CollisionGroup or "Default";p.CollisionGroup="RocketAscentBody"end end
 return saved
end
function Zones.Restore(saved)
 for p,group in saved or {}do if p.Parent then p.CollisionGroup=group end end
end
function Zones.Resolve(instance,point,normal)
 local layer=registered[instance]
 if not layer or not instance.Parent or not normal or normal.Y<.7 then return nil end
 local top=instance.Position.Y+instance.Size.Y/2
 if math.abs(point.Y-top)>.5 or math.abs(point.X-instance.Position.X)>instance.Size.X/2+.1 or math.abs(point.Z-instance.Position.Z)>instance.Size.Z/2+.1 then return nil end
 return layer
end
-- Sweep the solid character footprint across registered deck tops, not a center ray.
function Zones.IsDeck(instance) return registered[instance]~=nil and instance.Parent~=nil end
function Zones.Sweep(character,root,previous,nextPosition)
 local offset,halfX,halfZ=Impact.Bounds(character,root)
 local start=previous or root.Position;local from=start.Y-offset;local to=nextPosition.Y-offset
 if to>=from then return nil end
 local best,contact,point,bestT
 for deck,layer in registered do
  if not deck.Parent then continue end
  local top=deck.Position.Y+deck.Size.Y/2
  if from<top-.25 or to>top then continue end
  local t=math.clamp((from-top)/(from-to),0,1);local at=start+(nextPosition-start)*t
  if math.abs(at.X-deck.Position.X)>deck.Size.X/2+halfX-.08 or math.abs(at.Z-deck.Position.Z)>deck.Size.Z/2+halfZ-.08 then continue end
  if bestT and t>=bestT then continue end
  bestT=t;best=layer
  point=Vector3.new(math.clamp(at.X,deck.Position.X-deck.Size.X/2,deck.Position.X+deck.Size.X/2),top,math.clamp(at.Z,deck.Position.Z-deck.Size.Z/2,deck.Position.Z+deck.Size.Z/2))
  contact=Vector3.new(math.clamp(at.X,deck.Position.X-deck.Size.X/2+1,deck.Position.X+deck.Size.X/2-1),top+offset+.015,math.clamp(at.Z,deck.Position.Z-deck.Size.Z/2+1,deck.Position.Z+deck.Size.Z/2-1))
 end
 return best,contact,point
end
function Zones.Target(height)
 local layer=Config.Recommended(height)
 if not origin or not layer then return nil end
 return {Index=layer.Index,Height=layer.Height,Reward=layer.Reward,Position=origin+Vector3.new(layer.Offset,layer.Height,0)}
end
return Zones
