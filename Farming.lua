-- ============================================
--   💀 NUCLEAR OPTIMIZER 💀
--   Delta Executor | Mobile | Booga Booga
--   MAX CPU + GPU + RAM REDUCTION
--   Character: Only Hands & Feet visible
-- ============================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService") -- KEPT for armor script

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- NOTIFY
-- ============================================
local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5,
        })
    end)
end

-- ============================================
-- SAFETY CHECK - skip local player
-- ============================================
local function IsLocalCharacter(v)
    if not LocalPlayer.Character then return false end
    return LocalPlayer.Character:IsAncestorOf(v) or v == LocalPlayer.Character
end

-- ============================================
-- 1. FPS CAP
-- ============================================
pcall(function()
    setfpscap(30) -- lower = less work per second
    print("[Nuclear] FPS cap set to 30")
end)

-- ============================================
-- 2. QUALITY LEVEL (GPU)
-- ============================================
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    print("[Nuclear] Quality set to Level01")
end)

-- ============================================
-- 3. DISABLE 3D RENDERING (NUCLEAR GPU)
-- ============================================
pcall(function()
    game:GetService("RunService"):Set3dRenderingEnabled(false)
    print("[Nuclear] 3D Rendering DISABLED")
end)

-- ============================================
-- 4. SHADOWS (GPU)
-- ============================================
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.Brightness = 0
    print("[Nuclear] Shadows disabled")
end)

-- ============================================
-- 5. SKYBOX (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then
            v:Destroy()
        end
    end
    print("[Nuclear] Skybox destroyed")
end)

-- ============================================
-- 6. POST PROCESSING (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect")
        or v:IsA("BlurEffect")
        or v:IsA("SunRaysEffect")
        or v:IsA("ColorCorrectionEffect")
        or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end
    print("[Nuclear] Post processing destroyed")
end)

-- ============================================
-- 7. ATMOSPHERE + FOG (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") then
            v:Destroy()
        end
    end
    Lighting.FogEnd = 100000
    Lighting.FogStart = 100000
    print("[Nuclear] Atmosphere/fog destroyed")
end)

-- ============================================
-- 8. WATER (GPU + CPU)
-- ============================================
pcall(function()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterTransparency = 1
        terrain.WaterReflectance = 0
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain:ReplaceMaterial(Enum.Material.Water, 4, Enum.Material.Air)
    end
    print("[Nuclear] Water removed")
end)

-- ============================================
-- 9. ALL LIGHTS (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("PointLight")
        or v:IsA("SpotLight")
        or v:IsA("SurfaceLight") then
            v:Destroy()
        end
    end
    print("[Nuclear] All lights destroyed")
end)

-- ============================================
-- 10. PARTICLES FIRE SMOKE (GPU + CPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if not IsLocalCharacter(v) then
            if v:IsA("ParticleEmitter")
            or v:IsA("Trail")
            or v:IsA("Smoke")
            or v:IsA("Fire")
            or v:IsA("Sparkles")
            or v:IsA("Beam") then
                v:Destroy()
            end
        end
    end
    -- watch for new ones
    workspace.DescendantAdded:Connect(function(v)
        task.wait()
        pcall(function()
            if not IsLocalCharacter(v) then
                if v:IsA("ParticleEmitter")
                or v:IsA("Trail")
                or v:IsA("Smoke")
                or v:IsA("Fire")
                or v:IsA("Sparkles")
                or v:IsA("Beam") then
                    v:Destroy()
                end
            end
        end)
    end)
    print("[Nuclear] Particles/fire/smoke destroyed")
end)

-- ============================================
-- 11. DECALS + TEXTURES (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if not IsLocalCharacter(v) then
            if v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
    end
    print("[Nuclear] Decals/textures destroyed")
end)

-- ============================================
-- 12. SHADOWS ON ALL PARTS (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CastShadow = false
        end
    end
    workspace.DescendantAdded:Connect(function(v)
        if v:IsA("BasePart") then
            v.CastShadow = false
        end
    end)
    print("[Nuclear] All part shadows disabled")
end)

-- ============================================
-- 13. REFLECTANCE ON ALL PARTS (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if not IsLocalCharacter(v) then
            if v:IsA("BasePart") then
                v.Reflectance = 0
            end
        end
    end
    print("[Nuclear] All reflectance set to 0")
end)

-- ============================================
-- 14. SURFACE + BILLBOARD GUIS (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("SurfaceGui") or v:IsA("BillboardGui") then
            v:Destroy()
        end
    end
    print("[Nuclear] SurfaceGuis/BillboardGuis destroyed")
end)

-- ============================================
-- 15. SOUNDS (CPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Sound") then
            v:Destroy()
        end
    end
    SoundService.AmbientReverb = Enum.ReverbType.NoReverb
    print("[Nuclear] All sounds destroyed")
end)

-- ============================================
-- 16. CLICK DETECTORS + PROXIMITY PROMPTS (CPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ClickDetector") or v:IsA("ProximityPrompt") then
            v:Destroy()
        end
    end
    print("[Nuclear] ClickDetectors/ProximityPrompts destroyed")
end)

-- ============================================
-- 17. CONSTRAINTS + BODY MOVERS (CPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if not IsLocalCharacter(v) then
            if v:IsA("BodyVelocity")
            or v:IsA("BodyGyro")
            or v:IsA("BodyPosition")
            or v:IsA("BodyAngularVelocity")
            or v:IsA("HingeConstraint")
            or v:IsA("SpringConstraint")
            or v:IsA("RodConstraint")
            or v:IsA("RopeConstraint") then
                v:Destroy()
            end
        end
    end
    print("[Nuclear] Constraints/BodyMovers destroyed")
end)

-- ============================================
-- 18. DESTROY OTHER PLAYERS ENTIRELY (GPU+CPU+RAM)
-- ============================================
pcall(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                player.Character:Destroy()
            end
        end
    end

    -- Destroy characters of players who join
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            task.wait()
            pcall(function() char:Destroy() end)
        end)
    end)

    -- Destroy characters of existing players who respawn
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(char)
                task.wait()
                pcall(function() char:Destroy() end)
            end)
        end
    end
    print("[Nuclear] Other players destroyed")
end)

-- ============================================
-- 19. DESTROY NPCS (CPU + RAM)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= LocalPlayer.Character then
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hum then
                -- its an NPC, destroy it
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character == v then
                        isPlayer = true
                        break
                    end
                end
                if not isPlayer then
                    v:Destroy()
                end
            end
        end
    end
    print("[Nuclear] NPCs destroyed")
end)

-- ============================================
-- 20. SELECTION BOXES + HIGHLIGHTS (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("SelectionBox") or v:IsA("Highlight") or v:IsA("ForceField") then
            v:Destroy()
        end
    end
    print("[Nuclear] SelectionBoxes/Highlights destroyed")
end)

-- ============================================
-- 21. UNNECESSARY WORKSPACE FOLDERS/MODELS (RAM)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name ~= "Camera" then
            v:Destroy()
        end
    end
    print("[Nuclear] Workspace folders destroyed")
end)

-- ============================================
-- 22. INVISIBLE CHARACTER (except hands + feet)
-- ============================================
local KEEP_VISIBLE = {
    "LeftHand",
    "RightHand",
    "LeftFoot",
    "RightFoot",
}

local function isKeepVisible(name)
    for _, v in ipairs(KEEP_VISIBLE) do
        if v == name then return true end
    end
    return false
end

local function ApplyInvisible(char)
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                if isKeepVisible(v.Name) then
                    v.Transparency = 0
                else
                    v.Transparency = 1
                end
            end
            if v:IsA("Accessory") then
                local handle = v:FindFirstChild("Handle")
                if handle then handle.Transparency = 1 end
            end
            if v:IsA("Shirt") or v:IsA("Pants")
            or v:IsA("ShirtGraphic") or v:IsA("Decal") then
                v:Destroy()
            end
        end)
    end
    print("[Nuclear] Character invisibility applied")
end

if LocalPlayer.Character then
    ApplyInvisible(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    ApplyInvisible(char)
end)

-- ============================================
-- DONE 💀
-- ============================================
print("[Nuclear] ============================")
print("[Nuclear] ALL OPTIMIZATIONS APPLIED!")
print("[Nuclear] CPU: MINIMIZED")
print("[Nuclear] GPU: NEAR ZERO")
print("[Nuclear] RAM: CLEARED")
print("[Nuclear] You are now floating hands and feet 👣🖐️")
print("[Nuclear] ============================")

Notify("💀 NUCLEAR ACTIVE", "CPU+GPU+RAM Minimized! You are now just hands & feet 👣🖐️")
