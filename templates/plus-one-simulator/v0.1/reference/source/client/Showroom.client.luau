local Players=game:GetService("Players");local RS=game:GetService("ReplicatedStorage");local Run=game:GetService("RunService")
local p=Players.LocalPlayer;local stats=p:WaitForChild("leaderstats");local private=p:WaitForChild("ProgressStats")
local UIS=game:GetService("UserInputService")
local leave=RS:WaitForChild("LeaveSharedTraining")
local function leaveOnJump()
 if p:GetAttribute("SharedTrainingTier")then leave:FireServer()end
end
UIS.JumpRequest:Connect(leaveOnJump)
UIS.InputBegan:Connect(function(input,processed)
 if not processed and input.KeyCode==Enum.KeyCode.Space and not UIS:GetFocusedTextBox()then leaveOnJump()end
end)
local Skins=require(RS:WaitForChild("RocketSkinCatalog"));local Growth=require(RS:WaitForChild("ProgressionConfig"));local HUD=require(RS:WaitForChild("SimulatorHUD"))
local gui=Instance.new("ScreenGui");gui.Name="ShowroomGui";gui.ResetOnSpawn=false;HUD.screen(gui,65);gui.Parent=p.PlayerGui
local toast=Instance.new("TextLabel");toast.Name="Feedback";toast.AnchorPoint=Vector2.new(.5,0);toast.Position=UDim2.new(.5,0,0,28);toast.Size=UDim2.new(.7,0,0,60);HUD.text(toast,23);toast.TextWrapped=true;toast.Visible=false;toast.Parent=gui
local function notify()
 toast.Text=p:GetAttribute("ShowroomMessage")or "";toast.TextColor3=p:GetAttribute("ShowroomSuccess")and HUD.Colors.Green or HUD.Colors.Yellow;toast.Visible=true
 local token=p:GetAttribute("ShowroomMessageTime");task.delay(3,function()if p:GetAttribute("ShowroomMessageTime")==token then toast.Visible=false end end)
end
p:GetAttributeChangedSignal("ShowroomMessageTime"):Connect(notify)
local camp=workspace:WaitForChild("CliffCamp",30);if not camp then return end
local rows={}
local function bind(v)
 if not v:IsA("BillboardGui")or v.Name~="DisplayInfo"then return end
 local m=v.Parent.Parent;local rocket=m:GetAttribute("RocketIndex");local tier=m:GetAttribute("TrainingTier")
 if rocket or tier then rows[v]={model=m,index=rocket or tier,rocket=rocket~=nil}end
end
for _,v in camp:GetDescendants()do bind(v)end;camp.DescendantAdded:Connect(bind)
local function update()
 for b,row in rows do
  if not b.Parent then rows[b]=nil;continue end
  local i=row.index;local item=row.rocket and Skins.Items[i]or Growth.Tiers[i]
  local owned=row.rocket and Skins.Owns(private.RocketSkinMask.Value,i)or (not row.rocket and stats.TrainingTier.Value>=i)
  local selected=row.rocket and private.RocketSkinEquipped.Value==i or (not row.rocket and p:GetAttribute("SharedTrainingTier")==i)
  local meets=stats.Rebirths.Value>=(item.Rebirths or 0)and (not row.rocket or stats.Trophies.Value>=item.Cost)
  b.Status.Text=selected and (row.rocket and "Equipped"or "Training")or owned and "Unlocked"or meets and "Unlock Available"or "Locked"
  b.Status.TextColor3=(owned or meets)and HUD.Colors.Green or HUD.Colors.Coral
  b:FindFirstChild("Name").Text=(row.rocket and ""or tostring(i).." · ")..item.Name..(row.rocket and ""or " Toilet")
  b.Ability.Text=row.rocket and string.format("Thrust +%d · Growth +%d%%",item.FlatThrust,math.floor(item.GrowthBoost*100+.5))or "Bonus XP +"..item.Rate.." / sec"
  b.Requirement.Text=row.rocket and string.format("Requires: %d Trophies%s",item.Cost,(item.Rebirths or 0)>0 and " · "..item.Rebirths.." Rebirths"or "")or "Requires: "..(item.Rebirths or 0).." Rebirths"
  local prompt=row.model:FindFirstChild("UseDisplay",true)
  if prompt then prompt.ActionText=selected and (row.rocket and "Equipped"or "Stop Training")or owned and (row.rocket and "Equip"or "Start Training")or meets and (row.rocket and "Buy / Equip"or "Unlock / Train")or "Check Requirements"end
 end
end
for _,name in {"TrainingTier","Trophies","Rebirths"}do stats:WaitForChild(name).Changed:Connect(update)end
for _,name in {"RocketSkinMask","RocketSkinEquipped"}do private:WaitForChild(name).Changed:Connect(update)end
p:GetAttributeChangedSignal("SharedTrainingTier"):Connect(update)
camp.DescendantAdded:Connect(function(v)if v.Name=="Requirement"then task.defer(update)end end);update()
-- Each user sees their own avatar on a shared toilet. Restore original local
-- transparency when they stand up; never change the replicated avatar appearance.
local hidden={};local elapsed=0
Run.RenderStepped:Connect(function(dt)
 elapsed+=dt;if elapsed<.15 then return end;elapsed=0
 local desired={};local own=p:GetAttribute("SharedTrainingTier")
 if own then for _,other in Players:GetPlayers()do if other~=p and other:GetAttribute("SharedTrainingTier")==own and other.Character then
  for _,v in other.Character:GetDescendants()do if v:IsA("BasePart")then desired[v]=true;if hidden[v]==nil then hidden[v]=v.LocalTransparencyModifier end;v.LocalTransparencyModifier=1 end end
 end end end
 for v,original in hidden do if not desired[v]then if v.Parent then v.LocalTransparencyModifier=original end;hidden[v]=nil end end
end)
