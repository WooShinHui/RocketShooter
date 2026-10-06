-- Three fixed, run-owned landing choices. Server swept collision owns every award.
local RS=game:GetService("ReplicatedStorage")
local Visual=require(RS:WaitForChild("CourseVisualConfig"))
local Rewards=require(RS:WaitForChild("DestructionRewardConfig"))
local Gates=require(RS:WaitForChild("CloudConfig")).HeightPresentation.Gates
local Families=require(RS:WaitForChild("GateEncounterConfig"))
local Rules=require(script.Parent.RocketRules)
local Zone={Enabled=true}
function Zone.Plan(height,speed,topOverride)
 if height<80 then return {}end
 speed=math.clamp(speed or height/7,90,3600)
 local top=topOverride or height-math.min(height*.12,speed*2)
 if top<=45 then return {}end
 local bottom=math.max(25,top-speed*3);local rows={}
 for _,lane in {0,-1,1}do
  table.insert(rows,{Height=(top+bottom)/2,Top=top,Bottom=bottom,Layer=1,Lane=lane,Offset=lane*260,Units=lane==0 and 1 or 3,Size=Vector3.new(240,top-bottom,320)})
 end
 return rows
end
function Zone.Create(player,id,parent,score,groundY)
 local folder=Instance.new("Folder");folder.Name="DiveBreakZone";folder:SetAttribute("PlayerId",player.UserId);folder:SetAttribute("RunId",id);folder.Parent=parent
 return {Player=player,Id=id,Folder=folder,Rows={},Rings={},Enemies={},Score=score,Hits=0,BonusHits=0,RingHits=0,EnemyHits=0,GroundY=groundY or 0}
end
local function part(parent,name,size,position,color)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=position;p.CFrame=CFrame.new(position);p.Color=color;p.Material=Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent;return p
end
local function frame(z,position)
 return CFrame.lookAt(position,position+Vector3.yAxis:Cross(z.Basis or Vector3.new(1,0,0)))
end
function Zone.Update(z,position,velocity,diving,basis)
 if not Zone.Enabled or not diving then return end
 local height=position.Y-z.GroundY
 if not z.Origin then
  z.Basis=basis or Vector3.new(1,0,0);z.Origin=position;z.LayoutSpeed=math.clamp(height/7,90,3600);z.Section=0
  local plan=Zone.Plan(height,z.LayoutSpeed);z.NextTop=plan[1]and plan[1].Top or 0
 end
 if not z.FlightExtras then Zone.Extras(z,position)end
 for i=#z.Rows,1,-1 do local r=z.Rows[i]
  if z.LastY and z.LastY<r.Bottom-12 then r.Model:Destroy();table.remove(z.Rows,i)
  elseif position.Y<r.Bottom-12 then r.Model:SetAttribute("Passed",true)end
 end
 z.LastY=position.Y
 if #z.Rows>=6 or z.NextTop<=45 or height>z.NextTop+z.LayoutSpeed*2 then return end
 z.Spawned=true;z.Section+=1
 local plan=Zone.Plan(height,z.LayoutSpeed,z.NextTop);if #plan==0 then return end
 z.NextTop=plan[1].Bottom-math.max(35,z.LayoutSpeed*.4)
 for _,r in plan do
  r.Layer=z.Section;r.Top+=z.GroundY;r.Bottom+=z.GroundY
  r.Position=Vector3.new(z.Origin.X,r.Height+z.GroundY,z.Origin.Z)+z.Basis*r.Offset;r.Frame=frame(z,r.Position)
  r.Color=r.Lane==0 and Color3.fromRGB(102,229,255)or Color3.fromRGB(255,202,62)
  local m=Instance.new("Model");m.Name="DiveLayer"..r.Layer.."Lane"..r.Lane;m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
  for key,value in {TargetKind="Block",LayerIndex=r.Layer,Lane=r.Lane,WindowTop=r.Top,WindowBottom=r.Bottom,RewardUnits=r.Units,Broken=false,TrophyAmount=Rewards.Reward(r.Units,r.Height)}do m:SetAttribute(key,value)end
  local hit=part(m,"TargetBounds",r.Size,r.Position,r.Color);hit.CFrame=r.Frame;hit.Transparency=1;m.PrimaryPart=hit
  -- Visual lanes must not overlap the adjacent lane260 studs away.
  -- Collision windows remain unchanged; only decorative blocks are narrowed.
  local columns=3;local cellX=math.min(r.Size.X,240)/columns
  local thickness=math.min(24,r.Size.Y)
  local checkpoints=math.clamp(math.floor((r.Size.Y-thickness)/32)+1,1,10)
  local span=math.max(0,r.Size.Y-thickness)
  for checkpoint=0,checkpoints-1 do for x=1,columns do for depth=-1,1,2 do
   local size=Vector3.new(cellX-2,thickness,138)
   local color=Visual.Color(r.Top-r.Size.Y*(checkpoints==1 and .5 or checkpoint/(checkpoints-1)),z.Id+r.Layer*13+checkpoint+x+depth)
   local p=part(m,"BreakButter",size,r.Position,color);p.CFrame=r.Frame*CFrame.new((x-(columns+1)/2)*cellX,span*(checkpoints==1 and 0 or .5-checkpoint/(checkpoints-1)),depth*80)
   if Visual.Style=="Butter"then
    local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.FileMesh;mesh.MeshId=Visual.Mesh;mesh.Scale=Vector3.new(size.X/Visual.MeshSize[1],size.Y/Visual.MeshSize[2],size.Z/Visual.MeshSize[3]);mesh.Parent=p
   end
  end end end
  m.Parent=z.Folder;r.Model=m;table.insert(z.Rows,r)
 end
end
function Zone.Sample(z,from,to,diving,touches,emit)
 if not diving or to.Y>=from.Y then return 0,0 end
 local score,hits=0,0
 for _,r in z.Rows do if not r.Hit and touches(r,from,to)then
  r.Hit=true;z.Hits+=1;if r.Lane~=0 then z.BonusHits+=1 end
  score+=z.Score*r.Units;hits+=1;r.Model:SetAttribute("Broken",true)
  for _,p in r.Model:GetDescendants()do if p:IsA("BasePart")then p.Transparency=1 end end
  emit({Position=to,RewardPosition=r.Position,Size=Vector3.new(78,24,138),Color=r.Color,VisualKind=Visual.Style,MaterialTag="Ruin",Index=r.Layer,Award=z.Score*r.Units,
   ChainLength=z.Section,RunId=z.Id,Character=z.Player.Character,CourseHit=true,DiveZone=true,RewardUnits=r.Units})
 end end
 for _,r in z.Rings do if not r.Hit and Zone.Crosses(r.Position,from,to,r.Radius)then
  r.Hit=true;z.RingHits+=1;z.Folder:SetAttribute("RingHits",z.RingHits)
  r.Model:SetAttribute("Broken",true);for _,p in r.Model:GetDescendants()do if p:IsA("BasePart")then p.Transparency=1 end end
  score+=z.Score;hits+=1
  emit({Position=r.Position,Size=Vector3.new(10,10,10),Color=Color3.fromRGB(119,255,177),MaterialTag="Ruin",Index=z.RingHits,Award=z.Score,RunId=z.Id,Character=z.Player.Character,DiveZone=true,DiveRing=true,RewardUnits=1})
 end end
 for _,r in z.Enemies do if not r.Hit and touches(r,from,to)then
  r.Hit=true;z.EnemyHits+=1;r.Model:SetAttribute("Broken",true)
  for _,p in r.Model:GetDescendants()do if p:IsA("BasePart")then p.Transparency=1 end end
  score+=z.Score;hits+=1
  emit({Position=r.Position,Size=r.Size,Color=Color3.fromRGB(255,167,91),MaterialTag="Ruin",Index=z.EnemyHits,Award=z.Score,RunId=z.Id,Character=z.Player.Character,DiveZone=true,DiveEnemy=true,Pierce=true,RewardUnits=1})
 end end
 return score,hits
end
function Zone.Crosses(center,from,to,radius)
 local dy=to.Y-from.Y;if dy>=0 then return false end
 local t=(center.Y-from.Y)/dy;if t<0 or t>1 then return false end
 local p=from+(to-from)*t;return Vector3.new(p.X-center.X,0,p.Z-center.Z).Magnitude<=radius+3
end
function Zone.RingPlan(height)
 local rows={};local speed,drop,time,last=0,0,0,0
 local target=math.clamp(height/10,90,2400)
 for i=1,10 do
  local at=.8+(i-1)*.5
  while time<at do speed=Rules.DiveSpeed(speed,target,196.2,time,.05);drop+=speed*.05;time+=.05 end
  local distance=math.max(drop,last+35);if height-distance<25 then break end
  table.insert(rows,height-distance);last=distance
 end
 return rows
end
function Zone.Extras(z,position)
 z.FlightExtras=true
 local height=position.Y-z.GroundY
 for i,y in Zone.RingPlan(height)do
  local center=Vector3.new(position.X,y+z.GroundY,position.Z);local m=Instance.new("Model");m.Name="DiveRing"..i;m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;m:SetAttribute("TargetKind","Ring");m:SetAttribute("Broken",false)
  local anchor=part(m,"RingCenter",Vector3.new(1,1,1),center,Color3.new(1,1,1));anchor.Transparency=1;m.PrimaryPart=anchor
  local radius=170
  for j=1,24 do local angle=j*math.pi*2/24
   local p=part(m,"RingArc",Vector3.new(radius*.27,5,8),center+Vector3.new(math.cos(angle)*radius,0,math.sin(angle)*radius),Color3.fromRGB(119,255,177));p.CFrame=CFrame.new(p.Position)*CFrame.Angles(0,-angle,0);p.Material=Enum.Material.Neon
  end
  m.Parent=z.Folder;table.insert(z.Rings,{Position=center,Radius=radius,Model=m})
 end
 z.Folder:SetAttribute("RingHits",0);z.Folder:SetAttribute("RingTotal",#z.Rings)
 for index,gate in Gates do if height>gate.Bottom+20 then
  local top=math.min(gate.Top-35,height-35)
  for row=1,2 do local y=gate.Bottom+(top-gate.Bottom)*(row/3)
   for lane=-1,1 do
    local family=Families.Families[index];local name=family[(row+lane+2)%#family+1];local d=Families.Definitions[name]
    local h=math.max(60,gate.ChaserHeight*2);local center=Vector3.new(position.X,y+z.GroundY,position.Z)+(z.Basis or Vector3.new(1,0,0))*lane*120
    local m=Instance.new("Model");m.Name="DiveEnemy_"..index.."_"..row.."_"..lane;m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;m:SetAttribute("TargetKind","Enemy");m:SetAttribute("GateIndex",index);m:SetAttribute("Broken",false)
    local p=part(m,name,Vector3.new(90,h,100),center,Color3.new(1,1,1));p.CFrame=frame(z,center);m.PrimaryPart=p
    local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.FileMesh;mesh.MeshId=d.Mesh;mesh.TextureId=d.Texture;mesh.Scale=Vector3.one*(h/d.MeshSize[2]);mesh.Parent=p
    m.Parent=z.Folder;table.insert(z.Enemies,{Position=center,Frame=frame(z,center),Size=p.Size,Model=m})
   end
  end
 end end
end
return Zone
