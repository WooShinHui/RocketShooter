-- Temporary testing controls. Remove with StudioProgressTest.server.luau before release.
local RunService=game:GetService("RunService")
if not RunService:IsStudio() or (game.GameId~=0 and game.PlaceId~=0) then return end
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remote=RS:WaitForChild("StudioProgressTest",15)
if not remote or not remote:IsA("RemoteFunction") then return end
local gui=Instance.new("ScreenGui")
gui.Name="StudioProgressTestGui";gui.ResetOnSpawn=false;gui.DisplayOrder=100
gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
local panel=Instance.new("Frame")
panel.Name="Controls";panel.AnchorPoint=Vector2.new(1,0);panel.Position=UDim2.new(1,-10,0,8)
panel.Size=UDim2.fromOffset(222,56);panel.BackgroundTransparency=1;panel.Parent=gui
local status=Instance.new("TextLabel")
status.Name="Status";status.Position=UDim2.fromOffset(0,32);status.Size=UDim2.fromOffset(222,20)
status.BackgroundTransparency=1;status.Font=Enum.Font.Gotham;status.TextSize=12
status.TextColor3=Color3.fromRGB(235,240,250);status.TextStrokeTransparency=.4;status.Text="STUDIO TEST";status.Parent=panel
local busy=false
local function button(name,x,text,action)
 local b=Instance.new("TextButton")
 b.Name=name;b.Position=UDim2.fromOffset(x,0);b.Size=UDim2.fromOffset(108,28)
 b.BackgroundColor3=Color3.fromRGB(35,47,66);b.BackgroundTransparency=.15
 b.BorderSizePixel=0;b.Font=Enum.Font.GothamBold;b.TextSize=13;b.TextColor3=Color3.new(1,1,1);b.Text=text;b.Parent=panel
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,6);corner.Parent=b
 b.Activated:Connect(function()
  if busy then return end;busy=true
  local ok,success,message=pcall(function()return remote:InvokeServer(action)end)
  status.Text=if ok then message or (success and "+1" or "요청 실패") else "테스트 요청 실패"
  busy=false
 end)
end
button("RebirthPlus",0,"환생 +1","Rebirth")
button("LevelPlus",114,"레벨 +1","Level")
local function update()
 local state=player:GetAttribute("FlightState")
 gui.Enabled=player:GetAttribute("DataReady")==true and player:GetAttribute("DataMode")=="StudioMemory" and (state==nil or state=="Idle")
end
for _,name in {"DataReady","DataMode","FlightState"}do player:GetAttributeChangedSignal(name):Connect(update)end
update();gui.Parent=player:WaitForChild("PlayerGui")
