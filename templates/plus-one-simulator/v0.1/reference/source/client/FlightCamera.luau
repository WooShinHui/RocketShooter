local RunService = game:GetService("RunService")
local balanceModule = game:GetService("ReplicatedStorage"):WaitForChild("BalanceConfig", 15)
assert(balanceModule and balanceModule:IsA("ModuleScript"),
	"[Setup] ReplicatedStorage.BalanceConfig must be a ModuleScript. Stop Play, restart rojo serve with default.project.json, reconnect and accept sync.")
local Balance = require(balanceModule)
local Camera = {}
local Feedback = require(script.Parent.PresentationConfig).RingFeedback

function Camera.Start(root, launchVelocity, isCurrent)
	local horizontal = Vector3.new(launchVelocity.X, 0, launchVelocity.Z)
	local forward = horizontal.Magnitude > 0.01 and horizontal.Unit or Vector3.new(0, 0, -1)
	local settings = Balance.Camera
	local ownedCamera = workspace.CurrentCamera
	local originalFov = ownedCamera and ownedCamera.FieldOfView or 70
	local pulseAt = -math.huge
	local function update()
		local camera = workspace.CurrentCamera
		if not isCurrent() or not root.Parent or not camera then return end
		camera.CameraType = Enum.CameraType.Scriptable
		local remaining = math.clamp(1 - (os.clock() - pulseAt) / Feedback.Seconds, 0, 1)
		camera.FieldOfView = originalFov + Feedback.FovDegrees * remaining * remaining
		local rise=math.clamp(root.AssemblyLinearVelocity.Y*.14,-55,45)
		if root:GetAttribute("Diving") then
            camera.CFrame=CFrame.lookAt(root.Position+Vector3.new(0,38,0)-forward*12,root.Position-Vector3.new(0,110,0),forward)
            camera.FieldOfView=originalFov+8+Feedback.FovDegrees*remaining*remaining
            return
        end
		camera.CFrame = CFrame.lookAt(root.Position - forward * settings.Behind + Vector3.new(0, settings.Height, 0),
			root.Position + forward * settings.LookAhead + Vector3.new(0,rise-settings.LookDown,0))
	end
	update()
	local connection = RunService.RenderStepped:Connect(update)
	return {
		Pulse = function() if isCurrent() then pulseAt = os.clock() end end,
		Stop = function()
			connection:Disconnect()
			if ownedCamera then ownedCamera.FieldOfView = originalFov end
		end,
	}
end

return Camera
