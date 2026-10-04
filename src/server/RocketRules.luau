local Rules={}
function Rules.DiveSpeed(current,target,gravity,age,dt)
 -- A gentle first 1.2s, then increasing acceleration towards terminal dive speed.
 local acceleration
 if age<1.2 then acceleration=gravity*.8*math.max(0,age/1.2)^1.5
 else local ramp=math.clamp((age-1.2)/2,0,1);acceleration=gravity+math.max(0,target*.65-gravity)*ramp*ramp end
 return math.min(target,current+acceleration*math.clamp(dt,0,.1))
end
function Rules.Input(value)
 if typeof(value)~="Vector2" or value.X~=value.X or value.Y~=value.Y or math.abs(value.X)>1 or math.abs(value.Y)>1 or value.Magnitude>1.05 then return nil end
 return value
end
function Rules.Fallen(peak,y,velocity,drop)
 return velocity<0 and peak-y>=drop
end
function Rules.Trophies(zoneReward)
 if type(zoneReward)~="number" or zoneReward~=zoneReward or zoneReward==math.huge or zoneReward<1 or zoneReward%1~=0 or zoneReward>2048 then return 0 end
 return zoneReward
end
function Rules.Step(current,target,acceleration,dt)
 local delta=target-current;local limit=acceleration*math.clamp(dt,0,.1)
 return if delta.Magnitude>limit then delta.Unit*limit else delta
end
return Rules
