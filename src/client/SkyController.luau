local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local module = ReplicatedStorage:WaitForChild("CloudConfig", 15)
assert(module and module:IsA("ModuleScript"), "[Sky] Missing CloudConfig ModuleScript; reconnect Rojo")
local Config = require(module)
local PresentationConfig = require(script.Parent.PresentationConfig)
local Presentation = PresentationConfig.Sky
local Sky = {}
local started, atmosphere, label, noticeUntil = false, nil, nil, 0
local preview = false
local previewStage = 1
local biomeIndex = 1
local stageNames = {"GROUND", "CLOUD", "HIGH_ALTITUDE", "SPACE"}
local groundSky, spaceSky, activeSky
local skyBandIndex = 1
local activeSkyKey
local lightingTween, atmosphereTween
local originalAtmosphere
local Preview = Config.HeightPresentation or PresentationConfig.DestructionPreview

local function cancelTransition()
	if lightingTween then lightingTween:Cancel(); lightingTween = nil end
	if atmosphereTween then atmosphereTween:Cancel(); atmosphereTween = nil end
end

local function switchPreviewSky(space)
 local band = Preview.SkyBands and Preview.SkyBands[skyBandIndex]
 local key = band and (tostring(band.Min)..":"..(band.AssetId or band.Name)) or (space and "Space" or "Ground")
 if activeSkyKey == key and activeSky then return end
 local template = if space then spaceSky else groundSky
 local nextSky = if band then Instance.new("Sky") else (template and template:IsA("Sky") and template:Clone() or Instance.new("Sky"))
 if band then
  for property, value in band.Properties do nextSky[property] = value end
 else
  nextSky.StarCount = if space then 3000 else 0
  nextSky.CelestialBodiesShown = true
 end
 nextSky.Name = "FlightSky"
 nextSky.Parent = Lighting
 if activeSky then activeSky:Destroy() end
 activeSky, activeSkyKey = nextSky, key
 Lighting:SetAttribute("AltitudeSky", band and band.Name or key)
 Lighting:SetAttribute("AltitudeSkyAsset", band and band.AssetId or nil)
end

local function applyPreview(stage, immediate, biome, band)
	skyBandIndex = band or 1
	biomeIndex = biome or 1
	Lighting:SetAttribute("AltitudeBiome", biomeIndex)
	cancelTransition()
	local wasSpace = previewStage == 4
	previewStage = stage
	Lighting:SetAttribute("AltitudeLayer", stageNames[stage])
	switchPreviewSky(stage == 4)
 -- Sky textures define the background. Altitude does not tint, darken or fog them.
 local lighting={ClockTime=Presentation.ClockTime,Brightness=Config.Ground.Brightness,
  ExposureCompensation=Config.Ground.Exposure,Ambient=Color3.fromRGB(table.unpack(Config.Ground.Ambient)),
  OutdoorAmbient=Color3.fromRGB(table.unpack(Config.Ground.Outdoor)),
  FogColor=Color3.fromRGB(210,230,250),FogStart=100000000,FogEnd=1000000000}
 local air={Density=0,Haze=0,Glare=0,Color=originalAtmosphere.Color,Decay=originalAtmosphere.Decay}
	if immediate then
		for property, value in lighting do Lighting[property] = value end
		for property, value in air do atmosphere[property] = value end
	else
		local tweenService = game:GetService("TweenService")
		local info = TweenInfo.new(Preview.TransitionSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		lightingTween = tweenService:Create(Lighting, info, lighting)
		atmosphereTween = tweenService:Create(atmosphere, info, air)
		lightingTween:Play()
		atmosphereTween:Play()
	end
end

local function apply(clouds)
	local settings = clouds and Config.Clouds or Config.Ground
	Lighting.ClockTime, Lighting.Brightness = Presentation.ClockTime, settings.Brightness
	Lighting.ExposureCompensation = settings.Exposure
	Lighting.Ambient = Color3.fromRGB(table.unpack(settings.Ambient))
	Lighting.OutdoorAmbient = Color3.fromRGB(table.unpack(settings.Outdoor))
	Lighting.FogColor = Color3.fromRGB(210, 230, 250)
	Lighting.FogEnd = settings.FogEnd
	if atmosphere then atmosphere.Density, atmosphere.Haze = settings.Density, settings.Haze end
end

function Sky.Reset()
	if not started then return end
	if preview then applyPreview(1, true) else apply(false) end
	noticeUntil = 0
	if label then label.Visible = false end
end

-- Only FlightClient's current Flying run may dispatch this server-authored payload.
function Sky.SetRegion(region)
	if not started then return end
	-- Altitude changes appearance only; discovery and rewards stay server authoritative.
	if not preview then apply(region.Region == "Clouds") end
	if region.FirstEntry and label then
		label.Text = region.FirstDiscovery and "CLOUD LAYER REACHED\n처음 도달한 구름층 · 더 높은 공간을 발견했습니다"
			or "CLOUD LAYER REACHED\n구름층에 다시 도달했습니다"
		label.Visible = true
		noticeUntil = os.clock() + Config.NoticeSeconds
	end
end

function Sky.ShowDestination(destination)
	if not started or not label then return end
	label.Text = string.upper(destination.DisplayName) .. (destination.FirstDiscovery and " DISCOVERED" or " REVISITED")
		.. "\n" .. (destination.FirstDiscovery and "성장해서 도달한 새로운 장소" or "발견한 장소에 다시 도달했습니다")
	label.Visible = true
	noticeUntil = os.clock() + Config.NoticeSeconds
end

function Sky.Start()
	if started then return end
	started = true
	local player = Players.LocalPlayer
	preview = Config.HeightPresentation ~= nil
	if preview then
		groundSky = ReplicatedStorage:FindFirstChild("SkyGround") or Lighting:FindFirstChild("SkyGround")
		spaceSky = ReplicatedStorage:FindFirstChild("SkySpace") or Lighting:FindFirstChild("SkySpace")
		if groundSky and not groundSky:IsA("Sky") then groundSky = nil end
		if spaceSky and not spaceSky:IsA("Sky") then spaceSky = nil end
        groundSky = groundSky and groundSky:Clone(); spaceSky = spaceSky and spaceSky:Clone()
	end
	for _, object in Lighting:GetChildren() do
		if object:IsA("Sky") then
			object:Destroy()
		elseif object:IsA("ColorCorrectionEffect") then object.Enabled = false
		elseif object:IsA("Atmosphere") then
			object.Density, object.Haze = 0, 0
			atmosphere = atmosphere or object
		end
	end
	if not atmosphere then atmosphere = Instance.new("Atmosphere"); atmosphere.Parent = Lighting end
	if preview then originalAtmosphere = {Color = atmosphere.Color, Decay = atmosphere.Decay} end
	local sky = Instance.new("Sky")
	sky.Name, sky.StarCount, sky.Parent = "FlightSky", 0, Lighting
	activeSky = sky
	if preview and not Preview.SkyBands then
		-- Replication may deliver the existing Studio-owned Sky assets after Main starts.
		for _, name in {"SkyGround", "SkySpace"} do
			task.spawn(function()
				local template = ReplicatedStorage:WaitForChild(name, 10)
				if template and template:IsA("Sky") then
					if name == "SkySpace" then spaceSky = template else groundSky = template end
					if (name == "SkySpace") == (previewStage == 4) then
						switchPreviewSky(previewStage == 4)
					end
				elseif name == "SkySpace" and not spaceSky then
					warn("[DestructionSpike Preview] ReplicatedStorage.SkySpace missing; existing Space sky cannot be shown")
				end
			end)
		end
	end
	Sky.Reset() -- Bright Ground identity; no legacy automatic Space transition.
	local gui = Instance.new("ScreenGui")
	gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "DiscoveryGui", false, 10
	label = Instance.new("TextLabel")
	label.Name = "Notice"
	label.Size, label.Position = UDim2.new(0.8, 0, 0, 76), UDim2.new(0.1, 0, 0.13, 0)
	label.BackgroundColor3, label.BackgroundTransparency = Color3.fromRGB(32, 60, 90), 0.2
	label.TextColor3, label.TextSize = Color3.fromRGB(245, 250, 255), 20
	label.Font, label.TextWrapped, label.Visible = Enum.Font.GothamBold, true, false
	label.Parent = gui
	gui.Parent = player:WaitForChild("PlayerGui", 15)
	player.CharacterAdded:Connect(Sky.Reset)
	player.CharacterRemoving:Connect(Sky.Reset)
	if preview then
		player:GetAttributeChangedSignal("FlightState"):Connect(function()
			if player:GetAttribute("FlightState") ~= "Flying" then Sky.Reset() end
		end)
	end
	RunService.Heartbeat:Connect(function()
		if preview and player:GetAttribute("FlightState") == "Flying" then
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root and root:IsA("BasePart") then
				-- LevelConfig's audited GroundY is 0; this is presentation-only altitude.
				local altitude = root.Position.Y - Preview.GroundY
				local stage = previewStage
				while stage < 4 and altitude >= Preview.Enter[stage] do stage += 1 end
				while stage > 1 and altitude < Preview.Enter[stage - 1] - Preview.Hysteresis do stage -= 1 end
				local biome=biomeIndex
                local definitions=Preview.Biomes or {}
                while biome<#definitions and altitude>=definitions[biome+1].Min do biome+=1 end
                while biome>1 and altitude<definitions[biome].Min-Preview.Hysteresis do biome-=1 end
                local band = skyBandIndex
                local bands = Preview.SkyBands or {}
                while band < #bands and altitude >= bands[band+1].Min do band += 1 end
                while band > 1 and altitude < bands[band].Min - Preview.Hysteresis do band -= 1 end
                if stage ~= previewStage or biome ~= biomeIndex or band ~= skyBandIndex then
                 applyPreview(stage, false, biome, band)
                 if label and definitions[biome] then label.Text=definitions[biome].Name.."\n구름 경계를 통과했습니다!";label.Visible=true;noticeUntil=os.clock()+2.5 end
                end
			end
		end
		if label.Visible and os.clock() >= noticeUntil then label.Visible = false end
	end)
end

return Sky
