-- Real assembly separation on successful landing; the next character is a fresh rig.
local Landing={}
function Landing.Burst(character,root)
 if character:GetAttribute("LandingBurstDone") then return 0 end
 character:SetAttribute("LandingBurstDone",true)
 local joints,limbs={},{}
 for _,joint in character:GetDescendants() do
  if not joint:IsA("Motor6D") and not joint:IsA("Constraint") then continue end
  local name=joint.Name:lower()
  if not name:find("shoulder") and not name:find("hip") then continue end
  local limb
  if joint:IsA("Motor6D") then limb=joint.Part1
  else limb=joint.Attachment1 and joint.Attachment1.Parent end
  while limb and not limb:IsA("BasePart") do limb=limb.Parent end
  if limb then table.insert(joints,joint);limbs[limb]=true end
 end
 for _,joint in joints do joint:Destroy() end
 local count=0
 for limb in limbs do
  count+=1
  limb:SetAttribute("LandingDetached",true);limb.CanCollide=true
  local angle=count*math.pi/2+.4
  local direction=Vector3.new(math.cos(angle)*32,42,math.sin(angle)*32)
  pcall(function()limb:SetNetworkOwner(nil)end)
  limb.AssemblyLinearVelocity=direction
  limb.AssemblyAngularVelocity=Vector3.new(count%2==0 and 9 or -9,6,12)
 end
 return count
end
return Landing
