-- Read-only display of existing server-owned, replicated balances.
local rocketModule=game:GetService("ReplicatedStorage"):FindFirstChild("RocketModeConfig")
local rocket=rocketModule and require(rocketModule).Enabled
local Hud = {}
function Hud.Start(player)
	local playerGui = player:WaitForChild("PlayerGui", 15)
	if not playerGui then return end
	local oldCurrency = playerGui:FindFirstChild("CurrencyHud")
	if oldCurrency then oldCurrency:Destroy() end
	local currencyGui = Instance.new("ScreenGui")
	currencyGui.Name, currencyGui.ResetOnSpawn, currencyGui.DisplayOrder = "CurrencyHud", false, 20
	currencyGui.Parent = playerGui
	local currencyLabel = Instance.new("TextLabel")
	currencyLabel.Name = "Balances"
	currencyLabel.Size, currencyLabel.Position = UDim2.new(0, 260, 0, 64), UDim2.new(0, 20, 0, 16)
	currencyLabel.BackgroundColor3, currencyLabel.BackgroundTransparency = Color3.fromRGB(28, 37, 49), 0.15
	currencyLabel.TextColor3, currencyLabel.TextSize = Color3.fromRGB(255, 232, 164), 18
	currencyLabel.Font, currencyLabel.TextWrapped = Enum.Font.GothamBold, true
	currencyLabel.Text = "Gold: —\nTrophies: —"
	currencyLabel.Parent = currencyGui
	task.spawn(function()
		local stats = player:WaitForChild("leaderstats", 30)
		if not stats then return end
		if rocket then
            local trophies=stats:WaitForChild("Trophies",15);if not trophies then return end
            local function sync() currencyLabel.Text="트로피  "..trophies.Value end
            trophies.Changed:Connect(sync);sync();return
        end
        local gold, trophies = stats:WaitForChild("Gold", 15), stats:WaitForChild("Trophies", 15)
		if not gold or not trophies then return end
		local function updateBalances()
			currencyLabel.Text = string.format("골드  %d\n트로피  %d", gold.Value, trophies.Value)
		end
		gold.Changed:Connect(updateBalances)
		trophies.Changed:Connect(updateBalances)
		updateBalances()
	end)
end
return Hud
