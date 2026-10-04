local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local Input=require(script.Parent.RocketInput)
local Audio=require(script.Parent.Audio)
local Sky=require(script.Parent.SkyController)
local UIS=game:GetService("UserInputService")
local TrophyConfig=require(game:GetService("ReplicatedStorage"):WaitForChild("TrophyZoneConfig"))
local SpeedFX=require(script.Parent.RocketSpeedFX)
-- Tutorial (deferred): "로켓 발판을 밟으면 자동 상승!", "급강하 [F] 길게", "급강하 중 · 놓으면 해제"
local Controller={}
function Controller.Start(remotes,objective)
 require(script.Parent.StageCurtains).Start()
 local player=Players.LocalPlayer;local active;local newest=0;local defaultFOV=workspace.CurrentCamera.FieldOfView
 local gui=Instance.new("ScreenGui");gui.Name="RocketFlightGui";gui.ResetOnSpawn=false;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.DisplayOrder=55;gui.Parent=player.PlayerGui
 local speedFX=SpeedFX.Create(gui)
 local discovery=player.PlayerGui:FindFirstChild("DiscoveryGui");local notice=discovery and discovery:FindFirstChild("Notice")
 if notice then notice.BackgroundTransparency=1;notice.Position=UDim2.new(.025,0,.22,0);notice.Size=UDim2.new(.25,0,0,64);notice.TextSize=18;notice.TextStrokeTransparency=.25;notice.TextXAlignment=Enum.TextXAlignment.Left end
 local hint=Instance.new("TextLabel");hint.AnchorPoint=Vector2.new(.5,1);hint.Position=UDim2.new(.5,0,0,154);hint.AnchorPoint=Vector2.new(.5,0);hint.Size=UDim2.new(.8,0,0,44);hint.BackgroundTransparency=1;hint.BackgroundColor3=Color3.fromRGB(30,55,84)
 hint.TextColor3=Color3.new(1,1,1);hint.Font=Enum.Font.GothamBold;hint.TextSize=22;hint.TextWrapped=true;hint.Text="";hint.Visible=false;hint.Parent=gui
 local fuelFrame=Instance.new("Frame");fuelFrame.Name="RocketFuelGauges";fuelFrame.Size=UDim2.fromScale(1,1);fuelFrame.BackgroundTransparency=1;fuelFrame.Visible=false;fuelFrame.Parent=gui
 local fuelLeft=Instance.new("Frame");fuelLeft.Name="FuelArc";fuelLeft.AnchorPoint=Vector2.new(.5,.5);fuelLeft.Size=UDim2.fromOffset(200,120);fuelLeft.BackgroundTransparency=1;fuelLeft.Parent=fuelFrame
 local arc={};local count=40;local radius=78
 for i=1,count do
  local u=(i-.5)/count;local degrees=215-u*70;local angle=math.rad(degrees)
  local function segment(name,width,color,transparency)
   local f=Instance.new("Frame");f.Name=name..i;f.AnchorPoint=Vector2.new(.5,.5);f.Position=UDim2.fromOffset(100+radius*math.cos(angle),60+radius*math.sin(angle));f.Size=UDim2.fromOffset(width,3.8);f.Rotation=degrees-180;f.BackgroundColor3=color;f.BackgroundTransparency=transparency;f.BorderSizePixel=0;f.Parent=fuelLeft;return f
  end
  segment("Track",6,Color3.fromRGB(18,34,42),.12)
  local glow=segment("Glow",9,Color3.fromRGB(102,247,231),.75)
  local fill=segment("Fuel",3.5,Color3.fromRGB(132,255,238),0)
  table.insert(arc,{Fill=fill,Glow=glow,U=u})
 end
 local fuelLabel=Instance.new("TextLabel");fuelLabel.Name="FuelLabel";fuelLabel.AnchorPoint=Vector2.new(1,.5);fuelLabel.Size=UDim2.fromOffset(76,46);fuelLabel.BackgroundTransparency=1;fuelLabel.Font=Enum.Font.GothamBold;fuelLabel.TextSize=17;fuelLabel.TextWrapped=true;fuelLabel.TextColor3=Color3.fromRGB(201,255,249);fuelLabel.TextStrokeTransparency=.3;fuelLabel.Parent=fuelFrame
 local altitude=Instance.new("Frame");altitude.Name="RocketAltitudeReadout";altitude.AnchorPoint=Vector2.new(0,.5);altitude.Size=UDim2.fromOffset(152,124);altitude.BackgroundTransparency=1;altitude.Visible=false;altitude.Parent=gui
 local function altitudeText(name,y,height,size,color)
  local label=Instance.new("TextLabel");label.Name=name;label.Position=UDim2.fromOffset(0,y);label.Size=UDim2.fromOffset(152,height);label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBold;label.TextSize=size;label.TextColor3=color;label.TextStrokeTransparency=.2;label.TextXAlignment=Enum.TextXAlignment.Left;label.Parent=altitude;return label
 end
 altitudeText("CurrentTitle",0,22,16,Color3.fromRGB(213,245,255)).Text="현재 높이"
 local currentHeight=altitudeText("CurrentHeight",24,34,27,Color3.fromRGB(245,255,255))
 local expectedTitle=altitudeText("ExpectedTitle",66,22,15,Color3.fromRGB(255,229,126))
 local expectedHeight=altitudeText("ExpectedHeight",90,30,21,Color3.fromRGB(255,229,126))
 local function choice(name,x,text,color)
  local b=Instance.new("TextButton");b.Name=name;b.AnchorPoint=Vector2.new(.5,1);b.Position=UDim2.new(.5,x,1,-166);b.Size=UDim2.fromOffset(160,52);b.Text=text;b.TextSize=20;b.Font=Enum.Font.GothamBlack;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=color;b.TextWrapped=true;b.Visible=false;b.Parent=gui
  local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,12);corner.Parent=b;return b
 end
 local diveButton=choice("Dive",-88,"급강하 [F]",Color3.fromRGB(36,135,215))
 local explodeButton=choice("Explode",88,"폭파 귀환 [E]",Color3.fromRGB(220,73,80))
 -- Keep both flight actions on the right, above the mobile jump area.
 local function layoutActions()
  local camera=workspace.CurrentCamera;if not camera then return end
  local compact=camera.ViewportSize.Y<500
  local width,height=compact and 136 or 160,compact and 44 or 52
  local gap=compact and 8 or 12
  for index,button in {diveButton,explodeButton} do
   button.AnchorPoint=Vector2.new(1,.5)
   button.Position=UDim2.new(1,-20,compact and .55 or .62,(index-1.5)*(height+gap))
   button.Size=UDim2.fromOffset(width,height)
   button.TextSize=compact and 17 or 20
  end
 end
 local actionViewportConnection
 local function bindActionViewport()
  if actionViewportConnection then actionViewportConnection:Disconnect() end
  local camera=workspace.CurrentCamera
  if camera then actionViewportConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutActions) end
  layoutActions()
 end
 workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindActionViewport)
 bindActionViewport()

 local eventHint=Instance.new("TextLabel");eventHint.Name="GoldRingEventNotice";eventHint.AnchorPoint=Vector2.new(.5,0);eventHint.Position=UDim2.new(.5,0,0,54);eventHint.Size=UDim2.new(.8,0,0,28);eventHint.BackgroundTransparency=1;eventHint.TextColor3=Color3.fromRGB(255,220,62);eventHint.TextStrokeTransparency=.15;eventHint.Font=Enum.Font.GothamBlack;eventHint.TextSize=22;eventHint.Parent=gui
 local targetHint=Instance.new("TextLabel");targetHint.Name="TrophyTarget";targetHint.AnchorPoint=Vector2.new(.5,0);targetHint.Position=UDim2.new(.5,0,0,88);targetHint.Size=UDim2.new(.9,0,0,46);targetHint.BackgroundTransparency=1;targetHint.TextColor3=Color3.fromRGB(255,229,91);targetHint.TextStrokeTransparency=.1;targetHint.Font=Enum.Font.GothamBold;targetHint.TextSize=22;targetHint.TextWrapped=true;targetHint.Visible=false;targetHint.Parent=gui
 local function act(action)
  if active and active.diving and player.Character==active.character then remotes.ReturnToSpawn:FireServer(active.id,action) end
 end
 local function holdDive(held)
  if not active or not active.diving then return end
  active.diveHeld=held;act(held and "Dive"or "DiveStop");diveButton.Text=held and "급강하 중"or "급강하 [F]"
 end
 diveButton.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then holdDive(true)end end)
 UIS.InputEnded:Connect(function(input)if input.KeyCode==Enum.KeyCode.F or (active and active.diveHeld and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch))then holdDive(false)end end)
 UIS.WindowFocusReleased:Connect(function()holdDive(false)end)
 explodeButton.Activated:Connect(function()act("Explode")end)
 UIS.InputBegan:Connect(function(input,processed)
  if processed or UIS:GetFocusedTextBox()then return end
  if input.KeyCode==Enum.KeyCode.E then act("Explode") elseif input.KeyCode==Enum.KeyCode.F then holdDive(true)end
 end)
 local eventElapsed=0
 RunService.Heartbeat:Connect(function(dt)
  eventElapsed+=dt;if eventElapsed<1 then return end;eventElapsed=0
  local now=workspace:GetServerTimeNow();local ends=workspace:GetAttribute("GoldRingEndsAt")or 0;local nextAt=workspace:GetAttribute("GoldRingNextAt")or 0
  if ends>now then eventHint.Text=string.format("✦ 골드 링 등장! %d초 · 구간마다 대량 경험치 ✦",math.ceil(ends-now))
  elseif nextAt>now then local left=math.ceil(nextAt-now);eventHint.Text=string.format("골드 링 이벤트까지 %02d:%02d",math.floor(left/60),left%60)
  else eventHint.Text=""end
 end)
 local function clear()
  speedFX.Clear();Audio.Rush(0);Audio.Engine(0)
  fuelFrame.Visible=false;altitude.Visible=false;diveButton.Visible=false;explodeButton.Visible=false;targetHint.Visible=false
  if active then
   active.input.Stop();active.camera:Disconnect()
   if active.humanoid.Parent then active.humanoid.CameraOffset=active.previousCameraOffset end
   player.CameraMinZoomDistance=active.previousMinZoom
  end
  active=nil;objective.Stop();Sky.Reset()
  local camera=workspace.CurrentCamera;if camera then camera.FieldOfView=defaultFOV;camera.CameraType=Enum.CameraType.Custom;local c=player.Character;local h=c and c:FindFirstChildOfClass("Humanoid");if h then camera.CameraSubject=h end end
  hint.Text="";hint.Visible=false
 end
 remotes.FireCannon.OnClientEvent:Connect(function(velocity,id,character,_,settings,meta)
  if type(id)~="number"or id<=newest or character~=player.Character then return end
  clear();newest=id
  local root=character:FindFirstChild("HumanoidRootPart");local hum=character:FindFirstChildOfClass("Humanoid");if not root or not hum then return end
  local camera=workspace.CurrentCamera
  local run={id=id,character=character,humanoid=hum,previousCameraOffset=hum.CameraOffset,previousMinZoom=player.CameraMinZoomDistance,started=os.clock(),fov=camera.FieldOfView};active=run
  speedFX.Attach(root)
  run.trophyTarget=settings and settings.TrophyTarget
  run.groundY=settings and settings.GroundY or 0;run.expectedHeight=settings and settings.ExpectedHeight;run.launchLevel=settings and settings.LaunchLevel or 0
  player.CameraMinZoomDistance=math.min(24,player.CameraMaxZoomDistance)
  hum.CameraOffset=Vector3.new(0,4,0)
  local back=Vector3.new(camera.CFrame.Position.X-root.Position.X,0,camera.CFrame.Position.Z-root.Position.Z)
  back=if back.Magnitude>.01 then back.Unit else Vector3.new(0,0,1)
  local focus=root.Position+Vector3.new(0,5.5,0)
  camera.CameraSubject=hum;camera.CameraType=Enum.CameraType.Custom
  camera.CFrame=CFrame.lookAt(focus+back*25-Vector3.new(0,9,0),focus)
  run.input=Input.Start(hum,function(axis)if active==run then remotes.SteerFlight:FireServer(axis,id)end end)
  run.camera=RunService.RenderStepped:Connect(function(dt)
   if active~=run or player.Character~=character or not root.Parent then return end
   local camera=workspace.CurrentCamera;if camera then
    local blend=math.clamp((os.clock()-run.started)/.45,0,1);blend=blend*blend*(3-2*blend)
    -- Roblox's camera owns orbit/zoom for mouse, touch and gamepad throughout flight.
    local point,onScreen=camera:WorldToScreenPoint(root.Position)
    local intensity=speedFX.Update(math.abs(root.AssemblyLinearVelocity.Y),run.diving==true,dt,point)
    camera.FieldOfView=run.fov+(72-run.fov)*blend+16*intensity;Audio.Rush(intensity)
    local phase=character:GetAttribute("RocketPhase")or "Ignition";local fuel=character:GetAttribute("RocketFuel")or 1
    Audio.Engine(character:GetAttribute("RocketThrust")or 0)
    if run.diving then
     local extended=root.Position.Y>300
     explodeButton.Size=UDim2.fromOffset(extended and 160 or 116,extended and 52 or 38);explodeButton.BackgroundTransparency=extended and .2 or 1;explodeButton.TextSize=extended and 20 or 17;explodeButton.Text=extended and "폭파 귀환 [E]"or "귀환 [E]"
    end
    fuelFrame.Visible=onScreen and phase~="Diving"
    fuelLeft.Position=UDim2.fromOffset(point.X,point.Y)
    fuelLabel.Position=UDim2.fromOffset(point.X-92,point.Y)
    for _,piece in arc do local coverage=math.clamp((piece.U-(1-fuel))*count+.5,0,1);piece.Fill.BackgroundTransparency=1-coverage;piece.Glow.BackgroundTransparency=1-.25*coverage end
    fuelLabel.Text=string.format("비행\n%d%%",math.floor(fuel*100))
    altitude.Visible=onScreen
    altitude.Position=UDim2.fromOffset(math.clamp(point.X+52,8,math.max(8,gui.AbsoluteSize.X-160)),math.clamp(point.Y,66,math.max(66,gui.AbsoluteSize.Y-66)))
    currentHeight.Text=string.format("%dm",math.max(0,math.floor(root.Position.Y-run.groundY)))
    expectedTitle.Text=string.format("Lv.%d 도달 예상",run.launchLevel)
    expectedHeight.Text=run.expectedHeight and string.format("약 %dm",math.floor(run.expectedHeight))or "—"
    local target=run.trophyTarget
    while target and run.diving and target.Index>1 and root.Position.Y<target.Position.Y-12 do
     local lower=TrophyConfig.Layer(target.Index-1)
     target={Index=lower.Index,Height=lower.Height,Reward=lower.Reward,Position=target.Position+Vector3.new(-8,lower.Height-target.Height,0)};run.trophyTarget=target
    end
    targetHint.Visible=target~=nil
    if target then
     local aim=camera:WorldToViewportPoint(target.Position);local direction=target.Position-root.Position
     local horizontal=Vector3.new(direction.X,0,direction.Z).Magnitude
     -- Tutorial (deferred): local arrow=if horizontal<25 then "↓ 착지 준비"elseif aim.Z>0 and aim.X<camera.ViewportSize.X*.45 then "←"elseif aim.Z>0 and aim.X>camera.ViewportSize.X*.55 then "→"elseif aim.Z<0 then "뒤쪽으로 조종"else "앞으로 조종"
     local arrow=if horizontal<25 then "↓"elseif aim.Z>0 and aim.X<camera.ViewportSize.X*.45 then "←"elseif aim.Z>0 and aim.X>camera.ViewportSize.X*.55 then "→"elseif aim.Z<0 then "↶"else "↑"
     targetHint.Text=string.format("🏆 %dm 트로피 존 · +%d 트로피\n%s · 가로 거리 %dm · 높이 차이 %+dm",target.Height,target.Reward,arrow,math.floor(horizontal),math.floor(direction.Y))
     -- Tutorial (deferred): if run.diving and root.Position.Y<target.Position.Y-12 then targetHint.Text="착지 목표를 지나쳤어요 · 비행 경험치는 유지됩니다"end
    end
   end
  end)
  objective.Start(root,meta,function()return active==run end)
  -- Tutorial (deferred): hint.Visible=true;hint.Text=if game:GetService("UserInputService").TouchEnabled then "스틱 이동 · 화면 드래그로 위를 둘러보세요!"else "W A S D 이동 · 우클릭 드래그로 위를 둘러보세요!"
  fuelFrame.Visible=true;Audio.Play("Launch")
 end)
 remotes.FlightState.OnClientEvent:Connect(function(value,id,character,detail)
  if not active or active.id~=id or active.character~=character then return end
  if value=="Dive" then
   active.diving=true;diveButton.Text="급강하 [F]";diveButton.Visible=true;explodeButton.Visible=true
   if UIS:IsKeyDown(Enum.KeyCode.F)then holdDive(true)end
  -- Tutorial (deferred): hint.Text="트로피 존에 착지하세요 · 급강하는 길게 누르기"
   active.humanoid.CameraOffset=Vector3.new(0,0,0)
   local root=character:FindFirstChild("HumanoidRootPart");local camera=workspace.CurrentCamera
   if root and camera then local back=Vector3.new(camera.CFrame.Position.X-root.Position.X,0,camera.CFrame.Position.Z-root.Position.Z);back=if back.Magnitude>.1 then back.Unit else Vector3.new(0,0,1);camera.CFrame=CFrame.lookAt(root.Position+back*24+Vector3.new(0,16,0),root.Position-Vector3.new(0,20,0))end
  elseif value=="GoldRing"and type(detail)=="number"and detail>0 then
   if value=="GoldRing"then Audio.Play("Upgrade")end
   local label=Instance.new("TextLabel");label.AnchorPoint=Vector2.new(.5,.5);label.Position=UDim2.fromScale(.5,.55);label.Size=UDim2.fromOffset(360,40);label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBlack;label.TextSize=26;label.TextColor3=Color3.fromRGB(255,223,73);label.TextStrokeTransparency=.2;label.Text="✦ 골드 링 획득!";label.Parent=gui
   Tween:Create(label,TweenInfo.new(.7),{Position=UDim2.fromScale(.5,.45),TextTransparency=1}):Play();task.delay(.8,function()label:Destroy()end)
  elseif value=="Result"or value=="Returning"or value=="Cancelled"or value=="Idle"then
   if value=="Result"then Audio.Play(detail=="Exploded"and "Bomb"or "Result")end
   clear()
  end
 end)
 player.CharacterRemoving:Connect(clear)
end
return Controller
