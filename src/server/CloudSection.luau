local Coordinates = require(script.Parent.WorldCoordinates)
local Assets = require(script.Parent.AssetRegistry)
local Clouds = {}

function Clouds.Build(parent, frame, plan, config, destinations)
	if not config then return end
	local folder = Instance.new("Folder")
	folder.Name = "CloudLayer"
	local g = config.Geometry
	local first = math.ceil((plan.Start - g.Offset) / g.Spacing)
	local last = math.ceil((plan.Start + plan.Length - g.Offset) / g.Spacing) - 1
	for index = first, last do
		for bankIndex, bank in ipairs(g.Banks) do
				local object, reason = Assets.Create(bank.Key)
				if object then
					local position = Coordinates.Position(frame, g.Offset + index * g.Spacing + bank.ForwardOffset,
						bank.Lateral + (index % 2 == 0 and 32 or -32),
						bank.Altitude + ((index + bankIndex) % 3 - 1) * g.HeightVariation)
					-- Keep the destination silhouette and approach free of foreground cloud banks.
					local forward, _, lateral = Coordinates.Measure(frame, position)
					local obscures = false
					for _, destination in ipairs(destinations or {}) do
						if forward >= 0 and forward <= destination.Forward + destination.HalfForward
							and math.abs(lateral - destination.Lateral * math.min(1, forward / destination.Forward)) < destination.CloudClearance then
							obscures = true; break
						end
					end
					if obscures then object:Destroy(); continue end
					object:PivotTo(CFrame.lookAt(position, position + frame.Forward))
					object.Parent = folder
				else warn("[Clouds] Skipped puff:", reason) end
		end
	end
	folder.Parent = parent -- Uses existing section streaming and cleanup, no second world owner.
end

return Clouds
