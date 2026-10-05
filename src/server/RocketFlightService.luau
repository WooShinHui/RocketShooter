local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local Data=require(script.Parent.PlayerData)
local World=require(script.Parent.WorldService)
local Balance=require(RS:WaitForChild("BalanceConfig"))
local Config=require(RS:WaitForChild("RocketModeConfig"))
local Motion=require(RS:WaitForChild("RocketMotion"))
local Rules=require(script.Parent.RocketRules)
local Rocket=require(script.Parent.BackRocket)
local Course=require(script.Parent.BreakCourse)
local DiveZone=require(script.Parent.DiveBreakZone)
local GoldRings=require(script.Parent.GoldRingEvent)
local Impact=require(script.Parent.DiveImpact)
local Rewards=require(RS:WaitForChild("DestructionRewardConfig"))
local Requirements=require(RS:WaitForChild("GateRequirements"))
local GateRules=require(RS:WaitForChild("CloudGateRules"))
local Gates=require(RS:WaitForChild("CloudConfig")).HeightPresentation.Gates
local Pose=require(script.Parent.RocketPose)
local Streaming=require(script.Parent.FlightStreaming)
local Limbs=require(script.Parent.LimbLanding)
local Service={}
local runs,cooldowns={},{}
local serial=0
local pad,remotes
local function finite(v) return v==v and math.abs(v)<math.huge end
local function validVector(v) return finite(v.X)and finite(v.Y)and finite(v.Z)end
local function state(run,value,reason)
 run.state=value;run.player:SetAttribute("FlightState",value)
 remotes.FlightState:FireClient(run.player,value,run.id,run.character,reason)
end
local function cleanup(run)
 if run.cleaned then return end;run.cleaned=true
 run.player:SetAttribute("CloudGateIndex",nil);run.player:SetAttribute("CloudGatePressure",nil)
 Pose.Restore(run.pose);Course.Destroy(run.course);Streaming.Destroy(run.streaming);Rocket.Set(run.character,false)
 if run.orientation then run.orientation:Destroy();run.orientAttachment:Destroy()end
 for _,c in run.connections do c:Disconnect()end
end
local function abandon(run,reason)
 if runs[run.player]~=run then return end
 cleanup(run);runs[run.player]=nil
 run.player:SetAttribute("FlightState","Idle")
 remotes.FlightState:FireClient(run.player,"Cancelled",run.id,run.character,reason)
end
local function finish(run,reason,reward)
 if runs[run.player]~=run or run.state~="Flying"then return end
 local height=math.max(0,math.floor(run.peak-World.GroundY()))
 local trophies=reward and (run.trophies or 0)or 0
 local record,altitudeRecord=false,false
 if reward then record,altitudeRecord=Data.Award(run.player,height,0,math.min(trophies,2^53-1-(Data.GetLevel(run.player,"Trophies")or 0)),height) end
 if record==nil then abandon(run,"DataUnavailable");return end
 local metrics={ImpactSpeed=run.impactSpeed or 0,ImpactPosition=run.impactPosition,GoldRings=run.goldRings or 0,DiveHits=run.diveHits or 0,MaxAltitude=height,SkyScore=run.score,ChainHits=run.course.Count,PiercedEnemies=run.pierced,
  DestroyedObjects=run.destroyed or 0,DestructionTrophies=trophies,DiveZoneHits=run.diveZone.Hits,DiveZoneBonusHits=run.diveZone.BonusHits,DiveRingHits=run.diveZone.RingHits,DiveEnemyHits=run.diveZone.EnemyHits,XPGain=run.xp,FlightTime=os.clock()-run.launchedAt,EndReason=reason,AltitudeRecord=altitudeRecord,landingType="RocketFall"}
 cleanup(run)
 metrics.DetachedLimbs=Limbs.Burst(run.character,run.root)
 if reason=="Exploded" then
  local fx=Instance.new("Explosion");fx.Position=run.root.Position;fx.BlastRadius=14;fx.BlastPressure=0;fx.DestroyJointRadiusPercent=0;fx.Parent=workspace;game:GetService("Debris"):AddItem(fx,2)
 end
 state(run,"Result",reason)
 remotes.FlightResult:FireClient(run.player,height,0,trophies,record,run.id,run.character,metrics)
 run.humanoid.BreakJointsOnDeath=false;run.humanoid.Health=0
 state(run,"Returning",reason)
 task.delay(Config.ReturnDelay,function()
  if runs[run.player]~=run or run.player.Parent~=Players then return end
  if run.player.Character~=run.character then abandon(run,"CharacterReplaced");return end
  local ok=pcall(function()run.player:LoadCharacterAsync()end)
  if not ok then abandon(run,"RespawnFailed");return end
  local character=run.player.Character;local root=character and character:WaitForChild("HumanoidRootPart",10)
  if runs[run.player]~=run or not root then return end
  root.CFrame=run.returnFrame;root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
  runs[run.player]=nil;run.player:SetAttribute("FlightState","Idle")
  remotes.FlightState:FireClient(run.player,"Idle",run.id,character)
 end)
end
local function destroyed(run,position,units)
 local gain=Rewards.Reward(units or 1,math.max(0,position.Y-World.GroundY()))
 -- Flight rewards remain unbanked until safe return. Existing balance is never debited.
 run.destroyed+=1;run.trophies=math.min(40000000,run.trophies+gain)
 run.player:SetAttribute("DestroyedObjects",run.destroyed);run.player:SetAttribute("DestructionRunTrophies",run.trophies)
end
local function recommendations(player,originY)
 local growth=require(RS.ProgressionConfig);local rebirths=Data.GetLevel(player,"Rebirths")or 0
 local base=Data.GetLevel(player,"PowerLvl")or 1;local starter=Balance.VerticalPower(1)*math.sin(math.rad(65));local levels,powers={},{}
 local function profile(raw)
  local v=Data.LaunchVertical(player,Balance.VerticalPower(raw)*math.sin(math.rad(65)),starter)
  return Motion.CreateRocket(v,workspace.Gravity)
 end
 for i,gate in Gates do
  local required=Requirements.Power(gate,originY,profile,Motion.Sample);powers[i]=required
  local lo,hi=0,math.max(20,gate.Level)
  while base+growth.PowerBonus(hi,rebirths)<required do hi*=2 end
  while hi-lo>1 do local mid=math.floor((lo+hi)/2);if base+growth.PowerBonus(mid,rebirths)>=required then hi=mid else lo=mid end end
  levels[i]=base>=required and 0 or hi
 end
 return levels,powers
end
local function launch(player)
 if runs[player]or not Data.IsReady(player)or os.clock()-(cooldowns[player]or -math.huge)<1.5 then return end
 local character=player.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
 local hum=character and character:FindFirstChildOfClass("Humanoid")
 if not root or not hum or hum.Health<=0 or hum.SeatPart or root.Anchored then return end
 local localPosition=pad.CFrame:PointToObjectSpace(root.Position)
 if math.abs(localPosition.X)>pad.Size.X/2+1 or math.abs(localPosition.Z)>pad.Size.Z/2+1 or localPosition.Y<0 or localPosition.Y>4.5 then return end
 local power=(Data.GetLevel(player,"PowerLvl")or 1)+Data.GetTrainingPower(player)
 local starter=Balance.VerticalPower(1)*math.sin(math.rad(65))
 local vertical=Data.LaunchVertical(player,Balance.VerticalPower(power)*math.sin(math.rad(65)),starter)
 serial+=1;cooldowns[player]=os.clock()
 local profile=Motion.CreateRocket(vertical,workspace.Gravity)
 local run={motion=profile,player=player,character=character,root=root,humanoid=hum,id=serial,state="Flying",connections={},score=0,xp=0,pierced=0,trophies=0,destroyed=0,
  gate={},peak=root.Position.Y,lastPosition=root.Position,lastSample=os.clock(),launchedAt=os.clock(),lastXP=os.clock(),axis=Vector2.zero,lastAxis=-math.huge,lastPacket=-math.huge,
  speedBudget=math.max(profile.LaunchSpeed,profile.Peak),power=power,extraScore=0,visited={serial=serial},returnFrame=pad.CFrame*CFrame.new(Config.ReturnOffset,hum.HipHeight+root.Size.Y/2+1.6,0)}
 run.pose=Pose.Create(character);runs[player]=run
 player:SetAttribute("FlightAborted",false);player:SetAttribute("CloudGateOutcome",nil)
 player:SetAttribute("SkyRunSerial",run.id);player:SetAttribute("DestructionRunScore",0);player:SetAttribute("DestructionRunTrophies",0);player:SetAttribute("DestroyedObjects",0);player:SetAttribute("LastSkyHazard",nil)
 hum.Sit=false;hum.WalkSpeed=0;hum.AutoRotate=false;hum.PlatformStand=true;hum:ChangeState(Enum.HumanoidStateType.Physics)
 root:SetNetworkOwner(nil);root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
 local attachment=Instance.new("Attachment");attachment.Name="RocketUpright";attachment.Parent=root;run.orientAttachment=attachment
 local upright=Instance.new("AlignOrientation");upright.Mode=Enum.OrientationAlignmentMode.OneAttachment;upright.Attachment0=attachment;upright.RigidityEnabled=true;upright.CFrame=CFrame.new();upright.Parent=root;run.orientation=upright
 run.course=Course.Create(player,run.id,root.Position,root.AssemblyLinearVelocity,workspace.Gravity,power,{Profile=profile,Sample=Motion.Sample,Elapsed=0})
 run.diveZone=DiveZone.Create(player,run.id,run.course.Folder,run.course.Tier.Score,World.GroundY())
 run.streaming=Streaming.Create(player,root.Position,Vector3.new(0,profile.Peak,0))
 for _,body in character:GetDescendants()do
  if body:IsA("BasePart") and body.CanCollide then table.insert(run.connections,body.Touched:Connect(function(hit)
   if runs[player]==run and run.state=="Flying" and run.diving and not run.groundContact and hit.CanCollide and not hit:IsDescendantOf(character) then
    local offset=Impact.BottomOffset(character,root)
    local impact,contact=Impact.Sweep(workspace,character,root,Vector3.new(0,-math.max(1,run.diveSpeed),0),.02,run.lastImpactPosition or root.Position+Vector3.new(0,offset,0))
    run.groundContact=true;run.impactSpeed=run.diveSpeed;run.impactPosition=impact and impact.Position or body.Position
    if impact then if contact then root.CFrame=root.CFrame+(contact-root.Position)end end
   end
  end))end
 end
 table.insert(run.connections,hum.Died:Connect(function()if run.state=="Flying"then finish(run,"Death",false)end end))
 state(run,"Flying","RocketIgnition");Rocket.Set(character,true)
 local gateLevels,gatePowers=recommendations(player,root.Position.Y)
 run.xp+=Data.AwardFlightXP(player,1)
 remotes.FireCannon:FireClient(player,root.AssemblyLinearVelocity,run.id,character,nil,{Rocket=true,SendInterval=.05,GroundY=World.GroundY(),ExpectedHeight=profile.TargetHeight+root.Position.Y-World.GroundY(),LaunchLevel=Data.GetLevel(player,"TrainingLevel")or 0,GateLevels=gateLevels,GatePowers=gatePowers,LaunchPower=power},World.GetCloudOutpostObjective())
 if run.xp>0 then remotes.FlightState:FireClient(player,"XP",run.id,character,run.xp)end
end
local function beginDive(run,reason)
 if run.diving then return true end
 local height=run.root.Position.Y-World.GroundY()
 for index,gate in Gates do
  if index>(run.gate.Passed or 0)and height>=gate.Bottom and height<gate.Top then
   run.player:SetAttribute("CloudGateOutcome","Caught");finish(run,"BrainrotCaught",false);return false
  end
 end
 run.diving=true;run.diveAt=os.clock();run.diveSpeed=0;Pose.Dive(run.pose)
 if reason=="Aborted"then run.aborted=true;run.player:SetAttribute("FlightAborted",true)end
 remotes.FlightState:FireClient(run.player,"Dive",run.id,run.character,reason)
 return true
end
function Service.Start(cannon)
 remotes=require(script.Parent.Remotes).Ensure()
 World.Start(cannon,function()end)
 local origin=cannon:GetPivot().Position
 pad=Instance.new("Part");pad.Name="RocketLaunchPad";pad.Size=Vector3.new(18,1,18)
 pad.Position=Vector3.new(origin.X,World.GroundY()+6,origin.Z+18);pad.Anchored=true;pad.Material=Enum.Material.Neon;pad.Color=Color3.fromRGB(255,147,52);pad.Parent=workspace
 local g=Instance.new("BillboardGui");g.Name="RocketPadHint";g.Size=UDim2.fromOffset(340,85);g.StudsOffset=Vector3.new(0,7,0);g.AlwaysOnTop=true;g.MaxDistance=150;g.Parent=pad
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBlack;text.TextSize=25;text.TextWrapped=true;text.TextColor3=Color3.new(1,1,1);text.TextStrokeTransparency=0
 -- Tutorial (deferred): text.Text="🚀 밟으면 자동 상승!\n비행 중 자유롭게 이동하세요"
 g.Enabled=false;text.Text="";text.Parent=g
 for _,p in cannon:GetDescendants()do if p:IsA("ProximityPrompt")then p.Enabled=false end end
 cannon.Parent=game:GetService("ServerStorage")
 local function watch(player)
  local function characterAdded(character)
   local old=runs[player];if old and old.state=="Flying"then abandon(old,"CharacterReplaced")end
   local torso=character:WaitForChild("Humanoid",10);if torso and player.Character==character then
    character:WaitForChild("HumanoidRootPart",10);Rocket.Attach(character,player:GetAttribute("RocketStyle")or "Starter",player:GetAttribute("RocketTrail")or "None")
   end
  end
  local function refreshEquipment()local c=player.Character;if c and not runs[player]then local old=c:FindFirstChild("BackRocket");if old then old:Destroy()end;Rocket.Attach(c,player:GetAttribute("RocketStyle"),player:GetAttribute("RocketTrail"))end end
  player:GetAttributeChangedSignal("RocketStyle"):Connect(refreshEquipment)
  player:GetAttributeChangedSignal("RocketTrail"):Connect(refreshEquipment)
  player.CharacterAdded:Connect(characterAdded)
  if player.Character then task.spawn(characterAdded,player.Character)end
 end
 Players.PlayerAdded:Connect(watch);for _,p in Players:GetPlayers()do watch(p)end
 Players.PlayerRemoving:Connect(function(p)if runs[p]then cleanup(runs[p]);runs[p]=nil end;cooldowns[p]=nil end)
 local spawn=workspace:FindFirstChild("SpawnLocation");if spawn and spawn:IsA("SpawnLocation")then spawn.Transparency=1;spawn.CanCollide=false;for _,v in spawn:GetChildren()do if v:IsA("Decal")or v:IsA("Texture")then v.Transparency=1 end end;spawn.CFrame=pad.CFrame*CFrame.new(Config.ReturnOffset,.1-spawn.Size.Y/2,0)end
 local deck=Instance.new("Part");deck.Name="RocketReturnDeck";deck.Size=Vector3.new(16,.6,18);deck.CFrame=pad.CFrame*CFrame.new(Config.ReturnOffset,-.2,0);deck.Anchored=true;deck.Material=Enum.Material.SmoothPlastic;deck.Color=Color3.fromRGB(71,91,113);deck.Parent=workspace
 GoldRings.Start(pad.Position)
 -- Remove only the generated obsolete landing container.
 local obsolete=workspace:FindFirstChild("RocketTrophyZones");if obsolete then obsolete:Destroy()end
 pad.Touched:Connect(function(hit)local c=hit:FindFirstAncestorOfClass("Model");local p=c and Players:GetPlayerFromCharacter(c);if p then launch(p)end end)
 remotes.SteerFlight.OnServerEvent:Connect(function(p,axis,id,cameraRight)
  local run=runs[p];local accepted=Rules.Input(axis);local now=os.clock()
  if not run or run.state~="Flying"or run.id~=id or run.character~=p.Character or not accepted or now-run.lastPacket<.025 then return end
  run.axis=accepted;run.lastAxis=now;run.lastPacket=now
  local basis=Rules.Input(cameraRight)
  if basis and basis.Magnitude>.8 then run.cameraRight=Vector3.new(basis.X,0,basis.Y).Unit end
 end)
 remotes.ReturnToSpawn.OnServerEvent:Connect(function(p,id,action)
  local run=runs[p];if not run or run.id~=id or run.character~=p.Character or run.state~="Flying" then return end
  if action=="Abort" and not run.diving then beginDive(run,"Aborted")
  elseif action=="Explode" and run.diving then finish(run,"Exploded",true)
  elseif action=="Dive" and run.diving then run.diveBoost=true;run.speedBudget=math.max(run.speedBudget,Config.DiveBoostMaxSpeed+200)
  elseif action=="DiveStop" and run.diving then run.diveBoost=false
  elseif action==nil then finish(run,"Cancelled",false) end
 end)
 local accumulator=0
 RunService.Heartbeat:Connect(function(dt)
  local age=os.clock()
  for _,run in runs do if run.state=="Flying"then
   local t=age-run.launchedAt
   if run.root.Parent and not run.groundContact then
    if t>=run.motion.Burn and not run.diving then
     if not beginDive(run,"FuelEmpty")then continue end
    end
    local v=run.root.AssemblyLinearVelocity;local vy
    if run.diving then
     local target=Rules.DiveTarget(run.motion.TargetHeight,run.diveBoost,run.diveSpeed,Config.DiveMaxSpeed,Config.DiveBoostMaxSpeed)
     local aim=age-run.lastAxis<.3 and run.axis.Magnitude>.15
     run.diveSpeed,target=Rules.DiveAim(run.diveSpeed,target,aim,run.diveBoost,Config.DiveAimSpeed,Config.DiveAimDeceleration,dt)
     run.diveSpeed=Rules.DiveSpeed(run.diveSpeed,target,workspace.Gravity*(run.diveBoost and 1.6 or 1),age-run.diveAt,dt);vy=-run.diveSpeed
    else vy=Motion.Sample(run.motion,t+dt*.5) end
    run.root.AssemblyLinearVelocity=Vector3.new(v.X,vy+workspace.Gravity*dt*.5,v.Z)
    if run.diving then
     local velocity=Vector3.new(v.X,vy,v.Z)
     local hit,contact=Impact.Sweep(workspace,run.character,run.root,velocity,dt,run.lastImpactPosition)
     if hit then run.root.CFrame=run.root.CFrame+(contact-run.root.Position);run.groundContact=true;run.impactSpeed=run.diveSpeed;run.impactPosition=hit.Position end
    end
    run.lastImpactPosition=run.root.Position
    local axis=if age-run.lastAxis<.3 then run.axis else Vector2.zero
    local angle=math.rad(run.diving and 18 or 24)
    local goal=CFrame.Angles((run.diving and math.pi or 0)+axis.Y*angle,0,-axis.X*angle)
    run.orientation.CFrame=run.orientation.CFrame:Lerp(goal,1-math.exp(-dt*8))
   end
  end end
  accumulator+=dt;if accumulator<.05 then return end;accumulator=0;local now=os.clock()
  for _,p in Players:GetPlayers()do if not runs[p]then launch(p)end end
  for _,run in runs do
   if run.state~="Flying"then continue end
   if not Data.IsReady(run.player)or run.character~=run.player.Character or not run.root.Parent then abandon(run,"InvalidCharacter");continue end
   local position,velocity=run.root.Position,run.root.AssemblyLinearVelocity;local sampleDt=now-run.lastSample
   run.speedBudget+=workspace.Gravity*sampleDt
   if not validVector(position)or not validVector(velocity)or velocity.Magnitude>run.speedBudget+100 or (position-run.lastPosition).Magnitude>run.speedBudget*math.max(sampleDt,.1)+32 then finish(run,"InvalidPhysics",false);continue end
   run.peak=math.max(run.peak,position.Y)
   local outcome,index=GateRules.Step(run.gate,Gates,run.lastPosition.Y-World.GroundY(),position.Y-World.GroundY(),sampleDt,run.diving,velocity.Y)
   run.player:SetAttribute("CloudGateIndex",run.gate.Active)
   run.player:SetAttribute("CloudGatePressure",run.gate.Active and math.clamp(math.max(run.gate.Age/Gates[run.gate.Active].Grace,(run.gate.Slow or 0)/.25),0,1)or 0)
   if outcome then run.player:SetAttribute("CloudGateOutcome",outcome)end
   if outcome=="Caught"then finish(run,"BrainrotCaught",false);continue end
      if now-run.launchedAt>Rules.FlightTimeout(run.motion.TargetHeight,run.motion.Burn,Config.DiveMaxSpeed) then finish(run,"Timeout",true);continue end
   local _,_,throttle,phase,fuel=Motion.Sample(run.motion,now-run.launchedAt);Rocket.Pulse(run.character,throttle,run.diving and "Diving"or phase,fuel)
   Course.Update(run.course,position,velocity,now-run.launchedAt,run.diving)
   DiveZone.Update(run.diveZone,position,velocity,run.diving,run.cameraRight)
   local cumulative=run.score
   local score=Course.Sample(run.course,run.lastPosition,position,function(data)
    destroyed(run,data.Position);cumulative+=data.Award;data.RunScore=cumulative
    local ready=math.max(now,run.fxReadyAt or now);run.fxReadyAt=ready+.06
    task.delay(ready-now,function()if runs[run.player]==run and run.state=="Flying"and run.player.Character==run.character then RS.BarrierDestroyed:FireClient(run.player,data)end end)
   end)
   run.score+=score
   if run.diving then run.diveHits=(run.diveHits or 0)+score/run.course.Tier.Score end
   local zoneCumulative=run.score
   local zoneScore,zoneHits=DiveZone.Sample(run.diveZone,run.lastPosition,position,run.diving,Course.Touches,function(data)
    destroyed(run,data.RewardPosition or data.Position,data.RewardUnits);zoneCumulative+=data.Award;data.RunScore=zoneCumulative
    RS.BarrierDestroyed:FireClient(run.player,data)
   end)
   run.score+=zoneScore;run.diveHits=(run.diveHits or 0)+zoneHits
   local gx,gs,gr=GoldRings.Collect(run.player,run.lastPosition,position);run.xp+=gx;run.score+=gs;run.goldRings=(run.goldRings or 0)+gr
   local bonus=World.CollectSky(run.player,run.lastPosition,position,run.visited,function(point)destroyed(run,point)end)
   if run.power<5 then bonus=math.min(bonus,math.max(0,20-run.extraScore));run.extraScore+=bonus end
   run.score+=bonus;run.player:SetAttribute("DestructionRunScore",run.score)
   local hit,enemy=World.HazardHit(run.lastPosition,position)
   if hit and now-run.launchedAt>1 then
    if enemy and velocity.Magnitude>=360 then local enemyScore=World.BreakSkyEnemy(run.player,enemy,run.visited);if enemyScore>0 then run.score+=enemyScore;run.pierced+=1;destroyed(run,enemy.PrimaryPart.Position)end
    elseif not run.diving then
     run.motion.Burn=now-run.launchedAt;run.player:SetAttribute("LastSkyHazard",hit)
    end
   end
   if run.groundContact then finish(run,"DiveLanding",true);continue end
   if now-run.lastXP>=Config.FlightXPInterval then
    run.lastXP=now;local xp=Data.AwardFlightXP(run.player,1);run.xp+=xp
    remotes.FlightState:FireClient(run.player,"XP",run.id,run.character,xp)
   end
   local axis=if now-run.lastAxis<.3 then run.axis else Vector2.zero
   local speed,acceleration=Config.SteerSpeed,Config.SteerAcceleration
   if run.diving then speed,acceleration=Rules.DiveSteering(run.diveSpeed,Config.DiveSteerMinSpeed,Config.DiveSteerMaxSpeed,Config.DiveSteerRatio,Config.DiveSteerAcceleration)end
   local horizontal=Vector3.new(velocity.X,0,velocity.Z);local target=Vector3.new(axis.X,0,axis.Y)*speed
   local delta=Rules.Step(horizontal,target,acceleration,sampleDt)
   run.root:ApplyImpulse(delta*run.root.AssemblyMass);run.speedBudget+=delta.Magnitude
   Streaming.Update(run.streaming,position,velocity,nil)
   run.lastPosition=position;run.lastSample=now
  end
 end)
 print("[Rocket] Accelerating ascent, steerable dive, optional explosion return")
end
return Service
