-- Cosmetic helices surround the existing fuel plume; ownership/thrust stay on the server.
local Players=game:GetService("Players");local Run=game:GetService("RunService");local Catalog=require(game.ReplicatedStorage:WaitForChild("RocketTrailCatalog"))
local tracked={};local interval=0
local settings={Ember={2,.6,3.8},Mint={2,.85,5.4},Violet={3,1.2,3.1},Aurora={3,1.6,2.5},Prism={3,1.3,4.5}}
local function clear(m)local d=tracked[m];if not d then return end;for _,v in d.Objects do v:Destroy()end;tracked[m]=nil end
local function build(m,id)
 local cfg=settings[id];if not cfg then return end
 local item=Catalog.Find(id);local d={Objects={},Nozzles={},Item=item,Config=cfg};tracked[m]=d
 for _,nozzle in m:GetChildren()do if nozzle.Name=="Nozzle"then
  local n={Part=nozzle,Streams={}};table.insert(d.Nozzles,n)
  for stream=1,cfg[1]do local knots={};table.insert(n.Streams,knots)
   for i=1,9 do local a=Instance.new("Attachment");a.Name="PurchasedStreamKnot";a.Parent=nozzle;table.insert(knots,a);table.insert(d.Objects,a)
    if i>1 then local beam=Instance.new("Beam");beam.Name="PurchasedStream";beam.Attachment0=knots[i-1];beam.Attachment1=a;beam.FaceCamera=true;beam.LightEmission=.7
     local color=item.Colors[(stream-1)%#item.Colors+1];beam.Color=ColorSequence.new(Color3.fromRGB(color[1],color[2],color[3]));beam.Transparency=NumberSequence.new(.18,.85);beam.Width0=.18;beam.Width1=.1;beam.Segments=4;beam.Parent=nozzle;table.insert(d.Objects,beam)end
   end
  end
 end end
end
Run.RenderStepped:Connect(function(dt)
 interval+=dt;if interval<1/30 then return end;interval=0
 local camera=workspace.CurrentCamera;if not camera then return end
 local seen={};local visible=0
 for _,p in Players:GetPlayers()do local c=p.Character;local root=c and c:FindFirstChild("HumanoidRootPart");local m=c and c:FindFirstChild("BackRocket")
  if m and root then seen[m]=true;local id=m:GetAttribute("Trail");local d=tracked[m]
   local active=settings[id]and root.AssemblyLinearVelocity.Y>0 and (c:GetAttribute("RocketThrust")or 0)>.02 and(c:GetAttribute("RocketPhase")~="Diving")and(root.Position-camera.CFrame.Position).Magnitude<300 and visible<8
   if active then visible+=1;if not d then build(m,id);d=tracked[m]end end
   if d then
    for _,v in d.Objects do if v:IsA("Beam")then v.Enabled=active==true end end
    if active then local t=os.clock();local cfg=d.Config;local length=12+math.min(root.AssemblyLinearVelocity.Y/150,22)
     for _,n in d.Nozzles do local exhaust=n.Part:FindFirstChild("Exhaust");if exhaust then
      for stream,knots in n.Streams do for i,a in knots do
       local along=(i-1)/(#knots-1);local angle=t*cfg[3]+along*math.pi*2.3+(stream-1)*math.pi*2/cfg[1]
       if id=="Aurora"then angle+=math.sin(t*1.7+along*4)*.5 end
       local radius=cfg[2]*(.5+along*.6)
       a.CFrame=exhaust.CFrame*CFrame.new(math.cos(angle)*radius,-1-along*length,math.sin(angle)*radius)
      end end
     end end
    end
   end
  end
 end
 for m in pairs(tracked)do if not seen[m]or not m.Parent then clear(m)end end
end)
