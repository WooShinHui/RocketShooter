-- Bounded local spectacle; pressure, catches and rewards remain server authoritative.
local Players=game:GetService("Players");local RS=game:GetService("ReplicatedStorage");local Run=game:GetService("RunService")
local player=Players.LocalPlayer;local gates=require(RS:WaitForChild("CloudConfig")).HeightPresentation.Gates
local config=require(RS:WaitForChild("GateEncounterConfig"))
local folder=Instance.new("Folder");folder.Name="CloudGateChasers";folder.Parent=workspace
local models={};local activeIndex
local function clear()for _,p in models do p:Destroy()end;table.clear(models);activeIndex=nil end
local function make(index)
 clear();activeIndex=index;folder:SetAttribute("GateIndex",index)
 local gate=gates[index];local family=config.Families[index]
 for i=1,gate.Chasers do
  local name=family[(i-1)%#family+1];local d=config.Definitions[name];local height=i==1 and gate.BossHeight or gate.ChaserHeight
  local p=Instance.new("Part");p.Name=name;p.Size=Vector3.new(8,8,8);p.Color=Color3.new(1,1,1);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
  p:SetAttribute("VisualHeight",height);p:SetAttribute("Boss",i==1)
  local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.FileMesh;mesh.MeshId=d.Mesh;mesh.TextureId=d.Texture;mesh.Scale=Vector3.one*(height/d.MeshSize[2]);mesh.Parent=p
  if i==1 then
   local g=Instance.new("BillboardGui");g.Name="BossDanger";g.Size=UDim2.fromOffset(250,38);g.StudsOffset=Vector3.new(0,height*.65,0);g.AlwaysOnTop=true;g.Parent=p
   local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text="관문 "..index.." · 추격 대장";t.TextColor3=Color3.fromRGB(255,55,73);t.TextStrokeTransparency=0;t.Font=Enum.Font.GothamBlack;t.TextSize=25;t.Parent=g
  end
  p.Parent=folder;table.insert(models,p)
 end
 folder:SetAttribute("ChaserCount",#models)
end
Run.RenderStepped:Connect(function()
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");local index=player:GetAttribute("CloudGateIndex")
 if not root or not index or root.AssemblyLinearVelocity.Y<0 or player:GetAttribute("FlightState")~="Flying"then if #models>0 then clear()end;return end
 if activeIndex~=index then make(index)end
 local gate=gates[index];local pressure=player:GetAttribute("CloudGatePressure")or 0
 local distance=(88+index*20)*(1-pressure)+gate.ChaserHeight*.8
 local camera=workspace.CurrentCamera;local delta=camera and camera.CFrame.Position-root.Position or Vector3.zAxis
 local back=Vector3.new(delta.X,0,delta.Z);back=back.Magnitude>.01 and back.Unit or Vector3.zAxis;local right=back:Cross(Vector3.yAxis)
 for i,p in models do
  local angle=(i-1)*math.pi*2/#models+os.clock()*(.12+index*.025)
  local lateral=i==1 and 0 or math.cos(angle)*distance*.85
  local depth=i==1 and distance*.9 or distance*(.4+math.abs(math.sin(angle))*.3)
  local y=i==1 and gate.BossHeight*.2 or math.sin(angle*2)*gate.ChaserHeight*.55-distance*.1
  local position=root.Position+right*lateral-back*(depth+8)+Vector3.new(0,y,0)
  p.CFrame=CFrame.lookAt(position,root.Position)
 end
end)
player.CharacterRemoving:Connect(clear)
