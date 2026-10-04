-- Two bounded replication foci per fast flight; release both on every exit path.
local Streaming={}
local function focus(player,name,position)
 local p=Instance.new("Part");p.Name=name;p.Size=Vector3.one;p.Anchored=true;p.Transparency=1
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Position=position;p.Parent=workspace
 local ok=pcall(function()player:AddReplicationFocus(p) end)
 if not ok then p:Destroy();return nil end
 return p
end
function Streaming.Create(player,position,velocity)
 if velocity.Magnitude<1200 then return nil end
 return {Player=player,Ahead=focus(player,"FlightStreamingAhead",position+velocity*.7)}
end
function Streaming.Update(c,position,velocity,descent)
 if not c then return end
 if c.Ahead then c.Ahead.Position=position+velocity*.7 end
 if descent and not c.Ground then c.Ground=focus(c.Player,"FlightStreamingLanding",descent.Target) end
end
function Streaming.Destroy(c)
 if not c then return end
 for _,p in {Ahead=c.Ahead,Ground=c.Ground} do
  pcall(function()c.Player:RemoveReplicationFocus(p)end);p:Destroy()
 end
end
return Streaming
