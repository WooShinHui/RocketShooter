-- Return a complete, on-screen head popup position; never fall back to (0, 0).
local Projection={}
local function finite(n)return type(n)=="number"and n==n and math.abs(n)<math.huge end
function Projection.Calculate(camera,worldPosition,age)
 if not camera then return nil end
 local viewport=camera.ViewportSize
 if not viewport or not finite(viewport.X)or not finite(viewport.Y)or viewport.X<=0 or viewport.Y<=0 then return nil end
 local point,onScreen=camera:WorldToViewportPoint(worldPosition)
 if not onScreen or not finite(point.X)or not finite(point.Y)or not finite(point.Z)or point.Z<=0 then return nil end
 local rise=22*(1-(1-math.clamp(age/.9,0,1))^2)
 local x,y=point.X,point.Y-rise
 -- A partially clipped label can leave just 'XP' flashing in a corner.
 if x<102 or x>viewport.X-102 or y<33 or y>viewport.Y-33 then return nil end
 return x,y
end
return Projection
