local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Input = {}
local ACTION = "RocketShooterFlightSteer"

-- This adapter emits only a normalized axis; a future touch adapter can call
-- SetAxis(-1..1) without changing the remote contract or the physics implementation.
function Input.Start(sendAxis, settings)
	local stopped, axis, elapsed, focused = false, 0, 0, true
	local held = {}
	local connections = {}
	local controller = {}
	function controller.SetAxis(value)
		if stopped then return end
		if type(value) ~= "number" or value ~= value then value = 0 end
		axis = math.clamp(value, -1, 1)
	end
	local function neutral()
		table.clear(held)
		controller.SetAxis(0)
	end
	local function update()
		local left = held[Enum.KeyCode.A] or held[Enum.KeyCode.Left]
		local right = held[Enum.KeyCode.D] or held[Enum.KeyCode.Right]
		controller.SetAxis((right and 1 or 0) - (left and 1 or 0))
	end
	ContextActionService:BindActionAtPriority(ACTION, function(_, inputState, input)
		if stopped then return Enum.ContextActionResult.Pass end
		if not focused or UserInputService:GetFocusedTextBox() then
			neutral()
			return Enum.ContextActionResult.Pass
		end
		if inputState == Enum.UserInputState.Begin then held[input.KeyCode] = true
		elseif inputState == Enum.UserInputState.End then held[input.KeyCode] = nil
		elseif inputState == Enum.UserInputState.Cancel then neutral() end
		update()
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value,
		Enum.KeyCode.A, Enum.KeyCode.D, Enum.KeyCode.Left, Enum.KeyCode.Right)
	if not UserInputService:GetFocusedTextBox() then
		for _, key in ipairs({Enum.KeyCode.A, Enum.KeyCode.D, Enum.KeyCode.Left, Enum.KeyCode.Right}) do
			held[key] = UserInputService:IsKeyDown(key) or nil
		end
		update()
	end
	table.insert(connections, UserInputService.WindowFocusReleased:Connect(function() focused = false; neutral() end))
	table.insert(connections, UserInputService.WindowFocused:Connect(function() focused = true; neutral() end))
	table.insert(connections, UserInputService.TextBoxFocused:Connect(neutral))
	table.insert(connections, RunService.Heartbeat:Connect(function(dt)
		if stopped then return end
		if not focused or UserInputService:GetFocusedTextBox() then neutral() end
		elapsed += dt
		if elapsed >= settings.SendInterval then
			elapsed = 0 -- No packet burst after a slow frame.
			sendAxis(axis)
		end
	end))
	sendAxis(axis)
	function controller.Stop()
		if stopped then return end
		stopped = true
		ContextActionService:UnbindAction(ACTION)
		for _, connection in ipairs(connections) do connection:Disconnect() end
		table.clear(connections)
		table.clear(held)
		-- No late final packet: the server has already ended/cancelled this run.
	end
	return controller
end

return Input
