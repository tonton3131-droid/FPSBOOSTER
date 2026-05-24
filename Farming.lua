-- GAME SCANNER + GREY SKYBOX
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

print("===== SKYBOX SCAN =====")
for _, v in ipairs(Lighting:GetChildren()) do
    print(v.ClassName .. " | " .. v.Name)
    if v:IsA("Sky") then
        print("  >> Sky found! SkyboxBk: " .. tostring(v.SkyboxBk))
    end
end

-- ============================================
-- GREY SKYBOX
-- ============================================
pcall(function()
    -- Remove existing sky first
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then
            v:Destroy()
            print("[Sky] Removed old skybox")
        end
    end

    -- Make grey sky via Lighting color
    Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.FogColor = Color3.fromRGB(128, 128, 128)
    Lighting.FogEnd = 1000
    Lighting.FogStart = 0
    Lighting.Brightness = 0.5
    Lighting.ColorShift_Top = Color3.fromRGB(128, 128, 128)
    Lighting.ColorShift_Bottom = Color3.fromRGB(100, 100, 100)

    print("[Sky] Grey skybox applied!")
end)

print("===== DONE =====")
