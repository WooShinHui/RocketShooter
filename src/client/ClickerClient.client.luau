local Players=game:GetService("Players");local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer;local stats=player:WaitForChild("leaderstats")
local UI=require(RS:WaitForChild("ClickerUI"));local Config=require(RS:WaitForChild("ClickerConfig"));local Growth=require(RS:WaitForChild("ProgressionConfig"))
local HUD=require(RS:WaitForChild("SimulatorHUD"))
local click=RS:WaitForChild("ClickTraining");local toggle=RS:WaitForChild("ToggleAutoClick")
local gui=Instance.new("ScreenGui");gui.Name="ClickerGui";gui.ResetOnSpawn=false;HUD.screen(gui,45);gui:SetAttribute("UIReference",UI.Version);gui.Parent=player:WaitForChild("PlayerGui")
local view=UI.Progress(gui)
local dock=Instance.new("Frame");dock.Name="ClickerButtons";dock.BackgroundTransparency=1;dock.Size=UDim2.fromOffset(228,178);dock.AnchorPoint=Vector2.new(1,.5);dock.Position=UDim2.new(1,-18,.55,0);dock.Parent=gui
local op=UI.Button(dock,"OP");local free=UI.Button(dock,"Free");free.Button.Position=UDim2.fromOffset(0,94)
HUD.fit(dock,228,300,function(v)
 dock.SimulatorScale.Scale=if v.X<700 or v.Y<500 then .70 else 1
 dock.AnchorPoint=if v.X<700 then Vector2.new(1,0)else Vector2.new(1,.5)
 dock.Position=if v.X<700 then UDim2.new(1,-10,0,150)else UDim2.new(1,-18,.55,0)
end)
local function resize()
 local width=gui.AbsoluteSize.X;if width<=0 then return end
 UI.ResizeProgress(view,width,width<700 or gui.AbsoluteSize.Y<500)
 local phase=player:GetAttribute("FlightState")
 view.Frame.Visible=not player:GetAttribute("ProgressionModalOpen")and (not (width<700 or gui.AbsoluteSize.Y<500)or phase==nil or phase=="Idle")
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize()
local function value(name)local v=stats:FindFirstChild(name);return v and v.Value or 0 end
local function update()
 local level,xp,rebirths=value("TrainingLevel"),value("TrainingXP"),value("Rebirths")
 local private=player:FindFirstChild("ProgressStats");local base=private and private:FindFirstChild("PowerLvl")
 local skins=require(RS:WaitForChild("RocketSkinCatalog"));local trails=require(RS:WaitForChild("RocketTrailCatalog"))
 local skin=private and private:FindFirstChild("RocketSkinEquipped");local trail=private and private:FindFirstChild("RocketTrailEquipped")
 local flat,growth=require(RS:WaitForChild("EquipmentPower")).Bonuses(skins.Items[skin and skin.Value or 1],trails.Items[trail and trail.Value or 1])
 local power=tostring((base and base.Value or 1)+Growth.PowerBonus(level,rebirths)).." · 추력 +"..flat.." / 성장 +"..math.floor(growth*100+.5).."%"
 UI.UpdateProgress(view,level,xp,Growth.RequiredXP(level),power)
 local mode=player:GetAttribute("AutoClickMode")or "Off"
 UI.UpdateButton(free,mode=="Free");UI.UpdateButton(op,mode=="OP")
 if player:GetAttribute("OPAutoClickAvailable")==false then op.Action.Text="준비 중"end
 -- Tutorial (deferred): view.Hint.Text="화면 클릭 +1 XP"
 view.Hint.Text="";view.Hint.Visible=false
 local phase=player:GetAttribute("FlightState");dock.Visible=(phase==nil or phase=="Idle")and not player:GetAttribute("ProgressionModalOpen")
 view.Frame.Visible=not player:GetAttribute("ProgressionModalOpen")
 resize()
end
local equipment=player:WaitForChild("ProgressStats")
for _,name in {"RocketSkinEquipped","RocketTrailEquipped"}do equipment:WaitForChild(name).Changed:Connect(update)end
local pending=false
local function selectMode(mode)
 if pending then return end
 pending=true;local target=player:GetAttribute("AutoClickMode")==mode and "Off"or mode
 local ok,success,note=pcall(function()return toggle:InvokeServer(target)end)
 if not ok or not success then view.Hint.Text=ok and note or "잠시 후 다시 눌러 주세요"end
 pending=false;update()
end
free.Button.Activated:Connect(function()selectMode("Free")end);op.Button.Activated:Connect(function()selectMode("OP")end)
local function manual(processed)
 if processed or UIS:GetFocusedTextBox()or player:GetAttribute("ProgressionModalOpen")then return end
 click:FireServer()
end
UIS.InputBegan:Connect(function(input,processed)if input.UserInputType==Enum.UserInputType.MouseButton1 then manual(processed)end end)
-- Taps award once; camera drags, held joystick touches and multi-touch do not repeat.
UIS.TouchTapInWorld:Connect(function(_,processed)manual(processed)end)
for _,name in {"TrainingLevel","TrainingXP","Rebirths"}do stats:WaitForChild(name).Changed:Connect(update)end
for _,name in {"AutoClickMode","FlightState","OPAutoClickAvailable","ProgressionModalOpen"}do player:GetAttributeChangedSignal(name):Connect(update)end
update()
