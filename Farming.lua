-- GAME SCANNER - See everything in the game
local Lighting = game:GetService("Lighting")

print("===== WORKSPACE SCAN =====")
for _, v in ipairs(workspace:GetDescendants()) do
    print(v.ClassName .. " | " .. v.Name)
end

print("===== LIGHTING SCAN =====")
for _, v in ipairs(Lighting:GetDescendants()) do
    print(v.ClassName .. " | " .. v.Name)
end

print("===== SERVICES SCAN =====")
for _, v in ipairs(game:GetChildren()) do
    print(v.ClassName .. " | " .. v.Name)
end

print("===== TERRAIN INFO =====")
local terrain = workspace:FindFirstChildOfClass("Terrain")
if terrain then
    print("WaterTransparency: " .. terrain.WaterTransparency)
    print("WaterWaveSize: " .. terrain.WaterWaveSize)
    print("WaterWaveSpeed: " .. terrain.WaterWaveSpeed)
    print("WaterReflectance: " .. terrain.WaterReflectance)
end

print("===== DONE =====")
