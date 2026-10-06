local Pose={}
function Pose.Create(character)
 local p={Joints={}}
 for _,j in character:GetDescendants()do
  if j:IsA("Motor6D") and j.Name:lower():find("shoulder") then
   p.Joints[j]=j.C0
   j.C0=j.C0*CFrame.Angles(0,0,math.rad(j.Name:lower():find("left") and -12 or 12))
  end
 end
 return p
end
function Pose.Dive(p)
 if not p then return end
 for j,original in p.Joints do if j.Parent then j.C0=original*CFrame.Angles(math.rad(-25),0,math.rad(j.Name:lower():find("left") and -22 or 22)) end end
end
function Pose.Restore(p)
 if not p then return end
 for j,original in p.Joints do if j.Parent then j.C0=original end end
end
return Pose
