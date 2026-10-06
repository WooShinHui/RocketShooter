-- Swept collision advances a fast diver to the actual contact surface, without braking.
local Impact={}
function Impact.Bounds(character,root)
 local offset=root.Size.Y/2;local halfX,halfZ=root.Size.X/2,root.Size.Z/2
 for _,p in character:GetDescendants()do
  if p:IsA("BasePart") and p.CanCollide then
   local cf=p.CFrame;local size=p.Size
   local half=math.abs(cf.RightVector.Y)*size.X/2+math.abs(cf.UpVector.Y)*size.Y/2+math.abs(cf.LookVector.Y)*size.Z/2
   offset=math.max(offset,root.Position.Y-p.Position.Y+half)
   halfX=math.max(halfX,math.abs(p.Position.X-root.Position.X)+math.abs(cf.RightVector.X)*size.X/2+math.abs(cf.UpVector.X)*size.Y/2+math.abs(cf.LookVector.X)*size.Z/2)
   halfZ=math.max(halfZ,math.abs(p.Position.Z-root.Position.Z)+math.abs(cf.RightVector.Z)*size.X/2+math.abs(cf.UpVector.Z)*size.Y/2+math.abs(cf.LookVector.Z)*size.Z/2)
  end
 end
 return offset,halfX,halfZ
end
function Impact.BottomOffset(character,root)
 local offset=Impact.Bounds(character,root);return offset
end
function Impact.Sweep(world,character,root,velocity,dt,previous)
 if velocity.Y>=0 then return nil end
 local delta=velocity*math.clamp(dt,0,.1)
 local offset=Impact.BottomOffset(character,root)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={character};params.RespectCanCollide=true
 local start=previous or root.Position
 local hit=world:Raycast(start-Vector3.new(0,offset,0),root.Position-start+delta,params)
 if not hit then return nil end
 return hit,hit.Position+Vector3.new(0,offset,0)
end
return Impact
