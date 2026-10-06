// Usage: node tests/run-local.cjs <luau.exe> [scratch-output-directory]
// Real production modules; Roblox APIs are mocked. Not a physics/Studio test.
const fs = require('node:fs'), path = require('node:path'), cp = require('node:child_process');
const root = path.resolve(__dirname, '..');
const out = path.resolve(process.argv[3] || path.join(root, 'tests/.generated'));
fs.mkdirSync(out, {recursive: true});
const source = (name, area='server') => fs.readFileSync(path.join(root,'src',area,name+'.luau'),'utf8');
const literal = (name, text) => 'local '+name+' = (function()\n'+text+'\nend)()\n';
const moduleWrap = (name, deps='{}', area='server', extra='') =>
 'local function new'+name+'(env, deps)\n'+
 (['PlayerData','SkyController','BreakCourse','SkyLife','DiveBreakZone'].includes(name)?'for key,value in {EquipmentPower=Equipment,CloudGateRules=GateRules,CourseVisualConfig=CourseVisual,DestructionRewardConfig=DestructionRewards,GateEncounterConfig=Encounters,CloudConfig=CloudConfig} do if env.rs and not env.rs:FindFirstChild(key) then local m=env.Instance.new(\"ModuleScript\");m.Name=key;m.__module=value;m.Parent=env.rs end end\n':'')+
 'local game, Instance, task, os, workspace = env.game, env.Instance, env.task, env.os, env.workspace\n'+
 'local Vector3, CFrame, Enum, RaycastParams, typeof = env.Vector3, env.CFrame, env.Enum, env.RaycastParams, env.typeof\n'+
 'local Color3, ColorSequence, NumberSequence, UDim2 = env.Color3, env.ColorSequence, env.NumberSequence, env.UDim2\nlocal TweenInfo = env.TweenInfo\n'+
 'local script={Parent=deps or '+deps+'}\nlocal require=function(v) return v.__module or v end\n'+
 'local warn=function(...) table.insert(env.warnings,{...}) end\n'+extra+source(name,area)+'\nend\n';
let bundle = literal('BoostConfig',source('PowerBoostConfig','shared')) + literal('ShowroomConfig','local Color3={fromRGB=function(...)return {...}end}\n'+source('ShowroomConfig','shared')) + literal('Encounters',source('GateEncounterConfig','shared')) + literal('Equipment',source('EquipmentPower','shared')) + literal('GateRules',source('CloudGateRules','shared')) + literal('CourseVisual','local Color3={fromRGB=function(r,g,b)return {R=r/255,G=g/255,B=b/255}end}\n'+source('CourseVisualConfig','shared')) + literal('Trails',source('RocketTrailCatalog','shared')) + literal('DestructionRewards',source('DestructionRewardConfig','shared')) + literal('Skins',source('RocketSkinCatalog','shared')) + literal('XPProjection',source('XPProjection','client')) + literal('ClickerConfig',source('ClickerConfig','shared')) + literal('TrophyConfig',source('TrophyZoneConfig','shared')) + literal('Motion',source('RocketMotion','shared')) + literal('Growth','local Color3={fromRGB=function(...) return {...} end}\n'+source('ProgressionConfig','shared')) + literal('Balance',source('BalanceConfig','shared')) + literal('CloudConfig',source('CloudConfig','shared')) +
 literal('ProtoFuelConstants',source('ProtoFuelConstants','shared')) +
 literal('GameLevelConfig', 'local require=function(v) return v end\nlocal game={GetService=function() return {WaitForChild=function() return setmetatable({IsA=function() return true end},{__index=CloudConfig}) end} end}\n'+fs.readFileSync(path.join(__dirname,'legacy-course-config.luau'),'utf8')) +
 literal('LevelConfig',fs.readFileSync(path.join(__dirname,'phase2-config.luau'),'utf8')) + 'LevelConfig = table.clone(LevelConfig)\nLevelConfig.Destinations = LevelConfig.Destinations or {}\n' +
 literal('SteeringConfig',source('SteeringConfig')) + literal('Policy','local require=function(v) return v.__module or v end\nlocal game={GetService=function() return {WaitForChild=function() return {__module=Balance,IsA=function(_,c) return c=="ModuleScript" end} end} end}\n'+source('RunPolicy')) +
 literal('PresentationConfig',source('PresentationConfig','client'));
bundle += moduleWrap('AssetRegistry') + moduleWrap('WorldCoordinates') +
 moduleWrap('LaunchTrajectory') +
 moduleWrap('CloudDiscovery','{LevelConfig=GameLevelConfig}') +
 moduleWrap('CloudSection','{AssetRegistry=newAssetRegistry(env),WorldCoordinates=newWorldCoordinates(env)}') +
 moduleWrap('FlightMetrics','{WorldCoordinates=newWorldCoordinates(env)}') +
 moduleWrap('ObstaclePatterns','{AssetRegistry=newAssetRegistry(env),WorldCoordinates=newWorldCoordinates(env)}') +
 moduleWrap('CourseSection','{WorldCoordinates=newWorldCoordinates(env),LaunchTrajectory=newLaunchTrajectory(env)}') +
 moduleWrap('Destination','{AssetRegistry=newAssetRegistry(env),WorldCoordinates=newWorldCoordinates(env)}') +
 moduleWrap('LevelBuilder','{Destination=newDestination(env),CloudSection=newCloudSection(env),ObstaclePatterns=newObstaclePatterns(env),AssetRegistry=newAssetRegistry(env),WorldCoordinates=newWorldCoordinates(env),CourseSection=newCourseSection(env)}') +
 moduleWrap('LegacyGimmicks') + moduleWrap('WorldService') + moduleWrap('SpawnService') +
 moduleWrap('HorizontalSteering','{RunPolicy=Policy,SteeringConfig=SteeringConfig}') +
 moduleWrap('FlightCamera','{PresentationConfig=PresentationConfig}','client') + moduleWrap('SteeringInput','{}','client') + moduleWrap('Remotes') + moduleWrap('PlayerData','{RunPolicy=Policy}') +
 moduleWrap('Audio','{PresentationConfig=PresentationConfig}','client') +
 moduleWrap('SkyController','{PresentationConfig=PresentationConfig}','client') + moduleWrap('CurrencyHud','{}','client');
bundle += moduleWrap('SkyIslandConfig','{}','shared') +
 moduleWrap('SkyIslandSpawner.server','{LevelConfig=GameLevelConfig,WorldCoordinates=newWorldCoordinates(env)}')
 .replace('newSkyIslandSpawner.server(env, deps)','runSkyIslandSpawner(env, deps)') +
 moduleWrap('ProtoFuelServer.server','{ProtoFuelService=fuel}')
 .replace('newProtoFuelServer.server(env, deps)','runProtoFuelServer(env, fuel)').replace('Parent=deps or','Parent=') +
 moduleWrap('DiveImpact') + moduleWrap('TrophyZones','{DiveImpact=newDiveImpact(env)}') + moduleWrap('GoldRingEvent') + moduleWrap('RocketRules') + moduleWrap('RocketEconomy') + moduleWrap('LimbLanding') + moduleWrap('BreakCourse') + moduleWrap('DiveBreakZone','{RocketRules=newRocketRules(env)}') + moduleWrap('ProtoFuelService') + moduleWrap('DescentChallenge') + moduleWrap('SkyPatrol') + moduleWrap('SkyLife','{SkyPatrol=newSkyPatrol(env),BrainrotVisuals={Apply=function()return false end}}') + moduleWrap('FlightService',
 '{RunPolicy=Policy,PlayerData=Data,Remotes=newRemotes(env),FlightMetrics=newFlightMetrics(env),CloudDiscovery=newCloudDiscovery(env),LaunchTrajectory=newLaunchTrajectory(env),WorldService=env.world or {Start=function() end,GroundY=function() return 0 end,ExitReason=function() end,TargetCount=function() return 0 end,SampleDestination=function() end,GetCloudOutpostObjective=function() return nil end},HorizontalSteering=newHorizontalSteering(env),SteeringConfig=SteeringConfig}')
 .replace('(env, deps)','(env, Data)').replace('Parent=deps or','Parent=')
 .replace('local warn=function', 'script.Parent.FindFirstChild=function(self,key) return self[key] end\nif env.protoFuel then script.Parent.ProtoFuelService=env.protoFuel end\nlocal warn=function');
bundle += moduleWrap('ClickerService.server','{PlayerData=data,Remotes=newRemotes(env)}').replace('newClickerService.server(env, deps)','runClickerService(env, data)').replace('Parent=deps or','Parent=');
bundle += moduleWrap('FlightClient','{SkyController={ShowDestination=function(r) table.insert(env.regions,r) end,Reset=function() env.skyReset=true end,SetRegion=function(r) table.insert(env.regions,r) end},FlightCamera=newFlightCamera(env),SteeringInput=newSteeringInput(env),PresentationConfig=PresentationConfig,Audio={Play=function(kind) table.insert(env.audio,kind) end}}','client') +
 moduleWrap('RemoteClient','{}','client');
bundle += moduleWrap('Cannon.server','{FlightService=service,RocketFlightService=service,Remotes=newRemotes(env)}')
 .replace('newCannon.server(env, deps)','runGate(env, service)').replace('Parent=deps or','Parent=');
bundle += moduleWrap('DataManager.server','{PlayerData=data,Remotes=newRemotes(env)}')
 .replace('newDataManager.server(env, deps)','runManager(env, data, flight)').replace('Parent=deps or','Parent=');
bundle += moduleWrap('DestructibleConfig') + moduleWrap('BarrierSpawner.server')
 .replace('newBarrierSpawner.server(env, deps)', 'runBarrierSpawner(env, deps)');
bundle += fs.readFileSync(path.join(__dirname,'regression.luau'),'utf8').replace(
 'print("All "..count.." regression checks passed (mock engine; Studio physics not tested).")',
 fs.readFileSync(path.join(__dirname,'balance.luau'),'utf8')+'\n'+
 fs.readFileSync(path.join(__dirname,'target-choice.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'playtest-repair.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'proto-fuel.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'progression.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'descent.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'sky-bonuses.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'altitude-regions.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'chain-lockin.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'dive-impact.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'rocket-rebuild.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'rocket-polish.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'rocket-orbit.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'rocket-feel.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'rocket-passive.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'rocket-dive.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'rocket-impact.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'trophy-zones.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'rocket-growth.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'rocket-contact.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'rocket-clicker.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'xp-projection.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'balance-skins.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'rocket-height-dive.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'qa-propulsion.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'dive-break-zone.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'descent-wide.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'showroom-auto.luau'),'utf8')+'\n'+fs.readFileSync(path.join(__dirname,'power-boosts.luau'),'utf8')+'\nprint("All "..count.." regression checks passed (mock engine; legacy course fixture; Studio physics not tested).")');
const file=path.join(out,'regression.generated.luau');
fs.writeFileSync(file,bundle);
const run=cp.spawnSync(process.argv[2],[file],{stdio:'inherit'});
process.exit(run.status ?? 1);

