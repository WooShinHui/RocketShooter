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
local GoldRings=require(script.Parent.GoldRingEvent)
local Impact=require(script.Parent.DiveImpact)
local TrophyZones=require(script.Parent.TrophyZones)
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
 Pose.Restore(run.pose);Course.Destroy(run.course);Streaming.Destroy(run.streaming);Rocket.Set(run.character,false)
 TrophyZones.Restore(run.zoneCollision)
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
 local trophyLanding=reason=="TrophyLanding" and run.trophyZone~=nil
 local trophies=reward and Rules.Trophies(trophyLanding and run.trophyZone.Reward or 0)or 0
 local record,altitudeRecord=false,false
 if reward then record,altitudeRecord=Data.Award(run.player,height,0,trophies,height) end
 if record==nil then abandon(run,"DataUnavailable");return end
 local metrics={ImpactSpeed=run.impactSpeed or 0,ImpactPosition=run.impactPosition,GoldRings=run.goldRings or 0,DiveHits=run.diveHits or 0,MaxAltitude=height,SkyScore=run.score,ChainHits=run.course.Count,PiercedEnemies=run.pierced,
  TrophyZone=run.trophyZone and run.trophyZone.Index,XPGain=run.xp,FlightTime=os.clock()-run.launchedAt,EndReason=reason,AltitudeRecord=altitudeRecord,landingType=trophyLanding and "TrophyZone"or "RocketFall"}
 cleanup(run)
 metrics.DetachedLimbs=trophyLanding and 0 or Limbs.Burst(run.character,run.root)
 if trophyLanding then
  run.root.AssemblyLinearVelocity=Vector3.zero;run.root.AssemblyAngularVelocity=Vector3.zero
  run.root.CFrame=CFrame.new(run.root.Position.X,World.GroundY()+run.trophyZone.Height+run.humanoid.HipHeight+run.root.Size.Y/2,run.root.Position.Z);run.root.Anchored=true
 end
 if reason=="Exploded" then
  local fx=Instance.new("Explosion");fx.Position=run.root.Position;fx.BlastRadius=14;fx.BlastPressure=0;fx.DestroyJointRadiusPercent=0;fx.Parent=workspace;game:GetService("Debris"):AddItem(fx,2)
 end
 state(run,"Result",reason)
 remotes.FlightResult:FireClient(run.player,height,0,trophies,record,run.id,run.character,metrics)
 if not trophyLanding then run.humanoid.BreakJointsOnDeath=false;run.humanoid.Health=0 end
 state(run,"Returning",reason)
 task.delay(trophyLanding and 1.1 or Config.ReturnDelay,function()
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
local function launch(player)
 if runs[player]or not Data.IsReady(player)or os.clock()-(cooldowns[player]or -math.huge)<1.5 then return end
 local character=player.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
 local hum=character and character:FindFirstChildOfClass("Humanoid")
 if not root or not hum or hum.Health<=0 or hum.SeatPart or root.Anchored then return end
 local localPosition=pad.CFrame:PointToObjectSpace(root.Position)
 if math.abs(localPosition.X)>pad.Size.X/2+1 or math.abs(localPosition.Z)>pad.Size.Z/2+1 or localPosition.Y<0 or localPosition.Y>4.5 then return end
 local power=(Data.GetLevel(player,"PowerLvl")or 1)+Data.GetTrainingPower(player)
 local _,vertical=Balance.LaunchComponents(power,math.sin(math.rad(65)),1)
 serial+=1;cooldowns[player]=os.clock()
 local profile=Motion.Create(vertical,workspace.Gravity)
 local run={motion=profile,player=player,character=character,root=root,humanoid=hum,id=serial,state="Flying",connections={},score=0,xp=0,pierced=0,
  peak=root.Position.Y,lastPosition=root.Position,lastSample=os.clock(),launchedAt=os.clock(),lastXP=os.clock(),axis=Vector2.zero,lastAxis=-math.huge,lastPacket=-math.huge,
  speedBudget=math.max(profile.LaunchSpeed,profile.Peak),power=power,extraScore=0,visited={serial=serial},returnFrame=pad.CFrame*CFrame.new(Config.ReturnOffset,hum.HipHeight+root.Size.Y/2+1.6,0)}
 run.pose=Pose.Create(character);runs[player]=run
 run.zoneCollision=TrophyZones.Ascend(character)
 player:SetAttribute("SkyRunSerial",run.id);player:SetAttribute("DestructionRunScore",0);player:SetAttribute("LastSkyHazard",nil)
 hum.Sit=false;hum.WalkSpeed=0;hum.AutoRotate=false;hum.PlatformStand=true;hum:ChangeState(Enum.HumanoidStateType.Physics)
 root:SetNetworkOwner(nil);root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
 local attachment=Instance.new("Attachment");attachment.Name="RocketUpright";attachment.Parent=root;run.orientAttachment=attachment
 local upright=Instance.new("AlignOrientation");upright.Mode=Enum.OrientationAlignmentMode.OneAttachment;upright.Attachment0=attachment;upright.RigidityEnabled=true;upright.CFrame=CFrame.new();upright.Parent=root;run.orientation=upright
 run.course=Course.Create(player,run.id,root.Position,root.AssemblyLinearVelocity,workspace.Gravity,power,{Profile=profile,Sample=Motion.Sample,Elapsed=0})
 run.streaming=Streaming.Create(player,root.Position,Vector3.new(0,profile.Peak,0))
 for _,body in character:GetDescendants()do
  if body:IsA("BasePart") and body.CanCollide then table.insert(run.connections,body.Touched:Connect(function(hit)
   if runs[player]==run and run.state=="Flying" and run.diving and not run.groundContact and hit.CanCollide and not hit:IsDescendantOf(character) then
    local layer,landing,point=TrophyZones.Sweep(character,root,run.lastImpactPosition,root.Position+Vector3.new(0,-math.max(1,run.diveSpeed)*.02,0))
    if layer then
     run.trophyZone=layer;run.groundContact=true;run.impactSpeed=run.diveSpeed;run.impactPosition=point;root.CFrame=root.CFrame+(landing-root.Position);return
    end
    -- Touching a deck side/underside is not a ground death.
    if TrophyZones.IsDeck(hit)then return end
    local offset=Impact.BottomOffset(character,root)
    local impact,contact=Impact.Sweep(workspace,character,root,Vector3.new(0,-math.max(1,run.diveSpeed),0),.02,run.lastImpactPosition or root.Position+Vector3.new(0,offset,0))
    run.groundContact=true;run.impactSpeed=run.diveSpeed;run.impactPosition=impact and impact.Position or body.Position
    if impact then run.trophyZone=TrophyZones.Resolve(impact.Instance,impact.Position,impact.Normal);if contact then root.CFrame=root.CFrame+(contact-root.Position)end end
   end
  end))end
 end
 table.insert(run.connections,hum.Died:Connect(function()if run.state=="Flying"then finish(run,"Death",false)end end))
 state(run,"Flying","RocketIgnition");Rocket.Set(character,true)
 run.xp+=Data.AwardFlightXP(player,1)
 remotes.FireCannon:FireClient(player,root.AssemblyLinearVelocity,run.id,character,nil,{Rocket=true,SendInterval=.05,GroundY=World.GroundY(),ExpectedHeight=profile.TargetHeight+root.Position.Y-World.GroundY(),LaunchLevel=Data.GetLevel(player,"TrainingLevel")or 0,TrophyTarget=TrophyZones.Target(profile.TargetHeight+root.Position.Y-World.GroundY())},World.GetCloudOutpostObjective())
 if run.xp>0 then remotes.FlightState:FireClient(player,"XP",run.id,character,run.xp)end
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
    character:WaitForChild("HumanoidRootPart",10);Rocket.Attach(character,player:GetAttribute("RocketStyle")or "Starter")
   end
  end
  player:GetAttributeChangedSignal("RocketStyle"):Connect(function()local c=player.Character;if c and not runs[player]then local old=c:FindFirstChild("BackRocket");if old then old:Destroy()end;Rocket.Attach(c,player:GetAttribute("RocketStyle"))end end)
  player.CharacterAdded:Connect(characterAdded)
  if player.Character then task.spawn(characterAdded,player.Character)end
 end
 Players.PlayerAdded:Connect(watch);for _,p in Players:GetPlayers()do watch(p)end
 Players.PlayerRemoving:Connect(function(p)if runs[p]then cleanup(runs[p]);runs[p]=nil end;cooldowns[p]=nil end)
 local spawn=workspace:FindFirstChild("SpawnLocation");if spawn and spawn:IsA("SpawnLocation")then spawn.Transparency=1;spawn.CanCollide=false;for _,v in spawn:GetChildren()do if v:IsA("Decal")or v:IsA("Texture")then v.Transparency=1 end end;spawn.CFrame=pad.CFrame*CFrame.new(Config.ReturnOffset,.1-spawn.Size.Y/2,0)end
 local deck=Instance.new("Part");deck.Name="RocketReturnDeck";deck.Size=Vector3.new(16,.6,18);deck.CFrame=pad.CFrame*CFrame.new(Config.ReturnOffset,-.2,0);deck.Anchored=true;deck.Material=Enum.Material.SmoothPlastic;deck.Color=Color3.fromRGB(71,91,113);deck.Parent=workspace
 GoldRings.Start(pad.Position)
 TrophyZones.Start(pad.Position,World.GroundY())
 pad.Touched:Connect(function(hit)local c=hit:FindFirstAncestorOfClass("Model");local p=c and Players:GetPlayerFromCharacter(c);if p then launch(p)end end)
 remotes.SteerFlight.OnServerEvent:Connect(function(p,axis,id)
  local run=runs[p];local accepted=Rules.Input(axis);local now=os.clock()
  if not run or run.state~="Flying"or run.id~=id or run.character~=p.Character or not accepted or now-run.lastPacket<.025 then return end
  run.axis=accepted;run.lastAxis=now;run.lastPacket=now
 end)
 remotes.ReturnToSpawn.OnServerEvent:Connect(function(p,id,action)
  local run=runs[p];if not run or run.id~=id or run.character~=p.Character or run.state~="Flying" then return end
  if action=="Explode" and run.diving then finish(run,"Exploded",true)
  elseif action=="Dive" and run.diving then run.diveBoost=true;run.speedBudget=math.max(run.speedBudget,run.motion.TargetHeight/7+200)
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
     run.diving=true;run.diveAt=age;run.diveSpeed=0;TrophyZones.Restore(run.zoneCollision);Pose.Dive(run.pose)
     remotes.FlightState:FireClient(run.player,"Dive",run.id,run.character)
    end
    local v=run.root.AssemblyLinearVelocity;local vy
    if run.diving then
     local target=math.max(run.diveSpeed or 0,run.diveBoost and 180 or 90,run.motion.TargetHeight/(run.diveBoost and 7 or 10))
     run.diveSpeed=Rules.DiveSpeed(run.diveSpeed,target,workspace.Gravity*(run.diveBoost and 1.6 or 1),age-run.diveAt,dt);vy=-run.diveSpeed
    else vy=Motion.Sample(run.motion,t+dt*.5) end
    run.root.AssemblyLinearVelocity=Vector3.new(v.X,vy+workspace.Gravity*dt*.5,v.Z)
    if run.diving then
     local velocity=Vector3.new(v.X,vy,v.Z)
     local layer,landing,point=TrophyZones.Sweep(run.character,run.root,run.lastImpactPosition,run.root.Position+velocity*math.clamp(dt,0,.1))
     if layer then
      run.root.CFrame=run.root.CFrame+(landing-run.root.Position);run.groundContact=true;run.impactSpeed=run.diveSpeed;run.impactPosition=point;run.trophyZone=layer
     else
      local hit,contact=Impact.Sweep(workspace,run.character,run.root,velocity,dt,run.lastImpactPosition)
      if hit and not TrophyZones.IsDeck(hit.Instance)then run.root.CFrame=run.root.CFrame+(contact-run.root.Position);run.groundContact=true;run.impactSpeed=run.diveSpeed;run.impactPosition=hit.Position end
     end
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
      if now-run.launchedAt>110 then finish(run,"Timeout",true);continue end
   local _,_,throttle,phase,fuel=Motion.Sample(run.motion,now-run.launchedAt);Rocket.Pulse(run.character,throttle,run.diving and "Diving"or phase,fuel)
   Course.Update(run.course,position,velocity,now-run.launchedAt,run.diving)
   local cumulative=run.score
   local score=Course.Sample(run.course,run.lastPosition,position,function(data)
    cumulative+=data.Award;data.RunScore=cumulative
    local ready=math.max(now,run.fxReadyAt or now);run.fxReadyAt=ready+.06
    task.delay(ready-now,function()if runs[run.player]==run and run.state=="Flying"and run.player.Character==run.character then RS.BarrierDestroyed:FireClient(run.player,data)end end)
   end)
   run.score+=score
   if run.diving then run.diveHits=(run.diveHits or 0)+score/run.course.Tier.Score end
   local gx,gs,gr=GoldRings.Collect(run.player,run.lastPosition,position);run.xp+=gx;run.score+=gs;run.goldRings=(run.goldRings or 0)+gr
   local bonus=World.CollectSky(run.player,run.lastPosition,position,run.visited)
   if run.power<5 then bonus=math.min(bonus,math.max(0,20-run.extraScore));run.extraScore+=bonus end
   run.score+=bonus;run.player:SetAttribute("DestructionRunScore",run.score)
   local hit,enemy=World.HazardHit(run.lastPosition,position)
   if hit and now-run.launchedAt>1 then
    if enemy and velocity.Magnitude>=360 then run.score+=World.BreakSkyEnemy(run.player,enemy,run.visited);run.pierced+=1
    elseif not run.diving then
     run.motion.Burn=now-run.launchedAt;run.player:SetAttribute("LastSkyHazard",hit)
    end
   end
   if run.groundContact then finish(run,run.trophyZone and "TrophyLanding"or "DiveLanding",true);continue end
   if now-run.lastXP>=Config.FlightXPInterval then
    run.lastXP=now;local xp=Data.AwardFlightXP(run.player,1);run.xp+=xp
    remotes.FlightState:FireClient(run.player,"XP",run.id,run.character,xp)
   end
   local axis=if now-run.lastAxis<.3 then run.axis else Vector2.zero
   local horizontal=Vector3.new(velocity.X,0,velocity.Z);local target=Vector3.new(axis.X,0,axis.Y)*(run.diving and 110 or Config.SteerSpeed)
   local delta=Rules.Step(horizontal,target,Config.SteerAcceleration,sampleDt)
   run.root:ApplyImpulse(delta*run.root.AssemblyMass);run.speedBudget+=delta.Magnitude
   Streaming.Update(run.streaming,position,velocity,nil)
   run.lastPosition=position;run.lastSample=now
  end
 end)
 print("[Rocket] Accelerating ascent, steerable dive, optional explosion return")
end
return Service
