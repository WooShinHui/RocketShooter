do
 local env=environment();local V=env.Vector3;V.one=V.new(1,1,1);local c=newBreakCourse(env)
 check(c.Tier(1).Count==2 and c.Tier(20).Count==11 and c.Tier(200).Count==32,"progression grows from two to eleven to thirty-two consecutive rows")
 local p=V.new(0,15,0);local velocity=V.new(35,240,0);local rows=c.Plan(p,velocity,196.2,1,false)
 check(#rows==2 and rows[1].Score==40,"starter pack has two predictable rewards")
 for _,row in rows do
  row.Frame=env.CFrame.lookAt(row.Position,row.Position+row.Direction)
  local t=if row==rows[1] then .20 else .255
  local before=p+velocity*(t-.04)-V.new(0,196.2*(t-.04)^2/2,0)
  local after=p+velocity*(t+.04)-V.new(0,196.2*(t+.04)^2/2,0)
  check(c.Touches(row,before,after),"starter trajectory crosses central break row")
  check(c.Touches(row,before+V.new(25,0,0),after+V.new(25,0,0)),"wide row tolerates imperfect steering")
  check(not c.Touches(row,before+V.new(0,200,0),after+V.new(0,200,0)),"off-route flight cannot claim row reward")
 end
 local row={Frame=env.CFrame.new(),Size=V.new(100,64,8)}
 check(c.Touches(row,V.new(0,0,-2000),V.new(0,0,2000)),"swept hit detects high-speed tunneling")
 local model={GetChildren=function() return {} end,GetDescendants=function()return {}end};row.Model=model;row.Position=V.zero;row.Score=40;row.Index=1
 local run={Rows={row},Count=0,Id=1,Tier=c.Tier(1),Player={Character={}}};local emitted=0
 local award=c.Sample(run,V.new(0,0,-10),V.new(0,0,10),function()emitted+=1 end)
 check(award==40 and emitted==1 and run.Count==1,"server awards actual swept row hit once")
 check(c.Sample(run,V.new(0,0,-10),V.new(0,0,10),function()emitted+=1 end)==0 and emitted==1,"repeated crossing cannot duplicate destruction rewards")
end

do
 local env=environment();local V=env.Vector3;V.one=V.new(1,1,1);local course=newBreakCourse(env)
 local row={Frame=env.CFrame.new(),Size=V.new(100,64,8),Position=V.zero,Score=60,Index=3,Dive=true,Model={GetChildren=function()return {}end,GetDescendants=function()return {}end}}
 local player={Character={}};local run={Rows={row},Count=0,Id=9,Tier=course.Tier(30),Player=player};local payload
 local award=course.Sample(run,V.new(0,0,20),V.new(0,0,-20),function(data)payload=data end)
 check(award==60 and payload.CourseHit and payload.Index==3 and payload.Award==60,"descending brick hit emits the same chain notice and actual award as ascent")
 check(payload.RunId==9 and payload.Character==player.Character,"descent notice retains the run and character identity")
end

-- Regression: untouched ascent butter must still break on descent, once.
do
 local env=environment();local V=env.Vector3;V.one=V.new(1,1,1);local course=newBreakCourse(env)
 local model=env.Instance.new("Model");local visual=env.Instance.new("Part");visual.Parent=model
 local row={Frame=env.CFrame.new(),Size=V.new(100,64,8),Position=V.zero,Score=40,Index=1,Dive=false,Model=model}
 local run={Descending=true,Rows={row},Count=0,Id=10,Tier=course.Tier(1),Player={Character={}}};local notices=0
 check(course.Sample(run,V.new(0,2000,0),V.new(0,-2000,0),function()notices+=1 end)==40,"high-speed descent breaks previously untouched ascent butter")
 check(visual.Transparency==1 and notices==1 and run.Count==1,"descending butter contact hides geometry and emits one reward notice")
 check(course.Sample(run,V.new(0,2000,0),V.new(0,-2000,0),function()notices+=1 end)==0 and notices==1,"descent cannot claim a broken ascent target twice")
end
