// Executes the real mobile layout script with touch input and GUI/camera signals.
const fs=require('fs'),path=require('path'),cp=require('child_process');
const file=process.argv[3]||path.join(__dirname,'../src/client/MobileLayout.client.luau');
const scratch=process.argv[4]||path.join(__dirname,'.generated');fs.mkdirSync(scratch,{recursive:true});
const source=fs.readFileSync(file,'utf8');
const harness=`
local function signal()
 local s={handlers={}}
 function s:Connect(fn)local row={fn=fn};table.insert(self.handlers,row);return {Disconnect=function()row.off=true end}end
 function s:Fire()for _,row in self.handlers do if not row.off then row.fn()end end end
 return s
end
local dock={Visible=false};local descendant=signal();local flight=signal();local cameraChanged=signal();local viewportChanged=signal()
local attributes={FlightState="Idle"};local camera={ViewportSize={X=390,Y=844}}
function camera:GetPropertyChangedSignal()return viewportChanged end
local workspace={CurrentCamera=camera};function workspace:GetPropertyChangedSignal()return cameraChanged end
local gui={DescendantAdded=descendant}
function gui:FindFirstChild(name)
 if name=="ProgressionGui"then return {FindFirstChild=function(_,child)return child=="GrowthDock"and dock or nil end}end
end
local player={};function player:WaitForChild()return gui end
function player:GetAttribute(name)return attributes[name]end
function player:GetAttributeChangedSignal()return flight end
local game={Players={LocalPlayer=player}};function game:GetService()return {TouchEnabled=true}end
local deferred={};local task={defer=function(fn)table.insert(deferred,fn)end}
local function flush()while #deferred>0 do local fn=table.remove(deferred,1);fn()end end
local function run()
${source}
end
local count=0
local function check(note)assert(dock.Visible==false,note);count+=1 end
run();check("touch startup must keep retired Rebirth dock hidden")
for i=1,100 do descendant:Fire();flush();check("XP popup descendants must not reopen the legacy dock")end
camera.ViewportSize={X=844,Y=390};viewportChanged:Fire();check("landscape rotation must not reopen the legacy dock")
camera.ViewportSize={X=390,Y=844};viewportChanged:Fire();check("portrait rotation must not reopen the legacy dock")
for _,state in {"Flying","Returning","Idle"}do attributes.FlightState=state;flight:Fire();check("flight state must not reopen the legacy dock")end
attributes.RocketSkinShopOpen=true;descendant:Fire();flush();check("Trails menu open must preserve hidden legacy dock")
attributes.RocketSkinShopOpen=false;descendant:Fire();flush();check("Trails menu close must preserve hidden legacy dock")
cameraChanged:Fire();check("camera rebinding must preserve hidden legacy dock")
print("Passed "..count.." mobile legacy-dock regression checks (real script, mocked engine).")
`;
const generated=path.join(scratch,'mobile-layout.generated.luau');fs.writeFileSync(generated,harness);
const r=cp.spawnSync(process.argv[2],[generated],{stdio:'inherit'});process.exit(r.status??1);
