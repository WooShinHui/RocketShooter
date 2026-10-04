local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Input={}
function Input.Start(humanoid,send)
 local elapsed=0;local focused=true;local connections={}
 table.insert(connections,UIS.WindowFocusReleased:Connect(function()focused=false;send(Vector2.zero)end))
 table.insert(connections,UIS.WindowFocused:Connect(function()focused=true end))
 table.insert(connections,RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.05 then return end;elapsed=0
  local move=Vector3.zero
  if focused and not UIS:GetFocusedTextBox()then
   local camera=workspace.CurrentCamera;local forward=camera and Vector3.new(camera.CFrame.LookVector.X,0,camera.CFrame.LookVector.Z)or Vector3.new(0,0,-1)
   forward=if forward.Magnitude>.01 then forward.Unit else Vector3.new(0,0,-1)
   local right=Vector3.new(-forward.Z,0,forward.X)
   if UIS:IsKeyDown(Enum.KeyCode.W)or UIS:IsKeyDown(Enum.KeyCode.Up)then move+=forward end
   if UIS:IsKeyDown(Enum.KeyCode.S)or UIS:IsKeyDown(Enum.KeyCode.Down)then move-=forward end
   if UIS:IsKeyDown(Enum.KeyCode.D)or UIS:IsKeyDown(Enum.KeyCode.Right)then move+=right end
   if UIS:IsKeyDown(Enum.KeyCode.A)or UIS:IsKeyDown(Enum.KeyCode.Left)then move-=right end
   if UIS.TouchEnabled and humanoid.MoveDirection.Magnitude>.01 then move=humanoid.MoveDirection end
  end
  if move.Magnitude>1 then move=move.Unit end
  send(Vector2.new(move.X,move.Z))
 end))
 send(Vector2.zero)
 return {Stop=function()for _,c in connections do c:Disconnect()end end}
end
return Input
