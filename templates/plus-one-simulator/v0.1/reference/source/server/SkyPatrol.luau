-- Deterministic wandering within one altitude pocket; never targets a player.
local Patrol={}
function Patrol.New(origin,seed)
 return {Origin=origin,Center=origin,Seed=seed,Leg=0,NextTurn=0,Speed=22,Goal=origin}
end
function Patrol.Step(state,dt,now)
 if now>=state.NextTurn or (state.Goal-state.Center).Magnitude<3 then
  state.Leg+=1
  local n=state.Leg*2.399963+state.Seed*4.17
  local radius=18+math.abs(math.sin(n*1.73))*38
  state.Goal=state.Origin+Vector3.new(math.sin(n)*radius,math.sin(n*2.31)*18,math.cos(n*.83)*radius)
  state.Speed=18+math.abs(math.sin(n*.61))*24
  state.NextTurn=now+1.1+math.abs(math.cos(n*1.37))*2.4
 end
 local delta=state.Goal-state.Center
 if delta.Magnitude>0 then state.Center+=delta.Unit*math.min(delta.Magnitude,state.Speed*math.min(dt,.25)) end
 return state.Center
end
return Patrol
