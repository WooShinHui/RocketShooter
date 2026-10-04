local Config = require(script.Parent.SteeringConfig)
local Steering = {}

function Steering.Create(launchVelocity)
	local horizontal = Vector3.new(launchVelocity.X, 0, launchVelocity.Z)
	if horizontal.Magnitude < Config.MinForwardSpeed then return nil end
	local forward = horizontal.Unit
	return {
		forward = forward, right = Vector3.new(-forward.Z, 0, forward.X),
		axis = 0, receivedAt = -math.huge, acceptedAt = -math.huge, influenced = false,
	}
end

function Steering.Accept(control, axis, now)
	if not control or type(axis) ~= "number" or axis ~= axis or math.abs(axis) > 1 then return false end
	if now - control.acceptedAt < Config.MinPacketInterval then return false end
	control.axis, control.receivedAt, control.acceptedAt = axis, now, now
	return true
end

function Steering.Step(control, velocity, dt, now)
	if not control then return velocity, 0 end
	local axis = now - control.receivedAt <= Config.InputTimeout and control.axis or 0
	local forwardSpeed = velocity:Dot(control.forward)
	local sideSpeed = velocity:Dot(control.right)
	local target = 0
	if control.Descent or forwardSpeed >= Config.MinForwardSpeed then
		target = axis * (if control.Descent then 110 else math.min(Config.MaxLateralSpeed, forwardSpeed * Config.ForwardSpeedFraction))
	end
	-- Untouched runs follow their original trajectory, including external lateral impulses.
	if target == 0 and not control.influenced then return velocity, 0 end
	local rate = if control.Descent then (if target==0 then 280 else 360) else (target == 0 and Config.ReleaseDeceleration or Config.Acceleration)
	local maxChange = rate * math.clamp(dt, 0, Config.MaxStepSeconds)
	local delta = math.clamp(target - sideSpeed, -maxChange, maxChange)
	if delta == 0 then return velocity, 0 end
	control.influenced = true
	-- Fixed launch-plane right vector is orthogonal to both forward and world Y.
	-- Never rotate/rebuild the entire velocity vector, or add forward/upward thrust.
	return velocity + control.right * delta, math.abs(delta)
end

function Steering.Apply(control, root, dt, now)
	local velocity = root.AssemblyLinearVelocity
	local corrected, budget = Steering.Step(control, velocity, dt, now)
	if budget > 0 then
		-- Send only a lateral momentum delta, never an absolute XYZ velocity snapshot.
		local lateralDelta = (corrected - velocity):Dot(control.right)
		root:ApplyImpulse(control.right * lateralDelta * root.AssemblyMass)
	end
	return budget
end

return Steering
