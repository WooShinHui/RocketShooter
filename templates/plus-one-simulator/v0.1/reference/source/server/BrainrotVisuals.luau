-- Reviewed Creator Store geometry only: no imported scripts, sounds or NPC AI.
local definitions={
 ["퉁퉁퉁 사후르"]={
  {Mesh="rbxassetid://82464974337955",Texture="rbxassetid://105445253181063",Size=Vector3.new(1.891804575920105,4.74713134765625,1.9500000476837158),MeshSize=Vector3.new(0.3973720073699951,0.9971309900283813,0.40965497493743896),Color=Color3.new(0.6392157077789307,0.6352941393852234,0.6470588445663452),CF=CFrame.new(0.000030517578125,0,0,0.0002027451992034912,0,1.0000001192092896,0,1,0,-0.9999998807907104,0,0.00020271539688110352)},
 },
 ["트랄랄레로 트랄랄라"]={
  {Mesh="rbxassetid://95334903016944",Texture="rbxassetid://113482070800284",Size=Vector3.new(11.63805103302002,11.985137939453125,24.59893035888672),MeshSize=Vector3.new(11.63805103302002,11.985137939453125,24.59893035888672),Color=Color3.new(0.6392157077789307,0.6352941393852234,0.6470588445663452),CF=CFrame.new(0,-0.000244140625,0,1.0000001192092896,0,0,0,1,0,0,0,0.9999998807907104)},
 },
 ["발레리나 카푸치나"]={
  {Mesh="rbxassetid://126031734174893",Texture="",Size=Vector3.new(8.041040420532227,0.03986656665802002,0.678286075592041),MeshSize=Vector3.new(2.680346965789795,0.01328885555267334,0.22609534859657288),Color=Color3.new(1,0.35686275362968445,0.3960784375667572),CF=CFrame.new(0.0000019073486328125,1.6953125,0.02130126953125,-1.0000001192092896,0,0,0,1,0,0,0,-0.9999998807907104)},
  {Mesh="rbxassetid://97780786497924",Texture="",Size=Vector3.new(1.2203357219696045,2.4829225540161133,0.9758629202842712),MeshSize=Vector3.new(0.40677857398986816,0.8276408910751343,0.3252876400947571),Color=Color3.new(1,0.886274516582489,0.8274509906768799),CF=CFrame.new(0,-1.07421875,0.2220458984375,-1.0000001192092896,0,0,0,1,0,0,0,-0.9999998807907104)},
  {Mesh="rbxassetid://91215790821175",Texture="",Size=Vector3.new(5.6886162757873535,3.2684719562530518,3.8781416416168213),MeshSize=Vector3.new(1.8962054252624512,1.0894906520843506,1.2927138805389404),Color=Color3.new(0.9803921580314636,0.9372549057006836,0.886274516582489),CF=CFrame.new(-0.90521240234375,3.8125,-0.05120849609375,-1.0000001192092896,0,0,0,1,0,0,0,-0.9999998807907104)},
  {Mesh="rbxassetid://96342746946140",Texture="",Size=Vector3.new(1.4521400928497314,0.143096923828125,0.6898614764213562),MeshSize=Vector3.new(0.48404669761657715,0.047698974609375,0.2299538254737854),Color=Color3.new(1,0.35686275362968445,0.3960784375667572),CF=CFrame.new(0,0.19921875,-0.051204681396484375,-1.0000001192092896,0,0,0,1,0,0,0,-0.9999998807907104)},
  {Mesh="rbxassetid://124432184038410",Texture="",Size=Vector3.new(7.896049499511719,0.8045840263366699,0.739251434803009),MeshSize=Vector3.new(2.63201642036438,0.26819467544555664,0.24641714990139008),Color=Color3.new(0.929411768913269,0.7176470756530762,0.5568627715110779),CF=CFrame.new(0,1.81640625,0.013919830322265625,-1.0000001192092896,0,0,0,1,0,0,0,-0.9999998807907104)},
  {Mesh="rbxassetid://84982639767507",Texture="rbxassetid://98783340525031",Size=Vector3.new(3.3437068462371826,2.5043978691101074,3.713331699371338),MeshSize=Vector3.new(1.1145689487457275,0.8347992897033691,1.2377772331237793),Color=Color3.new(0.6392157077789307,0.6352941393852234,0.6470588445663452),CF=CFrame.new(0,4.046875,0.13360595703125,-1.0000001192092896,0,0,0,1,0,0,0,-0.9999998807907104)},
  {Mesh="rbxassetid://77161916398296",Texture="",Size=Vector3.new(2.199467658996582,5.970433235168457,2.5399203300476074),MeshSize=Vector3.new(0.7331558465957642,1.9901444911956787,0.8466401100158691),Color=Color3.new(0.9803921580314636,0.5607843399047852,0.48235294222831726),CF=CFrame.new(0,0.55078125,0.4727783203125,-1.0000001192092896,0,0,0,1,0,0,0,-0.9999998807907104)},
 },
}
local Visuals={}
function Visuals.Apply(model,name,position,radius)
 local definition=definitions[name];if not definition then return false end
 local body=model.PrimaryPart
 for _,p in model:GetChildren() do if p:IsA("BasePart") and p~=body then p:Destroy() end end
 body.Transparency=1;body:SetAttribute("CollisionProxy",true)
 local low,high=math.huge,-math.huge
 for _,d in definition do low=math.min(low,d.CF.Position.Y-d.Size.Y/2);high=math.max(high,d.CF.Position.Y+d.Size.Y/2) end
 local scale=radius*3/math.max(1,high-low);local center=(low+high)/2
 for i,d in definition do
  local p=Instance.new("Part");p.Name="BrainrotMesh"..i;p.Size=d.Size*scale;p.Color=if d.Texture~="" then Color3.new(1,1,1) else d.Color
  p.CFrame=CFrame.new(position)*CFrame.new((d.CF.Position-Vector3.new(0,center,0))*scale)*(d.CF-d.CF.Position)
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Material=Enum.Material.SmoothPlastic
  local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.FileMesh;mesh.MeshId=d.Mesh;mesh.TextureId=d.Texture
  mesh.Scale=Vector3.new(d.Size.X/d.MeshSize.X,d.Size.Y/d.MeshSize.Y,d.Size.Z/d.MeshSize.Z)*scale;mesh.Parent=p;p.Parent=model
 end
 return true
end
return Visuals
