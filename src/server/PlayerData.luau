local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Policy = require(script.Parent.RunPolicy)
-- Never open a DataStore during require: unpublished Places throw here.
local store = nil
local developmentMemory = false
local Data = {}
local profiles = {}
local defaults = {Gold = 0, Trophies = 0, PowerLvl = 1, BoostLvl = 1, MaxDistance = 0}
local started = false
local closing = false

local function valid(value, minimum)
	return Policy.finite(value) and value >= minimum and value <= 2 ^ 53 - 1
		and value == math.floor(value)
end

local function sameFields(a, b)
	for name in pairs(defaults) do
		if a[name] ~= b[name] then return false end
	end
	return true
end

function Data.IsReady(player)
	local profile = profiles[player]
	return profile ~= nil and profile.ready and not profile.leaving and not closing
end

function Data.GetLevel(player, name)
	local profile = profiles[player]
	return Data.IsReady(player) and profile.stats[name].Value or nil
end

function Data.Award(player, distance, gold, trophies)
	if not Data.IsReady(player) then return nil end
	local stats = profiles[player].stats
	if not valid(distance, 0) or not valid(gold, 0) or not valid(trophies, 0)
		or not valid(stats.Gold.Value + gold, 0) or not valid(stats.Trophies.Value + trophies, 0) then
		return nil
	end
	-- No yield: one run finalization commits all three fields together.
	local record = distance > stats.MaxDistance.Value
	stats.Gold.Value += gold
	stats.Trophies.Value += trophies
	if record then stats.MaxDistance.Value = distance end
	return record
end

function Data.Buy(player, kind)
	if not Data.IsReady(player) then return false end
	local profile = profiles[player]
	local now = os.clock()
	if now - profile.lastBuy < 0.2 then return false end
	profile.lastBuy = now
	local currency, level, cost
	if kind == "Gold" then
		currency, level = profile.stats.Gold, profile.stats.PowerLvl
		cost = math.floor(100 * 1.18 ^ (level.Value - 1))
	elseif kind == "Trophy" then
		currency, level = profile.stats.Trophies, profile.stats.BoostLvl
		cost = level.Value * 2
	else
		return false
	end
	if not valid(cost, 1) or not valid(level.Value + 1, 1) or currency.Value < cost then return false end
	currency.Value -= cost
	level.Value += 1
	return true
end

function Data.Save(player)
	local profile = profiles[player]
	if not profile or not profile.ready then return false end
	if developmentMemory then return true end -- Session-only; no DataStore API calls.
	while profile.saving do task.wait(0.05) end
	if not profile.ready then return false end
	profile.saving = true
	local snapshot = {}
	for name, minimum in pairs(defaults) do
		local value = profile.stats[name].Value
		if not valid(value, minimum) then
			profile.saving = false
			warn("[PlayerData] Invalid live data; refusing save for", player.UserId, name)
			return false
		end
		snapshot[name] = value
	end
	local success = false
	for attempt = 1, 3 do
		local conflict = false
		local ok, result = pcall(function()
			return store:UpdateAsync("Player_" .. player.UserId, function(old, keyInfo)
				if old ~= nil and type(old) ~= "table" then conflict = true; return nil end
				local previous = old or {}
				-- Optimistic concurrency: never overwrite another session's changed fields.
				-- The snapshot comparison permits retry after an uncertain successful write.
				if not sameFields(previous, profile.persisted) and not sameFields(previous, snapshot) then
					conflict = true
					return nil
				end
				local merged = table.clone(previous)
				for name, value in pairs(snapshot) do merged[name] = value end
				return merged, keyInfo and keyInfo:GetUserIds(), keyInfo and keyInfo:GetMetadata()
			end)
		end)
		if conflict then
			profile.ready = false
			player:SetAttribute("DataReady", false)
			warn("[PlayerData] Save conflict; no overwrite for", player.UserId)
			if player.Parent == Players then player:Kick("다른 세션의 데이터 변경을 확인했습니다. 다시 접속해 주세요.") end
			break
		end
		if ok and result ~= nil then
			profile.persisted = table.clone(snapshot)
			success = true
			break
		end
		warn("[PlayerData] Save failed", player.UserId, attempt, result)
		if attempt < 3 then task.wait(attempt) end
	end
	profile.saving = false
	return success
end

local function load(player)
	if profiles[player] then return end
	local profile = {ready = false, leaving = false, saving = false, lastBuy = -math.huge}
	profiles[player] = profile
	player:SetAttribute("DataReady", false)
	player:SetAttribute("DataMode", developmentMemory and "StudioMemory" or "Persistent")
	local ok, saved
	if developmentMemory then
		ok, saved = true, nil
	else
		for attempt = 1, 3 do
			ok, saved = pcall(function()
				if not store then store = game:GetService("DataStoreService"):GetDataStore("CannonGame_v3") end
				return store:GetAsync("Player_" .. player.UserId)
			end)
			if ok then break end
			if player.Parent ~= Players or profile.leaving or closing then return end
			if attempt < 3 then task.wait(attempt) end
		end
	end
	if profiles[player] ~= profile or player.Parent ~= Players or profile.leaving or closing then return end
	if not ok or (saved ~= nil and type(saved) ~= "table") then
		warn("[PlayerData] Load failed; save disabled", player.UserId, saved)
		player:Kick("데이터를 안전하게 불러오지 못했습니다. 잠시 후 다시 접속해 주세요.")
		return
	end
	local values = {}
	for name, minimum in pairs(defaults) do
		local value = saved and saved[name]
		if value == nil then value = minimum end
		if not valid(value, minimum) then
			warn("[PlayerData] Invalid saved field; save disabled", player.UserId, name)
			player:Kick("저장 데이터 확인이 필요합니다. 데이터는 변경되지 않았습니다.")
			return
		end
		values[name] = value
	end
	if player:FindFirstChild("leaderstats") then
		warn("[PlayerData] Duplicate leaderstats owner; refusing initialization")
		player:Kick("서버 데이터 초기화 충돌이 발생했습니다.")
		return
	end
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	for name, value in pairs(values) do
		local item = Instance.new("IntValue")
		item.Name, item.Value, item.Parent = name, value, stats
	end
	profile.stats, profile.persisted = stats, table.clone(saved or {})
	stats.Parent = player
	profile.ready = true
	player:SetAttribute("DataReady", true)
end

function Data.Start()
	if started then return end
	started = true
	-- Environment selection, NOT an API-failure fallback. A published game's
	-- storage outage must never turn into a writable default-data session.
	developmentMemory = RunService:IsStudio() and (game.GameId == 0 or game.PlaceId == 0)
	if developmentMemory then
		warn("[PlayerData] StudioMemory: unpublished Studio session; defaults only, NO DataStore reads/writes. Progress resets after leaving/Stop.")
	else
		print("[PlayerData] Persistent mode: load failures disable play/save; no memory fallback.")
	end
	Players.PlayerAdded:Connect(load)
	for _, player in Players:GetPlayers() do task.spawn(load, player) end
	Players.PlayerRemoving:Connect(function(player)
		local profile = profiles[player]
		if not profile then return end
		profile.leaving = true
		Data.Save(player)
		if profiles[player] == profile then profiles[player] = nil end
	end)
	if developmentMemory then
		game:BindToClose(function() closing = true; table.clear(profiles) end)
		return -- No autosave worker or persistent shutdown work in development.
	end
	task.spawn(function()
		while not closing do
			task.wait(60)
			if closing then break end
			for player, profile in pairs(profiles) do
				if profile.ready and not profile.leaving then task.spawn(Data.Save, player) end
			end
		end
	end)
	game:BindToClose(function()
		closing = true
		local pending = 0
		for player in pairs(profiles) do
			pending += 1
			task.spawn(function() Data.Save(player); pending -= 1 end)
		end
		local deadline = os.clock() + 25
		while pending > 0 and os.clock() < deadline do task.wait(0.1) end
	end)
end

return Data
