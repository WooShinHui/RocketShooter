-- Injected after the unmodified production modules by run-local.cjs.
local count = 0
local function check(value, label)
	assert(value, label)
	count += 1
	print("PASS", label)
end
local function event()
	local listeners = {}
	return {
		Connect = function(_, callback)
			local connection = {Connected = true}
			function connection:Disconnect() self.Connected = false end
			table.insert(listeners, {connection, callback})
			return connection
		end,
		Fire = function(_, ...)
			for _, pair in table.clone(listeners) do if pair[1].Connected then pair[2](...) end end
		end,
		Count = function()
			local n=0; for _,pair in ipairs(listeners) do if pair[1].Connected then n+=1 end end; return n
		end,
	}
end

local function environment()
	local env = {warnings = {}, audio = {}, regions = {}, time = 10, queued = {}, writes = 0, reads = 0, opens = 0, studio = false}
	local vec = {}
	local vector = {__type = "Vector3"}
	function vec.new(x, y, z) return setmetatable({X=x or 0, Y=y or 0, Z=z or 0}, vector) end
	vector.__add = function(a,b) return vec.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
	vector.__sub = function(a,b) return vec.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
	vector.__mul = function(a,b) return vec.new(a.X*b,a.Y*b,a.Z*b) end
	vector.__div = function(a,b) return vec.new(a.X/b,a.Y/b,a.Z/b) end
	vector.__index = function(a,key)
		if key == "Cross" then return function(self,b) return vec.new(self.Y*b.Z-self.Z*b.Y,self.Z*b.X-self.X*b.Z,self.X*b.Y-self.Y*b.X) end end
		if key == "Dot" then return function(self,b) return self.X*b.X+self.Y*b.Y+self.Z*b.Z end end
		if key == "Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end
		if key == "Unit" then return a/a.Magnitude end
	end
	vec.zero = vec.new()
	env.Vector3 = vec
	local cf = {}
	local cfMeta = {}
	function cf.new(x,y,z)
		return setmetatable({Position=type(x)=="table" and x or vec.new(x,y,z), LookVector=vec.new(0,0,-1),RightVector=vec.new(1,0,0),UpVector=vec.new(0,1,0)},cfMeta)
	end
	local function rotate(a,v) return a.RightVector*v.X+a.UpVector*v.Y-a.LookVector*v.Z end
	cfMeta.__mul = function(a,b)
		local r=cf.new(a.Position+rotate(a,b.Position))
		r.RightVector,r.UpVector,r.LookVector=rotate(a,b.RightVector),rotate(a,b.UpVector),rotate(a,b.LookVector)
		return r
	end
	cfMeta.__add = function(a,b) local r=a*cf.new(); r.Position=a.Position+b; return r end
	cf.Angles = function(x,y,z)
		local a,b,c=cf.new(),cf.new(),cf.new()
		a.UpVector,a.LookVector=vec.new(0,math.cos(x),math.sin(x)),vec.new(0,math.sin(x),-math.cos(x))
		b.RightVector,b.LookVector=vec.new(math.cos(y),0,-math.sin(y)),vec.new(-math.sin(y),0,-math.cos(y))
		c.RightVector,c.UpVector=vec.new(math.cos(z),math.sin(z),0),vec.new(-math.sin(z),math.cos(z),0)
		return a*b*c
	end
	cf.lookAt = function(position,target)
		local r=cf.new(position); r.LookVector=(target-position).Unit
		r.RightVector=r.LookVector:Cross(vec.new(0,1,0)).Unit; r.UpVector=r.RightVector:Cross(r.LookVector)
		return r
	end
	local function inverseVector(a,v) return vec.new(v:Dot(a.RightVector),v:Dot(a.UpVector),-v:Dot(a.LookVector)) end
	cfMeta.__index = {PointToObjectSpace=function(a,p) return inverseVector(a,p-a.Position) end,
		ToObjectSpace=function(a,b)
			local r=cf.new(inverseVector(a,b.Position-a.Position))
			r.RightVector,r.UpVector,r.LookVector=inverseVector(a,b.RightVector),inverseVector(a,b.UpVector),inverseVector(a,b.LookVector)
			return r
		end}
	env.CFrame=cf
	env.Enum={HumanoidStateType={GettingUp="GettingUp",Physics="Physics"}, Material={Air="Air",Grass="Grass"}, RaycastFilterType={Exclude="Exclude"},
		MouseBehavior={Default="Default",LockCenter="LockCenter"},CameraType={Custom="Custom",Scriptable="Scriptable"},
		UserInputType={MouseButton1="MouseButton1"},OrientationAlignmentMode={OneAttachment="OneAttachment"}}
	env.Enum.KeyCode={A="A",D="D",Left="Left",Right="Right"}
	env.Enum.Material.SmoothPlastic = "SmoothPlastic"
	env.Enum.SurfaceType = {Smooth = "Smooth"}
 env.Enum.ModelStreamingMode={Persistent="Persistent"}
	env.collection = {
		AddTag = function(_, instance, tag) instance._tags = instance._tags or {}; instance._tags[tag] = true end,
		HasTag = function(_, instance, tag) return instance._tags ~= nil and instance._tags[tag] == true end,
	}
	env.Enum.UserInputState={Begin="Begin",End="End",Cancel="Cancel"}
	env.Enum.ContextActionResult={Sink="Sink",Pass="Pass"}
	env.Enum.ContextActionPriority={High={Value=3000}}
	env.Color3={fromRGB=function(...) return {...} end}
	env.ColorSequence={new=function(...) return {...} end}
	env.NumberSequence=env.ColorSequence; env.UDim2={new=env.ColorSequence.new,fromScale=env.ColorSequence.new}
	env.RaycastParams={new=function() return {} end}
	env.typeof=function(v) return type(v)=="table" and getmetatable(v)==vector and "Vector3" or type(v) end
	local methods = {}
	local meta = {}
	meta.__index=function(obj,key)
		if methods[key] then return methods[key] end
		if obj._props[key] ~= nil then return obj._props[key] end
		return methods.FindFirstChild(obj,key)
	end
	meta.__newindex=function(obj,key,value)
		if key == "Parent" then
			local old=obj._props.Parent
			if old then for i,v in ipairs(old._children) do if v==obj then table.remove(old._children,i); break end end end
			if value then table.insert(value._children,obj) end
		elseif key=="CFrame" then obj._props.Position=value.Position end
		obj._props[key]=value
	end
	local function instance(class)
		local obj=setmetatable({_props={ClassName=class,Name=class},_children={},_attrs={}},meta)
		if class=="Part" then
			obj.Touched=event(); obj.Size=vec.new(2,2,2); obj.CFrame=cf.new(); obj.Transparency=0; obj.CanCollide=true
			obj.Anchored=false; obj.AssemblyLinearVelocity=vec.zero; obj.AssemblyAngularVelocity=vec.zero; obj.AssemblyMass=1
		elseif class=="Humanoid" then
			obj.Health=100; obj.WalkSpeed=23; obj.JumpPower=61; obj.JumpHeight=9
			obj.UseJumpPower=true; obj.AutoRotate=true; obj.PlatformStand=false; obj.HipHeight=2
			obj.FloorMaterial="Air"; obj.Died=event()
		elseif class=="Player" then obj.CharacterRemoving=event(); obj.CharacterAdded=event()
		elseif class=="ProximityPrompt" then obj.Enabled=true; obj.MaxActivationDistance=15; obj.Triggered=event()
		elseif class=="RemoteEvent" then obj.OnServerEvent=event(); obj.OnClientEvent=event(); obj.sent={}; obj.requests={}
		elseif class=="IntValue" then obj.Value=0 end
		return obj
	end
	function methods:IsA(class) return self.ClassName==class or (class=="BasePart" and self.ClassName=="Part") end
	function methods:GetChildren() return table.clone(self._children) end
	function methods:GetDescendants()
		local all={}
		for _,child in ipairs(self._children) do table.insert(all,child); for _,v in ipairs(child:GetDescendants()) do table.insert(all,v) end end
		return all
	end
	function methods:FindFirstChild(name) for _,child in ipairs(self._children) do if child.Name==name then return child end end end
	function methods:WaitForChild(name, timeout)
		if name == "SkyIslandConfig" then return {__module=newSkyIslandConfig(env)} end
		if name == "CloudConfig" then return {__module=CloudConfig,IsA=function(_,class) return class=="ModuleScript" end} end
		if name == "BalanceConfig" then
			if env.balanceMissing then return nil end
			return {__module=Balance, IsA=function(_, class) return not env.balanceWrongType and class=="ModuleScript" end}
		end
		local child=self:FindFirstChild(name)
		if child then return child end
		assert(timeout and timeout > 0,"unbounded WaitForChild: "..name)
		env.time+=timeout
		return nil
	end
	function methods:FindFirstChildOfClass(class) for _,child in ipairs(self._children) do if child:IsA(class) then return child end end end
	function methods:FindFirstAncestorOfClass(class) local p=self.Parent; while p do if p:IsA(class) then return p end; p=p.Parent end end
	function methods:IsDescendantOf(parent) local p=self.Parent; while p do if p==parent then return true end; p=p.Parent end; return false end
	function methods:SetAttribute(key,value) self._attrs[key]=value end
	function methods:GetAttribute(key) return self._attrs[key] end
	function methods:GetPivot() return self.CFrame or cf.new() end
	function methods:GetFullName() return self.Name end
	function methods:PivotTo(value) self.CFrame=value end
	function methods:CanSetNetworkOwnership() return not self.Anchored,"anchored" end
	function methods:SetNetworkOwner(player) assert(not self.Anchored); self.owner=player; self.explicitOwner=true end
	function methods:SetNetworkOwnershipAuto() self.owner=nil end
	function methods:ApplyImpulse(impulse)
		self.AssemblyLinearVelocity += impulse / (self.AssemblyMass or 1)
		self.lastImpulse = impulse
	end
	function methods:ChangeState(value) self.lastState=value end
	function methods:FireClient(player,...) table.insert(self.sent,{player,...}) end
	function methods:FireServer(...) table.insert(self.requests,{...}) end
	function methods:Destroy() self.Parent=nil; self.destroyed=true end
	function methods:Kick(message) self.kicked=message end
	function methods:LoadCharacterAsync()
		self.loadCount=(self.loadCount or 0)+1
		if env.onReturn then env.onReturn(self) end
		self.CharacterRemoving:Fire(self.Character)
		self.Character.Parent=nil
		self.Character=env.character()
		self.CharacterAdded:Fire(self.Character)
	end
	env.Instance={new=instance}
	env.workspace=instance("Workspace"); env.workspace.Gravity=196.2; env.workspace.FallenPartsDestroyHeight=-500
	env.workspace.CurrentCamera=instance("Camera")
	function env.workspace:Raycast() return nil end
	env.players=instance("Players"); env.players.PlayerAdded=event(); env.players.PlayerRemoving=event()
	function env.players:GetPlayers() return self:GetChildren() end
	function env.players:GetPlayerFromCharacter(char) for _,p in ipairs(self:GetChildren()) do if p.Character==char then return p end end end
	env.rs=instance("ReplicatedStorage")
	for _,name in ipairs({"AimCannon","FireCannon","FlightResult","ReturnToSpawn","FlightState","SteerFlight"}) do local r=instance("RemoteEvent"); r.Name=name; r.Parent=env.rs end
	env.heartbeat=event()
	env.render=event()
	env.input={InputBegan=event(),GetMouseDelta=function() return {X=0,Y=0} end}
	env.keys={}
	env.input.GetFocusedTextBox=function() return env.focusedTextBox end
	env.input.IsKeyDown=function(_,key) return env.keys[key] end
	env.input.WindowFocusReleased=event(); env.input.WindowFocused=event(); env.input.TextBoxFocused=event()
	env.actions={bindings={}}
	function env.actions:BindActionAtPriority(name,callback,touch,priority,...)
		self.bindings[name]={callback=callback,touch=touch,priority=priority,keys={...}}
	end
	function env.actions:UnbindAction(name) self.bindings[name]=nil end
	function env.key(key,inputState)
		for name,binding in pairs(env.actions.bindings) do binding.callback(name,inputState,{KeyCode=key}) end
	end
	local store={}
	function store:GetAsync(key)
		env.reads+=1
		if env.onGet then env.onGet() end
		if env.loadFail then error("offline") end
		return env.saved and table.clone(env.saved)
	end
	function store:UpdateAsync(key,callback)
		assert(string.sub(key,1,7)=="Player_")
		env.writes+=1
		if env.saveFail then error("offline") end
		local result=callback(env.saved)
		if result then env.saved=table.clone(result) end
		return result
	end
	env.storage=instance("ServerStorage")
	env.TweenInfo={new=function(...)return {...}end};env.Enum.EasingStyle={Quad="Quad"};env.Enum.EasingDirection={Out="Out"}
	env.Enum.PartType={Cylinder="Cylinder",Ball="Ball"}
	env.Enum.MeshType={Sphere="Sphere"}
	env.Enum.NormalId={Back="Back"}; env.Enum.Font={GothamBold="GothamBold"}
	env.Enum.AssetFetchStatus={Success="Success",Failure="Failure"}
	env.workspace.DescendantAdded=event()
	env.lighting=instance("Lighting"); env.soundService=instance("SoundService"); env.debris={}
	function methods:Play() self.played=true end
	local services={CollectionService=env.collection,ContentProvider={PreloadAsync=function(_,assets,callback)
		env.preloadCount=(env.preloadCount or 0)+1
		for _,asset in ipairs(assets) do
			assert(type(asset)=="table" and asset:IsA("Sound"),"audio preload must use Sound instances")
			asset.IsLoaded=not env.audioLoadFail
			callback(asset.SoundId,env.audioLoadFail and "Failure" or "Success")
		end
	end},TweenService={Create=function(_,object,info,properties) local done=event();return {Completed=done,Play=function()for key,value in properties do object[key]=value end;done:Fire()end,Cancel=function()done:Fire()end} end},Lighting=env.lighting,SoundService=env.soundService,Debris={AddItem=function(_,v,seconds) table.insert(env.debris,{v,seconds}) end},ServerStorage=env.storage,Players=env.players,ReplicatedStorage=env.rs,UserInputService=env.input,ContextActionService=env.actions,
		RunService={Heartbeat=env.heartbeat,RenderStepped=env.render,IsStudio=function() return env.studio end},
		DataStoreService={GetDataStore=function(_,name)
			env.opens+=1
			if env.openFail then error("You must publish this place to the web to access DataStore.") end
			assert(name=="CannonGame_v3"); return store
		end}}
	env.game={GameId=123,PlaceId=456,GetService=function(_,name) return services[name] end,BindToClose=function(_,callback) env.close=callback end}
	env.task={wait=function(seconds) env.time+=seconds or 0.01 end,spawn=function(fn,...) table.insert(env.queued,{fn,...}) end,
		delay=function(seconds,fn) table.insert(env.queued,{fn}) end}
	env.os={clock=function() return env.time end}
	function env.character()
		local char=instance("Model"); char.Parent=env.workspace
		local root=instance("Part"); root.Name="HumanoidRootPart"; root.Transparency=1; root.CanCollide=false; root.Parent=char
		local body=instance("Part"); body.Name="Body"; body.Transparency=0.4; body.Parent=char
		local humanoid=instance("Humanoid"); humanoid.Parent=char
		char.DescendantAdded=event()
		return char
	end
	function env.player(id)
		local p=instance("Player"); p.UserId=id; p.Character=env.character(); p.Parent=env.players
		local gui=instance("PlayerGui"); gui.Parent=p
		return p
	end
	function env.step(seconds)
		env.time+=seconds; env.heartbeat:Fire(seconds)
	end
	return env
end

check(Policy.validAim(-30,45) and not Policy.validAim(31,0) and not Policy.validAim("0",0),"aim limits and types")
check(not Policy.validAim(0/0,0) and not Policy.validAim(math.huge,0),"non-finite aim rejected")
check(Policy.validMultiplier(1) and not Policy.validMultiplier(0.7) and not Policy.validMultiplier(1.5),"only baseline launch accepted; obsolete timing multipliers rejected")
check(not Policy.validMultiplier(2) and not Policy.validMultiplier(0/0) and not Policy.validMultiplier("1"),"invalid multiplier rejected")
local d,g,t=Policy.reward(601.9,1)
check(d==601 and g==92 and t==7,"balanced Gold with unchanged distance and Trophies")

do
	local env=environment(); local data=newPlayerData(env); data.Start()
	local p=env.player(1); env.loadFail=true; env.players.PlayerAdded:Fire(p)
	check(not data.IsReady(p) and p.kicked~=nil,"failed load never becomes ready")
	env.players.PlayerRemoving:Fire(p)
	check(env.writes==0,"failed load cannot overwrite a save on leave")
end
do
	local env=environment(); env.saved={Gold="bad"}; local data=newPlayerData(env); data.Start()
	local p=env.player(2); env.players.PlayerAdded:Fire(p); data.Save(p)
	check(env.writes==0 and p.kicked~=nil,"malformed save rejected without writes")
end
do
	local env=environment(); local data=newPlayerData(env); data.Start()
	local p=env.player(3); env.onGet=function() p.Parent=nil; env.players.PlayerRemoving:Fire(p) end
	env.players.PlayerAdded:Fire(p)
	check(env.writes==0 and p:FindFirstChild("leaderstats")==nil,"leave during load cannot publish or save defaults")
end
do
	local env=environment(); env.saved={Gold=1000,Trophies=8,PowerLvl=2,BoostLvl=3,MaxDistance=20,LegacyExtra="keep"}
	local data=newPlayerData(env); data.Start(); local p=env.player(4); env.players.PlayerAdded:Fire(p)
	check(data.IsReady(p) and data.GetLevel(p,"PowerLvl")==2,"legacy fields load unchanged")
	check(data.Buy(p,"Gold") and p.leaderstats.Gold.Value==1000-Balance.PowerCost(2) and p.leaderstats.PowerLvl.Value==3,"server uses shared upgrade price")
	check(not data.Buy(p,"Gold"),"purchase rate limited")
	check(data.Award(p,400,600,1)==true and data.Award(p,300,0,0)==false,"reward and record update")
	check(data.Save(p) and env.saved.LegacyExtra=="keep" and env.saved.Gold==1600-Balance.PowerCost(2),"save preserves unknown fields")
	env.saved.Gold=9999
	check(not data.Save(p) and env.saved.Gold==9999 and not data.IsReady(p),"conflicting session cannot be overwritten")
end
do
	local env=environment(); local data=newPlayerData(env); data.Start(); local p=env.player(5); env.players.PlayerAdded:Fire(p)
	check(data.IsReady(p) and p.leaderstats.PowerLvl.Value==1,"successful absent key gets defaults")
	env.saveFail=true
	check(not data.Save(p) and env.writes==3,"save failure retries and reports failure")
end

local function flightEnvironment(withWorld)
	local env=environment()
	local data={IsReady=function() return true end,GetLevel=function() return 1 end}
	env.awards={}
	function data.Award(p,d,g,t,h) table.insert(env.awards,{p,d,g,t,h}); return true,true end
	local model=env.Instance.new("Model"); model.Name="Canon"; model.Parent=env.workspace
	local cylinder=env.Instance.new("Part"); cylinder.Name="Cylinder"; cylinder.Parent=model
	local launch=env.Instance.new("Part"); launch.Name="LaunchPoint"; launch.Parent=model
	local prompt=env.Instance.new("ProximityPrompt"); prompt.Parent=launch
	env.model,env.launch,env.prompt=model,launch,prompt
	if withWorld then
		env.world=newWorldService(env,{Destination=newDestination(env),LaunchTrajectory=newLaunchTrajectory(env),LevelConfig=LevelConfig,WorldCoordinates=newWorldCoordinates(env),LevelBuilder=newLevelBuilder(env),LegacyGimmicks=newLegacyGimmicks(env)})
	end
	local flight=newFlightService(env,data)
	-- workspace is a global in Roblox; injected explicitly into the module wrapper.
	flight.Start(model)
	env.flight=flight
	local createPlayer=env.player
	function env.player(id)
		local player=createPlayer(id)
		env.players.PlayerAdded:Fire(player)
		return player
	end
	function env.enter(p)
		p.Character.HumanoidRootPart.Position=launch.Position
		prompt.Triggered:Fire(p)
		local messages=env.rs.AimCannon.sent
		return messages[#messages][4]
	end
	function env.fire(p,id,mult) env.rs.FireCannon.OnServerEvent:Fire(p,mult or 1,id) end
	return env
end
do
	local env=flightEnvironment(); local a,b=env.player(10),env.player(11)
	local id=env.enter(a)
	env.rs.FireCannon.OnServerEvent:Fire(b,1,id)
	check(#env.rs.FireCannon.sent==0,"non-occupant cannot fire")
	env.fire(a,id,2)
	check(#env.rs.FireCannon.sent==0,"server rejects 2x request")
	env.fire(a,id)
	check(a.Character.HumanoidRootPart.owner==nil and a.Character.HumanoidRootPart.explicitOwner and not a.Character.HumanoidRootPart.Anchored,"server owns flight physics after unanchor")
	local bid=env.enter(b)
	check(b:GetAttribute("FlightState")=="Aiming" and a:GetAttribute("FlightState")=="Flying","B can aim while A flies")
	env.fire(a,id)
	check(#env.rs.FireCannon.sent==1,"duplicate launch ignored")
	a.Character.Humanoid.FloorMaterial="Grass"
	env.step(1.1); env.step(0.2); env.step(0.2)
	check(#env.awards==1 and #env.rs.FlightResult.sent==1,"one reward and result despite repeated grounded samples")
	check(a.Character.Body.Transparency==0.4 and not a.Character.HumanoidRootPart.CanCollide
		and a.Character.Humanoid.WalkSpeed==23 and a.Character.Humanoid.JumpPower==61,"original appearance collision and movement restored")
	check(b:GetAttribute("FlightState")=="Aiming" and not env.prompt.Enabled,"A cleanup does not release B occupancy")
	env.onReturn=function(p) env.rs.ReturnToSpawn.OnServerEvent:Fire(p,id) end
	env.rs.ReturnToSpawn.OnServerEvent:Fire(a,id)
	check(a.loadCount==1,"duplicate return rejected while respawning")
	local aid2=env.enter(a) -- B still owns cannon, A cannot enter.
	check(a:GetAttribute("FlightState")=="Idle","return does not steal another occupant")
	b.Character.Humanoid.Health=0; b.Character.Humanoid.Died:Fire()
	check(env.prompt.Enabled,"death releases aiming occupant")
	local nextId=env.enter(a); env.fire(a,id)
	check(a:GetAttribute("FlightState")=="Aiming","old run fire cannot launch new run")
	env.fire(a,nextId)
	a.Character.Humanoid.Health=0; a.Character.Humanoid.Died:Fire(); env.step(2)
	check(#env.awards==1,"dead flight cannot receive late reward")
end
do
	local env=flightEnvironment(); local p=env.player(20); local id=env.enter(p); env.fire(p,id)
	env.step(7)
	check(p:GetAttribute("FlightState")=="Flying" and #env.awards==0,"airborne low speed/time alone does not finish run")
	local ring=env.Instance.new("Part"); ring.CFrame=env.CFrame.new(p.Character.HumanoidRootPart.Position); ring.Size=env.Vector3.new(30,30,30)
	local v=p.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude
	env.flight.ApplyGimmick(ring,p.Character.Body,"Ring")
	check(p.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude>v,"active flight receives existing ring boost")
	local boosted=p.Character.HumanoidRootPart.AssemblyLinearVelocity
	env.flight.ApplyGimmick(ring,p.Character.Body,"Ring")
	check(p.Character.HumanoidRootPart.AssemblyLinearVelocity==boosted,"same-run ring debounce")
	env.rs.ReturnToSpawn.OnServerEvent:Fire(p,id); env.step(2)
	check(#env.awards==0,"return during flight cancels without reward")
	env.flight.ApplyGimmick(ring,p.Character.Body,"Ring")
	check(p.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude==0,"idle character ignores gimmicks")
end
do
	local env=environment(); local player=env.player(30); env.players.LocalPlayer=player
	local function child(parent,class,name) local c=env.Instance.new(class); c.Name=name; c.Parent=parent; return c end
	local gauge=env.Instance.new("ScreenGui")
	local results=env.Instance.new("ScreenGui")
	local frame=child(results,"Frame","MainFrame"); child(frame,"TextLabel","InfoLabel"); child(frame,"TextLabel","RecordBadge")
	local button=child(frame,"TextButton","ReturnButton"); button.Activated=event()
	local model=env.Instance.new("Model"); child(model,"Part","Cylinder")
	newFlightClient(env).Start(gauge,results,env.rs)
	local char=player.Character
	env.rs.AimCannon.OnClientEvent:Fire(true,model,1,char)
	env.rs.AimCannon.OnClientEvent:Fire(true,model,1,char)
	check(env.render:Count()==1 and env.input.InputBegan:Count()==1,"client duplicate aim does not leak connections")
	env.input.InputBegan:Fire({UserInputType="MouseButton1"},false)
	env.rs.FlightState.OnClientEvent:Fire("Cancelled",1,char)
	env.rs.AimCannon.OnClientEvent:Fire(true,model,2,char)
	for _,job in ipairs(env.queued) do job[1]() end
	check(#env.rs.FireCannon.requests==1 and env.rs.FireCannon.requests[1][1]==1 and gauge.Enabled,"click launches immediately at baseline; cancellation cannot hide newer aim UI")
	env.rs.FlightState.OnClientEvent:Fire("Cancelled",1,char)
	check(env.render:Count()==1,"old cancellation cannot clean new aiming run")
	local saved={walkSpeed=23,useJumpPower=true,jumpPower=61,jumpHeight=9,autoRotate=true,platformStand=false}
	env.rs.FireCannon.OnClientEvent:Fire(env.Vector3.new(0,10,-250),2,char,saved,SteeringConfig.Client)
	env.rs.AimCannon.OnClientEvent:Fire(false,model,2,char)
	env.rs.FlightState.OnClientEvent:Fire("Region",1,char,{Region="Clouds",FirstEntry=true})
	check(#env.regions==0,"stale run cannot change environment")
	env.rs.FlightState.OnClientEvent:Fire("Region",2,char,{Region="Clouds",FirstEntry=true})
	env.rs.FlightState.OnClientEvent:Fire("Region",2,char,{Region="Clouds",FirstEntry=true})
	check(#env.regions==1,"discovery duplicate suppressed by current run")
	check(env.workspace.CurrentCamera.CameraType=="Scriptable", "aim-off following launch cannot undo flight camera")
	env.time+=7
	check(char.Humanoid.PlatformStand and env.render:Count()==1,"client physics persists past six seconds until server end")
	check(char.HumanoidRootPart.FlyOrientation.Mode=="OneAttachment","flight orientation uses one attachment")
	env.rs.FlightResult.OnClientEvent:Fire(10,15,0,false,1,char)
	check(not results.Enabled,"client rejects old result")
	env.rs.FlightResult.OnClientEvent:Fire(300,450,1,true,2,char,
		{ForwardDistance=250,MaxAltitude=80,FlightTime=2.5,AltitudeRecord=true,landingType="SkyIsland"})
	check(frame.InfoLabel.Text:find("구름 전초기지 도착!", 1, true) ~= nil, "현재 비행의 SkyIsland 결과 메시지 표시")
	check(frame.InfoLabel.Text:find("최고 높이  80",1,true) and frame.InfoLabel.Text:find("골드  +450",1,true),"compact result displays authoritative altitude and rewards")
	local firstText=frame.InfoLabel.Text
	env.rs.FlightResult.OnClientEvent:Fire(999,999,9,true,2,char,{ForwardDistance=999,MaxAltitude=999,FlightTime=99})
	check(frame.InfoLabel.Text==firstText,"duplicate result cannot overwrite displayed metrics")
	check(not results.Enabled and not char.Humanoid.PlatformStand and char.Humanoid.WalkSpeed==23
		and char.HumanoidRootPart:FindFirstChild("FlyTrail")==nil,"server result restores client physics and removes effects")
	check(next(env.actions.bindings)==nil and env.heartbeat:Count()==0,"result transition removes flight steering adapter")
	check(env.render:Count()==0 and env.workspace.CurrentCamera.CameraType=="Custom", "result disconnects flight camera and restores default camera")
	button.Activated:Fire()
	check(not results.Enabled and #env.rs.ReturnToSpawn.requests==1,"legacy return handler cannot open a result modal")
	button.Activated:Fire()
	check(#env.rs.ReturnToSpawn.requests==1,"client return click rate limited")
	env.rs.FlightState.OnClientEvent:Fire("Returning",2,char)
	check(not results.Enabled,"return acknowledgement hides result")
	player.CharacterRemoving:Fire(char)
	player.Character=env.character(); player.CharacterAdded:Fire(player.Character)
	env.rs.FireCannon.OnClientEvent:Fire(env.Vector3.new(0,10,-250),2,char,saved)
	check(not player.Character.Humanoid.PlatformStand and env.render:Count()==0,"late launch cannot modify respawned character")
end
do
	local env=environment(); local model=env.Instance.new("Model"); model.Name="Canon"; model.Parent=env.workspace
	local old=env.Instance.new("Script"); old.Name="Script"; old.Enabled=true; old.Parent=model
	local starts=0; local service={Start=function() starts+=1 end}
	runGate(env,service)
	check(starts==0 and #env.warnings==1,"migration gate blocks active Studio server")
	old.Enabled=false; runGate(env,service)
	check(starts==1,"migration gate allows disabled Studio original")
end
do
	local env=flightEnvironment(); local p=env.player(40); local id=env.enter(p); env.fire(p,id)
	p.CharacterRemoving:Fire(p.Character); p.Character.Parent=nil; p.Character=env.character()
	local second=env.enter(p); env.fire(p,second); env.step(0.6)
	check(#env.awards==0 and p:GetAttribute("FlightState")=="Flying","character replacement cancels old run without affecting next run")
	env.rs.ReturnToSpawn.OnServerEvent:Fire(p,id)
	check(not p.loadCount and p:GetAttribute("FlightState")=="Flying","stale return request cannot respawn new run")
	p.Character.HumanoidRootPart.Position=env.Vector3.new(10000000,0,0); env.step(0.1)
	check(p:GetAttribute("FlightState")=="Idle" and #env.awards==0,"impossible displacement cancels without reward")
end
do
	local env=flightEnvironment(); local p=env.player(41); local id=env.enter(p); env.fire(p,id); env.step(121)
	check(p:GetAttribute("FlightState")=="Idle" and #env.awards==0,"flight timeout cancels without manufactured result")
end
do
	local env=environment(); env.studio=true; env.game.GameId=0; env.game.PlaceId=0
	env.openFail=true; env.loadFail=true; env.saveFail=true
	local ok,data=pcall(newPlayerData,env)
	check(ok and env.opens==0,"unpublished require does not open DataStore or throw")
	data.Start(); local p=env.player(50); env.players.PlayerAdded:Fire(p)
	check(data.IsReady(p) and not p.kicked and p:GetAttribute("DataMode")=="StudioMemory"
		and p.leaderstats.Gold.Value==0 and p.leaderstats.PowerLvl.Value==1,"unpublished Studio gets ready memory defaults")
	check(data.Award(p,300,450,1)==true and data.Buy(p,"Gold"),"memory session supports flight rewards and upgrades")
	data.Save(p); env.players.PlayerRemoving:Fire(p); p.Parent=nil
	local again=env.player(50); env.players.PlayerAdded:Fire(again)
	check(again.leaderstats.Gold.Value==0 and again.leaderstats.PowerLvl.Value==1,"memory progress is discarded on rejoin")
	env.close()
	check(env.opens==0 and env.reads==0 and env.writes==0 and #env.queued==0,"memory mode never opens reads writes or schedules persistence")
end
do
	local env=environment(); env.studio=true; env.game.GameId=0; env.game.PlaceId=95206881; env.openFail=true
	local data=newPlayerData(env); data.Start(); local p=env.player(51); env.players.PlayerAdded:Fire(p)
	check(data.IsReady(p) and env.opens==0,"unpublished Studio template with nonzero PlaceId uses memory")
end
for _,studio in ipairs({false,true}) do
	local env=environment(); env.studio=studio; env.openFail=true
	local ok,data=pcall(newPlayerData,env)
	check(ok and env.opens==0,"published module require survives unavailable DataStore (Studio="..tostring(studio)..")")
	data.Start(); local p=env.player(52); env.players.PlayerAdded:Fire(p); data.Save(p)
	check(not data.IsReady(p) and p.kicked~=nil and p:GetAttribute("DataMode")=="Persistent"
		and env.opens==3 and env.writes==0,"published open failure never falls back or writes defaults (Studio="..tostring(studio)..")")
end
do
	local env=environment(); env.game.GameId=0; env.game.PlaceId=0; env.openFail=true
	local data=newPlayerData(env); data.Start(); local p=env.player(53); env.players.PlayerAdded:Fire(p)
	check(not data.IsReady(p) and p:GetAttribute("DataMode")=="Persistent","zero IDs outside Studio cannot enable memory fallback")
end
do
	local env=environment(); env.rs.FlightState:Destroy(); env.rs.SteerFlight:Destroy()
	local original={env.rs.AimCannon,env.rs.FireCannon,env.rs.FlightResult,env.rs.ReturnToSpawn}
	local registry=newRemotes(env); local first=registry.Ensure(); local second=registry.Ensure()
	check(#env.rs:GetChildren()==13 and first.SelectRocketTrail:IsA("RemoteFunction") and first.SelectRocketSkin:IsA("RemoteFunction") and first.BuyUpgrade:IsA("RemoteFunction") and first.FlightState:IsA("RemoteEvent") and first.SteerFlight:IsA("RemoteEvent") and first.ExperienceGained:IsA("RemoteEvent"),"server creates all missing remotes including steering and XP notifications")
	check(first.AimCannon==original[1] and first.FireCannon==original[2] and first.FlightResult==original[3]
		and first.ReturnToSpawn==original[4] and first.BuyUpgrade==second.BuyUpgrade,"repeated bootstrap preserves original remotes without duplication")
	check(first.ResetData.OnServerInvoke()==false,"legacy reset remains inert")
	check(newRemoteClient(env).Wait(15).BuyUpgrade==first.BuyUpgrade,"client resolves complete typed remote inventory")
	first.SteerFlight:Destroy(); local waitStart=env.time
	check(newRemoteClient(env).Wait(15)==nil and env.time-waitStart==15,"missing steering remote has bounded client startup wait")
	registry.Ensure()
	first.BuyUpgrade:Destroy(); local before=env.time
	check(newRemoteClient(env).Wait(15)==nil and env.time-before==15,"missing BuyUpgrade returns after bounded total wait")
	local wrong=env.Instance.new("Folder"); wrong.Name="BuyUpgrade"; wrong.Parent=env.rs
	check(newRemoteClient(env).Wait(15)==nil,"client rejects incorrect remote class")
	check(not pcall(registry.Ensure) and env.rs.BuyUpgrade==wrong,"server rejects incorrect class without replacement")
	wrong:Destroy(); registry.Ensure()
	local duplicate=env.Instance.new("RemoteEvent"); duplicate.Name="AimCannon"; duplicate.Parent=env.rs
	check(not pcall(registry.Ensure),"server detects existing duplicate names")
end
do
	local env=environment(); env.studio=true; env.game.GameId=0; env.openFail=true
	env.rs.FlightState:Destroy()
	local data=newPlayerData(env)
	local flight=newFlightService(env,data)
	-- Reuse a saved layout to exercise real DataManager bootstrap without generating a map.
	local folder=env.Instance.new("Folder"); folder.Name="Gimmicks"; folder.Parent=env.workspace
	local target=env.Instance.new("Part"); target.Name="TargetZone_1"; target.Parent=folder
	local ok=pcall(runManager,env,data,flight)
	local model=env.Instance.new("Model"); model.Name="Canon"; model.Parent=env.workspace
	local cylinder=env.Instance.new("Part"); cylinder.Name="Cylinder"; cylinder.Parent=model
	local launch=env.Instance.new("Part"); launch.Name="LaunchPoint"; launch.Parent=model
	local prompt=env.Instance.new("ProximityPrompt"); prompt.Parent=launch
	local gateOk=pcall(runGate,env,flight)
	check(ok and gateOk and env.rs.BuyUpgrade and env.rs.FlightState,"unpublished DataManager FlightService and Cannon initialize together")
	local p=env.player(54); env.players.PlayerAdded:Fire(p); prompt.Triggered:Fire(p)
	check(p:GetAttribute("FlightState")=="Aiming" and env.opens==0,"unpublished player can enter cannon without DataStore access")
	local id=env.rs.AimCannon.sent[#env.rs.AimCannon.sent][4]
	env.rs.FireCannon.OnServerEvent:Fire(p,1,id)
	p.Character.Humanoid.FloorMaterial="Grass"; env.step(1.1); env.step(0.2)
	check(p:GetAttribute("FlightState")=="Result" and #env.rs.FlightResult.sent==1
		and p.leaderstats.Gold.Value>0,"unpublished integrated flight finalizes memory reward")
	env.rs.ReturnToSpawn.OnServerEvent:Fire(p,id)
	check(p:GetAttribute("FlightState")=="Idle" and p.loadCount==1 and env.opens==0
		and env.reads==0 and env.writes==0,"unpublished integrated return completes with zero DataStore API calls")
	end
local function near(a,b) return math.abs(a-b)<0.00001 end
do
	local env=environment(); local steer=newHorizontalSteering(env); local v=env.Vector3.new(0,50,-250)
	local control=steer.Create(v)
	local unchanged,budget=steer.Step(control,v,0.05,0)
	check(unchanged==v and budget==0,"no steering input preserves PHASE 0 trajectory exactly")
	check(not steer.Accept(control,0/0,0) and not steer.Accept(control,math.huge,0)
		and not steer.Accept(control,"1",0) and not steer.Accept(control,1.01,0),"steering rejects non-finite wrong-type and out-of-range axes")
	check(steer.Accept(control,1,0) and not steer.Accept(control,-1,0.001),"server steering packet rate limit")
	local nextVelocity=steer.Step(control,v,0.05,0.05)
	check(near(nextVelocity.X,3.75) and nextVelocity.Y==v.Y and nextVelocity.Z==v.Z,"right input adds bounded lateral acceleration only")
	local left=steer.Create(v); steer.Accept(left,-1,0)
	check(near(steer.Step(left,v,0.05,0.05).X,-3.75),"left input has correct launch-relative sign")
	local held=steer.Create(v)
	for i=1,200 do steer.Accept(held,1,i*0.05); v=steer.Step(held,v,0.05,i*0.05) end
	check(near(v.X,75) and v.Z==-250 and v.Y==50,"held input cannot exceed lateral target or increase forward speed")
	steer.Accept(held,0,11)
	local released=steer.Step(held,v,0.05,11)
	check(near(released.X,74.4),"release keeps inertia and decays gently")
	steer.Accept(held,-1,12)
	check(near(steer.Step(held,v,0.05,12).X,71.25),"opposite input cannot reverse lateral momentum instantly")
	steer.Accept(held,1,13)
	check(near(steer.Step(held,v,0.05,14).X,74.4),"expired input becomes neutral rather than sticky steering")
	local weak=env.Vector3.new(0,30,-10); local c=steer.Create(weak)
	steer.Accept(c,1,1)
	check(near(steer.Step(c,weak,0.1,1).X,3.5),"lateral target scales down with remaining forward speed")
	local slow=env.Vector3.new(0,30,-2)
	check(steer.Step(steer.Create(slow),slow,0.1,1)==slow,"near-vertical launch cannot generate sideways free flight")
	local c2=steer.Create(env.Vector3.new(0,0,-250)); steer.Accept(c2,1,1)
	check(steer.Step(c2,slow,0.1,1)==slow,"loss of forward momentum prevents new sideways thrust")
	local diagonal=env.Vector3.new(100,70,-100); local c3=steer.Create(diagonal); steer.Accept(c3,1,1)
	local corrected=steer.Step(c3,diagonal,0.1,1)
	check(near(corrected:Dot(c3.forward),diagonal:Dot(c3.forward)) and corrected.Y==70
		and corrected.X>diagonal.X and corrected.Z>diagonal.Z,"rotated cannon steering preserves its own forward and vertical components")
	local c4=steer.Create(diagonal); steer.Accept(c4,1,1)
	check(near(select(2,steer.Step(c4,diagonal,3,1)),7.5),"stalled frame has bounded steering correction")
	local boosted=diagonal*1.43+env.Vector3.new(0,40,0)
	local withBoost=steer.Step(c3,boosted,0.05,1.05)
	check(near(withBoost:Dot(c3.forward),boosted:Dot(c3.forward)) and withBoost.Y==boosted.Y,"steering preserves ring-modified forward and vertical velocity")
	local function simulate(dt,steps)
		local velocity=env.Vector3.new(0,0,-250); local c5=steer.Create(velocity)
		for i=1,steps do steer.Accept(c5,1,i*dt); velocity=steer.Step(c5,velocity,dt,i*dt) end
		return velocity.X
	end
	check(near(simulate(0.05,20),simulate(1/60,60)),"steering response is timestep independent at normal frame rates")
end
do
	local env=flightEnvironment(); local a,b=env.player(60),env.player(61)
	local id=env.enter(a)
	env.rs.SteerFlight.OnServerEvent:Fire(a,1,id) -- Aiming, must be ignored.
	env.fire(a,id); env.step(0.1)
	local root=a.Character.HumanoidRootPart
	check(root.AssemblyLinearVelocity.X==0,"aiming steering packet does not carry into flight")
	env.rs.SteerFlight.OnServerEvent:Fire(b,1,id)
	env.rs.SteerFlight.OnServerEvent:Fire(a,1,id+100)
	env.rs.SteerFlight.OnServerEvent:Fire(a,0/0,id)
	env.rs.SteerFlight.OnServerEvent:Fire(a,2,id)
	env.step(0.1)
	check(root.AssemblyLinearVelocity.X==0,"foreign stale and invalid steering requests cannot change flight")
	env.rs.SteerFlight.OnServerEvent:Fire(a,1,id)
	env.rs.SteerFlight.OnServerEvent:Fire(a,-1,id)
	env.step(0.1)
	check(near(root.AssemblyLinearVelocity.X,7.5) and near(root.AssemblyLinearVelocity.Z,-Balance.LaunchComponents(1,0,1)),"validated steering applied by server and spam reversal ignored")
	local bid=env.enter(b); env.fire(b,bid)
	env.rs.SteerFlight.OnServerEvent:Fire(b,-1,bid); env.step(0.1)
	check(root.AssemblyLinearVelocity.X>0 and b.Character.HumanoidRootPart.AssemblyLinearVelocity.X<0,"simultaneous players steer independent runs")
	local before=root.AssemblyLinearVelocity.X; env.step(0.5)
	check(root.AssemblyLinearVelocity.X<before and root.AssemblyLinearVelocity.X>0,"missing input packets remove thrust without instant stop")
	a.Character.Humanoid.FloorMaterial="Grass"; env.step(0.3); env.step(0.2)
	local landed=root.AssemblyLinearVelocity
	env.rs.SteerFlight.OnServerEvent:Fire(a,1,id); env.step(0.2)
	check(a:GetAttribute("FlightState")=="Result" and root.AssemblyLinearVelocity==landed,"result state rejects steering and has no residual physics update")
	env.rs.ReturnToSpawn.OnServerEvent:Fire(a,id)
	local nextId=env.enter(a); env.fire(a,nextId)
	env.rs.SteerFlight.OnServerEvent:Fire(a,-1,id); env.step(0.1)
	check(a.Character.HumanoidRootPart.AssemblyLinearVelocity.X==0,"old steering cannot affect next character/run")
end
do
	local env=environment(); local input=newSteeringInput(env); local sent={}
	local controller=input.Start(function(axis) table.insert(sent,axis) end,SteeringConfig.Client)
	check(#sent==1 and sent[1]==0,"steering adapter starts neutral")
	env.key("D","Begin"); env.step(0.1)
	check(sent[#sent]==1,"D produces right axis")
	env.key("A","Begin"); env.step(0.1)
	check(sent[#sent]==0,"opposing keys cancel")
	env.key("D","End"); env.step(0.1)
	check(sent[#sent]==-1,"releasing one opposing key retains the other")
	env.key("A","End"); env.key("Right","Begin"); env.step(0.1)
	check(sent[#sent]==1,"right arrow is supported")
	env.key("Right","End"); env.key("Left","Begin"); env.step(0.1)
	check(sent[#sent]==-1,"left arrow is supported")
	env.focusedTextBox={}; env.input.TextBoxFocused:Fire(); env.key("D","Begin"); env.step(0.1)
	check(sent[#sent]==0,"typing in a text box never steers")
	env.focusedTextBox=nil; env.key("D","Begin"); env.input.WindowFocusReleased:Fire(); env.step(0.1)
	check(sent[#sent]==0,"focus loss neutralizes held keys")
	env.input.WindowFocused:Fire(); env.step(0.1)
	check(sent[#sent]==0,"focus return does not resurrect stale held input")
	controller.SetAxis(0.4); env.step(0.1)
	check(sent[#sent]==0.4,"normalized analog adapter supports future non-keyboard controls")
	local packets=#sent; env.step(2)
	check(#sent==packets+1,"slow frame sends no catch-up packet burst")
	controller.Stop(); controller.Stop(); packets=#sent; env.key("D","Begin"); env.step(1)
	check(#sent==packets and next(env.actions.bindings)==nil and env.heartbeat:Count()==0
		and env.input.WindowFocusReleased:Count()==0,"steering stop is idempotent and removes bindings and connections")
end
do
	local env=environment(); local V=env.Vector3; local coordinates=newWorldCoordinates(env)
	local frame=coordinates.Create({Position=V.new(63,9,870),LookVector=V.new(0,0,-1)},0)
	local pos=coordinates.Position(frame,500,20,4)
	local forward,lateral=coordinates.Project(frame,pos)
	check(pos.X==83 and pos.Y==4 and pos.Z==370 and forward==500 and lateral==20,"layout uses translated cannon origin and actual negative Z direction")
	local rotated=coordinates.Create({Position=V.new(10,3,20),LookVector=V.new(1,0,0)},0)
	check(coordinates.Position(rotated,100,0,0).X==110,"rotated cannon course follows positive X without hardcoded Z")
	check(coordinates.RewardDistance(V.new(3,4,0),V.zero)==5,"reward remains 3D radial distance")
	check(coordinates.ExitReason(frame,V.new(63,-101,500),V.zero,-500,LevelConfig.Bounds)=="WorldFall","below-ground recovery precedes engine destruction")
	check(coordinates.ExitReason(frame,V.new(63,10,500),V.new(0,-2500,0),-500,LevelConfig.Bounds)=="WorldFall","high downward speed predicts destroy plane crossing")
	check(coordinates.ExitReason(frame,V.new(2000,100,870),V.zero,-500,LevelConfig.Bounds)=="OutOfFlightArea","corridor departure has distinct cancellation reason")
	check(coordinates.ExitReason(frame,V.new(63,100,-10000),V.zero,-500,LevelConfig.Bounds)==nil,"no forward wall at end of generated example")
	local B=newLevelBuilder(env); local config=table.clone(LevelConfig)
	config.Sections={table.clone(LevelConfig.Sections[1])}; config.Sections[1].RepeatCount=20
	local builder=B.new(env.workspace,frame,config)
	builder:Update({{0,900}},0)
	check(#builder.Plans==20 and #builder.Folder:GetChildren()==2,"10km configuration only activates nearby sections")
	local first=builder.Active.TestLane_1
	check(#first:GetChildren()==8 and first:GetChildren()[1].Position.Z==738,"section has eight deterministic correctly positioned tiles")
	check(first:GetChildren()[1].CFrame.LookVector.Z==-1 and first:GetChildren()[1].CanCollide,"floor orientation follows course and supports landing")
	check(not pcall(B.new,env.workspace,frame,config) and first.Parent==builder.Folder,"existing world container is preserved on ownership collision")
	builder:Update({{0,100},{9000,9300}},1)
	check(builder.Active.TestLane_1==first and builder.Active.TestLane_18~=nil,"two-player union preserves near and distant occupied sections")
	builder:Update({{9000,9300}},2); builder:Update({{9000,9300}},18)
	check(builder.Active.TestLane_1==nil and first.destroyed,"unneeded sections retire after grace period")
	builder:Update({{0,100}},19)
	check(builder.Active.TestLane_1~=first and builder.Active.TestLane_1:GetChildren()[1].Position.Z==738,"return recreates identical section without cumulative offset")
	local bad=table.clone(config); bad.Sections={table.clone(config.Sections[1])}; bad.Sections[1].TileLength=0
	check(not pcall(B.Plans,bad),"invalid config cannot loop forever")
end
do
	local env=environment(); local legacy=newLegacyGimmicks(env); local hits=0
	local folder=env.Instance.new("Folder"); folder.Name="Gimmicks"; folder.Parent=env.workspace
	local ring=env.Instance.new("Part"); ring.Name="BoosterRing"; ring.Parent=folder
	legacy.Start(function() hits+=1 end,"Preserve"); legacy.Start(function() hits+=1 end,"Preserve")
	ring.Touched:Fire(ring)
	check(hits==1 and #folder:GetChildren()==1,"legacy saved layout reuses one handler without duplicate generation")
	local disabledEnv=environment(); local f=disabledEnv.Instance.new("Folder"); f.Name="Gimmicks"; f.Parent=disabledEnv.workspace
	newLegacyGimmicks(disabledEnv).Start(function() error("disabled") end,"Disabled")
	check(disabledEnv.workspace.Gimmicks==nil and f.Parent.Parent==disabledEnv.storage and not f.destroyed,"disabled legacy layout archives safely without destruction or reward targets")
end
do
	local env=flightEnvironment(true); local a,b=env.player(101),env.player(102)
	check(env.workspace.GeneratedWorld.TestLane_1~=nil and #env.workspace.Gimmicks:GetChildren()==46,"real WorldService startup creates one section and unchanged 46 legacy objects")
	local id=env.enter(a); env.fire(a,id); local bid=env.enter(b)
	a.Character.HumanoidRootPart.Position=env.Vector3.new(0,-110,-9)
	env.step(1)
	check(a:GetAttribute("FlightState")=="Returning" and #env.awards==0 and #env.rs.FlightResult.sent==0,"world fall reserves recovery with no reward or result")
	check(b:GetAttribute("FlightState")=="Aiming" and not env.prompt.Enabled,"recovery does not release another cannon occupant")
	env.step(1); env.rs.ReturnToSpawn.OnServerEvent:Fire(a,id)
	check(#env.queued==1,"duplicate heartbeat and return cannot enqueue second recovery")
	local queued=table.remove(env.queued,1); queued[1]()
	check(a.loadCount==1 and a:GetAttribute("FlightState")=="Idle","automatic recovery reuses normal respawn lifecycle")
	b.Character.Humanoid.Died:Fire()
	local nextId=env.enter(a); env.fire(a,nextId)
	queued[1]()
	check(a.loadCount==1 and a:GetAttribute("FlightState")=="Flying","old recovery task cannot respawn a new run")
end
do
	local env=flightEnvironment(true); local p=env.player(103); local id=env.enter(p); env.fire(p,id)
	p.Character.HumanoidRootPart.Position=env.Vector3.new(0,-110,-9); env.step(1)
	p.Character=env.character()
	local queued=table.remove(env.queued,1); queued[1]()
	check(p.loadCount==nil and p:GetAttribute("FlightState")=="Idle","character replacement before queued recovery cancels stale work")
end

do
	local env=flightEnvironment(true); local p=env.player(104); local id=env.enter(p); env.fire(p,id)
	p.Character.HumanoidRootPart.Position=env.Vector3.new(1000,10,-9); env.step(5)
	local message=env.rs.FlightState.sent[#env.rs.FlightState.sent]
	check(message[2]=="Returning" and message[5]=="OutOfFlightArea" and #env.awards==0,"corridor exit follows recovery rather than rewarding a landing")
	local root=p.Character.HumanoidRootPart
	local before=root.AssemblyLinearVelocity
	env.flight.ApplyGimmick(env.workspace.Gimmicks:GetChildren()[1],root,"Ring")
	check(root.AssemblyLinearVelocity==before,"recovering run ignores legacy gimmick impulses")
	env.players.PlayerRemoving:Fire(p); p.Parent=nil
	local queued=table.remove(env.queued,1); queued[1]()
	check(p.loadCount==nil,"leaving before recovery does not respawn departed player")
end
do
	local env=environment(); local V=env.Vector3
	local model=env.Instance.new("Model"); model.Name="Canon"; model.Parent=env.workspace
	local cylinder=env.Instance.new("Part"); cylinder.Name="Cylinder"; cylinder.Parent=model
	local handmade=env.Instance.new("Folder"); handmade.Name="SIMULATOR MAP"; handmade.Parent=env.workspace
	local legacy=env.Instance.new("Folder"); legacy.Name="Gimmicks"; legacy.Parent=env.workspace
	local calls={}
	local world=newWorldService(env,{Destination=newDestination(env),LaunchTrajectory=newLaunchTrajectory(env),LevelConfig=GameLevelConfig,WorldCoordinates=newWorldCoordinates(env),LevelBuilder=newLevelBuilder(env),LegacyGimmicks=newLegacyGimmicks(env)})
	world.Start(model,function(part,hit,kind) table.insert(calls,kind) end)
	check(handmade.Parent.Parent==env.storage and legacy.Parent.Parent==env.storage,"playable course archives old handmade map and gimmicks without deleting")
	local folder=env.workspace.GeneratedWorld
	check(#folder:GetChildren()==2 and folder.MeadowRun_1 and folder.MeadowRun_2,"current config activates two nearby sections instead of entire 6k course")
	local first=folder.MeadowRun_1; local ring=first:FindFirstChild("BoosterRing")
	check(not first:FindFirstChild("ObstacleBomb"),"first section has no bomb hazard")
	local p=env.player(201); p.Character.HumanoidRootPart.Position=V.new(0,10,-1700); env.step(1)
	local bomb=folder.MeadowRun_4:FindFirstChild("ObstacleBomb")
	check(ring and near(ring.Position.Z,-46) and ring.Position.Y>60 and ring.CFrame.LookVector.Y>0
		and ring.CanTouch and not ring.CanCollide,"first optional booster follows upward tangent with an open noncolliding trigger")
	ring.Touched:Fire(ring); bomb.Touched:Fire(bomb)
	check(calls[1]=="Ring" and calls[2]=="Bomb","generated course routes ring and bomb contacts through authoritative flight handler")
	check(bomb.Position.Z==-1701 and bomb.Position.X==48 and bomb.Position.Y==20,"sparse low bomb leaves center route clear")
	check(world.TargetCount(V.new(0,10,-301))==1 and world.TargetCount(V.new(100,10,-301))==0,"generated targets preserve one plus-five zone within existing XZ radius")
	p.Character.HumanoidRootPart.Position=V.new(0,10,-2000); env.step(1); env.step(16)
	check(not first.Parent and world.TargetCount(V.new(0,10,-301))==0,"unloaded course removes target registration and contact instances")
end
do
	local env=environment(); local spawn=env.Instance.new("SpawnLocation")
	spawn.Name="SpawnLocation"; spawn.Size=env.Vector3.new(12,1,12); spawn.CFrame=env.CFrame.new(68,5,903); spawn.Parent=env.workspace
	local other=env.Instance.new("SpawnLocation"); other.Name="OtherSpawn"; other.Parent=env.workspace
	local p=env.player(202); newSpawnService(env).Start()
	local queued=table.remove(env.queued,1); queued[1](queued[2])
	check(p.RespawnLocation==spawn and other.Enabled==false and spawn.Enabled and spawn.Neutral,"only intended neutral spawn is enabled and explicitly assigned")
	check(p.Character.HumanoidRootPart.Position.X==68 and p.Character.HumanoidRootPart.Position.Z==903,"already spawned first character is corrected to cannon lobby")
	local char=p.Character; local before=char.HumanoidRootPart.CFrame
	p:SetAttribute("FlightState","Flying"); p.CharacterAdded:Fire(char)
	check(char.HumanoidRootPart.CFrame==before,"late spawn handler cannot teleport an active flight")
	p:SetAttribute("FlightState","Idle"); p.Character=env.character(); p.CharacterAdded:Fire(char)
	check(p.Character.HumanoidRootPart.Position.X==0,"stale character spawn callback cannot move replacement character")
	local late=env.Instance.new("SpawnLocation"); env.workspace.DescendantAdded:Fire(late)
	check(late.Enabled==false,"late-added alternate spawn is disabled")
	env.players.PlayerRemoving:Fire(p)
	check(p.CharacterAdded:Count()==0,"spawn watch disconnects when player leaves")
end
do
	local env=environment(); env.players.LocalPlayer=env.player(203)
    function env.players.LocalPlayer:GetAttributeChangedSignal()return event()end
	local sky=newSkyController(env)
	local old=env.Instance.new("Sky"); old.Parent=env.lighting
	env.players.LocalPlayer.Character=nil; sky.Start()
	check(old.destroyed and env.lighting.FlightSky and env.lighting.ClockTime==14,"bright sky applies immediately without character or remote availability")
	local p=env.players.LocalPlayer; p.Character=env.character(); p.Character.HumanoidRootPart.Position=env.Vector3.new(0,CloudConfig.HeightPresentation.Gates[3].Top+500,0)
	p:SetAttribute("FlightState","Flying"); env.step(0.1)
	check(env.lighting:GetAttribute("AltitudeLayer")=="HIGH_ALTITUDE" and env.lighting:GetAttribute("AltitudeSky")=="Skybox HD","third exit uses the requested purple regional sky")
	sky.SetRegion({Region="Clouds",FirstEntry=true,FirstDiscovery=true})
	check(env.lighting:GetAttribute("AltitudeLayer")=="HIGH_ALTITUDE" and p.PlayerGui.DiscoveryGui.Notice.Visible,"server discovery notice does not overwrite altitude appearance")
	env.step(CloudConfig.NoticeSeconds+.1)
	check(not p.PlayerGui.DiscoveryGui.Notice.Visible,"discovery notice expires without delayed task affecting next run")
	sky.SetRegion({Region="Ground",FirstEntry=false})
	check(env.lighting:GetAttribute("AltitudeLayer")=="HIGH_ALTITUDE","server region event does not override local high layer")
    p.Character.HumanoidRootPart.Position=env.Vector3.new(0,CloudConfig.HeightPresentation.Enter[3]+50,0);env.step(.1)
    check(env.lighting.FlightSky.StarCount==3000 and env.lighting.ClockTime==14,"100km switches space texture without darkening the scene")
    p.Character.HumanoidRootPart.Position=env.Vector3.new(0,CloudConfig.HeightPresentation.Enter[3]-4,0);env.step(.1)
    check(env.lighting:GetAttribute("AltitudeLayer")=="SPACE","boundary jitter stays in space within hysteresis")
    p.Character.HumanoidRootPart.Position=env.Vector3.new(0,CloudConfig.HeightPresentation.Enter[3]-10,0);env.step(.1)
    check(env.lighting:GetAttribute("AltitudeLayer")=="HIGH_ALTITUDE","descent leaves space below hysteresis threshold")
    p.Character.HumanoidRootPart.Position=env.Vector3.new(0,700,0);env.step(.1)
    check(env.lighting:GetAttribute("AltitudeLayer")=="CLOUD" and env.lighting.Brightness==CloudConfig.Ground.Brightness,"700m retains neutral lighting with the cloud layer")
    p.Character.HumanoidRootPart.Position=env.Vector3.new(0,100,0);env.step(.1)
    check(env.lighting:GetAttribute("AltitudeLayer")=="GROUND" and env.lighting.ClockTime==14,"low descent restores daytime")
	p.CharacterRemoving:Fire(p.Character)
	check(env.lighting:GetAttribute("AltitudeSky")=="Realistic Sky","character removal restores mountain sky immediately")
	local audio=newAudio(env); audio.Play("Launch"); audio.Play("Result"); audio.Play("Unknown")
	check(#env.soundService:GetChildren()==2 and env.soundService.FlightAudio_Launch.played,"known sounds use bounded reusable voices; unknown cues ignored")
	env.soundService.FlightAudio_Launch.IsLoaded=false; env.soundService.FlightAudio_Launch.played=false
	audio.Play("Launch")
	check(not env.soundService.FlightAudio_Launch.played and #env.soundService:GetChildren()==2,"unloaded cues are skipped without delayed replay or new instances")
end
do
	for _,flag in ipairs({"balanceMissing","balanceWrongType"}) do
		for _,factory in ipairs({newPlayerData,newFlightService,newFlightCamera}) do
			local env=environment(); env[flag]=true
			local ok,err=pcall(factory,env)
			check(not ok and string.find(tostring(err),"[Setup]",1,true)~=nil,
				"missing or wrong BalanceConfig reports sync instructions before require")
		end
	end
end
do
	local env=environment(); local registry=newAssetRegistry(env)
	for _,category in ipairs({"Obstacle","Ring","Environment","Landmark","LandingTarget"}) do
		local key="Test."..category
		local object,status=registry.Create(key)
		check(registry.Get(key).Category==category and status=="Primitive"
			and object:GetAttribute("AssetCategory")==category and object.Parent==nil
			and object.Anchored and not object.CanCollide and not object.CanTouch,
			"registry primitive is inert unparented geometry: "..category)
	end
	check(not pcall(function() registry.Get("Test.Ring").Category="Other" end),"asset catalogue cannot be mutated by consumers")
	check(registry.Get("Missing")==nil and registry.Create(nil)==nil,"invalid keys are handled without throwing")
	local a,status=registry.Create("Missing")
	local b=registry.Create("Missing")
	check(status=="Fallback" and a~=b and a:GetAttribute("AssetFallback") and #env.warnings==1,
		"unknown key has independent fallback instances and bounded warning")
	local _,missingStatus=registry.Create("Local.Landmark")
	check(missingStatus=="Fallback","absent template folder falls back immediately")
	local folder=env.Instance.new("Folder"); folder.Name="AssetTemplates"; folder.Parent=env.storage
	local template=env.Instance.new("Folder"); template.Name="Landmark"; template.Parent=folder
	local _,wrongStatus=registry.Create("Local.Landmark")
	check(wrongStatus=="Fallback","wrong template class falls back")
	template:Destroy(); template=env.Instance.new("Model"); template.Name="Landmark"; template.Parent=folder
	template.Clone=function() error("load failure") end
	local _,failedStatus=registry.Create("Local.Landmark")
	check(failedStatus=="Fallback","clone/load exception is contained")
	template.Clone=function() return nil end
	local _,nilStatus=registry.Create("Local.Landmark")
	check(nilStatus=="Fallback","non-archivable template falls back")
	local empty
	template.Clone=function() empty=env.Instance.new("Model"); return empty end
	local _,emptyStatus=registry.Create("Local.Landmark")
	check(emptyStatus=="Fallback" and empty.destroyed,"geometry-free clone is cleaned before fallback")
	local originalScript=env.Instance.new("Script"); originalScript.Parent=template
	template.Clone=function()
		local model=env.Instance.new("Model")
		local part=env.Instance.new("Part"); part.Name="Geometry"; part.Parent=model
		for _,class in ipairs({"Script","LocalScript","ModuleScript"}) do
			local code=env.Instance.new(class); code.Parent=model
		end
		return model
	end
	local clone,cloneStatus=registry.Create("Local.Landmark")
	local second=registry.Create("Local.Landmark")
	check(cloneStatus=="Template" and clone~=second and #clone:GetChildren()==1
		and clone.Geometry.Anchored and not clone.Geometry.CanCollide and not clone.Geometry.CanTouch
		and originalScript.Parent==template,"local clone strips code before parenting and preserves original")
	template.Clone=function()
		local part=env.Instance.new("Part"); part:SetAttribute("LandingTarget",true); return part
	end
	local targetClone=registry.Create("Local.Landmark")
	check(targetClone:GetAttribute("LandingTarget")==nil,"template metadata cannot silently activate legacy landing rewards")
	local V=env.Vector3
	local frame=newWorldCoordinates(env).Create({Position=V.new(10,3,20),LookVector=V.new(1,0,0)},0)
	local config=table.clone(LevelConfig); config.Sections={table.clone(LevelConfig.Sections[1])}
	config.Sections[1].Start=100; config.Sections[1].RepeatCount=2
	config.Sections[1].Assets={
		{Key="Test.Environment",Offset=25,Lateral=8,Height=10},
		{Key="Missing",Offset=30}, {Key="Local.Landmark",Offset=40},
		{Key="Test.Ring",Offset=0/0}, {Key=false},
	}
	local builder=newLevelBuilder(env).new(env.workspace,frame,config)
	builder:Update({{100,200}},0)
	local section=builder.Active.TestLane_1
	local asset=section:FindFirstChild("Test.Environment")
	check(asset.Position.X==135 and asset.Position.Y==10 and asset.Position.Z==28
		and asset.CFrame.LookVector.X==1,"asset placement uses section offset and rotated shared coordinates")
	check(#section:GetChildren()==11 and section:FindFirstChild("Missing"):GetAttribute("AssetFallback"),
		"bad placements cannot abort floor valid assets or section activation")
	builder:Update({},1); builder:Update({},20)
	check(section.destroyed and builder.Active.TestLane_1==nil,"assets belong to unloaded section without separate lifetime")
	builder:Update({{100,200}},21)
	local rebuilt=builder.Active.TestLane_1:FindFirstChild("Test.Environment")
	check(rebuilt~=asset and rebuilt.Position.X==135,"section reactivation regenerates deterministic independent assets")
end
do
	local env=environment(); local O=newObstaclePatterns(env)
	local placements=O.Placements(GameLevelConfig.Obstacles)
	check(#placements==6 and placements[1].Distance==600 and placements[2].Distance==1200
		and placements[3].Distance==2200 and placements[4].Distance==3400,"six configured obstacles progress from single to alternating to choice")
	check(placements[2].Lateral==80 and placements[3].Lateral==120
		and placements[5].Lateral==-160 and placements[6].Lateral==-80,"alternating sides and two 28-stud clear choice gaps")
	local frame=newWorldCoordinates(env).Create({Position=env.Vector3.new(10,0,20),LookVector=env.Vector3.new(1,0,0)},0)
	local model=env.Instance.new("Model"); model.Parent=env.workspace
	local config={table.clone(GameLevelConfig.Obstacles[1])}; config[1].Key="Unavailable.Obstacle"; config[1].Start=200 -- Stable section fixture
	local received
	O.Build(model,frame,{Start=0,Length=416},config,function(part,hit,kind) received={part,hit,kind} end)
	local obstacle=model:GetChildren()[1]
	check(obstacle.Position.X==210 and obstacle.Size.X==8 and obstacle.CanTouch and not obstacle.CanCollide
		and obstacle:GetAttribute("AssetFallback"),"fallback obstacle has configured hit volume with rotated coordinates and no physical wall")
	obstacle.Touched:Fire(obstacle)
	check(received[1]==obstacle and received[3]=="Bomb","all pattern contacts share existing Bomb handler")
	local other=env.Instance.new("Model")
	O.Build(other,frame,{Start=200,Length=216},config,function() end)
	check(other:GetChildren()[1]:GetAttribute("ObstacleId")==obstacle:GetAttribute("ObstacleId"),"obstacle identity stays stable after regeneration")
	local boundary=env.Instance.new("Model")
	O.Build(boundary,frame,{Start=0,Length=200},config,function() end)
	check(#boundary:GetChildren()==0,"section boundary cannot duplicate obstacle")
	config[1].Count=math.huge
	check(#O.Placements(config)==0,"invalid pattern density cannot run unbounded generation")
	-- L1 max horizontal speed with PERFECT and full ring bonus. Conservative
	-- bounding radius 3 studs, 0.1 s reaction allowance; steering values unchanged.
	local h=Balance.LaunchComponents(1,math.sin(math.rad(25)),1.5)
	local first=GameLevelConfig.Obstacles[1]
	local available=(first.Start-first.Depth/2-3-8)/h-0.1
	check(0.5*SteeringConfig.Acceleration*available^2>first.Width/2+3,
		"L1 PERFECT initial obstacle is avoidable after 0.1s reaction in lateral model")
	local weave=GameLevelConfig.Obstacles[2]
	local requiredShift=2*(weave.Width/2-weave.SideOffset+3+2)
	local availableTurn=(weave.Spacing-weave.Depth-6)/(h*1.35)
	check(availableTurn>2*math.sqrt(requiredShift/SteeringConfig.Acceleration),
		"alternating clear positions are reachable with unchanged L1 steering even at full ring bonus")
end
do
	local env=flightEnvironment(); local a,b=env.player(801),env.player(802)
	local id=env.enter(a); env.fire(a,id)
	local bid=env.enter(b); env.fire(b,bid)
	local root=a.Character.HumanoidRootPart
	local obstacle=env.Instance.new("Part"); obstacle.CFrame=env.CFrame.new(root.Position)
	obstacle.Size=env.Vector3.new(8,110,16); obstacle:SetAttribute("ObstacleId","test:1")
	local before=root.AssemblyLinearVelocity
	env.flight.ApplyGimmick(obstacle,root,"Bomb")
	local after=root.AssemblyLinearVelocity
	check(near(after.Z,before.Z*Balance.Bomb.SpeedFactor) and after.Y==before.Y*0.9-5
		and a.Character.Humanoid.Health==100,"collision reuses exact Bomb penalty without damage or instant death")
	env.time+=5
	env.flight.ApplyGimmick(obstacle,a.Character.Body,"Bomb")
	check(root.AssemblyLinearVelocity==after,"another body part or later contact cannot repeat obstacle penalty")
	local replacement=env.Instance.new("Part"); replacement.CFrame=obstacle.CFrame; replacement.Size=obstacle.Size
	replacement:SetAttribute("ObstacleId","test:1")
	env.flight.ApplyGimmick(replacement,root,"Bomb")
	check(root.AssemblyLinearVelocity==after,"regenerated same obstacle cannot repeat penalty within run")
	local broot=b.Character.HumanoidRootPart; env.flight.ApplyGimmick(obstacle,broot,"Bomb")
	check(near(broot.AssemblyLinearVelocity.Z,after.Z),"second player's run has independent contact history")
	env.rs.ReturnToSpawn.OnServerEvent:Fire(a,id); env.step(0)
	local newId=env.enter(a); env.fire(a,newId)
	root=a.Character.HumanoidRootPart; env.flight.ApplyGimmick(obstacle,root,"Bomb")
	check(near(root.AssemblyLinearVelocity.Z,after.Z),"new run can receive penalty from same obstacle")
	a.Character.Humanoid.Died:Fire()
	local cancelledVelocity=root.AssemblyLinearVelocity; env.flight.ApplyGimmick(obstacle,root,"Bomb")
	check(root.AssemblyLinearVelocity==cancelledVelocity,"cancelled run ignores late obstacle contact")
end
do
	local env=environment(); local V=env.Vector3; local metrics=newFlightMetrics(env)
	local m=metrics.Create(V.new(10,120,20),V.new(2,9,0),100,10)
	metrics.Sample(m,V.new(10,150,70),11)
	check(m.ForwardDistance==0 and m.MaxAltitude==50,"lateral and vertical travel do not increase forward progress; shared Ground is subtracted")
	check(near(m.RewardDistance,math.sqrt(30^2+50^2)),"reward remains 3D radial distance")
	metrics.Sample(m,V.new(110,130,20),12.5)
	local forward,altitude=newWorldCoordinates(env).Measure(m.Frame,V.new(90,110,30))
	check(forward==80 and altitude==10,"reusable spatial measurement reports simultaneous current coordinates")
	check(m.ForwardDistance==100 and m.MaxAltitude==50 and m.FlightTime==2.5,"run keeps independent peaks and flight duration")
	local snapshot=metrics.Snapshot(m)
	metrics.Sample(m,V.new(210,130,20),14)
	check(snapshot.ForwardDistance==100 and snapshot.FlightTime==2.5,"result snapshot independent of later sampling")
	local nextRun=metrics.Create(V.new(0,0,0),V.new(0,0,-1),0,20)
	metrics.Sample(nextRun,V.new(0,5,-10),20.25)
	check(nextRun.MaxAltitude==5 and nextRun.FlightTime==.25 and nextRun.ForwardDistance==10,"new run metrics reset with a separate launch frame")
end
do
	local env=environment(); env.saved={Gold=20,MaxDistance=100,LegacyExtra="keep"}
	local data=newPlayerData(env); data.Start(); local p=env.player(910); env.players.PlayerAdded:Fire(p)
	check(data.IsReady(p) and p.leaderstats.MaxAltitude.Value==0,"legacy save missing altitude safely defaults without resetting old fields")
	local distanceRecord,altitudeRecord=data.Award(p,50,10,0,80)
	check(not distanceRecord and altitudeRecord and p.leaderstats.MaxDistance.Value==100,"altitude record independent of distance record")
	check(data.Award(p,1000,10,0,0/0)==nil and p.leaderstats.Gold.Value==30 and p.leaderstats.MaxAltitude.Value==80,"invalid altitude rejects entire award atomically")
	data.Award(p,60,0,0,40)
	check(p.leaderstats.MaxAltitude.Value==80,"lower flight never reduces altitude record")
	check(data.Save(p) and env.saved.MaxAltitude==80 and env.saved.MaxDistance==100 and env.saved.LegacyExtra=="keep","legacy save migrates altitude in existing key preserving unknown fields")
	env.saved.MaxAltitude=999
	check(not data.Save(p) and env.saved.MaxAltitude==999,"altitude concurrent change preserves existing conflict protection")
end
do
	local env=environment(); env.saved={MaxAltitude=-1}; local data=newPlayerData(env); data.Start()
	local p=env.player(911); env.players.PlayerAdded:Fire(p)
	check(not data.IsReady(p) and not data.Save(p) and env.writes==0,"malformed stored altitude cannot become writable defaults")
end
do
	local env=flightEnvironment(); local p=env.player(912); local id=env.enter(p); env.fire(p,id)
	local root=p.Character.HumanoidRootPart
	root.Position=env.Vector3.new(20,50,-60); env.step(.5)
	root.Position=env.Vector3.new(30,10,-100); env.step(.6)
	p.Character.Humanoid.FloorMaterial="Grass"; env.step(.2); env.step(.2)
	local result=env.rs.FlightResult.sent[1]; local metrics=result and result[8]
	check(metrics and metrics.ForwardDistance==math.floor(env.launch.Position.Z+100) and metrics.MaxAltitude==50,"live service samples validated positions and emits metrics in appended payload")
	check(metrics and near(metrics.FlightTime,1.5) and metrics.RewardDistance==result[2] and env.awards[1][5]==50,"normal finalization preserves reward distance and commits altitude exactly once")
	env.rs.ReturnToSpawn.OnServerEvent:Fire(p,id)
	local nextId=env.enter(p); env.fire(p,nextId); p.Character.Humanoid.Died:Fire(); env.step(2)
	check(#env.awards==1 and #env.rs.FlightResult.sent==1,"cancelled next run cannot award or publish altitude")
end
do
	local env=environment(); local metrics=newFlightMetrics(env); local discovery=newCloudDiscovery(env)
	local m=metrics.Create(env.Vector3.new(0,110,0),env.Vector3.new(0,0,-1),100,0)
	local d=discovery.Create(0,false)
	metrics.Sample(m,env.Vector3.new(0,279.9,-30),1)
	check(discovery.Sample(d,m)==nil,"cloud threshold uses shared Ground, not World Y")
	metrics.Sample(m,env.Vector3.new(0,280,-30),2)
	local r=discovery.Sample(d,m)
	check(r.Region=="Clouds" and r.FirstEntry and r.FirstDiscovery,"first validated threshold crossing discovers Clouds")
	metrics.Sample(m,env.Vector3.new(0,270,-50),3)
	check(discovery.Sample(d,m)==nil,"cloud descent hysteresis prevents boundary flicker")
	metrics.Sample(m,env.Vector3.new(0,264,-70),4)
	check(discovery.Sample(d,m).Region=="Ground" and m.MaxAltitude==180,"descent uses current altitude instead of retained peak")
	metrics.Sample(m,env.Vector3.new(0,290,-80),5)
	check(not discovery.Sample(d,m).FirstEntry,"same-run reentry changes environment without another notice")
	local known=discovery.Create(200,false); local session=discovery.Create(0,true)
	check(not discovery.Sample(known,m).FirstDiscovery and not discovery.Sample(session,m).FirstDiscovery,"saved peak or session discovery distinguishes return visits")
	local other=discovery.Create(0,false)
	check(discovery.Sample(other,m).FirstDiscovery,"other player has independent discovery state")
end
do
	local env=environment(); local V=env.Vector3
	local coordinates=newWorldCoordinates(env); local frame=coordinates.Create({Position=V.new(20,120,30),LookVector=V.new(1,0,0)},100)
	local parent=env.Instance.new("Model")
	newCloudSection(env).Build(parent,frame,{Start=0,Length=512},CloudConfig)
	local puffs=parent.CloudLayer:GetChildren()
	check(#puffs==6,"bounded cloud banks use config spacing and lane count")
	local physical=true; local positioned=true
	for _,p in ipairs(puffs) do
		physical=physical and p:IsA("Model") and #p:GetChildren()==4
		for _,lobe in ipairs(p:GetChildren()) do
			physical=physical and lobe:FindFirstChildOfClass("SpecialMesh")~=nil and lobe.Size.X>lobe.Size.Y*2
				and lobe.Transparency==0 and lobe.Anchored and not lobe.CanCollide and not lobe.CanTouch and not lobe.CanQuery
		end
		local f,a=coordinates.Measure(frame,p.Position)
		positioned=positioned and f>=0 and f<512 and a>=130 and a<=240
	end
	check(physical and positioned,"cloud geometry follows rotated course and Ground datum without physics or rewards")
	local builder=newLevelBuilder(env).new(env.workspace,frame,GameLevelConfig,function() error("cloud collision") end)
	builder:Update({{0,100}},0); local first=builder.Active.MeadowRun_1
	check(first.CloudLayer and #first.CloudLayer:GetChildren()>0,"LevelBuilder owns cloud assets within streamed section")
	builder:Update({{2000,2100}},1); builder:Update({{2000,2100}},20)
	check(not first.Parent and not builder.Active.MeadowRun_1,"unneeded section retires cloud subtree with ground")
end
do
	local env=flightEnvironment(); local p=env.player(930); local id=env.enter(p); env.fire(p,id)
	local root=p.Character.HumanoidRootPart
	root.Position=env.Vector3.new(0,185,-60); env.step(1)
	local function countRegions()
		local n=0; for _,msg in ipairs(env.rs.FlightState.sent) do if msg[2]=="Region" then n+=1 end end; return n
	end
	check(countRegions()==1 and p:GetAttribute("CloudsDiscovered")==true,"active run sends authoritative discovery event without reward")
	check(#env.awards==0,"entering Clouds adds no currency or persistent award")
	root.Position=env.Vector3.new(0,160,-90); env.step(.2)
	check(countRegions()==2,"real service emits Ground transition on descent")
	root.Position=env.Vector3.new(0,185,-110); env.step(.2)
	check(countRegions()==3 and not env.rs.FlightState.sent[#env.rs.FlightState.sent][5].FirstEntry,"service permits reentry but suppresses discovery spam")
	p.Character.Humanoid.Died:Fire(); env.step(.2)
	check(countRegions()==3 and #env.awards==0,"cancelled cloud run cannot publish later environment or award altitude")
end
do
	local env=environment(); local V,C=env.Vector3,env.CFrame
	local coordinates=newWorldCoordinates(env); local frame=coordinates.Create(C.new(0,10,0),0)
	frame.RingMuzzle=C.Angles(math.rad(45),0,0)+V.new(0,16,0)
	local course=newCourseSection(env); local rings=course.RingPlacements(frame,GameLevelConfig.Course,196.2)
	check(#rings==6 and rings[1].Position.Y<rings[2].Position.Y and rings[2].Position.Y<rings[3].Position.Y,
		"reference rings climb in both forward distance and altitude")
	check(rings[1].Direction.Y>0 and math.abs(rings[4].Direction.Y)<.2 and rings[6].Direction.Y<0,
		"ring normals follow ascending, near-apex and descending velocity")
	local centered=true
	for _,ring in ipairs(rings) do
		local _,side=coordinates.Project(frame,ring.Position)
		centered=centered and near(side,0)
	end
	check(centered,"ring centers follow the launch trajectory without an artificial lateral offset")
	local model=env.Instance.new("Model")
	course.Build(model,frame,{Start=0,Length=512,Height=4.5},GameLevelConfig.Course,function() end)
	local normals=true; local arcIndex,triggerIndex=1,1
	for _,part in ipairs(model:GetChildren()) do
		if part.Name=="RingArc" then
			normals=normals and near(part.CFrame.LookVector:Dot(rings[math.ceil(arcIndex/16)].Direction),1)
			arcIndex+=1
		elseif part.Name=="BoosterRing" then
			normals=normals and near(part.CFrame.LookVector:Dot(rings[triggerIndex].Direction),1)
			triggerIndex+=1
		end
	end
	check(normals and arcIndex==97 and triggerIndex==7,"visual arcs and trigger planes have the same trajectory normal")
	local trajectory=newLaunchTrajectory(env)
	local at,velocity=trajectory.AtForward(frame,frame.RingMuzzle,20,1,196.2,90)
	local later=trajectory.AtForward(frame,frame.RingMuzzle,20,1,196.2,90.01)
	check((later-at).Unit:Dot(velocity.Unit)>.99999,"ring tangent agrees with the shared ballistic trajectory derivative")
	local changed=course.RingPlacements(frame,GameLevelConfig.Course,150)
	check(changed[3].Position.Y>rings[3].Position.Y,"ring layout uses actual world gravity rather than a hardcoded gravity")
end
do
	local env=environment(); local V,C=env.Vector3,env.CFrame
	local trajectory=newLaunchTrajectory(env)
	local pivot=C.new(70,12,80)*C.Angles(0,.6,0)
	local offset=C.new(2,3,-4)
	local aimed=trajectory.AimedMuzzle(pivot,offset,16,12,45)
	local actual=trajectory.Muzzle(pivot*C.Angles(0,math.rad(12),0)*C.Angles(math.rad(45),0,0)*offset,16)
	check((aimed.Position-actual.Position).Magnitude<1e-6,"representative muzzle matches aimed cylinder including pivot offset and yaw")
	local frame=newWorldCoordinates(env).Create(aimed,0)
	local origin=trajectory.Origin(aimed).Position
	local distance=(origin-frame.Origin):Dot(frame.Forward)
	local position,velocity,time=trajectory.AtForward(frame,aimed,20,1,196.2,distance)
	check((position-origin).Magnitude<1e-6 and near(time,0),"trajectory time zero is the exact character launch origin")
	check((velocity-trajectory.Velocity(aimed.LookVector,20,1)).Magnitude<1e-6,"trajectory begins with actual launch velocity")
	local root=env.Instance.new("Part"); root.Parent=env.workspace
	local current=true; env.workspace.CurrentCamera.FieldOfView=75
	local camera=newFlightCamera(env).Start(root,V.new(0,50,-100),function() return current end)
	camera.Pulse(); env.render:Fire(.01)
	check(near(env.workspace.CurrentCamera.FieldOfView,78),"ring feedback is bounded to three FOV degrees")
	env.time+=.14; env.render:Fire(.14)
	check(near(env.workspace.CurrentCamera.FieldOfView,75.75),"ring impulse decays immediately without shaking or occluding")
	env.time+=.15; env.render:Fire(.15)
	check(near(env.workspace.CurrentCamera.FieldOfView,75),"ring presentation completes within 0.28 seconds")
	current=false; camera.Pulse(); env.render:Fire(.1); camera.Stop()
	check(near(env.workspace.CurrentCamera.FieldOfView,75) and env.render:Count()==0,"cancelled ring feedback restores original FOV and disconnects")
	local ids={}; local unique=true
	for kind,entry in pairs(PresentationConfig.Sounds) do if kind~="SpeedRush"then unique=unique and not ids[entry.Id];ids[entry.Id]=true end end
	check(unique,"base audio roles remain distinct while speed wind intentionally layers the filtered engine loop")
end
for _,failed in ipairs({false,true}) do
	local env=environment(); env.audioLoadFail=failed
	local audio=newAudio(env); audio.Preload(); audio.Preload()
	check(#env.queued==1,"audio preload is asynchronous and idempotent")
	env.queued[1][1]()
	check(env.preloadCount==1 and #env.soundService:GetChildren()==8,"eight bounded audio roles including speed wind preload without duplicate voices")
	audio.Play("Ring"); audio.Play("Ring")
	check((env.soundService.FlightAudio_Ring.played==true)==not failed,"failed audio cannot trigger stale playback; loaded voice can replay")
	check(#env.warnings==(failed and 8 or 0),"audio load failures are reported per asset without crashing gameplay")
end
do
	local env=environment(); local V=env.Vector3
	local coordinates=newWorldCoordinates(env); local destination=newDestination(env)
	local frame=coordinates.Create({Position=V.new(20,110,30),LookVector=V.new(1,0,0)},100)
	local metrics=newFlightMetrics(env).Create(frame.Origin,frame.Forward,100,0)
	local visited={}
	local function sample(f,l,a)
		local position=coordinates.Position(frame,f,l,a)
		newFlightMetrics(env).Sample(metrics,position,1)
		return destination.Sample(frame,position,metrics,GameLevelConfig.Destinations,visited)
	end
	check(sample(100,65,210)==nil,"Cloud altitude alone does not discover destination")
	check(sample(300,65,100)==nil,"forward reach plus an earlier altitude maximum does not discover destination")
	check(sample(300,180,210)==nil,"wrong lateral path misses destination")
	check(sample(300,65,300)==nil,"passing above outpost does not count as arrival")
	local hit=sample(300,65,210)
	check(hit and hit.Id=="CloudOutpost","actual current 3D bounds discover destination using rotated frame and Ground")
	check(sample(300,65,210)==nil,"destination feedback occurs once per run")
	visited={}; check(sample(300,65,210)~=nil,"next run can revisit without persistent schema")
	local parent=env.Instance.new("Model")
	destination.Build(parent,frame,{Start=-96,Length=512},GameLevelConfig.Destinations)
	local model=parent.CloudOutpost; local harmless=model~=nil
	for _,p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			local landing = p:GetAttribute("LandingSurface") == true
			harmless=harmless and p.Anchored and not p.CanTouch
				and p.CanCollide == landing and p.CanQuery == landing
		end
	end
	check(harmless and #model:GetChildren()<=40 and model.SunlitDeck:GetAttribute("LandingSurface"),"only existing destination deck supports landing; bounded decoration has no collision or rewards")
	local absent=env.Instance.new("Model")
	destination.Build(absent,frame,{Start=416,Length=512},GameLevelConfig.Destinations)
	check(#absent:GetChildren()==0,"destination is owned by exactly one generated section")
end
do
	local env=environment(); local V=env.Vector3; local steering=newHorizontalSteering(env)
	local initial=V.new(70,262,-163); local control=steering.Create(initial)
	local root={AssemblyLinearVelocity=initial,AssemblyMass=12}
	function root:ApplyImpulse(impulse)
		self.lastImpulse=impulse
		self.AssemblyLinearVelocity+=impulse/self.AssemblyMass
	end
	local neutral=initial;local positionA=V.zero;local positionB=V.zero
	local preserves=true
	for i=1,180 do
		local dt=1/60; local gravity=V.new(0,-196.2*dt,0)
		neutral+=gravity;root.AssemblyLinearVelocity+=gravity
		steering.Accept(control,.7,i*dt)
		steering.Apply(control,root,dt,i*dt)
		preserves=preserves and near(root.AssemblyLinearVelocity.Y,neutral.Y)
			and near(root.AssemblyLinearVelocity:Dot(control.forward),neutral:Dot(control.forward))
		positionA+=neutral*dt;positionB+=root.AssemblyLinearVelocity*dt
	end
	check(preserves,"continuous applied steering preserves vertical and forward velocity throughout gravity integration")
	check(near(positionA.Y,positionB.Y),"no-steering and continuous-steering predicted altitudes remain identical")
	check((positionB-positionA):Dot(control.right)>50,"lateral displacement remains meaningful")
	check(root.lastImpulse.Y==0 and near(root.lastImpulse:Dot(control.forward),0),"steering impulse cannot carry vertical or forward momentum")
	steering.Accept(control,-.7,4)
	local before=root.AssemblyLinearVelocity
	function root:ApplyImpulse(impulse)
		-- Emulate gravity advancing after the velocity sample: an absolute overwrite would restore old Y.
		self.AssemblyLinearVelocity+=V.new(0,-10,0)+impulse/self.AssemblyMass
	end
	steering.Apply(control,root,.05,4)
	check(near(root.AssemblyLinearVelocity.Y,before.Y-10),"lateral application never restores a stale sampled Y")
end
do
	local env = environment()
	local world = env.Instance.new("Folder")
	world.Name, world.Parent = "GeneratedWorld", env.workspace
	world:SetAttribute("Owner", "LevelBuilder")
	world:SetAttribute("LayoutOrigin", env.Vector3.new(10, 0, 20))
	world:SetAttribute("Forward", env.Vector3.new(1, 0, 0))
	runSkyIslandSpawner(env)
	local platform = env.workspace.SkyIslandPlatform
	check(platform and platform.Anchored and platform.CanCollide and platform.Size.Y == 5,
		"Sky Island 플랫폼 생성 및 물리 속성")
	check(platform.Position.X == 310 and platform.Position.Y == 180 and platform.Position.Z == 85,
		"회전된 월드 좌표에서도 Cloud Outpost 인근 배치")
	check(env.collection:HasTag(platform, "SkyIsland") and platform:GetAttribute("IsSkyIsland") == true,
		"플랫폼 태그와 속성 부여")
	check(platform:GetAttribute("LandingTarget") == nil, "Sky Island 추가 보상 메타데이터 없음")
end
for _, mode in ipairs({"Ground", "Tag", "Attribute", "Ancestor", "Air", "Invalid"}) do
	local env = flightEnvironment()
	local p = env.player(1800)
	local id = env.enter(p)
	env.fire(p, id)
	local surface = env.Instance.new("Part")
	surface.Parent = env.workspace
	if mode == "Tag" then env.collection:AddTag(surface, "SkyIsland") end
	if mode == "Attribute" then surface:SetAttribute("IsSkyIsland", true) end
	if mode == "Ancestor" then
		local model = env.Instance.new("Model"); model.Parent = env.workspace
		env.collection:AddTag(model, "SkyIsland"); surface.Parent = model
	end
	function env.workspace:Raycast() return {Instance=surface} end
	if mode == "Air" then
		p.Character.HumanoidRootPart.AssemblyLinearVelocity = env.Vector3.new(0, 30, -100)
	else
		p.Character.HumanoidRootPart.AssemblyLinearVelocity = env.Vector3.zero
	end
	if mode == "Invalid" then
		env.collection:AddTag(surface, "SkyIsland")
		p.Character.HumanoidRootPart.Position = env.Vector3.new(1000000, 180, 0)
	end
	env.step(1); env.step(0.2)
	local result = env.rs.FlightResult.sent[1]
	if mode == "Air" then
		check(not result and p:GetAttribute("FlightState") == "Flying", "표면 근처 공중 통과는 착륙으로 확정하지 않음")
	elseif mode == "Invalid" then
		check(not result and p:GetAttribute("FlightState") == "Idle", "섬 태그가 있어도 비정상 위치 검증 유지")
	else
		local expected = mode == "Ground" and "Ground" or "SkyIsland"
		check(result and result[8].landingType == expected and p:GetAttribute("FlightState") == "Result",
			"착륙 분류 및 감속 시 InvalidPhysics 오탐 없음: " .. mode)
	end
end
print("All "..count.." regression checks passed (mock engine; Studio physics not tested).")
