do
 local env=environment();local rules=newRocketRules(env);local g=196.2
 local previous=0
 for _,power in {1,20,100,500,1000,10000,1000000,1e10,1e20,1e30} do
  local vertical=Balance.VerticalPower(power)*math.sin(math.rad(65))
  local p=Motion.CreateRocket(vertical,g)
  check(p.TargetHeight>previous,"rocket height keeps growing beyond the former capped power")
  check(p.TargetHeight<math.huge and p.Peak<=25000.001,"extreme growth keeps finite coordinates and bounded ascent speed")
  local _,height=Motion.Sample(p,p.Burn)
  check(math.abs(height-p.TargetHeight)<.001,"rocket prediction and final ascent height agree")
  previous=p.TargetHeight
 end
 local old=Motion.Create(7500,g);local at=Motion.CreateRocket(7500,g);local over=Motion.CreateRocket(7500.001,g)
 check(at.TargetHeight==old.TargetHeight and at.Burn==old.Burn,"former ceiling is a continuous transition with unchanged prior pacing")
 check(over.TargetHeight>at.TargetHeight and over.TargetHeight-at.TargetHeight<1,"growth above former limit is continuous")
 local starter=Motion.CreateRocket(260*math.sin(math.rad(65)),g)
 check(starter.ApexTime==5 and math.abs(starter.TargetHeight-141.5041337)<.001,"beginner height and ascent time stay unchanged")
 for _,height in {140,10000,140000,300000,1000000} do
  for _,boost in {false,true} do
   local speed,seconds,remaining=0,0,height;local bounded=true
   while remaining>0 and seconds<1000 do
    local target=rules.DiveTarget(height,boost,speed,2400,3600)
    speed=rules.DiveSpeed(speed,target,g*(boost and 1.6 or 1),seconds,1/60)
    remaining-=speed/60;seconds+=1/60
    bounded=bounded and speed<=(boost and 3600 or 2400)+.001
   end
   check(bounded,"simulated dive respects terminal speed throughout descent");check(remaining<=0,"high altitude dive reaches ground")
   check(seconds+30<rules.FlightTimeout(height,30,2400),"height-aware timeout permits the complete slower descent")
   if height==140000 then check(seconds>35,"140km descent leaves meaningful time to steer") end
  end
 end
 check(rules.DiveTarget(140000,false,3500,2400,3600)==3500,"releasing dive preserves acquired speed within the absolute limit")
 check(rules.DiveTarget(140000,true,20000,2400,3600)==3600,"an oversized carried speed cannot exceed the new absolute limit")
end
