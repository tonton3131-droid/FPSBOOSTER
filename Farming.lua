-- ============================================
--   FPS BOOSTER | Delta Executor | Mobile
--   Compatible with: Delta (iOS/Android)
-- ============================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- CONFIGURATION (edit values as you like)
-- ============================================
local CONFIG = {
    TargetFPS       = 60,     -- Set to 60 or 120 (depends on device)
    RemoveParticles = true,   -- Removes particle emitters
    RemoveDecals    = false,  -- Remove surface decals (can break visuals)
    LowQualityMesh  = false,  -- Reduce mesh quality (experimental)
    DisableShadows  = true,   -- Big FPS boost
    DisableFog      = true,   -- Removes atmospheric fog
    LowRenderDist   = false,  -- Reduces render distance
    ReduceGUI       = false,  -- Hides non-essential GUI
}

-- ============================================
-- UTILITY
-- ============================================
local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title   = "FPS Booster",
            Text    = text,
            Duration = 4,
        })
    end)
end

-- ============================================
-- 1. SET FRAME RATE CAP
-- ============================================
pcall(function()
    setfpscap(CONFIG.TargetFPS)
end)

-- ============================================
-- 2. DISABLE SHADOWS
-- ============================================
if CONFIG.DisableShadows then
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
    end)
end

-- ============================================
-- 3. DISABLE FOG / ATMOSPHERE
-- ============================================
if CONFIG.DisableFog then
    pcall(function()
        Lighting.FogEnd   = 100000
        Lighting.FogStart = 100000

        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then
                v.Density  = 0
                v.Haze     = 0
                v.Glare    = 0
                v.Blur     = 0
            end
            if v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect")
            or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect")
            or v:IsA("BlurEffect") then
                v.Enabled = false
            end
        end
    end)
end

-- ============================================
-- 4. REMOVE PARTICLES IN WORKSPACE
-- ============================================
if CONFIG.RemoveParticles then
    local function CleanParticles(parent)
        for _, v in ipairs(parent:GetDescendants()) do
            pcall(function()
                if v:IsA("ParticleEmitter")
                or v:IsA("Trail")
                or v:IsA("Smoke")
                or v:IsA("Fire")
                or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end)
        end
    end

    CleanParticles(workspace)

    workspace.DescendantAdded:Connect(function(v)
        pcall(function()
            if v:IsA("ParticleEmitter")
            or v:IsA("Trail")
            or v:IsA("Smoke")
            or v:IsA("Fire")
            or v:IsA("Sparkles") then
                task.wait()
                v.Enabled = false
            end
        end)
    end)
end

-- ============================================
-- 5. REMOVE DECALS (optional)
-- ============================================
if CONFIG.RemoveDecals then
    for _, v in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end)
    end
end

-- ============================================
-- 6. REDUCE RENDER DISTANCE (optional)
-- ============================================
if CONFIG.LowRenderDist then
    pcall(function()
        workspace.StreamingEnabled = true
        -- Lower streaming radius for performance
        if workspace.StreamingMinRadius then
            workspace.StreamingMinRadius = 32
            workspace.StreamingTargetRadius = 64
        end
    end)
end

-- ============================================
-- 7. CHARACTER OPTIMIZATIONS
-- ============================================
local function OptimizeCharacter(char)
    if not char then return end
    pcall(function()
        for _, v in ipairs(char:GetDescendants()) do
            -- Disable unnecessary scripts inside character
            if v:IsA("Script") or v:IsA("LocalScript") then
                -- Only disable safe ones
            end
            -- Lower shadow casting on accessories
            if v:IsA("BasePart") then
                v.CastShadow = false
            end
        end
    end)
end

-- Apply to current character
if LocalPlayer.Character then
    OptimizeCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(OptimizeCharacter)

-- ============================================
-- 8. WORKSPACE QUALITY TWEAKS
-- ============================================
pcall(function()
    workspace:FindFirstChildOfClass("Terrain").WaterWaveSize    = 0
    workspace:FindFirstChildOfClass("Terrain").WaterWaveSpeed   = 0
    workspace:FindFirstChildOfClass("Terrain").WaterReflectance = 0
    workspace:FindFirstChildOfClass("Terrain").WaterTransparency = 0.5
end)

-- ============================================
-- 9. RUNTIME FPS MONITOR (prints to console)
-- ============================================
local fpsCount  = 0
local lastPrint = tick()

RunService.Heartbeat:Connect(function()
    fpsCount = fpsCount + 1
    if tick() - lastPrint >= 5 then
        print(string.format("[FPS Booster] Current FPS: ~%d", fpsCount / 5))
        fpsCount  = 0
        lastPrint = tick()
    end
end)

-- ============================================
-- DONE
-- ============================================
Notify("FPS Booster Active! Target: " .. CONFIG.TargetFPS .. " FPS")
print("[FPS Booster] Script loaded successfully on Delta Mobile.")
