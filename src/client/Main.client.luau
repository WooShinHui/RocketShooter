local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local StarterGui=game:GetService("StarterGui")
pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,false)end)
local player=Players.LocalPlayer
local gui=player:WaitForChild("PlayerGui")
for _,name in {"TimingGaugeGui","CannonAimGui","ResultGui","ShopGui","AimGui"}do local old=gui:FindFirstChild(name);if old and old:IsA("ScreenGui")then old.Enabled=false end end
require(script.Parent.SkyController).Start()
local Audio=require(script.Parent.Audio);Audio.Preload()
local remotes=require(script.Parent.RemoteClient).Wait(15);if not remotes then return end
require(script.Parent.CurrencyHud).Start(player)
require(RS:WaitForChild("SimulatorHUD")).currency(gui:FindFirstChild("CurrencyHud"))
local objective=require(script.Parent.ObjectiveHud).new(gui)
require(script.Parent.RocketClient).Start(remotes,objective)
