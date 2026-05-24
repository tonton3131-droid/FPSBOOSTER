-- FIXED WATER REMOVER - No Lerp, No ReplaceMaterial
local terrain = workspace:FindFirstChildOfClass("Terrain")

pcall(function()
    terrain.WaterTransparency = 1
    terrain.WaterReflectance = 0
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
end)

print("[Water] Done - water should be invisible now!")
