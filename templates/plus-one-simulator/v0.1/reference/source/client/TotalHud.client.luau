local Players=game:GetService("Players");local RS=game:GetService("ReplicatedStorage")
local p=Players.LocalPlayer;local HUD=require(RS:WaitForChild("SimulatorHUD"));local Icons=require(RS:WaitForChild("UIIcons"))
local C=require(RS:WaitForChild("PowerBoostConfig"));local remote=RS:WaitForChild("UsePowerBoost")
-- Local audio bus includes current and subsequently created voices.
local SoundService=game:GetService("SoundService")
local soundBus=Instance.new("SoundGroup");soundBus.Name="HUDSoundBus";soundBus.Parent=SoundService
local otherGroups={}
local function soundAdded(v)
 if v:IsA("Sound")and not v.SoundGroup then v.SoundGroup=soundBus
 elseif v:IsA("SoundGroup")and v~=soundBus then
  otherGroups[v]=v.Volume;if p:GetAttribute("HUDSoundMuted")then v.Volume=0 end
 end
end
for _,v in game:GetDescendants()do soundAdded(v)end
game.DescendantAdded:Connect(soundAdded)
p:GetAttributeChangedSignal("HUDSoundMuted"):Connect(function()
 local muted=p:GetAttribute("HUDSoundMuted")==true;soundBus.Volume=muted and 0 or 1
 for group,volume in otherGroups do if group.Parent then group.Volume=muted and 0 or volume end end
end)
local gui=Instance.new("ScreenGui");gui.Name="TotalHUD";gui.ResetOnSpawn=false;HUD.screen(gui,35);gui.Parent=p:WaitForChild("PlayerGui")
local menus=Instance.new("ScreenGui");menus.Name="TotalMenus";menus.ResetOnSpawn=false;HUD.screen(menus,70);menus.Parent=p.PlayerGui
local function label(parent,name,text,x,y,w,h,size,color)
 local v=Instance.new("TextLabel");v.Name=name;v.Position=UDim2.fromOffset(x,y);v.Size=UDim2.fromOffset(w,h);v.Text=text;HUD.text(v,size or 20,color);v.TextWrapped=true;v.Parent=parent;return v
end
local function button(parent,name,text,x,y,w,h,color,icon)
 local b=Instance.new("TextButton");b.Name=name;b.Text="";b.Position=UDim2.fromOffset(x,y);b.Size=UDim2.fromOffset(w,h);HUD.button(b,color);b.Parent=parent
 if icon then Icons.Image(b,icon,UDim2.fromOffset((w-58)/2,5),UDim2.fromOffset(58,58));label(b,"Caption",text,2,65,w-4,h-66,18)
 else label(b,"Caption",text,6,0,w-12,h,20)end
 return b
end
local function open(page) p:SetAttribute("HUDPage",if p:GetAttribute("HUDPage")==page then nil else page)end
local left=Instance.new("Frame");left.Name="Navigation";left.BackgroundTransparency=1;left.Size=UDim2.fromOffset(224,282);left.Position=UDim2.fromOffset(12,145);left.Parent=gui
local store=button(left,"Store","Store",0,0,224,66,HUD.Colors.Yellow)
Icons.Image(store,"Shop",UDim2.fromOffset(18,7),UDim2.fromOffset(52,52));store.Caption.Position=UDim2.fromOffset(78,0);store.Caption.Size=UDim2.fromOffset(140,66)
store.Activated:Connect(function()open("Store")end)
for _,row in {{"Rebirth","Rebirth",0,76,Color3.fromRGB(171,98,245),"Rebirth"},{"Food","Food",118,76,HUD.Colors.Green},{"Trails","Trails",0,184,HUD.Colors.Blue,"Trail"},{"WorldTravel","World Travel",118,184,Color3.fromRGB(96,110,145)}}do
 local b=button(left,row[1],row[2],row[3],row[4],106,98,row[5],row[6]);b.Activated:Connect(function()open(row[1]=="WorldTravel"and "World"or row[1])end)
end
local right=Instance.new("Frame");right.Name="DurationOffers";right.BackgroundTransparency=1;right.AnchorPoint=Vector2.new(1,.5);right.Position=UDim2.new(1,-12,.48,0);right.Size=UDim2.fromOffset(180,230);right.Parent=gui
local wins=button(right,"Wins2","x2 Wins",0,0,180,92,HUD.Colors.Yellow)
Icons.Image(wins,"Trophy",UDim2.fromOffset(8,20),UDim2.fromOffset(45,45));wins.Caption.Position=UDim2.fromOffset(57,0);wins.Caption.Size=UDim2.fromOffset(118,92)
local winsTime=label(right,"WinsTime","FREE TEST · 15 min",0,94,180,25,16)
local power=button(right,"Power2","x2 Power",0,128,180,92,HUD.Colors.Coral)
Icons.Image(power,"Rocket",UDim2.fromOffset(8,20),UDim2.fromOffset(45,45));power.Caption.Position=UDim2.fromOffset(57,0);power.Caption.Size=UDim2.fromOffset(118,92)
local powerTime=label(right,"PowerTime","FREE TEST · 15 min",0,222,180,25,16)
for _,offer in {wins,power}do
 Icons.Image(offer,"Robux",UDim2.fromOffset(155,5),UDim2.fromOffset(16,16))
 label(offer,"FuturePrice","TBD",121,3,32,20,12)
end
local busy=false
local function request(action,id)
 if busy then return false,"Please wait"end;busy=true
 local ok,success,note=pcall(function()return remote:InvokeServer(action,id)end);busy=false
 return ok and success,if ok then note else "Please try again"
end
wins.Activated:Connect(function()local _,note=request("Boost","Wins2");winsTime.Text=note end)
power.Activated:Connect(function()local _,note=request("Boost","Power2");powerTime.Text=note end)
local topGui=Instance.new("ScreenGui");topGui.Name="TopToolsHUD";topGui.ResetOnSpawn=false;HUD.screen(topGui,35);topGui.ScreenInsets=Enum.ScreenInsets.TopbarSafeInsets;topGui.Parent=p.PlayerGui
local top=Instance.new("Frame");top.Name="TopTools";top.BackgroundTransparency=1;top.AnchorPoint=Vector2.new(1,0);top.Position=UDim2.new(1,-16,0,12);top.Size=UDim2.fromOffset(96,44);top.Parent=topGui
for i,key in {"Guide","Settings"}do
 local b=button(top,key,"",(i-1)*52,0,44,44,HUD.Colors.Blue)
 b.Caption:Destroy();local corner=b:FindFirstChildOfClass("UICorner");corner.CornerRadius=UDim.new(1,0)
 Icons.Image(b,key,UDim2.fromOffset(10,10),UDim2.fromOffset(24,24));b.Activated:Connect(function()open(key)end)
end
local friend=label(gui,"FriendBoost","Friend Boost: +0%",12,0,260,34,22,Color3.fromRGB(134,255,184));friend.AnchorPoint=Vector2.new(0,1);friend.Position=UDim2.new(0,12,1,-10);friend.TextXAlignment=Enum.TextXAlignment.Left
local shade=Instance.new("TextButton");shade.Name="Shade";shade.Text="";shade.AutoButtonColor=false;shade.BackgroundColor3=HUD.Colors.Ink;shade.BackgroundTransparency=.3;shade.Size=UDim2.fromScale(1,1);shade.Visible=false;shade.Parent=menus
local panel=Instance.new("Frame");panel.Name="Panel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.Size=UDim2.fromOffset(560,470);HUD.surface(panel,Color3.fromRGB(30,48,73));panel.Visible=false;panel.Parent=menus
local heading=label(panel,"Title","Store",22,12,450,48,32,HUD.Colors.Yellow)
local close=button(panel,"Close","",494,12,50,48,HUD.Colors.Coral);close.Caption:Destroy();Icons.Image(close,"Close",UDim2.fromOffset(9,8),UDim2.fromOffset(32,32))
local content=Instance.new("ScrollingFrame");content.Name="Content";content.BackgroundTransparency=1;content.BorderSizePixel=0;content.Position=UDim2.fromOffset(18,80);content.Size=UDim2.fromOffset(524,330);content.AutomaticCanvasSize=Enum.AutomaticSize.Y;content.CanvasSize=UDim2.new();content.ScrollBarThickness=6;content.Parent=panel
local status=label(panel,"Status","",18,418,524,38,17)
local pages={Store=true,Food=true,World=true,Guide=true,Settings=true}
local function clear()for _,v in content:GetChildren()do v:Destroy()end;content.CanvasPosition=Vector2.zero;status.Text=""end
local function row(name,text,y,color,callback,icon)
 local b=button(content,name,text,4,y,508,64,color)
 if icon then Icons.Image(b,icon,UDim2.fromOffset(12,8),UDim2.fromOffset(48,48));b.Caption.Position=UDim2.fromOffset(70,0);b.Caption.Size=UDim2.fromOffset(420,64)end
 b.Activated:Connect(callback);return b
end
local function render(page)
 clear();heading.Text=if page=="World"then "World Travel"else page
 if page=="Store"then
  for i,id in {"Wins2","Power2","Power4","Power8"}do
   local item=C.Products[id];row(id,item.Name.." · 15 minutes · FREE TEST",(i-1)*76,i==1 and HUD.Colors.Yellow or HUD.Colors.Coral,function()local _,note=request("Boost",id);status.Text=note end,item.Kind=="Wins"and "Trophy"or "Rocket")
  end
 elseif page=="Food"then
  for i,item in C.Foods do
   local selected=(p:GetAttribute("FoodSelected")or 1)==i
   row("Food"..i,(selected and "Selected · "or "")..item.Name.." · +"..math.floor(item.Percent*100+.5).."% Power · FREE",(i-1)*76,selected and HUD.Colors.Yellow or HUD.Colors.Green,function()local _,note=request("Food",i);render("Food");status.Text=note end)
  end
 elseif page=="World"then
  label(content,"ComingSoon","World 2 · Coming Soon",0,30,524,60,30,HUD.Colors.Yellow)
  -- World 2: later unlock travel only after clearing and exiting beyond
  -- the outer edge of current content. No travel/unlock remote is active yet.
 elseif page=="Guide"then
  label(content,"Instructions","Click to gain XP and Power.\n\nLeft showroom: press E to buy / equip rockets.\nRight showroom: unlock toilets with rebirths, then approach to train.\n\nPower = Base × Multiplier × (1 + Food %) × (1 + Friend %).\nEach friend in this server adds 10%.\n\nLaunch, break objects, earn Trophies!",12,8,492,305,20)
 elseif page=="Settings"then
  local muted=p:GetAttribute("HUDSoundMuted")==true
  local sound; sound=row("Sound",muted and "Sound: OFF"or "Sound: ON",0,HUD.Colors.Blue,function()
   muted=not muted;p:SetAttribute("HUDSoundMuted",muted);sound.Caption.Text=muted and "Sound: OFF"or "Sound: ON"
  end)
  label(content,"SettingsNote","Settings apply on this device for this session.",0,90,524,60,20)
 end
end
local function pageChanged()
 local page=p:GetAttribute("HUDPage")
 p:SetAttribute("RocketEquipmentTab","Trails");p:SetAttribute("RocketSkinShopOpen",page=="Trails")
 panel.Visible=pages[page]==true;shade.Visible=panel.Visible
 if panel.Visible then render(page)end
 task.defer(function()p:SetAttribute("ProgressionModalOpen",p:GetAttribute("HUDPage")~=nil)end)
end
p:GetAttributeChangedSignal("HUDPage"):Connect(pageChanged)
p:GetAttributeChangedSignal("FoodSelected"):Connect(function()if p:GetAttribute("HUDPage")=="Food"then render("Food")end end)
close.Activated:Connect(function()p:SetAttribute("HUDPage",nil)end);shade.Activated:Connect(function()p:SetAttribute("HUDPage",nil)end)
p:GetAttributeChangedSignal("FlightState"):Connect(function()
 local phase=p:GetAttribute("FlightState");local idle=phase==nil or phase=="Idle"
 left.Visible=idle;right.Visible=idle;top.Visible=idle
 if not idle then p:SetAttribute("HUDPage",nil)end
end)
local function resize()
 local size=gui.AbsoluteSize;local compact=size.X<900 or size.Y<600
 local scale=left:FindFirstChildOfClass("UIScale")or Instance.new("UIScale",left)
 scale.Scale=math.min(1,(size.Y-310)/282,size.X/1100);scale.Scale=math.max(.4,scale.Scale)
 left.Position=UDim2.fromOffset(12,math.max(120,(size.Y-192-282*scale.Scale)/2+40))
 local rscale=right:FindFirstChildOfClass("UIScale")or Instance.new("UIScale",right);rscale.Scale=scale.Scale
 friend.TextSize=compact and 16 or 22;friend.Size=UDim2.fromOffset(compact and 190 or 260,30)
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize()
HUD.fit(panel,560,470);require(RS.MenuOverlay).Attach(panel)
pageChanged()
task.spawn(function()
 while gui.Parent do
  local now=workspace:GetServerTimeNow()
  local function timer(attr,mult)
   local remaining=math.max(0,math.ceil((p:GetAttribute(attr)or 0)-now))
   return remaining>0 and string.format("x%s · %02d:%02d",p:GetAttribute(mult)or 1,math.floor(remaining/60),remaining%60)or "FREE TEST · 15 min"
  end
  winsTime.Text=timer("WinsBoostUntil","WinsMultiplier");powerTime.Text=timer("PowerBoostUntil","PowerMultiplier")
  friend.Text="Friend Boost: +"..math.floor((p:GetAttribute("FriendPowerPercent")or 0)*100+.5).."%";task.wait(1)
 end
end)
