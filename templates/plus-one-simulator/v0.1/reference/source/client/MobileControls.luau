local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Mobile={}
local function button(parent,name,text,position,size)
 local b=Instance.new("TextButton");b.Name=name;b.Text=text;b.Size=size or UDim2.fromOffset(64,64);b.Position=position
 b.Font=Enum.Font.GothamBold;b.TextSize=24;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(38,118,178);b.BackgroundTransparency=.12;b.Parent=parent
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,16);corner.Parent=b
 return b
end
local function scope(parent)
 local frame=Instance.new("Frame");frame.Name="TouchControls";frame.BackgroundTransparency=1;frame.Size=UDim2.fromScale(1,1);frame.Parent=parent
 local connections={};local pressed={};local stopped=false
 local function connect(signal,fn) table.insert(connections,signal:Connect(fn)) end
 local function hold(b,key)
  connect(b.InputBegan,function(input)
   if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then pressed[input]=key end
  end)
 end
 connect(UIS.InputEnded,function(input) pressed[input]=nil end)
 connect(UIS.WindowFocusReleased,function() table.clear(pressed) end)
 local function active(key) for _,value in pressed do if value==key then return 1 end end;return 0 end
 local function stop()
  if stopped then return end;stopped=true
  for _,c in connections do c:Disconnect() end;table.clear(pressed);frame:Destroy()
 end
 return frame,connect,hold,active,stop
end
function Mobile.Aim(gui,adjust,fire)
 local frame,connect,hold,active,stop=scope(gui)
 hold(button(frame,"AimLeft","◀",UDim2.new(0,16,1,-154)),"left")
 hold(button(frame,"AimRight","▶",UDim2.new(0,140,1,-154)),"right")
 hold(button(frame,"AimUp","▲",UDim2.new(0,86,1,-224)),"up")
 hold(button(frame,"AimDown","▼",UDim2.new(0,86,1,-84)),"down")
 local launch=button(frame,"FireButton","Launch!",UDim2.new(1,-126,1,-132),UDim2.fromOffset(110,88));launch.BackgroundColor3=Color3.fromRGB(240,107,48)
 connect(launch.Activated,fire)
 connect(RunService.RenderStepped,function(dt) adjust((active("right")-active("left"))*35*dt,(active("up")-active("down"))*35*dt) end)
 return {Stop=stop}
end
function Mobile.Steer(setAxis)
 local gui=Instance.new("ScreenGui");gui.Name="FlightTouchControls";gui.ResetOnSpawn=false;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.DisplayOrder=60;gui.Parent=Players.LocalPlayer.PlayerGui
 local frame,connect,hold,active,stop=scope(gui)
 hold(button(frame,"SteerLeft","◀",UDim2.new(0,20,1,-110),UDim2.fromOffset(88,76)),"left")
 hold(button(frame,"SteerRight","▶",UDim2.new(1,-108,1,-110),UDim2.fromOffset(88,76)),"right")
 connect(RunService.Heartbeat,function() setAxis(active("right")-active("left")) end)
 return {Stop=function() stop();gui:Destroy();setAxis(0) end}
end
return Mobile
