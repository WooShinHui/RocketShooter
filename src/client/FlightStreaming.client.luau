-- Server owns flight integration, landing and rewards while streaming catches up.
-- Keep the engine's full-screen loading modal from covering steering and impacts.
local player=game.Players.LocalPlayer
local GuiService=game:GetService("GuiService")
local function update()
 GuiService:SetGameplayPausedNotificationEnabled(player:GetAttribute("FlightState")~="Flying")
end
player:GetAttributeChangedSignal("FlightState"):Connect(update)
script.Destroying:Connect(function()GuiService:SetGameplayPausedNotificationEnabled(true)end)
update()
