-- Centered entrance animation; separate scale preserves responsive panel sizing.
local TweenService=game:GetService("TweenService")
local M={}
function M.Attach(panel)
 local scale=Instance.new("UIScale");scale.Name="MenuEntranceScale";scale.Parent=panel
 local tween
 local function changed()
  if tween then tween:Cancel()end
  if panel.Visible then
   scale.Scale=.92;tween=TweenService:Create(scale,TweenInfo.new(.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1});tween:Play()
  end
 end
 panel:GetPropertyChangedSignal("Visible"):Connect(changed);changed()
end
return M
