local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
local MaterialService = game:GetService("MaterialService")

local LocalPlayer = Players.LocalPlayer
local pgui = LocalPlayer:WaitForChild("PlayerGui")

task.defer(function()
    if getnilinstances then
        for _, v in pairs(getnilinstances()) do
            pcall(function() v:Destroy() end)
        end
    end
    for i = 1, 3 do
        collectgarbage("collect")
        task.wait(0.05)
    end
end)

task.spawn(function()
    while task.wait(3) do
        if Terrain then
            pcall(function()
                Terrain.Decoration = false
            end)
        end
    end
end)

task.defer(function()
    if not Terrain then return end
    pcall(function()
        local region = Terrain.MaxExtents
        Terrain:ReplaceMaterial(region, 4, Enum.Material.Grass, Enum.Material.Ground)
        Terrain:ReplaceMaterial(region, 4, Enum.Material.LeafyGrass, Enum.Material.Ground)
    end)
end)

task.defer(function()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            local name = obj.Name:lower()
            if name:find("grass") and not name:find("glass") then
                if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Color = Color3.fromRGB(139, 69, 19)
                elseif obj:IsA("Folder") or obj:IsA("Model") then
                    if name == "grass" or name == "grasses" or name:find("grass_") then
                        obj:Destroy()
                    end
                end
            end
        end)
    end
end)

settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
pcall(function()
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
end)

Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.ShadowSoftness = 0
pcall(function()
    sethiddenproperty(Lighting, "Technology", 2)
end)

if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
    pcall(function()
        sethiddenproperty(Terrain, "Decoration", false)
    end)
end

pcall(function()
    for _, v in pairs(MaterialService:GetChildren()) do
        v:Destroy()
    end
    MaterialService.Use2022Materials = false
end)

-- ============================================
-- VISIBILITY HELPERS
-- ============================================

local function isArmOrLeg(obj)
    local name = obj.Name:lower()
    return name:find("arm") or name:find("leg") or name:find("leftarm") or name:find("rightarm") or name:find("leftleg") or name:find("rightleg") or name:find("upperarm") or name:find("lowerarm") or name:find("upperleg") or name:find("lowerleg") or name:find("hand") or name:find("foot")
end

local function makeVisible(obj)
    pcall(function()
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part") then
            obj.Transparency = 0
            obj.LocalTransparencyModifier = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 0
        end
    end)
end

local function makeInvisible(obj)
    pcall(function()
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part") then
            obj.Transparency = 1
            obj.CastShadow = false
            obj.LocalTransparencyModifier = 1
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
            obj:Destroy()
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            obj.Enabled = false
        elseif obj:IsA("Accessory") or obj:IsA("Hat") or obj:IsA("Clothing") then
            obj:Destroy()
        end
    end)
end

-- ============================================
-- OTHER PLAYERS: FULLY INVISIBLE
-- ============================================

local function HidePlayerCharacter(char)
    if not char then return end
    if LocalPlayer.Character and char == LocalPlayer.Character then return end

    for _, obj in ipairs(char:GetDescendants()) do
        makeInvisible(obj)
    end

    char.DescendantAdded:Connect(function(desc)
        makeInvisible(desc)
    end)
end

local function HideAllOtherPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            HidePlayerCharacter(player.Character)
        end
    end
end

HideAllOtherPlayers()

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        HidePlayerCharacter(char)
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            HidePlayerCharacter(char)
        end)
    end
end

-- ============================================
-- LOCAL PLAYER: ARMS & LEGS VISIBLE ONLY
-- ============================================

local function SetupLocalCharacter(char)
    if not char then return end

    -- First pass: hide everything
    for _, obj in ipairs(char:GetDescendants()) do
        makeInvisible(obj)
    end

    -- Second pass: make arms and legs visible
    for _, obj in ipairs(char:GetDescendants()) do
        pcall(function()
            if isArmOrLeg(obj) then
                makeVisible(obj)
            end
        end)
    end

    -- Monitor new descendants
    char.DescendantAdded:Connect(function(desc)
        pcall(function()
            if isArmOrLeg(desc) then
                makeVisible(desc)
            else
                makeInvisible(desc)
            end
        end)
    end)
end

if LocalPlayer.Character then
    SetupLocalCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(SetupLocalCharacter)

-- ============================================
-- WORLD STRIPPING (skip local character)
-- ============================================

local particleTypes = {
    ParticleEmitter = true,
    Trail = true,
    Smoke = true,
    Fire = true,
    Sparkles = true,
    Beam = true
}

local function StripInstance(obj)
    pcall(function()
        if LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then return end

        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
            obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
        elseif particleTypes[obj.ClassName] then
            obj:Destroy()
        elseif obj:IsA("Light") and not obj:IsA("PointLight") then
            obj:Destroy()
        elseif obj:IsA("MeshPart") then
            obj.RenderFidelity = Enum.RenderFidelity.Performance
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
            obj.Reflectance = 0
        elseif obj:IsA("SpecialMesh") then
            obj:Destroy()
        elseif obj:IsA("Explosion") then
            obj.BlastPressure = 1
            obj.BlastRadius = 1
            obj.Visible = false
        elseif obj:IsA("Clothing") or obj:IsA("SurfaceAppearance") or obj:IsA("BaseWrap") then
            obj:Destroy()
        elseif obj:IsA("PostEffect") then
            obj.Enabled = false
        end
    end)
end

for _, obj in ipairs(game:GetDescendants()) do
    StripInstance(obj)
end

game.DescendantAdded:Connect(function(obj)
    task.defer(function()
        StripInstance(obj)
    end)
end)

task.spawn(function()
    while task.wait(30) do
        collectgarbage("collect")
        local count = #Workspace:GetDescendants()
        if count > 8000 then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                pcall(function()
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Decal") or obj:IsA("Texture") then
                        obj:Destroy()
                    end
                end)
            end
        end
    end
end)

-- ============================================
-- RENDER GUI (3D Toggle Only) - Multi-Instance Farm Optimized
-- ============================================

local oldGui = pgui:FindFirstChild("RenderToggle")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RenderToggle"
ScreenGui.Parent = pgui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 10, 0, 50)
MainFrame.Size = UDim2.new(0, 220, 0, 80)
MainFrame.ZIndex = 10

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 6)
Title.Size = UDim2.new(1, 0, 0, 24)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "LYANNE IS CUTE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.ZIndex = 11

local RenderButton = Instance.new("TextButton")
RenderButton.Name = "RenderButton"
RenderButton.Parent = MainFrame
RenderButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
RenderButton.BorderSizePixel = 0
RenderButton.Position = UDim2.new(0, 10, 0, 36)
RenderButton.Size = UDim2.new(1, -20, 0, 36)
RenderButton.Font = Enum.Font.SourceSansBold
RenderButton.Text = "RENDER: ON"
RenderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RenderButton.TextSize = 20
RenderButton.ZIndex = 11

local renderCorner = Instance.new("UICorner")
renderCorner.CornerRadius = UDim.new(0, 6)
renderCorner.Parent = RenderButton

local renderOn = true

RenderButton.MouseButton1Click:Connect(function()
    renderOn = not renderOn
    RunService:Set3dRenderingEnabled(renderOn)
    if renderOn then
        RenderButton.Text = "RENDER: ON"
        RenderButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    else
        RenderButton.Text = "RENDER: OFF"
        RenderButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- ============================================
-- MULTI-INSTANCE FARM OPTIMIZATIONS
-- ============================================

local heartbeat = RunService.Heartbeat

-- Lightweight connection tracker (no metatable overhead)
local activeConnections = {}
local function trackConnection(name, conn)
    if not activeConnections[name] then
        activeConnections[name] = {}
    end
    table.insert(activeConnections[name], conn)
    return conn
end

local function disconnectByName(name)
    local conns = activeConnections[name]
    if conns then
        for i = #conns, 1, -1 do
            local c = conns[i]
            if c and typeof(c) == "RBXScriptConnection" and c.Connected then
                pcall(function() c:Disconnect() end)
            end
            conns[i] = nil
        end
        activeConnections[name] = nil
    end
end

-- Fast player hiding (no nested trackers per char)
local function hideCharacter(char)
    if not char then return end
    if LocalPlayer.Character and char == LocalPlayer.Character then return end
    for _, obj in ipairs(char:GetDescendants()) do
        makeInvisible(obj)
    end
    trackConnection("hide_" .. tostring(char), char.DescendantAdded:Connect(function(desc)
        makeInvisible(desc)
    end))
end

-- Hide all existing other players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        hideCharacter(player.Character)
    end
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    trackConnection("player_" .. tostring(player), player.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        hideCharacter(char)
    end))
end)

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player)
    disconnectByName("player_" .. tostring(player))
    disconnectByName("hide_" .. tostring(player.Character))
end)

-- Local character: arms/legs only, aggressive cleanup
local function setupLocalChar(char)
    if not char then return end

    -- Kill ALL old local char connections immediately
    for name, _ in pairs(activeConnections) do
        if name:find("local_") then
            disconnectByName(name)
        end
    end

    -- First pass: nuke everything
    for _, obj in ipairs(char:GetDescendants()) do
        makeInvisible(obj)
    end

    -- Second pass: restore arms/legs
    for _, obj in ipairs(char:GetDescendants()) do
        pcall(function()
            if isArmOrLeg(obj) then
                makeVisible(obj)
            end
        end)
    end

    -- Track new descendants
    trackConnection("local_desc", char.DescendantAdded:Connect(function(desc)
        pcall(function()
            if isArmOrLeg(desc) then
                makeVisible(desc)
            else
                makeInvisible(desc)
            end
        end)
    end))
end

if LocalPlayer.Character then
    setupLocalChar(LocalPlayer.Character)
end

trackConnection("local_charadded", LocalPlayer.CharacterAdded:Connect(setupLocalChar))
trackConnection("local_charremoving", LocalPlayer.CharacterRemoving:Connect(function()
    for name, _ in pairs(activeConnections) do
        if name:find("local_") then
            disconnectByName(name)
        end
    end
end))

-- Throttled world stripper (critical for multi-instance)
local stripQueue = {}
local lastStripTick = 0
local STRIP_BATCH = 25        -- smaller batches = smoother
local STRIP_INTERVAL = 0.033  -- ~30fps processing cap

game.DescendantAdded:Connect(function(obj)
    table.insert(stripQueue, obj)
end)

-- Dedicated strip loop (not event-driven to prevent spam)
task.spawn(function()
    while true do
        local t = tick()
        if t - lastStripTick >= STRIP_INTERVAL and #stripQueue > 0 then
            lastStripTick = t
            for i = 1, math.min(STRIP_BATCH, #stripQueue) do
                local obj = table.remove(stripQueue, 1)
                if obj and obj.Parent then
                    StripInstance(obj)
                end
            end
        end
        task.wait(0.016)  -- ~60 checks per second, but only process on interval
    end
end)

-- Lightweight cleanup loop (every 60s, only if actually bloated)
local lastCount = 0
task.spawn(function()
    while true do
        task.wait(60)
        collectgarbage("collect")

        local count = #Workspace:GetDescendants()
        -- Only act if count is high AND grew significantly
        if count > 10000 and count > lastCount * 1.3 then
            local toDestroy = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                pcall(function()
                    local class = obj.ClassName
                    if class == "ParticleEmitter" or class == "Trail" or class == "Decal" or class == "Texture" then
                        table.insert(toDestroy, obj)
                    end
                end)
            end
            -- Destroy in small batches with yields
            for i = 1, #toDestroy, 50 do
                for j = i, math.min(i + 49, #toDestroy) do
                    pcall(function() toDestroy[j]:Destroy() end)
                end
                task.wait(0.05)
            end
        end
        lastCount = count
    end
end)

-- Emergency cleanup on script destroy
pcall(function()
    script.Destroying:Connect(function()
        for name, _ in pairs(activeConnections) do
            disconnectByName(name)
        end
        stripQueue = {}
    end)
end)