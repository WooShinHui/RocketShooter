do
 local env=environment();local V=env.Vector3;V.one=V.new(1,1,1);V.yAxis=V.new(0,1,0);local zone=newDiveBreakZone(env);local course=newBreakCourse(env)
 check(#zone.Plan(79)==0,"short aborted flight does not place targets underground")
 for _,speed in {90,1800,2400,3600}do local plan=zone.Plan(50000,speed)
  check(#plan==3 and near(plan[1].Size.Y/speed,3),"each stable lane gives three seconds even at F speed")
  check(plan[1].Top<50000 and plan[1].Bottom>0,"lane window stays below approach and above ground")
 end
 local p=env.player(9981);local parent=env.Instance.new("Folder");parent.Parent=env.workspace
 local z=zone.Create(p,901,parent,60);z.FlightExtras=true
 zone.Update(z,V.new(0,50000,0),V.new(0,-3600,0),true)
 check(z.Spawned and #z.Rows==3,"first lane choices appear high in the descent")
 local first=z.Rows[1];local pos=first.Position;local top,bottom=first.Top,first.Bottom
 local noop=function()end
 zone.Sample(z,V.new(600,top+10,0),V.new(600,top-100,0),true,course.Touches,noop)
 check(z.Hits==0,"missing the upper entrance is not an automatic reward")
 local score,hits=zone.Sample(z,V.new(600,top-3600,0),V.new(0,top-7200,0),true,course.Touches,noop)
 check(hits>=1 and first.Hit,"late sideways correction can hit the original target during descent")
 check(zone.Sample(z,V.new(0,top-7200,0),V.new(0,bottom+10,0),true,course.Touches,noop)==0,"the same lane cannot pay twice")
 zone.Update(z,V.new(700,top-4000,0),V.new(0,-3600,0),true)
 check(first.Position==pos,"target never moves to follow the player")
 zone.Update(z,V.new(700,bottom+2000,0),V.new(0,-3600,0),true)
 check(z.Section==2 and #z.Rows==6,"next section previews before the original section finishes")
 check(z.Rows[4].Position.X==0,"future targets keep the original world lane instead of relocating")
 for i=1,60 do zone.Update(z,V.new(700,50000-i*800,0),V.new(0,-3600,0),true);check(#z.Rows<=6,"only current and next target sections remain live")end
 local state={Active=1,Passed=0,Age=.1};check(GateRules.Step(state,CloudConfig.HeightPresentation.Gates,550,530,.05,true,-100)=="Caught","unfinished gate cannot become harmless merely by entering dive state")
 state={Active=1,Passed=1,Age=99};check(GateRules.Step(state,CloudConfig.HeightPresentation.Gates,550,530,.05,true,-100)=="Diving","a gate already cleared remains harmless on the return descent")
 check(#Skins.Items>=15 and Skins.Valid(7,3)and Skins.Valid(2^#Skins.Items-1,#Skins.Items),"extended catalog preserves old and new ownership masks")
 parent:Destroy()
end
