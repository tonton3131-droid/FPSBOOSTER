-- ============================================
--   💀 NUCLEAR OPTIMIZER v3 💀
--   Delta | Android 9 | Booga Booga Reborn
--   Fixed: Spawn bug, FPS display, sky/grass
-- ============================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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
-- SAFETY CHECK - skip local player STRICTLY
-- ============================================
local function IsLocalCharacter(v)
    if not LocalPlayer.Character then return false end
    return LocalPlayer.Character:IsAncestorOf(v) or v == LocalPlayer.Character
end

local function IsAnyPlayerCharacter(v)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            if player.Character == v or player.Character:IsAncestorOf(v) then
                return true
            end
        end
    end
    return false
end

-- ============================================
-- GUI: FPS COUNTER + RENDER TOGGLE
-- ============================================
local renderingEnabled = true

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NuclearGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

-- FPS Label (hidden by default, only shows when rendering OFF)
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSLabel"
fpsLabel.Size = UDim2.new(0, 400, 0, 100)
fpsLabel.Position = UDim2.new(0.5, -200, 0.5, -50)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "-- FPS"
fpsLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
fpsLabel.TextScaled = true
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.ZIndex = 10
fpsLabel.Visible = false -- HIDDEN BY DEFAULT
fpsLabel.Parent = screenGui

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "RenderToggle"
toggleBtn.Size = UDim2.new(0, 180, 0, 55)
toggleBtn.Position = UDim2.new(0.5, -90, 0, 20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "3D RENDER: ON"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.ZIndex = 10
toggleBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = toggleBtn

-- Toggle Logic
toggleBtn.MouseButton1Click:Connect(function()
    renderingEnabled = not renderingEnabled
    pcall(function()
        game:GetService("RunService"):Set3dRenderingEnabled(renderingEnabled)
    end)
    if renderingEnabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
        toggleBtn.Text = "3D RENDER: ON"
        fpsLabel.Visible = false -- hide FPS when rendering ON
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        toggleBtn.Text = "3D RENDER: OFF"
        fpsLabel.Visible = true -- show FPS when rendering OFF
    end
end)

-- Live FPS (only updates when label is visible)
local frameCount = 0
local lastTime = tick()
RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastTime >= 0.5 then
        local fps = math.round(frameCount / (now - lastTime))
        if fpsLabel.Visible then
            fpsLabel.Text = fps .. " FPS"
        end
        frameCount = 0
        lastTime = now
    end
end)

-- ============================================
-- 1. QUALITY LEVEL (GPU)
-- ============================================
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    print("[Nuclear] Quality Level01")
end)

-- ============================================
-- 2. SHADOWS (GPU)
-- ============================================
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.Brightness = 0
    print("[Nuclear] Shadows disabled")
end)

-- ============================================
-- 3. SKYBOX - MULTIPLE METHODS (GPU)
-- ============================================
pcall(function()
    -- Method 1: destroy Sky object
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
    -- Method 2: set sky color to black
    Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
    Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
    Lighting.FogColor = Color3.fromRGB(0, 0, 0)
    Lighting.FogEnd = 1
    Lighting.FogStart = 0
    -- Method 3: watch for new sky objects
    Lighting.ChildAdded:Connect(function(v)
        if v:IsA("Sky") then
            task.wait()
            pcall(function() v:Destroy() end)
        end
    end)
    print("[Nuclear] Skybox destroyed (3 methods)")
end)

-- ============================================
-- 4. POST PROCESSING (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect")
        or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect")
        or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end
    Lighting.ChildAdded:Connect(function(v)
        if v:IsA("BloomEffect") or v:IsA("BlurEffect")
        or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect")
        or v:IsA("DepthOfFieldEffect") then
            task.wait()
            pcall(function() v:Destroy() end)
        end
    end)
    print("[Nuclear] Post processing destroyed")
end)

-- ============================================
-- 5. ATMOSPHERE + FOG (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") then v:Destroy() end
    end
    print("[Nuclear] Atmosphere destroyed")
end)

-- ============================================
-- 6. WATER - MULTIPLE METHODS (GPU + CPU)
-- ============================================
pcall(function()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        -- Method 1: make invisible
        terrain.WaterTransparency = 1
        terrain.WaterReflectance = 0
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        -- Method 2: replace with air
        terrain:ReplaceMaterial(Enum.Material.Water, 4, Enum.Material.Air)
        -- Method 3: replace grass with smoothplastic color
        terrain:ReplaceMaterial(Enum.Material.Grass, 4, Enum.Material.SmoothPlastic)
        terrain:ReplaceMaterial(Enum.Material.Ground, 4, Enum.Material.SmoothPlastic)
        terrain:ReplaceMaterial(Enum.Material.LeafyGrass, 4, Enum.Material.SmoothPlastic)
        terrain:ReplaceMaterial(Enum.Material.Mud, 4, Enum.Material.SmoothPlastic)
        terrain:ReplaceMaterial(Enum.Material.Sand, 4, Enum.Material.SmoothPlastic)
    end
    print("[Nuclear] Water + terrain materials replaced")
end)

-- ============================================
-- 7. ALL LIGHTS (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v:Destroy()
        end
    end
    print("[Nuclear] All lights destroyed")
end)

-- ============================================
-- 8. PARTICLES FIRE SMOKE BEAMS (GPU + CPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if not IsLocalCharacter(v) then
            if v:IsA("ParticleEmitter") or v:IsA("Trail")
            or v:IsA("Smoke") or v:IsA("Fire")
            or v:IsA("Sparkles") or v:IsA("Beam") then
                v:Destroy()
            end
        end
    end
    workspace.DescendantAdded:Connect(function(v)
        task.wait()
        pcall(function()
            if not IsLocalCharacter(v) then
                if v:IsA("ParticleEmitter") or v:IsA("Trail")
                or v:IsA("Smoke") or v:IsA("Fire")
                or v:IsA("Sparkles") or v:IsA("Beam") then
                    v:Destroy()
                end
            end
        end)
    end)
    print("[Nuclear] Particles/fire/smoke destroyed")
end)

-- ============================================
-- 9. DECALS + TEXTURES (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if not IsLocalCharacter(v) then
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
    end
    print("[Nuclear] Decals/textures destroyed")
end)

-- ============================================
-- 10. CAST SHADOW OFF (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.CastShadow = false end
    end
    workspace.DescendantAdded:Connect(function(v)
        if v:IsA("BasePart") then v.CastShadow = false end
    end)
    print("[Nuclear] All shadows disabled")
end)

-- ============================================
-- 11. REFLECTANCE ZERO (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if not IsLocalCharacter(v) then
            if v:IsA("BasePart") then v.Reflectance = 0 end
        end
    end
    print("[Nuclear] All reflectance zeroed")
end)

-- ============================================
-- 12. SURFACE + BILLBOARD GUIS (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("SurfaceGui") or v:IsA("BillboardGui") then v:Destroy() end
    end
    print("[Nuclear] SurfaceGuis/BillboardGuis destroyed")
end)

-- ============================================
-- 13. ALL SOUNDS (CPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Sound") then v:Destroy() end
    end
    SoundService.AmbientReverb = Enum.ReverbType.NoReverb
    print("[Nuclear] All sounds destroyed")
end)

-- ============================================
-- 14. CLICK DETECTORS + PROXIMITY PROMPTS (CPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ClickDetector") or v:IsA("ProximityPrompt") then v:Destroy() end
    end
    print("[Nuclear] ClickDetectors/ProximityPrompts destroyed")
end)

-- ============================================
-- 15. CONSTRAINTS + BODY MOVERS (CPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if not IsLocalCharacter(v) then
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro")
            or v:IsA("BodyPosition") or v:IsA("BodyAngularVelocity")
            or v:IsA("HingeConstraint") or v:IsA("SpringConstraint")
            or v:IsA("RodConstraint") or v:IsA("RopeConstraint") then
                v:Destroy()
            end
        end
    end
    print("[Nuclear] Constraints/BodyMovers destroyed")
end)

-- ============================================
-- 16. DESTROY OTHER PLAYERS - SAFE (GPU+CPU+RAM)
-- ============================================
pcall(function()
    -- Only destroy OTHER players, never local
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                player.Character:Destroy()
            end
        end
    end
    -- Watch for new players joining
    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer then return end
        player.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            pcall(function() char:Destroy() end)
        end)
    end)
    -- Watch existing players respawning
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                pcall(function() char:Destroy() end)
            end)
        end
    end
    print("[Nuclear] Other players destroyed")
end)

-- ============================================
-- 17. DESTROY NPCS ONLY - NOT PLAYERS (CPU+RAM)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= LocalPlayer.Character then
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hum and not IsAnyPlayerCharacter(v) then
                v:Destroy()
            end
        end
    end
    print("[Nuclear] NPCs destroyed")
end)

-- ============================================
-- 18. SELECTION BOXES + HIGHLIGHTS (GPU)
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
-- 19. WORKSPACE FOLDERS (RAM)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Folder") then v:Destroy() end
    end
    print("[Nuclear] Workspace folders destroyed")
end)

-- ============================================
-- 20. NPC ANIMATIONS (CPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if not IsLocalCharacter(v) then
            if v:IsA("AnimationController") or v:IsA("Animator") then
                v:Destroy()
            end
        end
    end
    print("[Nuclear] NPC animations destroyed")
end)

-- ============================================
-- 21. SMOOTH PLASTIC ALL NON-LOCAL PARTS (GPU)
-- ============================================
pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if not IsLocalCharacter(v) then
            if v:IsA("BasePart") and not v:IsA("Terrain") then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
    end
    print("[Nuclear] All parts SmoothPlastic")
end)

-- ============================================
-- 22. INVISIBLE CHARACTER - FIXED (Hands+Feet)
-- ============================================
local KEEP_VISIBLE = { "LeftHand", "RightHand", "LeftFoot", "RightFoot" }

local function isKeepVisible(name)
    for _, v in ipairs(KEEP_VISIBLE) do
        if v == name then return true end
    end
    return false
end

local function ApplyInvisible(char)
    if not char then return end
    task.wait(0.5) -- wait for full char load
    for _, v in ipairs(char:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.Transparency = isKeepVisible(v.Name) and 0 or 1
            end
            if v:IsA("Accessory") then
                local handle = v:FindFirstChild("Handle")
                if handle then handle.Transparency = 1 end
            end
            if v:IsA("Shirt") or v:IsA("Pants")
            or v:IsA("ShirtGraphic") then
                v:Destroy()
            end
        end)
    end
    print("[Nuclear] Invisibility applied - hands & feet only")
end

-- Apply on current character
if LocalPlayer.Character then
    task.spawn(function() ApplyInvisible(LocalPlayer.Character) end)
end

-- Apply on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.spawn(function() ApplyInvisible(char) end)
end)

-- ============================================
-- DONE
-- ============================================
print("[Nuclear] ================================")
print("[Nuclear] v3 ALL OPTIMIZATIONS DONE")
print("[Nuclear] GPU    : NEAR ZERO")
print("[Nuclear] CPU    : MINIMIZED")
print("[Nuclear] RAM    : CLEARED")
print("[Nuclear] FPS shows ONLY when render OFF")
print("[Nuclear] Spawn bug: FIXED")
print("[Nuclear] ================================")

Notify("NUCLEAR v3 ACTIVE", "Fixed! Spawn + FPS + Sky + Grass all sorted")
