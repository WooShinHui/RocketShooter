-- Visual skin using reviewed packs 99176447965360 (icons),
-- 136376766704443 (adapted hover/press effect), 111176085924966 (reviewed panel).
-- Its close image fails ContentProvider loading; use the icon pack's Close.
-- No imported admin/network scripts run.
local Tween=game:GetService("TweenService")
local T={}
function T.Surface(frame,studs)
 if frame.Name=="Shade"or frame.Name=="ModalShade"then return end
 local gradient=frame:FindFirstChild("SimulatorGradient")
 if not gradient then gradient=Instance.new("UIGradient");gradient.Name="SimulatorGradient";gradient.Rotation=90;gradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(169,179,200));gradient.Parent=frame end

end
function T.Button(button)
 if button:GetAttribute("SimulatorAnimated")then return end;button:SetAttribute("SimulatorAnimated",true)
 -- Retain the caller's logical placement while centering the scale anchor.
 local logical=button.Position;local callerAnchor=button.AnchorPoint;local applied
 local function recenter()
  local dx,dy=.5-callerAnchor.X,.5-callerAnchor.Y
  applied=logical+UDim2.new(button.Size.X.Scale*dx,button.Size.X.Offset*dx,button.Size.Y.Scale*dy,button.Size.Y.Offset*dy)
  button.AnchorPoint=Vector2.new(.5,.5);button.Position=applied
 end
 button:GetPropertyChangedSignal("Position"):Connect(function()if button.Position~=applied then logical=button.Position;recenter()end end)
 button:GetPropertyChangedSignal("Size"):Connect(recenter)
 button:GetPropertyChangedSignal("AnchorPoint"):Connect(function()if button.AnchorPoint~=Vector2.new(.5,.5)then callerAnchor=button.AnchorPoint;recenter()end end)
 recenter()
 local scale=Instance.new("UIScale");scale.Name="PackHoverScale";scale.Parent=button
 local animation;local hover=false
 local function play(value)if animation then animation:Cancel()end;animation=Tween:Create(scale,TweenInfo.new(.13,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=value});animation:Play()end
 button.MouseEnter:Connect(function()hover=true;play(1.035)end);button.MouseLeave:Connect(function()hover=false;play(1)end)
 button.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then play(.95)end end)
 button.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then play(hover and 1.035 or 1)end end)
end
return T
