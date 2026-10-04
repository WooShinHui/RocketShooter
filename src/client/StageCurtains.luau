-- Local, noninteractive cloud ceilings. Never enter the server reward/hazard path.
local Curtains={};local started=false
function Curtains.Start()
 if started then return end;started=true
 local player=game:GetService("Players").LocalPlayer
 local config=require(game:GetService("ReplicatedStorage"):WaitForChild("CloudConfig"))
 if config.HeightPresentation.CloudCurtainsEnabled==false then return end
 local definitions=config.HeightPresentation.Biomes;local active={}
 local folder=Instance.new("Folder");folder.Name="StageCloudCurtains";folder.Parent=workspace
 local function make(index)
  local model=Instance.new("Model");model.Name="구름 경계 · "..definitions[index].Name;model:SetAttribute("SkyKind","Decoration")
  local function part(size,offset)
   local p=Instance.new("Part");p.Name="StageCloud";p.Size=size;p.CFrame=CFrame.new(offset);p.Material=Enum.Material.SmoothPlastic
   p.Color=Color3.fromRGB(230,240,255);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=model;return p
  end
  model.PrimaryPart=part(Vector3.new(2048,4,2048),Vector3.zero)
  for x=-2,2 do for z=-2,2 do local p=part(Vector3.new(540,16,540),Vector3.new(x*380,0,z*380));p.Shape=Enum.PartType.Ball end end
  model.Parent=folder;return model
 end
 local elapsed=0
 game:GetService("RunService").Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.12 then return end;elapsed=0
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not root then return end
  local wanted={};local above
  for i=2,#definitions do if root.Position.Y<definitions[i].Min then above=i;break end end
  if above then wanted[above]=true;if above>2 then wanted[above-1]=true end else wanted[#definitions]=true end
  for index in wanted do
   local m=active[index];if not m then m=make(index);active[index]=m end
   m:PivotTo(CFrame.new(math.floor(root.Position.X/512)*512,definitions[index].Min,math.floor(root.Position.Z/512)*512))
   local height=definitions[index].Min;local camera=workspace.CurrentCamera
   local cameraY=camera and camera.CFrame.Position.Y or root.Position.Y
   local distance=math.min(math.abs(root.Position.Y-height),math.abs(cameraY-height))
   local transparency=.85*math.clamp(1-distance/32,0,1)
   if (root.Position.Y-height)*(cameraY-height)<0 then transparency=math.max(transparency,.9)end
   for _,p in m:GetDescendants()do if p:IsA("BasePart")then p.Transparency=transparency end end
  end
  for index,m in active do if not wanted[index] then m:Destroy();active[index]=nil end end
 end)
end
return Curtains
