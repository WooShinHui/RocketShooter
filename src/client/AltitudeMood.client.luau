-- SkyController owns all sky/lighting transitions. This script only labels the layer.
local p=game.Players.LocalPlayer
local L=game:GetService("Lighting")
local HUD=require(game.ReplicatedStorage:WaitForChild("SimulatorHUD",15))
local C=require(game.ReplicatedStorage:WaitForChild("CloudConfig",15)).HeightPresentation
local gui=Instance.new("ScreenGui");gui.Name="SkyLayerGui";gui.ResetOnSpawn=false;HUD.screen(gui,25);gui.Parent=p.PlayerGui
local text=Instance.new("TextLabel");text.Name="Layer";text.Position=UDim2.new(1,-352,0,14);text.Size=UDim2.fromOffset(340,34);text.Parent=gui;HUD.text(text,18,HUD.Colors.Yellow)
local indices={GROUND=1,CLOUD=2,HIGH_ALTITUDE=3,SPACE=4}
local function sync()text.Visible=p:GetAttribute("FlightState")=="Flying";text.Text=if C.Biomes then C.Biomes[L:GetAttribute("AltitudeBiome") or 1].Name else C.Names[indices[L:GetAttribute("AltitudeLayer")] or 1] end
L:GetAttributeChangedSignal("AltitudeLayer"):Connect(sync);L:GetAttributeChangedSignal("AltitudeBiome"):Connect(sync);p:GetAttributeChangedSignal("FlightState"):Connect(sync);sync()
