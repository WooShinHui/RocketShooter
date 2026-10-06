local module = game:GetService("ReplicatedStorage"):WaitForChild("BalanceConfig", 15)
assert(module and module:IsA("ModuleScript"), "[Setup] ReplicatedStorage.BalanceConfig must be a ModuleScript; reconnect Rojo with default.project.json")
local Balance = require(module)
local Trajectory = {ExitOffset = 8} -- Existing root offset beyond the muzzle.

function Trajectory.Muzzle(cylinderFrame, cylinderLength)
	return cylinderFrame * CFrame.new(0, 0, -cylinderLength / 2)
end

function Trajectory.AimedMuzzle(basePivot, pivotToCylinder, cylinderLength, yaw, pitch)
	return Trajectory.Muzzle(basePivot * CFrame.Angles(0, math.rad(yaw), 0)
		* CFrame.Angles(math.rad(pitch), 0, 0) * pivotToCylinder, cylinderLength)
end

function Trajectory.Origin(muzzle)
	return muzzle * CFrame.new(0, 0, -Trajectory.ExitOffset)
end

function Trajectory.Velocity(look, level, timing, fuelBoost)
	local horizontal, vertical = Balance.LaunchComponents(level, look.Y, timing)
	horizontal, vertical = horizontal * (fuelBoost or 1), vertical * (fuelBoost or 1)
	local planar = Vector3.new(look.X, 0, look.Z)
	if planar.Magnitude < 0.01 then return nil end
	return planar.Unit * horizontal + Vector3.new(0, vertical, 0), horizontal, vertical
end

-- Ballistic reference for static layout, not a replacement for Roblox simulation.
-- Uses the same launch velocity and workspace.Gravity; ignores optional boosts/steering.
function Trajectory.AtForward(frame, muzzle, level, timing, gravity, distance)
	local velocity = Trajectory.Velocity(muzzle.LookVector, level, timing)
	if not velocity then return nil end
	local origin = Trajectory.Origin(muzzle).Position
	local speed = velocity:Dot(frame.Forward)
	if speed <= 0 then return nil end
	local time = (distance - (origin - frame.Origin):Dot(frame.Forward)) / speed
	if time < 0 then return nil end
	local position = origin + velocity * time - Vector3.new(0, gravity * time * time / 2, 0)
	local tangent = velocity - Vector3.new(0, gravity * time, 0)
	return position, tangent, time
end

return Trajectory
