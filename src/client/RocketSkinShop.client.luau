local Players=game:GetService("Players");local RS=game:GetService("ReplicatedStorage")
if not require(RS:WaitForChild("RocketModeConfig")).Enabled then return end
local p=Players.LocalPlayer;local private=p:WaitForChild("ProgressStats",20);local stats=p:WaitForChild("leaderstats",20)
if not private or not stats then return end
local mask=private:WaitForChild("RocketSkinMask",20);local equipped=private:WaitForChild("RocketSkinEquipped",20)
if not mask or not equipped then return end
local C=require(RS:WaitForChild("RocketSkinCatalog"));local Styles=require(RS:WaitForChild("RocketStyles"))
local HUD=require(RS:WaitForChild("SimulatorHUD"));local remote=RS:WaitForChild("SelectRocketSkin")
local gui=Instance.new("ScreenGui");gui.Name="RocketSkinGui";gui.ResetOnSpawn=false;HUD.screen(gui,50);gui.Parent=p.PlayerGui
local function text(parent,name,position,size,value,font)
 local v=Instance.new("TextLabel");v.Name=name;v.Position=position;v.Size=size;v.Text=value;HUD.text(v,font or 22);v.TextWrapped=true;v.Parent=parent;return v
end
local shade=Instance.new("TextButton");shade.Name="Shade";shade.Text="";shade.BackgroundColor3=HUD.Colors.Ink;shade.BackgroundTransparency=.35;shade.Size=UDim2.fromScale(1,1);shade.Parent=gui
local panel=Instance.new("Frame");panel.Name="Shop";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.Size=UDim2.fromOffset(540,500);HUD.surface(panel,HUD.Colors.Blue);panel.Parent=gui
text(panel,"Title",UDim2.fromOffset(20,8),UDim2.fromOffset(410,50),"🚀 로켓 스킨",30)
local close=Instance.new("TextButton");close.Name="Close";close.Position=UDim2.fromOffset(464,10);close.Size=UDim2.fromOffset(60,48);close.Text="×";HUD.button(close,HUD.Colors.Coral);close.TextSize=34;close.Parent=panel
local balance=text(panel,"Balance",UDim2.fromOffset(20,58),UDim2.fromOffset(500,30),"",22)
local list=Instance.new("ScrollingFrame");list.Name="Skins";list.BackgroundTransparency=1;list.BorderSizePixel=0;list.Position=UDim2.fromOffset(16,98);list.Size=UDim2.fromOffset(508,346);list.CanvasSize=UDim2.fromOffset(0,#C.Items*92);list.ScrollBarThickness=6;list.Parent=panel
local message=text(panel,"Message",UDim2.fromOffset(16,450),UDim2.fromOffset(508,36),"외형 전용 · 추진력은 동일",20)
local previews=RS:WaitForChild("RocketSkinPreviews",15)
local views={};local pending=false
local function update()
 balance.Text="🏆 트로피 "..stats.Trophies.Value
 for i,item in C.Items do
  local v=views[i];local owned=C.Owns(mask.Value,i);local selected=equipped.Value==i
  v.Requirement.Text=if owned then "보유" else (if item.Rebirths>0 then "환생 "..item.Rebirths.."회 · " else "").."🏆 "..item.Cost
  local meets=stats.Rebirths.Value>=item.Rebirths and stats.Trophies.Value>=item.Cost
  v.Action.Text=if selected then "장착 중" elseif owned then "장착" elseif meets then "해금" else "잠김"
  v.Action.BackgroundColor3=if selected then HUD.Colors.Yellow elseif owned or meets then HUD.Colors.Green else Color3.fromRGB(100,116,139)
 end
end
for i,item in C.Items do
 local card=Instance.new("Frame");card.Name=item.Id;card.Position=UDim2.fromOffset(0,(i-1)*92);card.Size=UDim2.fromOffset(496,84);HUD.surface(card,HUD.Colors.Ink);card.Parent=list
 if previews and previews:FindFirstChild(item.Id) then
  local viewport=Instance.new("ViewportFrame");viewport.Name="Preview";viewport.BackgroundTransparency=1;viewport.Position=UDim2.fromOffset(4,2);viewport.Size=UDim2.fromOffset(78,78);viewport.Ambient=Color3.fromRGB(210,210,210);viewport.LightColor=Color3.new(1,1,1);viewport.Parent=card
  local model=previews[item.Id]:Clone();model.Parent=viewport
  local camera=Instance.new("Camera");camera.FieldOfView=42;camera.CFrame=CFrame.lookAt(Vector3.new(5,3,10),Vector3.new(0,.4,1.5));camera.Parent=viewport;viewport.CurrentCamera=camera
 else
  text(card,"Icon",UDim2.fromOffset(4,2),UDim2.fromOffset(78,78),item.Icon,44).TextColor3=Styles[item.Id].Accent
 end
 text(card,"Name",UDim2.fromOffset(86,2),UDim2.fromOffset(256,38),item.Name,24)
 local condition=text(card,"Requirement",UDim2.fromOffset(86,42),UDim2.fromOffset(256,34),"",19)
 local action=Instance.new("TextButton");action.Name="Action";action.Position=UDim2.fromOffset(352,16);action.Size=UDim2.fromOffset(128,52);HUD.button(action,HUD.Colors.Green);action.Parent=card
 views[i]={Requirement=condition,Action=action}
 action.Activated:Connect(function()
  if pending then return end;pending=true
  local ok,success,result=pcall(function() return remote:InvokeServer(i) end)
  message.Text=if ok then result or "" else "잠시 후 다시 시도하세요"
  pending=false;update()
 end)
end
local function setOpen(open)
 panel.Visible=open;shade.Visible=open
 p:SetAttribute("ProgressionModalOpen",open)
 if open then update() end
end
local function dismiss() p:SetAttribute("RocketSkinShopOpen",false) end
close.Activated:Connect(dismiss);shade.Activated:Connect(dismiss)
p:GetAttributeChangedSignal("RocketSkinShopOpen"):Connect(function() setOpen(p:GetAttribute("RocketSkinShopOpen")==true) end)
p:GetAttributeChangedSignal("FlightState"):Connect(function() if p:GetAttribute("FlightState")=="Flying" then dismiss() end end)
for _,v in {mask,equipped,stats.Trophies,stats.Rebirths} do v.Changed:Connect(update) end
HUD.fit(panel,540,500);setOpen(false);update()
