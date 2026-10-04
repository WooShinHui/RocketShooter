local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rocket=ReplicatedStorage:FindFirstChild("RocketModeConfig")
if rocket and require(rocket).Enabled then return end -- No legacy landing island in rocket/dive mode.
local configModule = ReplicatedStorage:WaitForChild("SkyIslandConfig", 10)
if not configModule then
	warn("[SkyIslandSpawner] 10초 내에 ReplicatedStorage.SkyIslandConfig를 찾지 못해 플랫폼을 생성하지 않습니다.")
	return
end
local Config = require(configModule)
local LevelConfig = require(script.Parent.LevelConfig)
local Coordinates = require(script.Parent.WorldCoordinates)
-- 월드 빌더가 캡처한 축을 사용하여 시작 순서나 조준으로 인한 배치 차이를 방지한다.
local world = workspace:WaitForChild("GeneratedWorld", 15)
if not world or world:GetAttribute("Owner") ~= "LevelBuilder" then
	warn("[SkyIsland] 생성된 월드가 없어 플랫폼을 생성하지 못했습니다")
	return
end
local origin, forward = world:GetAttribute("LayoutOrigin"), world:GetAttribute("Forward")
assert(typeof(origin) == "Vector3" and typeof(forward) == "Vector3", "[SkyIsland] 월드 좌표가 필요합니다")
local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildOfClass("SpawnLocation")
local groundY = LevelConfig.GroundY
if groundY == nil then
	assert(spawn and spawn:IsA("BasePart"), "[SkyIsland] SpawnLocation 또는 LevelConfig.GroundY가 필요합니다")
	groundY = spawn.Position.Y + spawn.Size.Y / 2
end
local frame = {Origin = origin, Forward = forward,
	Right = Vector3.new(-forward.Z, 0, forward.X), GroundY = groundY}
local definition = Config.Platform
local platform = Instance.new("Part")
platform.Name = "SkyIslandPlatform"
platform.Position = Coordinates.Position(frame, definition.Forward, definition.Lateral, definition.Altitude)
platform.Size, platform.Color, platform.Material = definition.Size, definition.Color, definition.Material
platform.Anchored, platform.CanCollide = definition.Anchored, definition.CanCollide
platform.TopSurface, platform.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
platform:SetAttribute("IsSkyIsland", true)
CollectionService:AddTag(platform, Config.TAG)
platform.Parent = workspace
