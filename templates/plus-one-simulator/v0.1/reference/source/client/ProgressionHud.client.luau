local player=game:GetService("Players").LocalPlayer
local RS=game:GetService("ReplicatedStorage");local UIS=game:GetService("UserInputService")
local stats=player:WaitForChild("leaderstats",20);if not stats then return end
local C=require(RS:WaitForChild("ProgressionConfig",15));local HUD=require(RS:WaitForChild("SimulatorHUD",15))
local rebirth=RS:WaitForChild("RequestRebirth",15);local buy=RS:WaitForChild("BuyTrainingTier",15)
local buyItem=RS:WaitForChild("BuyXPItem",15)
local click=RS:WaitForChild("ClickTraining",15);local auto=RS:WaitForChild("ToggleAutoClick",15)
local Icons=require(RS:WaitForChild("UIIcons"))
local Audio=require(script.Parent.Audio);local purple=Color3.fromRGB(171,98,245)
local gui=Instance.new("ScreenGui");gui.Name="ProgressionGui";gui.ResetOnSpawn=false;HUD.screen(gui,40);gui.Parent=player.PlayerGui
local function label(parent,name,x,y,w,h,text,size,color)
 local v=Instance.new("TextLabel");v.Name=name;v.Position=UDim2.fromOffset(x,y);v.Size=UDim2.fromOffset(w,h);v.Text=text or "";HUD.text(v,math.max(18,math.floor((size or 22)*1.12)),color);v.TextWrapped=true;v.Parent=parent;return v
end
local function box(parent,name,x,y,w,h,color)
 local v=Instance.new("Frame");v.Name=name;v.Position=UDim2.fromOffset(x,y);v.Size=UDim2.fromOffset(w,h);HUD.surface(v,color);v.Parent=parent;return v
end
local function button(parent,name,x,y,w,h,text,color,size)
 local v=Instance.new("TextButton");v.Name=name;v.Position=UDim2.fromOffset(x,y);v.Size=UDim2.fromOffset(w,h);v.Text=text;HUD.button(v,color);v.TextSize=size or 26;v.Parent=parent;return v
end
local dock=Instance.new("Frame");dock.Name="GrowthDock";dock.BackgroundTransparency=1;dock.Size=UDim2.fromOffset(212,420);dock.Visible=false;dock.Parent=gui
local open=button(dock,"OpenRebirth",0,0,96,100,"",purple,54);Icons.Image(open,"Rebirth",UDim2.fromOffset(20,8),UDim2.fromOffset(56,56))
local training=button(dock,"OpenTraining",112,0,96,100,"🚽",HUD.Colors.Blue,48)
label(open,"Caption",0,74,96,26,"Rebirth",16);label(training,"Caption",0,74,96,26,"Training",16)
local gift=button(dock,"OpenCommunity",0,114,96,100,"",HUD.Colors.Yellow,48);Icons.Image(gift,"Gift",UDim2.fromOffset(20,8),UDim2.fromOffset(56,56))
local toggle=button(dock,"AutoClick",112,114,96,100,"",HUD.Colors.Green,40);Icons.Image(toggle,"Upgrade",UDim2.fromOffset(20,8),UDim2.fromOffset(56,56))
label(gift,"Caption",0,74,96,26,"Gifts",16);local autoCaption=label(toggle,"Caption",0,74,96,26,"Auto Training",13)
local level=label(dock,"Level",0,183,172,28,"",22,HUD.Colors.Yellow)
local xpbar=box(dock,"XPBar",0,216,172,16,HUD.Colors.Ink)
local xpfill=Instance.new("Frame");xpfill.Name="XPFill";xpfill.BackgroundColor3=HUD.Colors.Green;xpfill.BorderSizePixel=0;xpfill.Size=UDim2.fromScale(0,1);xpfill.Parent=xpbar
local xpText=label(dock,"XPValue",0,237,172,24,"",15)
local nextGoal=label(dock,"NextGoal",0,263,208,60,"",19,HUD.Colors.Yellow)
local growthPower=label(dock,"GrowthPower",0,311,172,30,"",17)
local passiveRate=label(dock,"PassiveRate",0,344,172,32,"",14,HUD.Colors.Green)
for _,v in {level,xpbar,xpText,growthPower,passiveRate}do v.Visible=false end
nextGoal.Position=UDim2.fromOffset(0,342)
local skins=button(dock,"OpenSkins",0,228,208,48,"",purple,24)
Icons.Image(skins,"Rocket",UDim2.fromOffset(10,6),UDim2.fromOffset(36,36));label(skins,"Caption",52,0,150,48,"Inventory",22)
local trails=button(dock,"OpenTrails",0,284,208,48,"",HUD.Colors.Blue,24)
Icons.Image(trails,"Trail",UDim2.fromOffset(10,6),UDim2.fromOffset(36,36));label(trails,"Caption",52,0,150,48,"Trails",22)
trails.Activated:Connect(function()if player:GetAttribute("FlightState")~="Flying"then player:SetAttribute("RocketEquipmentTab","Trails");player:SetAttribute("RocketSkinShopOpen",true)end end)
skins.Activated:Connect(function() if player:GetAttribute("FlightState")~="Flying" then player:SetAttribute("RocketEquipmentTab","Rockets");player:SetAttribute("RocketSkinShopOpen",true) end end)
local shade=button(gui,"ModalShade",0,0,1,1,"",HUD.Colors.Ink);shade.Size=UDim2.fromScale(1,1);shade.BackgroundTransparency=.35;shade.ZIndex=10;shade.Visible=false
local popup=box(gui,"RebirthPanel",0,0,500,460,HUD.Colors.Blue);popup.AnchorPoint=Vector2.new(.5,.5);popup.Position=UDim2.fromScale(.5,.5);popup.ZIndex=11;popup.Visible=false
local title=label(popup,"Title",20,12,372,48,"🔄 Rebirth",32)
local close=button(popup,"Close",408,10,80,76,"",HUD.Colors.Coral,42);Icons.Image(close,"Close",UDim2.fromOffset(15,12),UDim2.fromOffset(50,50))
local content=Instance.new("Frame");content.Name="Content";content.Position=UDim2.fromOffset(0,84);content.Size=UDim2.fromOffset(500,346);content.BackgroundTransparency=1;content.Parent=popup
local rebirthPage=Instance.new("Frame");rebirthPage.Name="RebirthPage";rebirthPage.Size=UDim2.fromScale(1,1);rebirthPage.BackgroundTransparency=1;rebirthPage.Parent=content
local requirement=box(rebirthPage,"RequiredLevel",88,0,324,48,HUD.Colors.Yellow)
local requiredText=label(requirement,"Value",0,0,324,48,"Level 20 required",25)
local current=box(rebirthPage,"CurrentCard",20,60,194,84,HUD.Colors.Green)
local nextCard=box(rebirthPage,"NextCard",286,60,194,84,HUD.Colors.Green)
local nowValue=label(current,"Value",0,0,194,84,"",23);local nextValue=label(nextCard,"Value",0,0,194,84,"",23)
label(rebirthPage,"Arrow",222,70,55,64,"▶",40)
label(rebirthPage,"MultiplierMeaning",20,145,460,20,"Boosts passive, flight and toilet XP",14)
local progress=box(rebirthPage,"LevelProgress",20,163,460,48,HUD.Colors.Ink)
local pfill=box(progress,"Fill",0,0,1,48,HUD.Colors.Blue)
local progressText=label(progress,"Value",0,0,460,48,"",22);progressText.ZIndex=2
local confirm=button(rebirthPage,"ConfirmRebirth",20,227,294,82,"🔄 Rebirth",purple,28)
local skip=button(rebirthPage,"SkipRebirth",326,227,154,82,"Skip Rebirth",HUD.Colors.Green,19)
label(skip,"Caption",0,57,154,22,"Coming Soon",16)
label(rebirthPage,"ResetNote",20,315,460,24,"Resets level / XP · Keeps toilets, trophies and records",14)
local trainingPage=Instance.new("Frame");trainingPage.Name="TrainingPage";trainingPage.Size=UDim2.fromScale(1,1);trainingPage.BackgroundTransparency=1;trainingPage.Visible=false;trainingPage.Parent=content
local toiletIcon=Icons.Image(trainingPage,"Training",UDim2.fromOffset(30,12),UDim2.fromOffset(125,125))
local tierValue=label(trainingPage,"TierValue",176,0,304,60,"",24)
local buffs=label(trainingPage,"Buffs",176,65,304,60,"",20,HUD.Colors.Yellow)
local tierButton=button(trainingPage,"BuyTier",20,157,460,82,"",HUD.Colors.Green,20)
local tap=button(trainingPage,"TapXP",20,255,220,82,"Click Training\n+1 XP",HUD.Colors.Yellow,22)
local op=button(trainingPage,"OPAuto",252,255,228,82,"OP Auto Training\nComing Soon",purple,22)
local communityPage=Instance.new("Frame");communityPage.Name="CommunityPage";communityPage.Size=UDim2.fromScale(1,1);communityPage.BackgroundTransparency=1;communityPage.Visible=false;communityPage.Parent=content
Icons.Image(communityPage,"Gift",UDim2.fromOffset(290,10),UDim2.fromOffset(150,150))
local like=button(communityPage,"Like",20,15,254,82,"♥ Like",HUD.Colors.Coral)
local join=button(communityPage,"Join",20,112,254,82,"✚ Join",HUD.Colors.Blue)
local claim=button(communityPage,"Claim",20,227,460,82,"🎁 Claim",HUD.Colors.Green,30)
label(communityPage,"ConnectionStatus",20,314,460,24,"Community rewards coming soon",16)
local message=label(popup,"Message",20,434,460,22,"",14)
HUD.fit(popup,500,460)
-- User revision: three vertical menu rows, centered hover/press animation.
toggle.Visible=false;training.Visible=false;skins.Visible=false
local dockButtons={open,trails,gift}
local dockKeys={"Rebirth","Trail","Gift"}
local dockCaptions={"Rebirth","Trails","Gifts"}
for i,b in dockButtons do
 b.Text="";b.BackgroundColor3=Color3.fromRGB(78,87,96)
 for _,v in b:GetChildren()do if v:IsA("ImageLabel")then v:Destroy()end end
 local icon=Icons.Image(b,dockKeys[i],UDim2.fromOffset(8,4),UDim2.fromOffset(80,74));icon.Name="TileIcon"
 local caption=b:FindFirstChild("Caption");caption.Text=dockCaptions[i];caption.Position=UDim2.fromOffset(0,73);caption.Size=UDim2.fromOffset(96,23);caption.TextSize=19
end
local percent=label(open,"Percent",0,-8,96,26,"",19)
nextGoal.Visible=false
HUD.fit(dock,212,220,function(v)
 local compact=v.X<700 or v.Y<500;dock.SimulatorScale.Scale=compact and .78 or .88;dock.Size=UDim2.fromOffset(198,214)
 dock.Position=UDim2.fromOffset(12,math.max(55,(gui.AbsoluteSize.Y-214*dock.SimulatorScale.Scale)/2-15))
 for i,b in dockButtons do
  b.Position=UDim2.fromOffset(0,(i-1)*74);b.Size=UDim2.fromOffset(198,66)
  b.TileIcon.Position=UDim2.fromOffset(8,6);b.TileIcon.Size=UDim2.fromOffset(54,54)
  b.Caption.Position=UDim2.fromOffset(72,0);b.Caption.Size=UDim2.fromOffset(118,66);b.Caption.TextSize=22
 end
 open.Caption.Size=UDim2.fromOffset(118,41);percent.Position=UDim2.fromOffset(72,39);percent.Size=UDim2.fromOffset(118,23);percent.TextSize=18
end)

local page="Rebirth";local pending=false
local function val(name)local s=stats:FindFirstChild(name);return s and s.Value or 0 end
local function update()
 local l,x,r,t=val("TrainingLevel"),val("TrainingXP"),val("Rebirths"),val("TrainingTier");if l<0 or t<1 then return end
 local required=C.RebirthRequired(r)
 local ratio=math.clamp(x/C.RequiredXP(l),0,1)
 percent.Text=math.floor(math.clamp((l+ratio)/required,0,1)*100).."%"
 level.Text="Current Level "..l;xpfill.Size=UDim2.fromScale(ratio,1)
 xpText.Text=x.." / "..C.RequiredXP(l).." XP"
 nextGoal.Text=if l>=required then "Rebirth ready!\nYou can keep leveling" else string.format("Rebirth at Level %d\nNext level in %d XP",required,C.RequiredXP(l)-x)
 growthPower.Text="Training Power +"..C.PowerBonus(l,r)
 local multiplier=C.Multiplier(r)*(player:GetAttribute("TrainingXPMultiplier") or 1)*C.XPItems[val("XPGearLvl")].Multiplier
 passiveRate.Text=string.format("Passive XP +%.2f / sec",C.PassiveXPRate(l)*multiplier)
 nowValue.Text=string.format("Current XP Rate\nx%.2f",C.Multiplier(r));nextValue.Text=string.format("After Rebirth\nx%.2f",C.Multiplier(r+1))
 local remainingXP=math.max(0,C.XPBetween(l,required)-x)
 requiredText.Text="Requires Level "..required.." required"
 progressText.Text=string.format("Level %d / %d · %d levels left\n%d XP until rebirth",l,required,math.max(0,required-l),remainingXP);progressText.TextSize=20
 pfill.Size=UDim2.fromScale(math.clamp((l+ratio)/required,0,1),1)
 confirm.Text=if l>=required then "🔄 Rebirth" else "Level "..required.." required"
 confirm.BackgroundColor3=if l>=required then purple else Color3.fromRGB(111,120,141)
 tierValue.Text=C.Tiers[t].Name.." Toilet\nBonus +"..string.format("%.2f",C.Tiers[t].Rate*multiplier).." XP / sec"
 buffs.Text=string.format("Gear XP x%s\nPad x%s · Rebirth x%.2f",C.XPItems[val("XPGearLvl")].Multiplier,player:GetAttribute("TrainingXPMultiplier") or 1,C.Multiplier(r))
 local nextTier=C.Tiers[t+1]
 local meets=nextTier and r>=(nextTier.Rebirths or 0)
 tierButton.Text=if not nextTier then "Best Toilet Unlocked!"else string.format("%s Toilet · Bonus %s XP/sec\nRequires %d rebirths · Current %d\nPress E at the right showroom",nextTier.Name,nextTier.Rate,nextTier.Rebirths or 0,r)
 tierButton.BackgroundColor3=if meets then HUD.Colors.Green else Color3.fromRGB(110,125,142)
 tierButton:SetAttribute("RequiredLevel",nextTier and nextTier.Level);tierButton:SetAttribute("RequiredRebirths",nextTier and nextTier.Rebirths or 0)
 autoCaption.Text="Shop"
 toggle.Text=""
 local item=C.XPItems[val("XPGearLvl")+1]
 op.Text=if item then string.format("%s · XP x%s\nBuy for %d Trophies",item.Name,item.Multiplier,item.Cost)else "Best XP Gear Owned!"
 -- Tutorial (deferred): tap.Text="화면 클릭 +1 XP\n비행 중에도 클릭 가능"
 tap.Text="Click +1 XP"
 toggle.BackgroundColor3=if player:GetAttribute("AutoClickEnabled") then HUD.Colors.Green else Color3.fromRGB(96,123,145)
 local phase=player:GetAttribute("FlightState");dock.Visible=false
 if phase~=nil and phase~="Idle"then popup.Visible=false;shade.Visible=false;player:SetAttribute("ProgressionModalOpen",false) end
end
local function show(kind)
 player:SetAttribute("RocketSkinShopOpen",false)
 page=kind;message.Text="";popup.Visible=true;shade.Visible=true;player:SetAttribute("ProgressionModalOpen",true)
 rebirthPage.Visible=kind=="Rebirth";trainingPage.Visible=kind=="Training";communityPage.Visible=kind=="Community"
 title.Text=if kind=="Rebirth" then "Rebirth" elseif kind=="Training" then "🚽 Toilet Training / Unlock" else "🎁 Group Rewards"
 popup.BackgroundColor3=Color3.fromRGB(30,48,73);update()
end
player:GetAttributeChangedSignal("RocketSkinShopOpen"):Connect(function() if player:GetAttribute("RocketSkinShopOpen") then popup.Visible=false;shade.Visible=false end;update() end)
open.Activated:Connect(function()show("Rebirth")end);gift.Activated:Connect(function()show("Community")end)
close.Activated:Connect(function()popup.Visible=false;shade.Visible=false;player:SetAttribute("ProgressionModalOpen",false) end)
confirm.Activated:Connect(function()
 if pending or val("TrainingLevel")<C.RebirthRequired(val("Rebirths")) then return end
 pending=true;local ok,success,note=pcall(function()return rebirth:InvokeServer(val("Rebirths"))end)
 message.Text=if ok then note or "" else "Try Again";if ok and success then Audio.Play("Upgrade") end;pending=false;update()
end)
tierButton.Activated:Connect(function()
 if pending then return end;pending=true
 local ok,success,note=pcall(function()return buy:InvokeServer(val("TrainingTier")+1)end)
 message.Text=if ok then note or "" else "Try Again";if ok and success then Audio.Play("Upgrade") end;pending=false;update()
end)
local function prepare()message.Text="Coming Soon"end
for _,b in {skip,like,join,claim} do b.Activated:Connect(prepare) end

op.Activated:Connect(function()
 if pending then return end;pending=true
 local ok,success,note=pcall(function()return buyItem:InvokeServer(val("XPGearLvl")+1)end)
 message.Text=if ok then note or ""else "Please try again";if ok and success then Audio.Play("Upgrade")end;pending=false;update()
end)
tap.Activated:Connect(function()click:FireServer()end)
for _,name in {"TrainingLevel","TrainingXP","Rebirths","TrainingTier","Trophies","XPGearLvl"} do local s=stats:WaitForChild(name,15);if s then s.Changed:Connect(update) end end
for _,name in {"TrainingActive","FlightState","AutoClickEnabled","TrainingXPMultiplier","ProgressionModalOpen"} do player:GetAttributeChangedSignal(name):Connect(update) end
update()

player:GetAttributeChangedSignal("HUDPage"):Connect(function()
 if player:GetAttribute("HUDPage")=="Rebirth"then show("Rebirth")else popup.Visible=false;shade.Visible=false end
end)
popup.BackgroundColor3=Color3.fromRGB(30,48,73)
title.Text="Rebirth";require(RS.MenuOverlay).Attach(popup)
close.Activated:Connect(function()player:SetAttribute("HUDPage",nil)end)
shade.Activated:Connect(function()popup.Visible=false;shade.Visible=false;player:SetAttribute("HUDPage",nil)end)
