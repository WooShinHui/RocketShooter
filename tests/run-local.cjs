// Usage: node tests/run-local.cjs <path-to-luau.exe> [output-directory]
// Runs production modules with a small engine mock, not a Studio physics test.
const fs = require('node:fs');
const path = require('node:path');
const cp = require('node:child_process');
const root = path.resolve(__dirname, '..');
const out = path.resolve(process.argv[3] || path.join(root, 'tests/.generated'));
fs.mkdirSync(out, {recursive: true});
const source = name => fs.readFileSync(path.join(root, 'src/server', name + '.luau'), 'utf8');
const wrap = (name, dependencies) => `local function new${name}(env${dependencies ? ', '+dependencies : ''})\nlocal game, Instance, task, os, workspace = env.game, env.Instance, env.task, env.os, env.workspace\nlocal Vector3, CFrame, Enum, RaycastParams, typeof = env.Vector3, env.CFrame, env.Enum, env.RaycastParams, env.typeof\nlocal script = {Parent = {RunPolicy=Policy, PlayerData=${dependencies || 'nil'}, Remotes=${name === 'FlightService' ? 'newRemotes(env)' : 'nil'}, SteeringConfig=SteeringConfig, HorizontalSteering=${name === 'FlightService' ? 'newHorizontalSteering(env)' : 'nil'}}}\nlocal require = function(value) return value end\nlocal warn = function(...) table.insert(env.warnings, {...}) end\n${source(name)}\nend\n`;
const clientSource = fs.readFileSync(path.join(root, 'src/client/FlightClient.luau'), 'utf8');
const steeringSource = fs.readFileSync(path.join(root, 'src/client/SteeringInput.luau'), 'utf8');
const steeringWrap = 'local function newSteeringInput(env)\nlocal game, Enum = env.game, env.Enum\n' + steeringSource + '\nend\n';
const clientWrap = 'local function newFlightClient(env)\nlocal game, Instance, task, workspace = env.game, env.Instance, env.task, env.workspace\nlocal Vector3, CFrame, Enum = env.Vector3, env.CFrame, env.Enum\nlocal Color3, ColorSequence, NumberSequence, UDim2 = env.Color3, env.ColorSequence, env.NumberSequence, env.UDim2\nlocal warn = function(...) end\nlocal os = env.os\nlocal script={Parent={SteeringInput=newSteeringInput(env)}}\nlocal require=function(value) return value end\n' + clientSource + '\nend\n';
const gateSource = fs.readFileSync(path.join(root, 'src/server/Cannon.server.luau'), 'utf8');
const gateWrap = 'local function runGate(env, service)\nlocal workspace = env.workspace\nlocal script = {Parent={FlightService=service,Remotes=newRemotes(env)}}\nlocal require = function(value) return value end\nlocal warn = function(...) table.insert(env.warnings,{...}) end\n' + gateSource + '\nend\n';
const remoteClientSource = fs.readFileSync(path.join(root, 'src/client/RemoteClient.luau'), 'utf8');
const remoteClientWrap = 'local function newRemoteClient(env)\nlocal game, os = env.game, env.os\nlocal warn = function(...) table.insert(env.warnings,{...}) end\n' + remoteClientSource + '\nend\n';
const managerSource = fs.readFileSync(path.join(root, 'src/server/DataManager.server.luau'), 'utf8');
const managerWrap = 'local function runManager(env, data, flight)\nlocal game, Instance, workspace = env.game, env.Instance, env.workspace\nlocal Vector3, CFrame, Enum, Color3 = env.Vector3, env.CFrame, env.Enum, env.Color3\nlocal script={Parent={PlayerData=data,FlightService=flight,Remotes=newRemotes(env)}}\nlocal require=function(value) return value end\nlocal warn=function(...) table.insert(env.warnings,{...}) end\n' + managerSource + '\nend\n';
const bundle = `local SteeringConfig = (function()\n${source('SteeringConfig')}\nend)()\nlocal Policy = (function()\n${source('RunPolicy')}\nend)()\n` +
  wrap('HorizontalSteering') + steeringWrap + wrap('Remotes') + wrap('PlayerData') + wrap('FlightService','Data') + clientWrap + gateWrap + remoteClientWrap + managerWrap + fs.readFileSync(path.join(__dirname, 'regression.luau'), 'utf8');
const file = path.join(out, 'regression.generated.luau');
fs.writeFileSync(file, bundle);
const run = cp.spawnSync(process.argv[2], [file], {stdio:'inherit'});
process.exit(run.status ?? 1);
