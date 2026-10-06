local RS=game:GetService("ReplicatedStorage")
if not require(RS:WaitForChild("RocketModeConfig")).Enabled then return end
local Data=require(script.Parent.PlayerData)
require(script.Parent.Remotes).Ensure().SelectRocketTrail.OnServerInvoke=function(player,index)return Data.SelectRocketTrail(player,index)end
require(script.Parent.Remotes).Ensure().SelectRocketSkin.OnServerInvoke=function(player,index)
 local camp=workspace:FindFirstChild("CliffCamp");local displays=camp and camp:FindFirstChild("RocketDisplays")
 local item=require(RS.RocketSkinCatalog).Items[index];local display=item and displays and displays:FindFirstChild(item.Id)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if display then if not root or (root.Position-display.Pedestal.Position).Magnitude>14 then return false,"Press E at the left showroom to unlock / equip"end
 else
  local private=player:FindFirstChild("ProgressStats");if not item or not private or not require(RS.RocketSkinCatalog).Owns(private.RocketSkinMask.Value,index)then return false,"Only displayed rockets can be purchased"end
 end
 return Data.SelectRocketSkin(player,index)
end

-- Preview the exact wearable meshes, without scripts, physics or live effects.
local Rocket=require(script.Parent.BackRocket)
local Catalog=require(RS:WaitForChild("RocketSkinCatalog"))
local previews=Instance.new("Folder");previews.Name="RocketSkinPreviews"
for _,item in Catalog.Items do
 local dummy=Instance.new("Model");local torso=Instance.new("Part");torso.Name="UpperTorso";torso.Anchored=true;torso.Parent=dummy
 Rocket.Attach(dummy,item.Id)
 local model=dummy:FindFirstChild("BackRocket");model.Name=item.Id
 for _,v in model:GetDescendants() do
  if v:IsA("BasePart") then v.Anchored=true end
  if v:IsA("WeldConstraint") then v:Destroy() end
 end
 model.Parent=previews;dummy:Destroy()
end
previews.Parent=RS
