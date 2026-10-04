-- Run-owned encounters. Layout predicts validated physics; awards require real swept hits.
local Course={}
function Course.Tier(level)
 local count=if level<5 then 2 elseif level<20 then 5 elseif level<60 then 11 elseif level<200 then 20 else 32
 return {Count=count,Score=if level<5 then 40 elseif level<20 then 45 elseif level<60 then 60 else 80,Packs=if level<20 then 1 elseif level<200 then 2 else 3}
end
function Course.Plan(position,velocity,gravity,level,dive,motion)
 local tier=Course.Tier(level);local rows={};local height=math.max(0,position.Y);local previousY
 for i=1,tier.Count do
  local time=.20+(i-1)*.055
  local center,tangent
  if dive then
   local spacing=math.min(18,math.max(5,height*.35/tier.Count))
   local approach=if motion then math.min(height*.4,math.max(40,math.abs(velocity.Y)*.65)) else math.min(160,height*.4)
   center=position+Vector3.new(0,-approach-spacing*i,0);tangent=Vector3.new(0,-1,0)
  elseif motion then
   local delay=.55;time+=delay
   local _,h0=motion.Sample(motion.Profile,motion.Elapsed);local vy,h=motion.Sample(motion.Profile,motion.Elapsed+time)
   center=position+Vector3.new(velocity.X*time,math.max(24,h-h0),velocity.Z*time);tangent=Vector3.new(0,math.max(1,vy),0)
   if previousY then center=Vector3.new(center.X,math.max(center.Y,previousY+12),center.Z)end
   previousY=center.Y
  else center=position+velocity*time-Vector3.new(0,gravity*time*time/2,0);tangent=velocity-Vector3.new(0,gravity*time,0) end
  table.insert(rows,{Position=center,Direction=tangent,Size=Vector3.new(100,64,8),Score=tier.Score})
 end
 return rows
end
local function swept(row,from,to)
 local a=row.Frame:PointToObjectSpace(from);local b=row.Frame:PointToObjectSpace(to);local delta=b-a
 local extent=row.Size/2+Vector3.one*3;local low,high=0,1
 for _,axis in {"X","Y","Z"} do
  if math.abs(delta[axis])<.0001 then if math.abs(a[axis])>extent[axis] then return false end
  else local x=(-extent[axis]-a[axis])/delta[axis];local y=(extent[axis]-a[axis])/delta[axis]
   low=math.max(low,math.min(x,y));high=math.min(high,math.max(x,y));if low>high then return false end
  end
 end
 return true
end
Course.Touches=swept
local function makePart(parent,name,size,frame,color)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=frame;p.Color=color;p.Material=Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent;return p
end
function Course.Create(player,id,position,velocity,gravity,level,motion)
 local c={OriginY=position.Y,Motion=motion,Player=player,Id=id,Level=level,Tier=Course.Tier(level),Rows={},Gravity=gravity,Count=0,AscentPacks=0,DivePacks=0}
 if motion and level<20 then c.Tier.Packs=2 end -- Short beginner chains recur during the longer ascent.
 local f=Instance.new("Folder");f.Name="BreakCourse_"..player.UserId.."_"..id;f:SetAttribute("RunId",id);f:SetAttribute("PlayerId",player.UserId);f.Parent=workspace;c.Folder=f
 c.AscentInterval=math.max(1.4,math.max(0,velocity.Y)/gravity*.35);if motion then c.AscentInterval=motion.Profile.ApexTime*.35 end;c.NextAscent=c.AscentInterval
 if not motion then Course.Spawn(c,position,velocity,false) end
 return c
end
function Course.Spawn(c,position,velocity,dive)
 if dive then c.DivePacks+=1 else c.AscentPacks+=1 end
 for i,row in Course.Plan(position,velocity,c.Gravity,c.Level,dive,c.Motion) do
  if row.Position.Y<9 then continue end
  local up=if dive or math.abs(row.Direction.Unit:Dot(Vector3.yAxis))>.95 then Vector3.new(0,0,-1) else Vector3.yAxis
  row.Frame=CFrame.lookAt(row.Position,row.Position+row.Direction,up)
  local m=Instance.new("Model");m.Name=if dive then "다이브 파괴 묶음" else "연속 파괴 묶음";m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
  m:SetAttribute("RunId",c.Id);m:SetAttribute("ChainIndex",i);m:SetAttribute("ChainLength",c.Tier.Count)
  m.PrimaryPart=makePart(m,"HitBox",row.Size,row.Frame,Color3.fromRGB(255,218,99));m.PrimaryPart.Transparency=1
  local color=if dive then Color3.fromRGB(102,229,255) else Color3.fromRGB(255,205,105)
  for x=-1,1 do for y=-1,1,2 do
   makePart(m,"BreakBrick",Vector3.new(30,27,6),row.Frame*CFrame.new(x*32,y*15,0),if x==0 then color else Color3.fromRGB(255,237,184))
  end end
  local core=makePart(m,"ChainCore",Vector3.new(8,8,8),row.Frame*CFrame.new(0,0,-5),color);core.Material=Enum.Material.Neon
  m.Parent=c.Folder;row.Model=m;row.Index=i;row.Dive=dive;table.insert(c.Rows,row)
 end
end
function Course.Update(c,position,velocity,elapsed,descent)
 if c.Motion then c.Motion.Elapsed=elapsed end
 if descent then
  if not c.DiveStarted then c.DiveStarted=position.Y;c.NextDive=position.Y;end
  if c.DivePacks<c.Tier.Packs and position.Y<=c.NextDive then
   Course.Spawn(c,position,velocity,true)
   c.NextDive=c.DiveStarted*(if c.DivePacks==1 then .55 else .25)
  end
 elseif c.Motion and c.AscentPacks==0 then
  if velocity.Y>0 and position.Y-c.OriginY>=35 then Course.Spawn(c,position,velocity,false);c.NextAscent=elapsed+1.2 end
 elseif velocity.Y>0 and c.AscentPacks<c.Tier.Packs and elapsed>=c.NextAscent then
  Course.Spawn(c,position,velocity,false);c.NextAscent+=c.AscentInterval
 end
end
function Course.DiveTarget(c,position)
 local nearest,left=nil,0
 for _,row in c.Rows do
  if row.Dive and not row.Hit and row.Position.Y<=position.Y+4 then
   left+=1
   if not nearest or row.Position.Y>nearest.Position.Y then nearest=row end
  end
 end
 return nearest,left
end
function Course.Sample(c,from,to,emit)
 local score,hits=0,0
 for _,row in c.Rows do
  if not row.Hit and swept(row,from,to) then
   row.Hit=true;score+=row.Score;hits+=1;c.Count+=1
   for _,p in row.Model:GetChildren() do if p:IsA("BasePart") then p.Transparency=1 end end
   emit({Position=row.Position,Size=Vector3.new(30,27,6),Color=if row.Dive then Color3.fromRGB(102,229,255) else Color3.fromRGB(255,205,105),
    MaterialTag="Ruin",Index=row.Index,Award=row.Score,ChainLength=c.Tier.Count,RunId=c.Id,Character=c.Player.Character,CourseHit=true})
  end
 end
 return score,hits
end
function Course.Destroy(c)
 if c and c.Folder then c.Folder:Destroy();c.Folder=nil;table.clear(c.Rows) end
end
return Course
