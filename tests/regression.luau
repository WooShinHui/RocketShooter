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
	local env = {warnings = {}, time = 10, queued = {}, writes = 0, reads = 0, opens = 0, studio = false}
	local vec = {}
	local vector = {__type = "Vector3"}
	function vec.new(x, y, z) return setmetatable({X=x or 0, Y=y or 0, Z=z or 0}, vector) end
	vector.__add = function(a,b) return vec.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
	vector.__sub = function(a,b) return vec.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
	vector.__mul = function(a,b) return vec.new(a.X*b,a.Y*b,a.Z*b) end
	vector.__div = function(a,b) return vec.new(a.X/b,a.Y/b,a.Z/b) end
	vector.__index = function(a,key)
		if key == "Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end
		if key == "Unit" then return a/a.Magnitude end
	end
	vec.zero = vec.new()
	env.Vector3 = vec
	local cf = {}
	local cfMeta = {}
	function cf.new(x,y,z)
		return setmetatable({Position=type(x)=="table" and x or vec.new(x,y,z), LookVector=vec.new(0,0,-1)},cfMeta)
	end
	cf.Angles = function() return cf.new() end
	cf.lookAt = function() return cf.new() end
	cfMeta.__mul = function(a,b) return cf.new(a.Position+b.Position) end
	cfMeta.__add = function(a,b) return cf.new(a.Position+b) end
	cfMeta.__index = {PointToObjectSpace=function(a,p) return p-a.Position end}
	env.CFrame=cf
	env.Enum={HumanoidStateType={GettingUp="GettingUp",Physics="Physics"}, Material={Air="Air",Grass="Grass"}, RaycastFilterType={Exclude="Exclude"},
		MouseBehavior={Default="Default",LockCenter="LockCenter"},CameraType={Custom="Custom",Scriptable="Scriptable"},
		UserInputType={MouseButton1="MouseButton1"},OrientationAlignmentMode={OneAttachment="OneAttachment"}}
	env.Color3={fromRGB=function(...) return {...} end}
	env.ColorSequence={new=function(...) return {...} end}
	env.NumberSequence=env.ColorSequence; env.UDim2=env.ColorSequence
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
			obj.Size=vec.new(2,2,2); obj.CFrame=cf.new(); obj.Transparency=0; obj.CanCollide=true
			obj.Anchored=false; obj.AssemblyLinearVelocity=vec.zero; obj.AssemblyAngularVelocity=vec.zero
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
	function methods:SetNetworkOwner(player) assert(not self.Anchored); self.owner=player end
	function methods:SetNetworkOwnershipAuto() self.owner=nil end
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
	env.workspace=instance("Workspace"); env.workspace.Gravity=196.2
	env.workspace.CurrentCamera=instance("Camera")
	function env.workspace:Raycast() return nil end
	env.players=instance("Players"); env.players.PlayerAdded=event(); env.players.PlayerRemoving=event()
	function env.players:GetPlayers() return self:GetChildren() end
	function env.players:GetPlayerFromCharacter(char) for _,p in ipairs(self:GetChildren()) do if p.Character==char then return p end end end
	env.rs=instance("ReplicatedStorage")
	for _,name in ipairs({"AimCannon","FireCannon","FlightResult","ReturnToSpawn","FlightState"}) do local r=instance("RemoteEvent"); r.Name=name; r.Parent=env.rs end
	env.heartbeat=event()
	env.render=event()
	env.input={InputBegan=event(),GetMouseDelta=function() return {X=0,Y=0} end}
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
	local services={Players=env.players,ReplicatedStorage=env.rs,UserInputService=env.input,
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
		local p=instance("Player"); p.UserId=id; p.Character=env.character(); p.Parent=env.players; return p
	end
	function env.step(seconds)
		env.time+=seconds; env.heartbeat:Fire(seconds)
	end
	return env
end

check(Policy.validAim(-30,45) and not Policy.validAim(31,0) and not Policy.validAim("0",0),"aim limits and types")
check(not Policy.validAim(0/0,0) and not Policy.validAim(math.huge,0),"non-finite aim rejected")
check(Policy.validMultiplier(0.7) and Policy.validMultiplier(1) and Policy.validMultiplier(1.5),"existing timing UX values")
check(not Policy.validMultiplier(2) and not Policy.validMultiplier(0/0) and not Policy.validMultiplier("1"),"invalid multiplier rejected")
local d,g,t=Policy.reward(601.9,1)
check(d==601 and g==901 and t==7,"original distance reward formula")

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
	check(data.Buy(p,"Gold") and p.leaderstats.Gold.Value==882 and p.leaderstats.PowerLvl.Value==3,"server upgrade price retained")
	check(not data.Buy(p,"Gold"),"purchase rate limited")
	check(data.Award(p,400,600,1)==true and data.Award(p,300,0,0)==false,"reward and record update")
	check(data.Save(p) and env.saved.LegacyExtra=="keep" and env.saved.Gold==1482,"save preserves unknown fields")
	env.saved.Gold=9999
	check(not data.Save(p) and env.saved.Gold==9999 and not data.IsReady(p),"conflicting session cannot be overwritten")
end
do
	local env=environment(); local data=newPlayerData(env); data.Start(); local p=env.player(5); env.players.PlayerAdded:Fire(p)
	check(data.IsReady(p) and p.leaderstats.PowerLvl.Value==1,"successful absent key gets defaults")
	env.saveFail=true
	check(not data.Save(p) and env.writes==3,"save failure retries and reports failure")
end

local function flightEnvironment()
	local env=environment()
	local data={IsReady=function() return true end,GetLevel=function() return 1 end}
	env.awards={}
	function data.Award(p,d,g,t) table.insert(env.awards,{p,d,g,t}); return true end
	local model=env.Instance.new("Model"); model.Name="Canon"; model.Parent=env.workspace
	local cylinder=env.Instance.new("Part"); cylinder.Name="Cylinder"; cylinder.Parent=model
	local launch=env.Instance.new("Part"); launch.Name="LaunchPoint"; launch.Parent=model
	local prompt=env.Instance.new("ProximityPrompt"); prompt.Parent=launch
	env.model,env.launch,env.prompt=model,launch,prompt
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
	check(a.Character.HumanoidRootPart.owner==a and not a.Character.HumanoidRootPart.Anchored,"ownership assigned after unanchor")
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
	local bar=child(gauge,"Frame","BgBar"); child(bar,"Frame","Pointer"); child(bar,"TextLabel","StatusLabel")
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
	check(#env.rs.FireCannon.requests==0 and gauge.Enabled,"cancelled delayed click cannot fire or hide newer gauge")
	env.rs.FlightState.OnClientEvent:Fire("Cancelled",1,char)
	check(env.render:Count()==1,"old cancellation cannot clean new aiming run")
	local saved={walkSpeed=23,useJumpPower=true,jumpPower=61,jumpHeight=9,autoRotate=true,platformStand=false}
	env.rs.FireCannon.OnClientEvent:Fire(env.Vector3.new(0,10,-250),2,char,saved)
	env.time+=7
	check(char.Humanoid.PlatformStand and env.render:Count()==0,"client physics persists past six seconds until server end")
	check(char.HumanoidRootPart.FlyOrientation.Mode=="OneAttachment","flight orientation uses one attachment")
	env.rs.FlightResult.OnClientEvent:Fire(10,15,0,false,1,char)
	check(not results.Enabled,"client rejects old result")
	env.rs.FlightResult.OnClientEvent:Fire(300,450,1,true,2,char)
	check(results.Enabled and not char.Humanoid.PlatformStand and char.Humanoid.WalkSpeed==23
		and char.HumanoidRootPart:FindFirstChild("FlyTrail")==nil,"server result restores client physics and removes effects")
	button.Activated:Fire()
	check(results.Enabled and #env.rs.ReturnToSpawn.requests==1,"return UI waits for server acknowledgement")
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
	local env=environment(); env.rs.FlightState:Destroy()
	local original={env.rs.AimCannon,env.rs.FireCannon,env.rs.FlightResult,env.rs.ReturnToSpawn}
	local registry=newRemotes(env); local first=registry.Ensure(); local second=registry.Ensure()
	check(#env.rs:GetChildren()==7 and first.BuyUpgrade:IsA("RemoteFunction") and first.FlightState:IsA("RemoteEvent"),"server creates all missing remotes from original Studio inventory")
	check(first.AimCannon==original[1] and first.FireCannon==original[2] and first.FlightResult==original[3]
		and first.ReturnToSpawn==original[4] and first.BuyUpgrade==second.BuyUpgrade,"repeated bootstrap preserves original remotes without duplication")
	check(first.ResetData.OnServerInvoke()==false,"legacy reset remains inert")
	check(newRemoteClient(env).Wait(15).BuyUpgrade==first.BuyUpgrade,"client resolves complete typed remote inventory")
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
print("All "..count.." regression checks passed (mock engine; Studio physics not tested).")
