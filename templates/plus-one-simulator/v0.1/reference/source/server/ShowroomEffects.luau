local SS=game:GetService("ServerStorage")
local Effects={}
function Effects.Pedestal(base,color)
 local templates=SS:FindFirstChild("ShowroomAssetTemplates")
 local source=templates and templates:FindFirstChild("PedestalSparkle90896557694774")
 if not source then warn("[Showroom] Reviewed pedestal sparkle template is missing");return end
 -- Corner emitters remain visible around the rocket rather than inside it.
 for i,offset in {Vector3.new(-4,0,-4),Vector3.new(4,0,-4),Vector3.new(-4,0,4),Vector3.new(4,0,4)}do
  local a=source:Clone();a.Name="PedestalSparkle"..i;a.Position=offset+Vector3.new(0,base.Size.Y/2+.5,0);a.Parent=base
  for _,p in a:GetChildren()do if p:IsA("ParticleEmitter")then p.Color=ColorSequence.new(color:Lerp(Color3.new(1,1,1),.45));p.Rate=.65;p.Enabled=true end end
  if i==1 then local light=Instance.new("PointLight");light.Name="PedestalGlow";light.Color=color;light.Brightness=.5;light.Range=10;light.Shadows=false;light.Parent=a end
 end
end
function Effects.Toilet(model,base,style)
 if not style.Glow then return end
 local a=Instance.new("Attachment");a.Name="TierAura";a.Position=Vector3.new(0,1,0);a.Parent=base
 local sparkle=Instance.new("Sparkles");sparkle.Name="TierSparkles";sparkle.SparkleColor=style.Accent;sparkle.Parent=base
 local light=Instance.new("PointLight");light.Color=style.Accent;light.Brightness=style.Divine and 1.2 or .5;light.Range=style.Divine and 16 or 10;light.Shadows=false;light.Parent=a
 if style.Divine then
  -- A gold crown/halo distinguishes the final white-marble tier.
  local ring=Instance.new("Model");ring.Name="DivineHalo";ring.Parent=model
  for i=1,16 do local angle=i*math.pi*2/16;local p=Instance.new("Part");p.Name="HaloArc";p.Size=Vector3.new(1.4,.2,.35);p.CFrame=base.CFrame*CFrame.new(math.cos(angle)*3.6,10,math.sin(angle)*3.6)*CFrame.Angles(0,-angle,0);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Material=Enum.Material.Neon;p.Color=style.Accent;p.Parent=ring end
 end
end
return Effects
