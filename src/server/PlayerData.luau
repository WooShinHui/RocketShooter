local balanceModule = game:GetService("ReplicatedStorage"):WaitForChild("BalanceConfig", 15)
assert(balanceModule and balanceModule:IsA("ModuleScript"),
	"[Setup] ReplicatedStorage.BalanceConfig must be a ModuleScript. Stop Play, restart rojo serve with default.project.json, reconnect and accept sync.")
local Balance = require(balanceModule)
local growthModule = game:GetService("ReplicatedStorage"):FindFirstChild("ProgressionConfig")
local Growth = growthModule and require(growthModule)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Policy = require(script.Parent.RunPolicy)
-- Never open a DataStore during require: unpublished Places throw here.
local store = nil
local developmentMemory = false
local rocketModeModule=game:GetService("ReplicatedStorage"):FindFirstChild("RocketModeConfig")
local RocketMode=rocketModeModule and require(rocketModeModule).Enabled
local RocketEconomy=RocketMode and require(script.Parent.RocketEconomy)
local ClickerModule=game:GetService("ReplicatedStorage"):FindFirstChild("ClickerConfig")
local Clicker=ClickerModule and require(ClickerModule)
local SkinModule=RocketMode and game:GetService("ReplicatedStorage"):FindFirstChild("RocketSkinCatalog")
local Skins=SkinModule and require(SkinModule)
local Data = {}
local profiles = {}
local defaults = {Gold = 0, Trophies = 0, PowerLvl = 1, BoostLvl = 1, MaxDistance = 0, MaxAltitude = 0,
	TrainingLevel = 0, TrainingXP = 0, Rebirths = 0, TrainingTier = 1}
if RocketMode then defaults.EconomyVersion=0;defaults.XPGearLvl=1;if Skins then defaults.RocketSkinMask=1;defaults.RocketSkinEquipped=1 end end
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

function Data.Award(player, distance, gold, trophies, altitude)
	if not Data.IsReady(player) then return nil end
    if RocketMode and gold~=0 then return nil end
	local stats = profiles[player].stats
	if not valid(distance, 0) or not valid(gold, 0) or not valid(trophies, 0)
		or (altitude ~= nil and not valid(altitude, 0))
		or not valid(stats.Gold.Value + gold, 0) or not valid(stats.Trophies.Value + trophies, 0) then
		return nil
	end
	-- No yield: a successful run commits rewards and records together.
	local record = distance > stats.MaxDistance.Value
	local altitudeRecord = altitude ~= nil and altitude > stats.MaxAltitude.Value
	stats.Gold.Value += gold
	stats.Trophies.Value += trophies
	if record then stats.MaxDistance.Value = distance end
	if altitudeRecord then stats.MaxAltitude.Value = altitude end
	return record, altitudeRecord
end

function Data.Buy(player, kind)
    if RocketMode then return false end -- Rocket progression buys XP items, never direct launch power.
	if not Data.IsReady(player) then return false end
	local profile = profiles[player]
	local now = os.clock()
	if now - profile.lastBuy < 0.2 then return false end
	profile.lastBuy = now
	local currency, level, cost
	if kind == "Gold" then
		currency, level = profile.stats.Gold, profile.stats.PowerLvl
		cost = Balance.PowerCost(level.Value)
	elseif kind == "Trophy" then
		currency, level = profile.stats.Trophies, profile.stats.BoostLvl
		cost = Balance.BoostCost(level.Value)
	else
		return false
	end
	if not valid(cost, 1) or not valid(level.Value + 1, 1) or currency.Value < cost then return false end
	currency.Value -= cost
	level.Value += 1
	return true
end

local function idle(player)
	local phase=player:GetAttribute("FlightState")
	return Data.IsReady(player) and (phase==nil or phase=="Idle")
end

function Data.GetTrainingPower(player)
	if not Growth or not Data.IsReady(player) then return 0 end
	local s=profiles[player].stats
	return Growth.PowerBonus(s.TrainingLevel.Value,s.Rebirths.Value)
end

function Data.TrophyMultiplier(player)
	if not Growth or not Data.IsReady(player) then return 1 end
	local index=player:GetAttribute("TrainingBuffIndex") or 1
	local pad=Growth.TrophyPads[index]
	return pad and profiles[player].stats.Trophies.Value>=pad.Required and pad.Multiplier or 1
end

local function addXP(player,gain,source,unscaled)
	local profile=profiles[player];local s=profile.stats
	gain=gain*(if unscaled then 1 else Growth.Multiplier(s.Rebirths.Value)*Data.TrophyMultiplier(player)*(if RocketMode then Growth.XPItems[s.XPGearLvl.Value].Multiplier else 1))+(profile.xpRemainder or 0)
	local whole=math.floor(gain);profile.xpRemainder=gain-whole
	if not valid(whole,0) or not valid(s.TrainingXP.Value+whole,0) then profile.xpRemainder=0;return 0 end
 local level,xp=Growth.Advance(s.TrainingLevel.Value,s.TrainingXP.Value+whole)
 if not valid(level,0) or not valid(xp,0) then return 0 end
 s.TrainingLevel.Value=level;s.TrainingXP.Value=xp
 local remote=game:GetService("ReplicatedStorage"):FindFirstChild("ExperienceGained")
 if whole>0 and remote then remote:FireClient(player,whole,player.Character,source or "XP")end
	return whole
end

-- Online baseline accrues independently of character/flight/toilet state.
function Data.PassiveXP(player,seconds)
 if not RocketMode or not Growth or not Data.IsReady(player) or not Policy.finite(seconds) or seconds<=0 or seconds>2 then return 0 end
 local profile=profiles[player];local now=os.clock()
 local budget=math.min(seconds,math.max(0,now-profile.lastPassive))
 profile.lastPassive=now
 return addXP(player,budget*Growth.PassiveXPRate(profile.stats.TrainingLevel.Value),"Passive")
end

-- Called only by the server-owned event after a swept ring crossing.
function Data.AwardGoldRingXP(player)
 if not Growth or not Data.IsReady(player) or player:GetAttribute("FlightState")~="Flying" then return 0 end
 return addXP(player,Growth.GoldRingXP(profiles[player].stats.TrainingLevel.Value),"GoldRing",true)
end

function Data.AwardFlightXP(player,gain)
	if not Growth or not Data.IsReady(player) or player:GetAttribute("FlightState")~="Flying" or not valid(gain,0) or gain>1000000 then return 0 end
	return addXP(player,gain,"Flight")
end

function Data.BuyXPItem(player,expected)
    if not RocketMode or not idle(player) then return false,"귀환 후 구매할 수 있습니다" end
    local profile=profiles[player];local s=profile.stats;local nextIndex=s.XPGearLvl.Value+1
    local item=Growth.XPItems[nextIndex];local now=os.clock()
    if expected~=nextIndex or not item or now-(profile.lastXPBuy or -math.huge)<.2 then return false,"구매 정보를 다시 확인하세요" end
    profile.lastXPBuy=now
    if s.Trophies.Value<item.Cost then return false,"트로피가 부족합니다" end
    s.Trophies.Value-=item.Cost;s.XPGearLvl.Value=nextIndex
    player:SetAttribute("TrainingXPMultiplier",Data.TrophyMultiplier(player))
    return true,item.Name.." 구매 완료! 경험치 x"..item.Multiplier
end

local function clickAlive(player)
 if not Data.IsReady(player)then return false end
 local character=player.Character;local hum=character and character:FindFirstChildOfClass("Humanoid")
 return hum~=nil and hum.Health>0 and character.Parent~=nil
end
function Data.AwardAutoClickXP(player,count,mode)
 if not Clicker or not Growth or not clickAlive(player)or not valid(count,1)or count>6 or Clicker.Rate(mode)==0 or player:GetAttribute("AutoClickMode")~=mode then return 0 end
 if mode=="OP"and not Clicker.PreviewOP then return 0 end
 return addXP(player,count*Clicker.ManualXP,"AutoClick")
end
function Data.ClickXP(player)
    if RocketMode then
     if not Clicker or not Growth or not clickAlive(player)then return false end
     local profile=profiles[player];local now=os.clock()
     local tokens=math.min(Clicker.ManualBurst,(profile.clickTokens or Clicker.ManualBurst)+math.max(0,now-(profile.clickTokenTime or now))*Clicker.ManualRate)
     profile.clickTokenTime=now;profile.clickTokens=tokens
     if tokens+1e-8<1 then return false end
     profile.clickTokens=math.max(0,tokens-1);addXP(player,Clicker.ManualXP,"Click");return true
    end
	if not Growth or not idle(player) then return false end
	local profile=profiles[player];local now=os.clock()
	if now-(profile.lastClick or -math.huge)<.2 then return false end
	profile.lastClick=now;addXP(player,1,"Click");return true
end

function Data.Train(player,seconds,tier)
	if not Growth or not idle(player) or not valid(tier,1) or tier>#Growth.Tiers
		or not Policy.finite(seconds) or seconds<=0 or seconds>2 then return false end
	local profile=profiles[player];local s=profile.stats
	if tier>s.TrainingTier.Value then return false end
	-- Server clock budget prevents repeated calls from creating extra XP.
	local now=os.clock();local previous=profile.lastTrain or now
	profile.lastTrain=now
	seconds=math.min(seconds,math.max(0,now-previous))
	addXP(player,seconds*Growth.Tiers[tier].Rate,"Toilet")
	return true
end

function Data.Rebirth(player,expected)
	if not Growth or not idle(player) then return false,"비행을 마치고 귀환해 주세요" end
	local profile=profiles[player];local s=profile.stats
	if not valid(expected,0) or expected~=s.Rebirths.Value then return false,"최신 환생 정보를 확인해 주세요" end
	if s.TrainingLevel.Value<Growth.RebirthRequired(s.Rebirths.Value) then return false,"환생에 레벨 "..Growth.RebirthRequired(s.Rebirths.Value).."이 필요합니다" end
	if s.Rebirths.Value>=Growth.MaxRebirths then return false,"환생 상한에 도달했습니다" end
	-- No yield; resets only the new training track. Existing purchases/currencies/records survive.
	s.Rebirths.Value+=1;s.TrainingLevel.Value=0;s.TrainingXP.Value=0
 if Skins then s.RocketSkinMask.Value=Skins.Milestones(s.RocketSkinMask.Value,s.Rebirths.Value) end
	profile.xpRemainder=0;profile.lastTrain=os.clock();profile.lastPassive=os.clock()
	return true,"환생 완료! 영구 수련 배율 증가"
end

function Data.SelectRocketSkin(player,index)
 if not Skins or not idle(player) then return false,"귀환 후 장착할 수 있습니다" end
 if not valid(index,1) or not Skins.Items[index] then return false,"잘못된 스킨입니다" end
 local profile=profiles[player];local s=profile.stats;local item=Skins.Items[index]
 local now=os.clock()
 if now-(profile.lastSkinChange or -math.huge)<.2 then return false,"잠시 후 다시 선택하세요" end
 profile.lastSkinChange=now
 if not Skins.Owns(s.RocketSkinMask.Value,index) then
  if s.Rebirths.Value<item.Rebirths then return false,"환생 "..item.Rebirths.."회 필요" end
  if s.Trophies.Value<item.Cost then return false,"트로피가 부족합니다" end
  -- Ownership and payment commit together; repeat requests never charge twice.
  s.Trophies.Value-=item.Cost;s.RocketSkinMask.Value=Skins.Grant(s.RocketSkinMask.Value,index)
 end
 s.RocketSkinEquipped.Value=index;player:SetAttribute("RocketStyle",item.Id)
 return true,item.Name.." 장착 완료!"
end

function Data.BuyTrainingTier(player,expected)
	if not Growth or not idle(player) then return false,"귀환 후 구매할 수 있습니다" end
	local s=profiles[player].stats;local index=s.TrainingTier.Value+1
	if not valid(expected,1) or expected~=index then return false,"최신 티어 정보를 확인해 주세요" end
	local tier=Growth.Tiers[index]
	if not tier then return false,"최고 티어입니다" end
	if s.TrainingLevel.Value<tier.Level or s.Rebirths.Value<(tier.Rebirths or 0) then return false,"수련 레벨 / 환생 조건이 부족합니다" end
	if s.Trophies.Value<tier.Cost then return false,"트로피가 부족합니다" end
	s.Trophies.Value-=tier.Cost;s.TrainingTier.Value=index
	return true,tier.Name.." 티어 해금!"
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
	if RocketMode then
        local migrated=RocketEconomy.Migrate(values,#Growth.XPItems)
        if not migrated then player:Kick("저장된 성장 데이터를 확인해야 합니다");return end
        values=migrated
        if Skins then
         if not Skins.Valid(values.RocketSkinMask,values.RocketSkinEquipped) then player:Kick("로켓 스킨 저장 정보를 확인해야 합니다");return end
         values.RocketSkinMask=Skins.Milestones(values.RocketSkinMask,values.Rebirths)
        end
    end
    if Growth and (not valid(Growth.RequiredXP(values.TrainingLevel),1) or values.Rebirths>Growth.MaxRebirths
		or values.TrainingTier>#Growth.Tiers or values.TrainingXP>=math.max(Growth.RequiredXP(values.TrainingLevel),40+12*values.TrainingLevel)) then
		warn("[PlayerData] Invalid training data; save disabled",player.UserId)
		player:Kick("수련 저장 데이터 확인이 필요합니다. 데이터는 변경되지 않았습니다.")
		return
	end
	-- Preserve valid XP from the previous, slower curve by carrying it into new levels.
	if Growth then
	 local level,xp=Growth.Advance(values.TrainingLevel,values.TrainingXP)
	 if not valid(level,0) or not valid(xp,0) then player:Kick("수련 데이터 계산을 확인해야 합니다");return end
	 values.TrainingLevel=level;values.TrainingXP=xp
	end
	if player:FindFirstChild("leaderstats") then
		warn("[PlayerData] Duplicate leaderstats owner; refusing initialization")
		player:Kick("서버 데이터 초기화 충돌이 발생했습니다.")
		return
	end
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local private=Instance.new("Folder");private.Name="ProgressStats";private.Parent=player
    local byName={}
	for name, value in pairs(values) do
		local item = Instance.new("IntValue")
		item.Name,item.Value=name,value
        item.Parent=if RocketMode and (name=="Gold" or name=="PowerLvl" or name=="BoostLvl" or name=="EconomyVersion" or name=="RocketSkinMask" or name=="RocketSkinEquipped") then private else stats
        byName[name]=item
	end
	profile.stats, profile.persisted = byName, table.clone(saved or {})
	stats.Parent = player
	profile.lastPassive=os.clock()
	profile.ready = true
 if Skins then player:SetAttribute("RocketStyle",Skins.Items[values.RocketSkinEquipped].Id) end
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
