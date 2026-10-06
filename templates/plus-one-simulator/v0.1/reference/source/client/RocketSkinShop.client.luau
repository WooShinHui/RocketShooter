local Players=game:GetService("Players");local RS=game:GetService("ReplicatedStorage")
if not require(RS:WaitForChild("RocketModeConfig")).Enabled then return end
local p=Players.LocalPlayer;local private=p:WaitForChild("ProgressStats",20);local stats=p:WaitForChild("leaderstats",20)
if not private or not stats then return end
local Skins=require(RS:WaitForChild("RocketSkinCatalog"));local Trails=require(RS:WaitForChild("RocketTrailCatalog"))
local Equipment=require(RS:WaitForChild("EquipmentPower"))
local Icons=require(RS:WaitForChild("UIIcons"));local HUD=require(RS:WaitForChild("SimulatorHUD"))
local skinMask=private:WaitForChild("RocketSkinMask");local skinEquip=private:WaitForChild("RocketSkinEquipped")
local trailMask=private:WaitForChild("RocketTrailMask");local trailEquip=private:WaitForChild("RocketTrailEquipped")
local skinRemote=RS:WaitForChild("SelectRocketSkin");local trailRemote=RS:WaitForChild("SelectRocketTrail")
local gui=Instance.new("ScreenGui");gui.Name="RocketSkinGui";gui.ResetOnSpawn=false;HUD.screen(gui,60);gui.Parent=p.PlayerGui
local function text(parent,name,x,y,w,h,value,size,color)
 local v=Instance.new("TextLabel");v.Name=name;v.Position=UDim2.fromOffset(x,y);v.Size=UDim2.fromOffset(w,h);v.Text=value;HUD.text(v,size or 20,color);v.TextStrokeTransparency=.65;v.TextXAlignment=Enum.TextXAlignment.Left;v.TextWrapped=true;v.Parent=parent;return v
end
local function button(parent,name,x,y,w,h,value,color)
 local v=Instance.new("TextButton");v.Name=name;v.Position=UDim2.fromOffset(x,y);v.Size=UDim2.fromOffset(w,h);v.Text=value;HUD.button(v,color);v.TextSize=20;v.Parent=parent;return v
end
local shade=Instance.new("TextButton");shade.Name="Shade";shade.Text="";shade.BackgroundColor3=HUD.Colors.Ink;shade.BackgroundTransparency=.25;shade.Size=UDim2.fromScale(1,1);shade.Parent=gui
local panel=Instance.new("Frame");panel.Name="Shop";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.Size=UDim2.fromOffset(560,530);HUD.surface(panel,Color3.fromRGB(30,48,73));panel.Parent=gui
Icons.Image(panel,"Rocket",UDim2.fromOffset(18,14),UDim2.fromOffset(36,36));text(panel,"Title",64,8,380,46,"Trails",28)
local close=button(panel,"Close",494,10,50,42,"×",HUD.Colors.Coral)
Icons.Image(panel,"Trophy",UDim2.fromOffset(18,61),UDim2.fromOffset(28,28));local balance=text(panel,"Balance",54,58,485,32,"",20,HUD.Colors.Yellow)
local tabs={Rockets=button(panel,"Rockets",16,102,260,46,"Owned Rockets",HUD.Colors.Yellow),Trails=button(panel,"Trails",284,102,260,46,"Trails",HUD.Colors.Blue)}
Icons.Image(tabs.Rockets,"Rocket",UDim2.fromOffset(14,7),UDim2.fromOffset(32,32));Icons.Image(tabs.Trails,"Trail",UDim2.fromOffset(14,7),UDim2.fromOffset(32,32))
local list=Instance.new("ScrollingFrame");list.Name="Equipment";list.BackgroundTransparency=1;list.BorderSizePixel=0;list.Position=UDim2.fromOffset(16,160);list.Size=UDim2.fromOffset(528,306);list.ScrollBarThickness=6;list.CanvasSize=UDim2.fromOffset(0,0);list.Parent=panel
local message=text(panel,"Message",18,482,524,36,"",18)
local previews=RS:WaitForChild("RocketSkinPreviews",15)
local views={Rockets={},Trails={}};local page="Rockets";local pending=false
local function update()
 local flat,growth=Equipment.Bonuses(Skins.Items[skinEquip.Value],Trails.Items[trailEquip.Value])
 balance.Text=string.format("%d · Thrust +%d / Growth +%d%%",stats.Trophies.Value,flat,math.floor(growth*100+.5))
 for kind,rows in views do
  local catalog=kind=="Rockets"and Skins or Trails;local mask=kind=="Rockets"and skinMask.Value or trailMask.Value;local selected=kind=="Rockets"and skinEquip.Value or trailEquip.Value
  for i,v in rows do
   local item=catalog.Items[i];local owned=catalog.Owns(mask,i);local meets=kind=="Trails"and stats.Trophies.Value>=item.Cost and stats.Rebirths.Value>=(item.Rebirths or 0)
   v.Card.Visible=kind==page
   v.Condition.Text=Equipment.Description(item)..(owned and " · Owned"or "\n"..item.Cost.." Trophies"..(item.Rebirths and item.Rebirths>0 and " · Rebirths "..item.Rebirths or ""))
   v.Action.Text=if kind=="Rockets"and i<=10 then "E at Showroom"elseif selected==i then "Equipped"elseif owned then "Equip"elseif meets then "Buy"else "Locked"
   v.Action.BackgroundColor3=if selected==i then HUD.Colors.Yellow elseif owned or meets then HUD.Colors.Green else Color3.fromRGB(99,116,137)
   v.Card.BackgroundColor3=if selected==i then Color3.fromRGB(57,68,69)else Color3.fromRGB(20,31,50)
  end
 end
 for kind,b in tabs do b.BackgroundColor3=kind==page and HUD.Colors.Yellow or HUD.Colors.Blue end
 list.CanvasSize=UDim2.fromOffset(0,#(page=="Rockets"and Skins or Trails).Items*102)
end
for kind,catalog in {Trails=Trails}do
 for i,item in catalog.Items do
  local card=Instance.new("Frame");card.Name=kind..item.Id;card.Position=UDim2.fromOffset(0,(i-1)*102);card.Size=UDim2.fromOffset(516,94);HUD.surface(card,HUD.Colors.Ink);card.Parent=list
  local viewport=Instance.new("ViewportFrame");viewport.Name="Preview";viewport.BackgroundTransparency=1;viewport.Position=UDim2.fromOffset(4,4);viewport.Size=UDim2.fromOffset(86,86);viewport.Ambient=Color3.fromRGB(230,230,230);viewport.LightColor=Color3.new(1,1,1);viewport.Parent=card
  local camera=Instance.new("Camera");camera.FieldOfView=42;camera.CFrame=CFrame.lookAt(Vector3.new(5,3,10),Vector3.new(0,.4,1.5));camera.Parent=viewport;viewport.CurrentCamera=camera
  if kind=="Rockets"and previews and previews:FindFirstChild(item.Id)then previews[item.Id]:Clone().Parent=viewport
  elseif kind=="Trails"then
   viewport:Destroy()
   local sample=Instance.new("Frame");sample.Name="TrailPreview";sample.Position=UDim2.fromOffset(14,18);sample.Size=UDim2.fromOffset(64,58);sample.BackgroundColor3=Color3.new(1,1,1);sample.BorderSizePixel=0;sample.Parent=card
   local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,14);corner.Parent=sample
   local gradient=Instance.new("UIGradient");gradient.Color=Trails.Sequence(item);gradient.Rotation=45;gradient.Parent=sample
   Icons.Image(sample,"Trail",UDim2.fromOffset(8,5),UDim2.fromOffset(48,48))
  else viewport:Destroy();Icons.Image(card,"Rocket",UDim2.fromOffset(12,12),UDim2.fromOffset(64,64))end
  text(card,"Name",98,7,284,30,item.Name,23)
  local condition=text(card,"Requirement",98,39,278,48,"",17,HUD.Colors.Yellow)
  local action=button(card,"Action",388,22,114,50,"",HUD.Colors.Green)
  views[kind][i]={Card=card,Condition=condition,Action=action}
  action.Activated:Connect(function()
   if kind=="Rockets"and (i<=10 or not Skins.Owns(skinMask.Value,i))then message.Text="Press E at the left showroom to buy / equip";return end
   if pending then return end;pending=true
   local remote=kind=="Rockets"and skinRemote or trailRemote
   local ok,success,result=pcall(function()return remote:InvokeServer(i)end)
   message.Text=if ok then result or ""else "Please try again shortly"
   pending=false;update()
  end)
 end
end
local function choose(kind)
 kind="Trails";page=kind;list.CanvasPosition=Vector2.zero;message.Text=kind=="Rockets"and "Equipped rocket bonuses apply to your next launch"or "Power bonus + Rocket exhaust trail";update()
end
for kind,b in tabs do b.Activated:Connect(function()p:SetAttribute("RocketEquipmentTab",kind);choose(kind)end)end
tabs.Rockets.Visible=false;tabs.Trails.Visible=false
local function setOpen(open)
 panel.Visible=open;shade.Visible=open;p:SetAttribute("ProgressionModalOpen",open)
 if open then choose(p:GetAttribute("RocketEquipmentTab")=="Trails"and "Trails"or "Rockets")end
end
local function dismiss()p:SetAttribute("RocketSkinShopOpen",false);if p:GetAttribute("HUDPage")=="Trails"then p:SetAttribute("HUDPage",nil)end end
close.Activated:Connect(dismiss);shade.Activated:Connect(dismiss)
p:GetAttributeChangedSignal("RocketSkinShopOpen"):Connect(function()setOpen(p:GetAttribute("RocketSkinShopOpen")==true)end)
p:GetAttributeChangedSignal("RocketEquipmentTab"):Connect(function()choose(p:GetAttribute("RocketEquipmentTab")=="Trails"and "Trails"or "Rockets")end)
p:GetAttributeChangedSignal("FlightState"):Connect(function()if p:GetAttribute("FlightState")~="Idle"then dismiss()end end)
for _,v in {skinMask,skinEquip,trailMask,trailEquip,stats.Trophies,stats.Rebirths}do v.Changed:Connect(update)end
HUD.fit(panel,560,530,function(viewport)
 panel.SimulatorScale.Scale=1
 local safe=gui.AbsoluteSize;local w=math.min(560,math.max(280,safe.X-24));local h=math.min(530,math.max(230,safe.Y-24))
 local narrow=w<480;local compact=h<450
 panel.Size=UDim2.fromOffset(w,h);close.Position=UDim2.fromOffset(w-66,10);close.Size=UDim2.fromOffset(50,44);close.TextSize=30
 panel.Title.Size=UDim2.fromOffset(w-140,46);balance.Size=UDim2.fromOffset(w-72,32);balance.TextSize=narrow and 17 or 20
 panel.Title.Position=UDim2.fromOffset(64,8);panel.Title.Size=UDim2.fromOffset(w-140,compact and 32 or 46);panel.Title.TextSize=compact and 24 or 28
 balance.Position=UDim2.fromOffset(54,compact and 42 or 58);balance.Size=UDim2.fromOffset(w-72,compact and 26 or 32)
 panel.TrophyIcon.Position=UDim2.fromOffset(18,compact and 41 or 61)
 local tabY=compact and 70 or 102;local top=compact and 78 or 106;local tabW=(w-40)/2
 tabs.Rockets.Position=UDim2.fromOffset(16,tabY);tabs.Rockets.Size=UDim2.fromOffset(tabW,46)
 tabs.Trails.Position=UDim2.fromOffset(w/2+4,tabY);tabs.Trails.Size=UDim2.fromOffset(tabW,46)
 list.Position=UDim2.fromOffset(16,top);list.Size=UDim2.fromOffset(w-32,h-top-(compact and 42 or 62))
 message.Position=UDim2.fromOffset(18,h-(compact and 36 or 48));message.Size=UDim2.fromOffset(w-36,compact and 28 or 36);message.TextSize=narrow and 16 or 18
 for _,rows in views do for _,v in rows do
  local cw=w-44;local x=narrow and 78 or 98;local actionW=narrow and 98 or 114;local actionX=cw-actionW-12
  v.Card.Size=UDim2.fromOffset(cw,94)
  local title=v.Card.Name;local nameLabel=v.Card:FindFirstChild("Name")
  nameLabel.Position=UDim2.fromOffset(x,7);nameLabel.Size=UDim2.fromOffset(actionX-x-6,30);nameLabel.TextSize=narrow and 18 or 23
  v.Condition.Position=UDim2.fromOffset(x,39);v.Condition.Size=UDim2.fromOffset(actionX-x-6,48);v.Condition.TextSize=narrow and 14 or 17
  v.Action.Position=UDim2.fromOffset(actionX,22);v.Action.Size=UDim2.fromOffset(actionW,50);v.Action.TextSize=narrow and 18 or 20
  local preview=v.Card:FindFirstChild("Preview");if preview then preview.Size=UDim2.fromOffset(narrow and 66 or 86,narrow and 86 or 86)end
  local swatch=v.Card:FindFirstChild("TrailPreview");if swatch then swatch.Position=UDim2.fromOffset(narrow and 6 or 14,18)end
 end end
end);setOpen(false);update()

require(RS.MenuOverlay).Attach(panel)
