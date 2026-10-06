local Players=game:GetService("Players");local Run=game:GetService("RunService")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui");gui.Name="DiveBreakGuide";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=56;gui.Parent=player:WaitForChild("PlayerGui")
local title=Instance.new("TextLabel");title.Name="NextLayer";title.AnchorPoint=Vector2.new(.5,0);title.Position=UDim2.new(.5,0,0,140);title.Size=UDim2.fromOffset(460,64);title.BackgroundColor3=Color3.fromRGB(18,31,49);title.BackgroundTransparency=.2;title.TextColor3=Color3.new(1,1,1);title.Font=Enum.Font.GothamBold;title.TextSize=19;title.TextWrapped=true;title.Visible=false;title.Parent=gui
local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,12);corner.Parent=title
local markers={}
for i=1,3 do
 local t=Instance.new("TextLabel");t.Name="TargetChoice"..i;t.AnchorPoint=Vector2.new(.5,.5);t.Size=UDim2.fromOffset(116,38);t.BackgroundColor3=Color3.fromRGB(18,31,49);t.BackgroundTransparency=.2;t.TextStrokeTransparency=.25;t.Font=Enum.Font.GothamBlack;t.TextSize=17;t.Visible=false;t.Parent=gui;markers[i]=t
end
local folder;local elapsed=0
Run.RenderStepped:Connect(function(dt)
 elapsed+=dt;if elapsed<.06 then return end;elapsed=0
 title.Visible=false;for _,m in markers do m.Visible=false end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");local camera=workspace.CurrentCamera
 if not root or not camera or player:GetAttribute("FlightState")~="Flying"or root.AssemblyLinearVelocity.Y>=0 then return end
 if not folder or not folder.Parent or folder:GetAttribute("RunId")~=player:GetAttribute("SkyRunSerial")then
  folder=nil
  for _,f in workspace:GetChildren()do if f:GetAttribute("PlayerId")==player.UserId and f:GetAttribute("RunId")==player:GetAttribute("SkyRunSerial")then folder=f:FindFirstChild("DiveBreakZone");if folder then break end end end
 end
 if not folder then return end
 local targets={};local nearest
 for _,m in folder:GetChildren()do if m:IsA("Model")and m:GetAttribute("TargetKind")=="Block"and m.PrimaryPart and not m:GetAttribute("Broken")and not m:GetAttribute("Passed")and (m:GetAttribute("WindowBottom")or m.PrimaryPart.Position.Y)<root.Position.Y+4 then
  local top=m:GetAttribute("WindowTop")or m.PrimaryPart.Position.Y;if not nearest or top>nearest then nearest=top end;table.insert(targets,m)
 end end
 local ringNearest;for _,m in folder:GetChildren()do if m:GetAttribute("TargetKind")=="Ring"and m.PrimaryPart and not m:GetAttribute("Broken")and m.PrimaryPart.Position.Y<root.Position.Y+4 then
  if not ringNearest or m.PrimaryPart.Position.Y>ringNearest then ringNearest=m.PrimaryPart.Position.Y end
 end end
 local ringOnly=not nearest
 if not nearest then nearest=ringNearest end
 if not nearest then return end
 local viewport=camera.ViewportSize;local compact=viewport.Y<500 or viewport.X<600
 title.Size=UDim2.fromOffset(math.max(180,math.min(compact and 300 or 460,viewport.X-(compact and 180 or 24))),compact and 38 or 64);title.TextSize=compact and 13 or 19
 local flightGui=player.PlayerGui:FindFirstChild("RocketFlightGui")
 local meter=flightGui and flightGui:FindFirstChild("DestructionRewards")
 local top=140
 if meter and meter.Visible then top=meter.AbsolutePosition.Y+meter.AbsoluteSize.Y+10-gui.AbsolutePosition.Y end
 local readout=flightGui and flightGui:FindFirstChild("CompactFlightReadout")
 if compact and readout and readout.Visible then top=readout.AbsolutePosition.Y+readout.AbsoluteSize.Y+6-gui.AbsolutePosition.Y end
 title.Position=UDim2.new(.5,0,0,top)
 local shown=0;local central,bonus,layer
 for _,m in targets do if math.abs((m:GetAttribute("WindowTop")or m.PrimaryPart.Position.Y)-nearest)<1 then
  local lane=m:GetAttribute("Lane");layer=m:GetAttribute("LayerIndex");if lane==0 then central=m:GetAttribute("TrophyAmount")else bonus=m:GetAttribute("TrophyAmount")end
  shown+=1;local marker=markers[shown];if not marker then break end
  local point,visible=camera:WorldToViewportPoint(Vector3.new(m.PrimaryPart.Position.X,math.clamp(root.Position.Y-100,m:GetAttribute("WindowBottom")or nearest,nearest),m.PrimaryPart.Position.Z))
  marker.Size=UDim2.fromOffset(compact and 86 or 116,compact and 26 or 38);marker.TextSize=compact and 12 or 17
  local low=math.min(top+(compact and 60 or 90),viewport.Y-(compact and 86 or 190))
  marker.Visible=point.Z>0;marker.Position=UDim2.fromOffset(math.clamp(point.X,62,math.max(62,viewport.X-62)),math.clamp(point.Y,low,math.max(low,viewport.Y-190)));marker.Text=lane==0 and "Center ×1"or(point.X<viewport.X/2 and "◀ Bonus ×3"or "Bonus ×3 ▶");marker.TextColor3=lane==0 and Color3.fromRGB(102,229,255)or Color3.fromRGB(255,202,62)
  if compact and visible and flightGui then
   local x,y=marker.Position.X.Offset,marker.Position.Y.Offset;local w,h=marker.Size.X.Offset,marker.Size.Y.Offset
   for _,name in {"Dive","Explode","Abort"}do local button=flightGui:FindFirstChild(name)
    if button and button.Visible then
     local bx,by=button.AbsolutePosition.X-gui.AbsolutePosition.X,button.AbsolutePosition.Y-gui.AbsolutePosition.Y
     if x-w/2<bx+button.AbsoluteSize.X and x+w/2>bx and y-h/2<by+button.AbsoluteSize.Y and y+h/2>by then x=math.max(w/2+8,bx-w/2-10)end
    end
   end
   marker.Position=UDim2.fromOffset(x,y)
  end
 end end
 title.Visible=true
 if ringOnly then title.Text=string.format(compact and "Ring %d/%d · %dm below\nPass through the ring!"or "Dive Ring %d/%d · Next %dm\nKeep passing through rings!",folder:GetAttribute("RingHits")or 0,folder:GetAttribute("RingTotal")or 0,math.max(0,math.floor(root.Position.Y-nearest)))
 else title.Text=string.format(compact and "Dive Zone %d · %dm below\nCenter +%d · Bonus +%d"or "Dive Zone %d · %dm below\nCenter +%d / Bonus +%d Trophies",layer or 1,math.max(0,math.floor(root.Position.Y-nearest)),central or 0,bonus or 0)end
end)
