local SoundService = game:GetService("SoundService")
local Config = require(script.Parent.PresentationConfig)
local Audio = {}
local preloaded = false
local sounds = {}
local function getSound(kind)
	if sounds[kind] then return sounds[kind] end
	local entry = Config.Sounds[kind]
	if not entry then return nil end
	local sound = Instance.new("Sound")
	sound.Name = "FlightAudio_" .. kind
	sound.SoundId, sound.Volume, sound.PlaybackSpeed = entry.Id, entry.Volume, entry.Speed
	sound.Looped=entry.Looped==true
	sound.Parent = SoundService
	if kind=="SpeedRush"then
	 local eq=Instance.new("EqualizerSoundEffect");eq.Name="WindTone";eq.LowGain=-12;eq.MidGain=-5;eq.HighGain=3;eq.Parent=sound
	end
	sounds[kind] = sound -- One bounded reusable voice per role; no overlap buildup.
	return sound
end
function Audio.Preload()
	if preloaded then return end
	preloaded = true
	-- Never block flight/setup on network audio. Failed cues are skipped, not queued late.
	task.spawn(function()
		local assets = {}
		for kind in pairs(Config.Sounds) do table.insert(assets, getSound(kind)) end
		local ok, reason = pcall(function()
			game:GetService("ContentProvider"):PreloadAsync(assets, function(id, status)
				if status ~= Enum.AssetFetchStatus.Success then warn("[Audio] Unavailable:", id, status) end
			end)
		end)
		if not ok then warn("[Audio] Preload failed:", reason) end
	end)
end
function Audio.Play(kind)
	local sound = getSound(kind)
	if not sound or sound.IsLoaded == false then return end
	sound.TimePosition = 0
	sound:Play()
end
function Audio.Engine(throttle)
 local sound=getSound("Engine");if not sound then return end
 if throttle<=.001 then sound:Stop();return end
 if not sound.IsLoaded then return end
 sound.Volume=Config.Sounds.Engine.Volume*math.clamp(throttle,0,1)
 sound.PlaybackSpeed=.7+math.clamp(throttle,0,1)*.55
 if not sound.IsPlaying then sound:Play()end
end
function Audio.Rush(intensity)
 local sound=getSound("SpeedRush");if not sound then return end
 if intensity<=.015 then sound:Stop();return end
 if not sound.IsLoaded then return end
 sound.Volume=Config.Sounds.SpeedRush.Volume*math.clamp(intensity,0,1)
 sound.PlaybackSpeed=1.4+math.clamp(intensity,0,1)*.7
 if not sound.IsPlaying then sound:Play()end
end
return Audio
