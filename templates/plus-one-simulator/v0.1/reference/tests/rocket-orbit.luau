do
 local base=260*math.sin(math.rad(65));local g=196.2
 local p=Motion.Create(base,g)
 check(p.ApexTime+math.sqrt(16/g)>=5,"level-one rocket has at least five seconds before the small-drop respawn")
 check(math.abs(p.LaunchSpeed-base)<.001 and p.TargetHeight>=100 and p.TargetHeight<=200,"level-one rocket climbs only 100-200 meters without inflated launch power")
 local previous=0
 local growth=true
 for _,level in {1,2,5,10,20,60,200,1000,10000}do
  local _,v=Balance.LaunchComponents(level,math.sin(math.rad(65)),1)
  local profile=Motion.Create(v,g)
  if profile.TargetHeight<=previous then growth=false end
  previous=profile.TargetHeight
 end
 check(growth,"longer beginner flight preserves increasing height at every progression tier")
 local space=Motion.Create(7500,g)
 check(space.LaunchSpeed==7500 and math.abs(space.TargetHeight-7500^2/(2*g))<.001,"beginner extension preserves the existing space height cap")
end
