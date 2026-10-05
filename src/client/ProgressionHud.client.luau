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
local dock=Instance.new("Frame");dock.Name="GrowthDock";dock.BackgroundTransparency=1;dock.Size=UDim2.fromOffset(212,420);dock.Parent=gui
local open=button(dock,"OpenRebirth",0,0,96,100,"",purple,54);Icons.Image(open,"Rebirth",UDim2.fromOffset(20,8),UDim2.fromOffset(56,56))
local training=button(dock,"OpenTraining",112,0,96,100,"🚽",HUD.Colors.Blue,48)
label(open,"Caption",0,74,96,26,"환생",16);label(training,"Caption",0,74,96,26,"수련",16)
local gift=button(dock,"OpenCommunity",0,114,96,100,"",HUD.Colors.Yellow,48);Icons.Image(gift,"Gift",UDim2.fromOffset(20,8),UDim2.fromOffset(56,56))
local toggle=button(dock,"AutoClick",112,114,96,100,"",HUD.Colors.Green,40);Icons.Image(toggle,"Upgrade",UDim2.fromOffset(20,8),UDim2.fromOffset(56,56))
label(gift,"Caption",0,74,96,26,"선물",16);local autoCaption=label(toggle,"Caption",0,74,96,26,"자동 수련",13)
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
Icons.Image(skins,"Rocket",UDim2.fromOffset(10,6),UDim2.fromOffset(36,36));label(skins,"Caption",52,0,150,48,"로켓",22)
local trails=button(dock,"OpenTrails",0,284,208,48,"",HUD.Colors.Blue,24)
Icons.Image(trails,"Trail",UDim2.fromOffset(10,6),UDim2.fromOffset(36,36));label(trails,"Caption",52,0,150,48,"트레일",22)
trails.Activated:Connect(function()if player:GetAttribute("FlightState")~="Flying"then player:SetAttribute("RocketEquipmentTab","Trails");player:SetAttribute("RocketSkinShopOpen",true)end end)
skins.Activated:Connect(function() if player:GetAttribute("FlightState")~="Flying" then player:SetAttribute("RocketEquipmentTab","Rockets");player:SetAttribute("RocketSkinShopOpen",true) end end)
local shade=button(gui,"ModalShade",0,0,1,1,"",HUD.Colors.Ink);shade.Size=UDim2.fromScale(1,1);shade.BackgroundTransparency=.35;shade.ZIndex=10;shade.Visible=false
local popup=box(gui,"RebirthPanel",0,0,500,460,HUD.Colors.Blue);popup.AnchorPoint=Vector2.new(.5,.5);popup.Position=UDim2.fromScale(.5,.5);popup.ZIndex=11;popup.Visible=false
local title=label(popup,"Title",20,12,372,48,"🔄 환생",32)
local close=button(popup,"Close",408,10,80,76,"×",HUD.Colors.Coral,42)
local content=Instance.new("Frame");content.Name="Content";content.Position=UDim2.fromOffset(0,84);content.Size=UDim2.fromOffset(500,346);content.BackgroundTransparency=1;content.Parent=popup
local rebirthPage=Instance.new("Frame");rebirthPage.Name="RebirthPage";rebirthPage.Size=UDim2.fromScale(1,1);rebirthPage.BackgroundTransparency=1;rebirthPage.Parent=content
local requirement=box(rebirthPage,"RequiredLevel",88,0,324,48,HUD.Colors.Yellow)
local requiredText=label(requirement,"Value",0,0,324,48,"환생에 레벨 20 필요",25)
local current=box(rebirthPage,"CurrentCard",20,60,194,84,HUD.Colors.Green)
local nextCard=box(rebirthPage,"NextCard",286,60,194,84,HUD.Colors.Green)
local nowValue=label(current,"Value",0,0,194,84,"",23);local nextValue=label(nextCard,"Value",0,0,194,84,"",23)
label(rebirthPage,"Arrow",222,70,55,64,"▶",40)
label(rebirthPage,"MultiplierMeaning",20,145,460,20,"기본·비행·변기 경험치가 더 빨리 쌓여요",14)
local progress=box(rebirthPage,"LevelProgress",20,163,460,48,HUD.Colors.Ink)
local pfill=box(progress,"Fill",0,0,1,48,HUD.Colors.Blue)
local progressText=label(progress,"Value",0,0,460,48,"",22);progressText.ZIndex=2
local confirm=button(rebirthPage,"ConfirmRebirth",20,227,294,82,"🔄 환생",purple,28)
local skip=button(rebirthPage,"SkipRebirth",326,227,154,82,"환생 건너뛰기",HUD.Colors.Green,19)
label(skip,"Caption",0,57,154,22,"준비 중",16)
label(rebirthPage,"ResetNote",20,315,460,24,"환생하면 레벨 0 / XP 초기화 · 변기·트로피·기록 유지",14)
local trainingPage=Instance.new("Frame");trainingPage.Name="TrainingPage";trainingPage.Size=UDim2.fromScale(1,1);trainingPage.BackgroundTransparency=1;trainingPage.Visible=false;trainingPage.Parent=content
local toiletIcon=label(trainingPage,"ToiletIcon",20,0,150,136,"🚽",86)
local tierValue=label(trainingPage,"TierValue",176,0,304,60,"",24)
local buffs=label(trainingPage,"Buffs",176,65,304,60,"",20,HUD.Colors.Yellow)
local tierButton=button(trainingPage,"BuyTier",20,157,460,82,"",HUD.Colors.Green,20)
local tap=button(trainingPage,"TapXP",20,255,220,82,"클릭 수련\n경험치 +1 XP",HUD.Colors.Yellow,22)
local op=button(trainingPage,"OPAuto",252,255,228,82,"고속 자동 수련\n준비 중",purple,22)
local communityPage=Instance.new("Frame");communityPage.Name="CommunityPage";communityPage.Size=UDim2.fromScale(1,1);communityPage.BackgroundTransparency=1;communityPage.Visible=false;communityPage.Parent=content
label(communityPage,"GiftIcon",290,10,180,150,"🎁",96)
local like=button(communityPage,"Like",20,15,254,82,"♥ 좋아요",HUD.Colors.Coral)
local join=button(communityPage,"Join",20,112,254,82,"✚ 가입",HUD.Colors.Blue)
local claim=button(communityPage,"Claim",20,227,460,82,"🎁 받기",HUD.Colors.Green,30)
label(communityPage,"ConnectionStatus",20,314,460,24,"커뮤니티 연결 준비 중",16)
local message=label(popup,"Message",20,434,460,22,"",14)
HUD.fit(popup,500,460)
HUD.fit(dock,212,420,function(v)
 local landscape=v.Y<500 and v.X>v.Y
 dock.SimulatorScale.Scale=if landscape then .78 elseif v.X<700 then .78 else 1
 nextGoal.Visible=not landscape
 if landscape then
  skins.Position=UDim2.fromOffset(0,228);skins.Size=UDim2.fromOffset(96,68);skins.Caption.Position=UDim2.fromOffset(0,42);skins.Caption.Size=UDim2.fromOffset(96,24);skins.Caption.TextSize=18;skins.RocketIcon.Position=UDim2.fromOffset(30,4)
  trails.Position=UDim2.fromOffset(112,228);trails.Size=UDim2.fromOffset(96,68);trails.Caption.Position=UDim2.fromOffset(0,42);trails.Caption.Size=UDim2.fromOffset(96,24);trails.Caption.TextSize=18;trails.TrailIcon.Position=UDim2.fromOffset(30,4)
 else
  skins.Position=UDim2.fromOffset(0,228);skins.Size=UDim2.fromOffset(208,48);skins.Caption.Position=UDim2.fromOffset(52,0);skins.Caption.Size=UDim2.fromOffset(150,48);skins.Caption.TextSize=22;skins.RocketIcon.Position=UDim2.fromOffset(10,6)
  trails.Position=UDim2.fromOffset(0,284);trails.Size=UDim2.fromOffset(208,48);trails.Caption.Position=UDim2.fromOffset(52,0);trails.Caption.Size=UDim2.fromOffset(150,48);trails.Caption.TextSize=22;trails.TrailIcon.Position=UDim2.fromOffset(10,6)
 end
 dock.Position=UDim2.fromOffset(12,HUD.leftDockTop(v))
end)
local page="Rebirth";local pending=false
local function val(name)local s=stats:FindFirstChild(name);return s and s.Value or 0 end
local function update()
 local l,x,r,t=val("TrainingLevel"),val("TrainingXP"),val("Rebirths"),val("TrainingTier");if l<0 or t<1 then return end
 local required=C.RebirthRequired(r)
 local ratio=math.clamp(x/C.RequiredXP(l),0,1)
 level.Text="현재 레벨 "..l;xpfill.Size=UDim2.fromScale(ratio,1)
 xpText.Text=x.." / "..C.RequiredXP(l).." XP"
 nextGoal.Text=if l>=required then "환생 가능!\n계속 성장할 수도 있어요" else string.format("환생 목표 레벨 %d\n다음 레벨까지 %d XP",required,C.RequiredXP(l)-x)
 growthPower.Text="수련 추진력 +"..C.PowerBonus(l,r)
 local multiplier=C.Multiplier(r)*(player:GetAttribute("TrainingXPMultiplier") or 1)*C.XPItems[val("XPGearLvl")].Multiplier
 passiveRate.Text=string.format("자동 경험치 +%.2f / 초",C.PassiveXPRate(l)*multiplier)
 nowValue.Text=string.format("현재 수련 속도\nx%.2f",C.Multiplier(r));nextValue.Text=string.format("환생 후 수련 속도\nx%.2f",C.Multiplier(r+1))
 local remainingXP=math.max(0,C.XPBetween(l,required)-x)
 requiredText.Text="환생에 레벨 "..required.." 필요"
 progressText.Text=string.format("레벨 %d / %d · %d레벨 남음\n환생까지 경험치 %d XP 남음",l,required,math.max(0,required-l),remainingXP);progressText.TextSize=20
 pfill.Size=UDim2.fromScale(math.clamp((l+ratio)/required,0,1),1)
 confirm.Text=if l>=required then "🔄 환생하기" else "레벨 "..required.." 필요"
 confirm.BackgroundColor3=if l>=required then purple else Color3.fromRGB(111,120,141)
 tierValue.Text=C.Tiers[t].Name.." 변기\n추가 +"..string.format("%.2f",C.Tiers[t].Rate*multiplier).." XP / 초"
 buffs.Text=string.format("아이템 경험치 x%s\n발판 x%s · 환생 x%.2f",C.XPItems[val("XPGearLvl")].Multiplier,player:GetAttribute("TrainingXPMultiplier") or 1,C.Multiplier(r))
 local nextTier=C.Tiers[t+1]
 local meets=nextTier and l>=nextTier.Level and r>=(nextTier.Rebirths or 0) and val("Trophies")>=nextTier.Cost
 tierButton.Text=if not nextTier then "최고 변기 해금 완료!" else string.format("%s 변기 해금 · 추가 %s XP/초\n레벨 %d / 환생 %d회 / 트로피 %d 필요\n현재 %d레벨 · 환생 %d회 · 트로피 %d",nextTier.Name,nextTier.Rate,nextTier.Level,nextTier.Rebirths or 0,nextTier.Cost,l,r,val("Trophies"))
 tierButton.BackgroundColor3=if meets then HUD.Colors.Green else Color3.fromRGB(110,125,142)
 tierButton:SetAttribute("RequiredLevel",nextTier and nextTier.Level);tierButton:SetAttribute("RequiredRebirths",nextTier and nextTier.Rebirths or 0)
 autoCaption.Text="XP 아이템"
 toggle.Text=""
 local item=C.XPItems[val("XPGearLvl")+1]
 op.Text=if item then string.format("%s · 경험치 x%s\n트로피 %d 구매",item.Name,item.Multiplier,item.Cost)else "최고 경험치 아이템 보유!"
 -- Tutorial (deferred): tap.Text="화면 클릭 +1 XP\n비행 중에도 클릭 가능"
 tap.Text="클릭 +1 XP"
 toggle.BackgroundColor3=if player:GetAttribute("AutoClickEnabled") then HUD.Colors.Green else Color3.fromRGB(96,123,145)
 local phase=player:GetAttribute("FlightState");dock.Visible=(phase==nil or phase=="Idle")and not player:GetAttribute("RocketSkinShopOpen")
 if phase~=nil and phase~="Idle"then popup.Visible=false;shade.Visible=false;player:SetAttribute("ProgressionModalOpen",false) end
end
local function show(kind)
 player:SetAttribute("RocketSkinShopOpen",false)
 page=kind;message.Text="";popup.Visible=true;shade.Visible=true;player:SetAttribute("ProgressionModalOpen",true)
 rebirthPage.Visible=kind=="Rebirth";trainingPage.Visible=kind=="Training";communityPage.Visible=kind=="Community"
 title.Text=if kind=="Rebirth" then "🔄 환생" elseif kind=="Training" then "🚽 변기 수련 / 해금" else "🎁 그룹 보상"
 popup.BackgroundColor3=if kind=="Community" then HUD.Colors.Yellow else HUD.Colors.Blue;update()
end
player:GetAttributeChangedSignal("RocketSkinShopOpen"):Connect(function() if player:GetAttribute("RocketSkinShopOpen") then popup.Visible=false;shade.Visible=false end;update() end)
open.Activated:Connect(function()show("Rebirth")end);training.Activated:Connect(function()show("Training")end);gift.Activated:Connect(function()show("Community")end)
close.Activated:Connect(function()popup.Visible=false;shade.Visible=false;player:SetAttribute("ProgressionModalOpen",false) end)
confirm.Activated:Connect(function()
 if pending or val("TrainingLevel")<C.RebirthRequired(val("Rebirths")) then return end
 pending=true;local ok,success,note=pcall(function()return rebirth:InvokeServer(val("Rebirths"))end)
 message.Text=if ok then note or "" else "다시 시도";if ok and success then Audio.Play("Upgrade") end;pending=false;update()
end)
tierButton.Activated:Connect(function()
 if pending then return end;pending=true
 local ok,success,note=pcall(function()return buy:InvokeServer(val("TrainingTier")+1)end)
 message.Text=if ok then note or "" else "다시 시도";if ok and success then Audio.Play("Upgrade") end;pending=false;update()
end)
local function prepare()message.Text="준비 중"end
for _,b in {skip,like,join,claim} do b.Activated:Connect(prepare) end
toggle.Activated:Connect(function()show("Training")end)
op.Activated:Connect(function()
 if pending then return end;pending=true
 local ok,success,note=pcall(function()return buyItem:InvokeServer(val("XPGearLvl")+1)end)
 message.Text=if ok then note or ""else "다시 시도해 주세요";if ok and success then Audio.Play("Upgrade")end;pending=false;update()
end)
tap.Activated:Connect(function()click:FireServer()end)
for _,name in {"TrainingLevel","TrainingXP","Rebirths","TrainingTier","Trophies","XPGearLvl"} do local s=stats:WaitForChild(name,15);if s then s.Changed:Connect(update) end end
for _,name in {"TrainingActive","FlightState","AutoClickEnabled","TrainingXPMultiplier","ProgressionModalOpen"} do player:GetAttributeChangedSignal(name):Connect(update) end
update()
