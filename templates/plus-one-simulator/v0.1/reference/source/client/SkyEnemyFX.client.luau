-- Local warning outline; patrol movement and collision remain on the server.
local player=game.Players.LocalPlayer
local highlights={};local elapsed=0
game:GetService("RunService").Heartbeat:Connect(function(dt)
 elapsed+=dt;if elapsed<.15 then return end;elapsed=0
 for m,h in highlights do if not m.Parent then h:Destroy();highlights[m]=nil end end
 local folder=workspace:FindFirstChild("SkyLife");if not folder then return end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 local flying=player:GetAttribute("FlightState")=="Flying"
 for _,m in folder:GetChildren() do
  if m:GetAttribute("SkyKind")~="Enemy" or not m:IsA("Model") or not m.PrimaryPart then continue end
  local near=flying and root and (root.Position-m.PrimaryPart.Position).Magnitude<160
  local h=highlights[m]
  if near and not h then
   h=Instance.new("Highlight");h.Name="EnemyWarning";h.Adornee=m;h.FillTransparency=.8;h.OutlineTransparency=0;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=m;highlights[m]=h
  end
  if h then
   h.Enabled=near==true;local attack=m:GetAttribute("Attacking")
   h.FillColor=if attack then Color3.fromRGB(255,55,65) else Color3.fromRGB(255,70,95)
   h.OutlineColor=h.FillColor
  end
 end
end)
