do
 local base=260*math.sin(math.rad(65));local p=Motion.Create(base,196.2)
 check(math.abs(p.ApexTime-5)<.001 and p.TargetHeight>100 and p.TargetHeight<200,"beginner reaches 100-200m over five ascending seconds")
 check(p.Peak<55,"beginner speed is gentle rather than a 1.4km rocket impulse")
 local _,early=Motion.Sample(p,1);local _,middle=Motion.Sample(p,2.5)
 check(early<20 and middle>60 and middle<90,"beginner moves slowly in the first second and reaches half height halfway")
 local a=Motion.Sample(p,3);local b=Motion.Sample(p,4);local c=Motion.Sample(p,5)
 check(a>b and b>c and c==0,"fuel depletion slows ascent smoothly to rest at the apex")
 local env=environment();local course=newBreakCourse(env)
 local rows=course.Plan(env.Vector3.new(0,9,0),env.Vector3.zero,196.2,1,false,{Profile=p,Sample=Motion.Sample,Elapsed=0})
 check(rows[2].Position.Y-rows[1].Position.Y>=12,"slow starter break walls do not visually overlap")
 check(PresentationConfig.Sounds.Engine.Looped and PresentationConfig.DestructionSounds.Slime.Impact.Seconds>=.5,"engine loop and complete short slime-pop cues are configured")
end
