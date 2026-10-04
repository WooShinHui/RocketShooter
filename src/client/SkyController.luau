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
local lightingTween, atmosphereTween
local originalAtmosphere
local Preview = Config.HeightPresentation or PresentationConfig.DestructionPreview

local function cancelTransition()
	if lightingTween then lightingTween:Cancel(); lightingTween = nil end
	if atmosphereTween then atmosphereTween:Cancel(); atmosphereTween = nil end
end

local function switchPreviewSky(space)
	-- Templates remain untouched in ReplicatedStorage; only the active local clone changes.
	local template
	if space then template = spaceSky else template = groundSky end
	if activeSky then activeSky:Destroy() end
	-- Never reuse an unidentified Lighting sky as Ground (it may be Space).
	activeSky = template and template:IsA("Sky") and template:Clone() or Instance.new("Sky")
	activeSky.StarCount = if space then 3000 else 0
    activeSky.CelestialBodiesShown = true
	activeSky.Name = "FlightSky"
	activeSky.Parent = Lighting
end

local function applyPreview(stage, immediate, biome)
	biomeIndex = biome or 1
	Lighting:SetAttribute("AltitudeBiome", biomeIndex)
	cancelTransition()
	local wasSpace = previewStage == 4
	previewStage = stage
	Lighting:SetAttribute("AltitudeLayer", stageNames[stage])
	if immediate or wasSpace ~= (stage == 4) then switchPreviewSky(stage == 4) end
	local settings = stage == 2 and Config.Clouds or Config.Ground
	local lighting = {
		ClockTime = Presentation.ClockTime, Brightness = settings.Brightness,
		ExposureCompensation = settings.Exposure,
		Ambient = Color3.fromRGB(table.unpack(settings.Ambient)),
		OutdoorAmbient = Color3.fromRGB(table.unpack(settings.Outdoor)),
		FogColor = Color3.fromRGB(210, 230, 250), FogEnd = settings.FogEnd,
	}
	local air = {Density = settings.Density, Haze = settings.Haze,
		Color = originalAtmosphere.Color, Decay = originalAtmosphere.Decay}
	if stage == 2 then
		air.Color, air.Decay = Color3.fromRGB(218, 233, 250), Color3.fromRGB(170, 194, 225)
	elseif stage == 3 then
		lighting.ClockTime = 17
        lighting.Brightness, lighting.ExposureCompensation = 1.8, -0.08
		lighting.Ambient, lighting.OutdoorAmbient = Color3.fromRGB(83, 108, 155), Color3.fromRGB(105, 133, 182)
		lighting.FogColor = Color3.fromRGB(85, 124, 190)
		air.Density, air.Haze = 0.12, 0.15
		air.Color, air.Decay = Color3.fromRGB(127, 166, 225), Color3.fromRGB(60, 89, 150)
	elseif stage == 4 then
		lighting.ClockTime, lighting.Brightness, lighting.ExposureCompensation = 0, 1.1, -0.1
		lighting.Ambient, lighting.OutdoorAmbient = Color3.fromRGB(65, 75, 105), Color3.fromRGB(90, 105, 140)
		lighting.FogColor = Color3.fromRGB(25, 35, 65)
		air.Density, air.Haze = 0, 0
	end
	-- Strong region identities, while the existing 100km Space switch stays intact.
    local profiles={
        [3]={Clock=13,Ambient={142,191,222},Color={193,229,255},Decay={97,149,195},Density=.17,Haze=.5},
        [4]={Clock=18.4,Ambient={116,77,167},Color={165,131,233},Decay={66,48,127},Density=.1,Haze=.3},
        [5]={Clock=19.6,Ambient={62,99,140},Color={77,126,177},Decay={35,48,80},Density=.2,Haze=1.2},
        [6]={Clock=18.1,Ambient={166,103,92},Color={243,153,101},Decay={105,60,111},Density=.07,Haze=.2},
        [7]={Clock=22,Ambient={63,110,143},Color={79,151,192},Decay={28,45,82},Density=.025,Haze=0},
    }
    local profile=profiles[biomeIndex]
    if profile then
        lighting.ClockTime=profile.Clock;lighting.Ambient=Color3.fromRGB(table.unpack(profile.Ambient));lighting.OutdoorAmbient=lighting.Ambient
        lighting.FogColor=Color3.fromRGB(table.unpack(profile.Color))
        air.Color=lighting.FogColor;air.Decay=Color3.fromRGB(table.unpack(profile.Decay));air.Density=profile.Density;air.Haze=profile.Haze
    end
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
	if preview then
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
                if stage ~= previewStage or biome ~= biomeIndex then
                 applyPreview(stage, false, biome)
                 if label and definitions[biome] then label.Text=definitions[biome].Name.."\n구름 경계를 통과했습니다!";label.Visible=true;noticeUntil=os.clock()+2.5 end
                end
			end
		end
		if label.Visible and os.clock() >= noticeUntil then label.Visible = false end
	end)
end

return Sky
