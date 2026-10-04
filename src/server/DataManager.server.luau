-- Remotes are independent of persistence and exist before data initialization.
local remotes = require(script.Parent.Remotes).Ensure()
local Data = require(script.Parent.PlayerData)
remotes.BuyUpgrade.OnServerInvoke = function(player, kind) return Data.Buy(player, kind) end
remotes.ResetData.OnServerInvoke = function() return false end
Data.Start()
