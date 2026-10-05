local RS=game:GetService("ReplicatedStorage")
if not require(RS:WaitForChild("RocketModeConfig")).Enabled then return end
local Data=require(script.Parent.PlayerData)
require(script.Parent.Remotes).Ensure().SelectRocketTrail.OnServerInvoke=function(player,index)return Data.SelectRocketTrail(player,index)end
require(script.Parent.Remotes).Ensure().SelectRocketSkin.OnServerInvoke=function(player,index)
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
