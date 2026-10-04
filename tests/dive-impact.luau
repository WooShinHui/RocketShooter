do
 local env=environment();local V=env.Vector3;V.one=V.new(1,1,1)
 local course=newBreakCourse(env);local position=V.new(0,140000,0)
 local slow=course.Plan(position,V.new(0,-180,0),196.2,200,true)
 local fast=course.Plan(position,V.new(0,-24000,0),196.2,200,true)
 check(#slow==32 and #fast==32,"dive encounters keep progression chain lengths")
 check(near(slow[1].Position.Y,fast[1].Position.Y) and near(slow[32].Position.Y,fast[32].Position.Y),"dive course spacing stays readable independently of fall speed")
 check(position.Y-slow[1].Position.Y>=160 and slow[1].Position.Y-slow[2].Position.Y==18,"dive pack gives advance notice and fixed chain spacing")
 for _,r in fast do r.Dive=true end
 local nearest,left=course.DiveTarget({Rows=fast},position)
 check(left==32 and nearest==fast[1],"dive guidance selects nearest unbroken target below player")
 fast[1].Hit=true;nearest,left=course.DiveTarget({Rows=fast},position)
 check(left==31 and nearest==fast[2],"target guidance advances after each destruction")
 nearest,left=course.DiveTarget({Rows=fast},V.new(0,100000,0))
 check(nearest==nil and left==0,"passed targets cannot hold descent in slow mode")
 local character=env.Instance.new("Model");local root=env.Instance.new("Part");root.Parent=character
 local torso=env.Instance.new("Part");torso.Parent=character
 local neck=env.Instance.new("Motor6D");neck.Name="Neck";neck.Part1=root;neck.Parent=torso
 for _,name in {"LeftShoulder","RightShoulder","LeftHip","RightHip"} do
  local limb=env.Instance.new("Part");limb.Name=name;limb.Parent=character
  local joint=env.Instance.new("Motor6D");joint.Name=name;joint.Part1=limb;joint.Parent=torso
 end
 local landing=newLimbLanding(env)
 check(landing.Burst(character,root)==4,"successful landing actually disconnects four limb assemblies")
 check(neck.Parent==torso,"landing leaves head and body joint intact")
 local detached=0;for _,part in character:GetChildren() do if part:GetAttribute("LandingDetached") then detached+=1;check(part.AssemblyLinearVelocity.Y>0,"detached limb receives visible upward burst velocity") end end
 check(detached==4 and landing.Burst(character,root)==0,"landing separation is idempotent")
 local modern=env.Instance.new("Model");local torso2=env.Instance.new("Part");torso2.Parent=modern
 local arm=env.Instance.new("Part");arm.Parent=modern
 local attachment=env.Instance.new("Attachment");attachment.Parent=arm
 local nested=env.Instance.new("Attachment");nested.Parent=attachment
 for _,name in {"LeftShoulder","LeftShoulderBallSocket"} do
  local joint=env.Instance.new("Constraint");joint.Name=name;joint.Attachment1=nested;joint.Parent=arm
 end
 local neck2=env.Instance.new("Constraint");neck2.Name="Neck";neck2.Attachment1=attachment;neck2.Parent=torso2
 check(landing.Burst(modern,torso2)==1,"modern constraint pairs detach one limb without duplicate counting")
 check(#arm:GetChildren()==1 and neck2.Parent==torso2,"modern landing removes both shoulder constraints and preserves neck")
end
