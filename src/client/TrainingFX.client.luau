local p=game.Players.LocalPlayer
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local track,character,clips,arm,originalArm,gas,snack
local function stop()
	if track then track:Stop(.2);track:Destroy();track=nil end
	if arm and arm.Parent and originalArm then arm.C0=originalArm end
	arm,originalArm=nil,nil
	if gas then gas:Destroy();gas=nil end
	if snack then snack:Destroy();snack=nil end
end
local function sync()
	stop()
	if not p:GetAttribute("TrainingActive") then return end
	character=p.Character
	local hum=character and character:FindFirstChildOfClass("Humanoid")
	local animate=character and character:FindFirstChild("Animate")
	local run=animate and animate:FindFirstChild("sit")
	local clip=run and run:FindFirstChildWhichIsA("Animation")
	local animator=hum and hum:FindFirstChildOfClass("Animator")
	if clip and animator then
		local ok,result=pcall(function()return animator:LoadAnimation(clip)end)
		if ok then track=result;track.Looped=true;track.Priority=Enum.AnimationPriority.Action;track:Play(.2,1,.8) end
	end
	if character then
		local hand=character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
		if hand then
			snack=Instance.new("Part");snack.Name="EatingDumpling";snack.Shape=Enum.PartType.Ball;snack.Size=Vector3.new(.8,.6,.8);snack.Color=Color3.fromRGB(255,229,163);snack.CanCollide=false;snack.CanTouch=false;snack.CanQuery=false;snack.Massless=true
			snack.CFrame=hand.CFrame*CFrame.new(0,-.7,-.5);snack.Parent=character
			local weld=Instance.new("WeldConstraint");weld.Part0=hand;weld.Part1=snack;weld.Parent=snack
		end
		for _,v in character:GetDescendants() do if v:IsA("Motor6D") and (v.Name=="RightShoulder" or v.Name=="Right Shoulder") then arm=v;originalArm=v.C0;break end end
		local root=character:FindFirstChild("HumanoidRootPart")
		if root then
			gas=Instance.new("ParticleEmitter");gas.Name="TrainingGas";gas.Texture="rbxasset://textures/particles/smoke_main.dds"
			gas.Rate=0;gas.Color=ColorSequence.new(Color3.fromRGB(170,218,95));gas.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.5),NumberSequenceKeypoint.new(1,1)})
			gas.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,3)})
			gas.Lifetime=NumberRange.new(.5,.9);gas.Speed=NumberRange.new(2,4);gas.Parent=root
		end
	end
end
p:GetAttributeChangedSignal("TrainingActive"):Connect(sync)
p.CharacterRemoving:Connect(stop)
p.CharacterAdded:Connect(function()stop();clips=nil end)
local timer=0;local props={}
local camp=workspace:WaitForChild("CliffCamp",15)
local stations=camp and camp:FindFirstChild("TrainingStations")
if stations then
	for _,m in stations:GetChildren() do
		local food=m:FindFirstChild("DumplingSnack")
		if food then table.insert(props,{part=food,original=food.CFrame}) end
	end
end
RunService.RenderStepped:Connect(function(dt)
	timer+=dt
	if arm and arm.Parent and originalArm then arm.C0=originalArm*CFrame.Angles(math.rad(-50-35*math.sin(timer*3)),0,0) end
	for i,o in props do
		if o.part.Parent then o.part.CFrame=o.original*CFrame.new(0,math.sin(timer*2+i)*.25,0)*CFrame.Angles(0,timer*.3,0) end
	end
end)
sync()
local stats=p:WaitForChild("leaderstats",15)
local xp=stats and stats:WaitForChild("TrainingXP",15)
if xp then
	local previous=xp.Value
	xp.Changed:Connect(function(value)
		local gain=value-previous;previous=value
		local head=p.Character and p.Character:FindFirstChild("Head")
		if gain<=0 or not head or p:GetAttribute("TrainingActive")~=true then return end
        if game:GetService("ReplicatedStorage"):FindFirstChild("ExperienceGained")then if gas then gas:Emit(4)end;return end
		if gas then gas:Emit(4) end
		local popup=Instance.new("BillboardGui");popup.Name="TrainingXPPop";popup.Adornee=head;popup.Size=UDim2.fromOffset(160,56);popup.StudsOffset=Vector3.new(0,2.5,0);popup.AlwaysOnTop=true;popup.Parent=head
		local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBlack;label.TextSize=24;label.TextColor3=Color3.fromRGB(255,217,55);label.TextStrokeTransparency=0;label.Text="+"..gain.." XP";label.Parent=popup
		TweenService:Create(popup,TweenInfo.new(.9),{StudsOffset=Vector3.new(0,4,0)}):Play()
		TweenService:Create(label,TweenInfo.new(.9),{TextTransparency=1,TextStrokeTransparency=1}):Play()
		Debris:AddItem(popup,1)
	end)
end
