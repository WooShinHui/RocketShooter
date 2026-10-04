return table.freeze({
	TAG = "SkyIsland",
	Platform = table.freeze({
		Forward = 300,
		Lateral = 65,
		Altitude = 180,
		Size = Vector3.new(60, 5, 60),
		Color = Color3.fromRGB(200, 220, 255),
		Material = Enum.Material.SmoothPlastic,
		Anchored = true,
		CanCollide = true,
	}),
})
