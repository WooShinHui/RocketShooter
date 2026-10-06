-- Camera-facing launch canvas: one continuous chevron image, bottom-to-top chase.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local pad=workspace:WaitForChild("RocketLaunchPad",30)
if not pad then return end
local gui=Instance.new("BillboardGui")
gui.Name="LaunchPadGuide";gui.Adornee=pad
local width=math.min(pad.Size.X,pad.Size.Z)
gui.Size=UDim2.fromScale(width,width*1.05)
gui.StudsOffsetWorldSpace=Vector3.new(0,width*.525+3,0)
gui.MaxDistance=130;gui.AlwaysOnTop=true;gui.LightInfluence=0;gui.ResetOnSpawn=false
gui.ClipsDescendants=false
local arrows={}
for i=1,3 do
 local image=Instance.new("ImageLabel");image.Name="Chevron"..i
 image.BackgroundTransparency=1;image.BorderSizePixel=0
 image.Size=UDim2.fromScale(1,.5);image.Position=UDim2.fromScale(0,(3-i)*.295)
 image.Image="rbxassetid://89592676843349";image.ScaleType=Enum.ScaleType.Fit
 image.ImageColor3=Color3.fromRGB(255,212,0);image.ImageTransparency=.6
 image.Parent=gui;arrows[i]=image
end
gui.Parent=player:WaitForChild("PlayerGui")
local elapsed=0;local connection
connection=RunService.RenderStepped:Connect(function(dt)
 if not pad.Parent then connection:Disconnect();gui:Destroy();return end
 local idle=(player:GetAttribute("FlightState")or "Idle")=="Idle"
 gui.Enabled=idle
 if not idle then elapsed=0;gui:SetAttribute("ActiveChevron",0);return end
 elapsed+=dt
 -- Three distinct .28s steps followed by a .36s pause; i=1 is the bottom image.
 local phase=elapsed%1.2
 local selected=phase<.84 and math.floor(phase/.28)+1 or 0
 gui:SetAttribute("ActiveChevron",selected)
 gui.StudsOffsetWorldSpace=Vector3.new(0,width*.525+3+math.sin(elapsed*2)*.35,0)
 for i,image in arrows do
  image.ImageTransparency=i==selected and 0 or .6
  image.ImageColor3=i==selected and Color3.fromRGB(255,233,44)or Color3.fromRGB(255,194,0)
 end
end)
