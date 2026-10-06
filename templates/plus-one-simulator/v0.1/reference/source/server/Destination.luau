local Coordinates = require(script.Parent.WorldCoordinates)
local Assets = require(script.Parent.AssetRegistry)
local Destination = {}

function Destination.Build(parent, frame, plan, definitions)
	for _, definition in ipairs(definitions or {}) do
		if definition.Forward >= plan.Start and definition.Forward < plan.Start + plan.Length then
			local object, reason = Assets.Create(definition.Key)
			if object then
				object.Name = definition.Id
				object:SetAttribute("DestinationId", definition.Id)
				object:SetAttribute("DisplayName", definition.DisplayName)
				object:SetAttribute("Region", definition.Region)
				local position = Coordinates.Position(frame, definition.Forward, definition.Lateral, definition.Altitude)
				object:PivotTo(CFrame.lookAt(position, position + frame.Forward))
				object.Parent = parent
			else warn("[Destination] Missing landmark", definition.Id, reason) end
		end
	end
end

-- Current, validated sample only. Never combine maxima from different points in a run.
-- The fixed course frame also rejects a high-altitude flight along the wrong yaw.
function Destination.Sample(frame, position, metrics, definitions, visited)
	local forward, altitude, lateral = Coordinates.Measure(frame, position)
	for _, definition in ipairs(definitions or {}) do
		if not visited[definition.Id] and metrics.CurrentAltitude >= definition.RequiredAltitude
			and altitude >= definition.RequiredAltitude
			and math.abs(forward - definition.Forward) <= definition.HalfForward
			and math.abs(lateral - definition.Lateral) <= definition.HalfLateral
			and math.abs(altitude - definition.Altitude) <= definition.HalfAltitude then
			visited[definition.Id] = true
			return {Id = definition.Id, DisplayName = definition.DisplayName, Region = definition.Region}
		end
	end
	return nil
end

return Destination
