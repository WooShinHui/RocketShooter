local UIS=game:GetService("UserInputService")
if not UIS.TouchEnabled then return end
local player=game.Players.LocalPlayer
local gui=player:WaitForChild("PlayerGui")
local function update()
 local camera=workspace.CurrentCamera;if not camera then return end
 local v=camera.ViewportSize;local compact=v.Y<500
 local function find(screen,name) local s=gui:FindFirstChild(screen);return s and s:FindFirstChild(name,true) end
 local layer=find("SkyLayerGui","Layer")
 if layer then layer.AnchorPoint=Vector2.new(1,0);layer.Position=UDim2.new(1,-10,0,compact and 8 or 88);layer.Size=UDim2.fromOffset(math.min(180,v.X*.45),30);layer.TextSize=14;layer.TextWrapped=true end
 local score=find("DestructionSpikeFlash","TemporaryRunScore")
 if score then score.AnchorPoint=Vector2.new(1,0);score.Position=UDim2.new(1,-10,0,compact and 42 or 122);score.Size=UDim2.fromOffset(155,32);score.TextSize=16 end
 local altitude=find("ObjectiveGui","AltitudeValue")
 if altitude then altitude.Size=UDim2.fromOffset(math.min(270,v.X*.55),46);altitude.TextSize=30 end
 local progress=find("ObjectiveGui","AltitudeProgress")
 if progress then progress.Position=UDim2.new(.5,0,0,54);progress.Size=UDim2.new(.65,0,0,28);progress.TextSize=13 end
 local balances=find("CurrencyHud","Balances")
 -- SimulatorHUD owns the trophy icon/value pair and its safe-area layout.
 local descent=find("DescentGui","Challenge")
 if descent then descent.AnchorPoint=Vector2.new(.5,1);descent.Position=UDim2.new(.5,0,1,compact and -14 or -130);local scale=descent:FindFirstChild("SimulatorScale");if scale then scale.Scale=math.min(.65,(v.X-32)/440) end end
 -- ProgressionHud owns its legacy dock visibility; TotalHud owns current menus.
 -- Descendant/viewport updates must never re-enable the retired GrowthDock.
end
local connection
local function bind()
 if connection then connection:Disconnect() end
 if workspace.CurrentCamera then connection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update) end
 update()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bind)
gui.DescendantAdded:Connect(function() task.defer(update) end)
player:GetAttributeChangedSignal("FlightState"):Connect(update)
bind()
