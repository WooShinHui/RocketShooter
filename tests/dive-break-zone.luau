do
 local env=environment();env.Vector3.one=env.Vector3.new(1,1,1);env.Vector3.yAxis=env.Vector3.new(0,1,0);local zone=newDiveBreakZone(env);local course=newBreakCourse(env)
 check(#zone.Plan(79)==0,"very low aborts do not create targets under ground")
 for _,speed in {180,1800,2400,3600}do
  local plan=zone.Plan(50000,speed)
  local gap=plan[1].Height-plan[4].Height
  check(gap>=speed*.7 and plan[7].Height==140,"high-speed final layers retain at least .7 seconds between choices")
 end
 for _,height in {80,180,600,12000,300000}do
  local plan=zone.Plan(height);check(#plan==9,"three descent layers have three lanes")
  for _,r in plan do
   check(r.Height>0 and r.Height<height and r.Height<=420,"targets stay below first cloud and flight")
   check(r.Size.X==240 and r.Units==(r.Lane==0 and 1 or 3),"all lanes are wide and bonus uses explicit reward units")
  end
 end
 local p=env.player(9981);local parent=env.Instance.new("Folder");parent.Parent=env.workspace
 local z=zone.Create(p,901,parent,60);z.FlightExtras=true
 zone.Update(z,env.Vector3.new(5,600,8),env.Vector3.new(0,-90,0),false)
 check(not z.Spawned,"ascending flight cannot spawn descent targets")
 zone.Update(z,env.Vector3.new(5,10000,8),env.Vector3.new(0,-2400,0),true)
 check(not z.Spawned,"targets wait for descent approach window")
 zone.Update(z,env.Vector3.new(5,600,8),env.Vector3.new(0,-90,0),true)
 check(z.Spawned and #z.Rows==9 and #z.Folder:GetChildren()==9,"run owns exactly nine targets")
 local first=z.Rows[1].Position
 zone.Update(z,env.Vector3.new(300,400,100),env.Vector3.new(0,-90,0),true)
 check(z.Rows[1].Position==first and #z.Rows==9,"targets lock their position and never chase the player")
 local emitted={};local function emit(d)table.insert(emitted,d)end
 local score,hits=zone.Sample(z,env.Vector3.new(5,0,8),env.Vector3.new(5,1000,8),true,course.Touches,emit)
 check(score==0 and hits==0,"ascending intersections never award")
 score,hits=zone.Sample(z,env.Vector3.new(5,1000,8),env.Vector3.new(5,0,8),true,course.Touches,emit)
 check(score==180 and hits==3 and z.Hits==3 and z.BonusHits==0,"fast swept descent hits all three center layers")
 local trophies=0
 for _,d in emitted do trophies+=DestructionRewards.Reward(d.RewardUnits,d.RewardPosition.Y);check(d.DiveZone and d.RewardUnits==1,"center events preserve server reward units")end
 check(trophies==5,"first-cloud central route grants five escrow trophies")
 score,hits=zone.Sample(z,env.Vector3.new(5,1000,8),env.Vector3.new(5,0,8),true,course.Touches,emit)
 check(score==0 and hits==0 and #emitted==3,"repeated crossing cannot duplicate awards")
 local other=zone.Create(p,902,parent,60);other.FlightExtras=true;zone.Update(other,env.Vector3.new(5,600,8),env.Vector3.new(0,-90,0),true)
 emitted={};score,hits=zone.Sample(other,env.Vector3.new(235,1000,8),env.Vector3.new(235,0,8),true,course.Touches,emit)
 check(score==540 and hits==3 and other.BonusHits==3,"bonus route triples reward units without tripling object count")
 trophies=0;for _,d in emitted do trophies+=DestructionRewards.Reward(d.RewardUnits,d.RewardPosition.Y)end
 check(trophies==15,"three side targets grant fifteen escrow trophies")
 local miss=zone.Create(p,903,parent,60);miss.FlightExtras=true;zone.Update(miss,env.Vector3.new(5,600,8),env.Vector3.new(0,-90,0),true)
 score,hits=zone.Sample(miss,env.Vector3.new(400,1000,8),env.Vector3.new(400,0,8),true,course.Touches,emit)
 check(score==0 and hits==0,"off-route descent earns nothing")
 for _,r in z.Rows do for _,part in r.Model:GetDescendants()do if part:IsA("BasePart")then check(not part.CanCollide and not part.CanTouch,"targets never change fall physics")end end end
 parent:Destroy();check(parent.Parent==nil,"run container cleanup removes its world parent")
end
