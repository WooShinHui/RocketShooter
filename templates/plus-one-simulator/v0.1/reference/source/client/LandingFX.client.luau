local rocketMode=game:GetService("ReplicatedStorage"):FindFirstChild("RocketModeConfig")
if rocketMode and require(rocketMode).Enabled then return end
local player=game.Players.LocalPlayer
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
game.ReplicatedStorage:WaitForChild("FlightState").OnClientEvent:Connect(function(state,id,character)
 if state~="Result" or character~=player.Character then return end
 local root=character:FindFirstChild("HumanoidRootPart");if not root then return end
 for i=1,12 do
  local angle=i*math.pi/6;local p=Instance.new("Part");p.Name="LandingImpactDust";p.Shape=Enum.PartType.Ball
  p.Size=Vector3.one*2;p.Color=Color3.fromRGB(222,201,156);p.Material=Enum.Material.SmoothPlastic;p.Transparency=.25
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Position=root.Position+Vector3.new(0,-2,0);p.Parent=workspace
  Tween:Create(p,TweenInfo.new(.55,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=p.Position+Vector3.new(math.cos(angle)*16,2,math.sin(angle)*16),Size=Vector3.one*5,Transparency=1}):Play()
  Debris:AddItem(p,.6)
 end
end)
