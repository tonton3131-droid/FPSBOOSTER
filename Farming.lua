local terrain = workspace:FindFirstChildOfClass("Terrain")
terrain.WaterTransparency = 1
terrain.WaterWaveSize = 0
terrain.WaterWaveSpeed = 0
terrain.WaterReflectance = 0
pcall(function()
    terrain:ReplaceMaterial(Enum.Material.Water, 4, Enum.Material.Air)
end)
