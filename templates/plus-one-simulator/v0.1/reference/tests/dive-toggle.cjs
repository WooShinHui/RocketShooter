// Exercise production input handlers, including unrelated touch release.
const fs=require('fs'),path=require('path'),cp=require('child_process');
const source=fs.readFileSync(path.join(__dirname,'../src/client/RocketClient.luau'),'utf8');
const start=source.indexOf(' local function act(action)'),end=source.indexOf(' local eventElapsed=0',start);if(start<0||end<0)throw Error('Input handlers not found');
const harness=`
local function signal()
 local s={handlers={}};function s:Connect(fn)table.insert(self.handlers,fn);return {Disconnect=function()end}end
 function s:Fire(...)for _,fn in self.handlers do fn(...)end end;return s
end
local function button()
 local b={Activated=signal(),InputBegan=signal(),MouseButton1Down=signal(),attrs={}}
 function b:SetAttribute(k,v)self.attrs[k]=v end;return b
end
local diveButton,explodeButton,abortButton=button(),button(),button()
local UIS={TouchEnabled=true,InputBegan=signal(),InputEnded=signal(),WindowFocusReleased=signal(),GetFocusedTextBox=function()return nil end}
local Enum={KeyCode={F="F",Q="Q",E="E"},UserInputType={Touch="Touch",MouseButton1="MouseButton1"}}
local Color3={fromRGB=function(...)return {...}end}
local character={};local player={Character=character};local active={id=7,character=character,diving=true}
local calls={};local remotes={ReturnToSpawn={FireServer=function(_,id,action)table.insert(calls,{id,action})end}}
${source.slice(start,end)}
local count=0;local function check(v,note)assert(v,note);count+=1 end
diveButton.InputBegan:Fire({UserInputType="Touch"});check(#calls==0,"touch down alone does not toggle")
diveButton.Activated:Fire();check(active.diveHeld and #calls==1 and calls[1][2]=="Dive","tap activates exactly once")
check(diveButton.attrs.Selected==true and diveButton.Text=="Fast Dive: ON","mobile ON indicator")
UIS.InputEnded:Fire({UserInputType="Touch"});check(active.diveHeld and #calls==1,"releasing joystick or button finger keeps toggle on")
diveButton.Activated:Fire();check(not active.diveHeld and calls[2][2]=="DiveStop","second tap disables")
UIS.TouchEnabled=false;UIS.InputBegan:Fire({KeyCode="F"},false);check(active.diveHeld and calls[3][2]=="Dive"and diveButton.Text=="Fast Dive: ON [F]","F toggles on with shortcut label")
UIS.InputEnded:Fire({KeyCode="F"});check(active.diveHeld and #calls==3,"F release keeps toggle on")
UIS.InputBegan:Fire({KeyCode="F"},false);check(not active.diveHeld and calls[4][2]=="DiveStop","second F toggles off")
UIS.InputBegan:Fire({KeyCode="F"},true);check(#calls==4,"processed keyboard input ignored")
active.diving=false;diveButton.Activated:Fire();check(#calls==4,"ascent ignores fast dive toggle")
active.diving=true;player.Character={};diveButton.Activated:Fire();check(#calls==4,"stale character cannot toggle")
player.Character=character;diveButton.Activated:Fire();UIS.WindowFocusReleased:Fire();check(not active.diveHeld and calls[#calls][2]=="DiveStop","focus loss releases current toggle")
active=nil;diveButton.Activated:Fire();check(#calls==6,"idle click ignored")
print("Passed "..count.." Fast Dive toggle regression checks (real handlers, mocked input).")
`;
const out=process.argv[3]||path.join(__dirname,'.generated');fs.mkdirSync(out,{recursive:true});const p=path.join(out,'dive-toggle.generated.luau');fs.writeFileSync(p,harness);const r=cp.spawnSync(process.argv[2],[p],{stdio:'inherit'});process.exit(r.status??1);
