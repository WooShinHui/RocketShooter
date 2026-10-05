-- Pure server encounter rules. No level check: flight speed and retreat decide survival.
local G={}
function G.Step(state,gates,previous,height,dt,diving,velocity)
 if diving then
  state.Age=0;state.Slow=0;state.Active=nil
  for index,gate in gates do if height>=gate.Bottom and height<gate.Top then state.Active=index;return "Diving",index end end
  return nil
 end
 if state.Active then
  local gate=gates[state.Active]
  if height>=gate.Top then state.Passed=state.Active;state.Active=nil;state.Age=0;state.Slow=0;return "Passed",state.Passed end
  if height<gate.Bottom then state.Active=nil;state.Age=0;return "Retreated" end
  state.Age+=dt
  state.Slow=not diving and velocity and velocity<35 and (state.Slow or 0)+dt or 0
  if state.Slow>=.25 then return "Caught",state.Active end
  if state.Age>=gate.Grace then return "Caught",state.Active end
 elseif not diving then
  for index,gate in gates do
   if index>(state.Passed or 0) and height>=gate.Bottom and previous<gate.Top then
    if height>=gate.Top then state.Passed=index else state.Active=index;state.Age=0;return "Entered",index end
   end
  end
 end
 return nil,state.Active
end
function G.Band(band,gates,height)
 while band<=#gates and height>=gates[band].Top do band+=1 end
 while band>1 and height<gates[band-1].Bottom do band-=1 end
 return band
end
return table.freeze(G)
