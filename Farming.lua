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
        pcall(function() gcinfo() end)
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

    for _, obj in ipairs(char:GetDescendants()) do
        makeInvisible(obj)
    end

    for _, obj in ipairs(char:GetDescendants()) do
        pcall(function()
            if isArmOrLeg(obj) then
                makeVisible(obj)
            end
        end)
    end

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
        elseif obj:IsA("Light") then
            obj:Destroy()
        elseif obj:IsA("MeshPart") then
            local p = Instance.new("Part")
            p.Size = obj.Size
            p.CFrame = obj.CFrame
            p.Color = Color3.fromRGB(100,100,100)
            p.Material = Enum.Material.SmoothPlastic
            p.Anchored = obj.Anchored
            p.CanCollide = obj.CanCollide
            p.Transparency = obj.Transparency
            p.Parent = obj.Parent
            obj:Destroy()
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
        pcall(function() gcinfo() end)
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
-- RENDER GUI (3D Toggle + BIG CENTERED FPS Counter)
-- ============================================

local oldGui = pgui:FindFirstChild("RenderToggle")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RenderToggle"
ScreenGui.Parent = pgui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- FPS Counter (BIG & CENTERED - Black text on white background)
local FpsFrame = Instance.new("Frame")
FpsFrame.Name = "FpsCounter"
FpsFrame.Parent = ScreenGui
FpsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FpsFrame.BackgroundTransparency = 0.1
FpsFrame.BorderSizePixel = 0
-- CENTER OF SCREEN
FpsFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
FpsFrame.Size = UDim2.new(0, 300, 0, 150)
FpsFrame.ZIndex = 100
FpsFrame.Visible = false -- Hidden by default, shows when render is off

local fpsCorner = Instance.new("UICorner")
fpsCorner.CornerRadius = UDim.new(0, 16)
fpsCorner.Parent = FpsFrame

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Name = "FpsLabel"
FpsLabel.Parent = FpsFrame
FpsLabel.BackgroundTransparency = 1
FpsLabel.Size = UDim2.new(1, 0, 1, 0)
FpsLabel.Font = Enum.Font.SourceSansBold
FpsLabel.Text = "FPS: --"
FpsLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
FpsLabel.TextSize = 72  -- BIG FONT
FpsLabel.TextStrokeTransparency = 0.8
FpsLabel.ZIndex = 101

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

-- FPS tracking variables
local fps = 0
local lastTick = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastTick >= 1 then
        fps = frameCount
        frameCount = 0
        lastTick = now
        if FpsLabel then
            FpsLabel.Text = "FPS: " .. tostring(fps)
        end
    end
end)

RenderButton.MouseButton1Click:Connect(function()
    renderOn = not renderOn
    RunService:Set3dRenderingEnabled(renderOn)
    if renderOn then
        RenderButton.Text = "RENDER: ON"
        RenderButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        FpsFrame.Visible = false
    else
        RenderButton.Text = "RENDER: OFF"
        RenderButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        FpsFrame.Visible = true
    end
end)

-- ============================================
-- MULTI-INSTANCE FARM OPTIMIZATIONS
-- ============================================

local heartbeat = RunService.Heartbeat

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

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        hideCharacter(player.Character)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    trackConnection("player_" .. tostring(player), player.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        hideCharacter(char)
    end))
end)

Players.PlayerRemoving:Connect(function(player)
    disconnectByName("player_" .. tostring(player))
    disconnectByName("hide_" .. tostring(player.Character))
end)

local function setupLocalChar(char)
    if not char then return end

    for name, _ in pairs(activeConnections) do
        if name:find("local_") then
            disconnectByName(name)
        end
    end

    for _, obj in ipairs(char:GetDescendants()) do
        makeInvisible(obj)
    end

    for _, obj in ipairs(char:GetDescendants()) do
        pcall(function()
            if isArmOrLeg(obj) then
                makeVisible(obj)
            end
        end)
    end

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

local stripQueue = {}
local lastStripTick = 0
local STRIP_BATCH = 25
local STRIP_INTERVAL = 0.033

game.DescendantAdded:Connect(function(obj)
    table.insert(stripQueue, obj)
end)

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
        task.wait(0.016)
    end
end)

local lastCount = 0
task.spawn(function()
    while true do
        task.wait(60)
        pcall(function() gcinfo() end)

        local count = #Workspace:GetDescendants()
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

pcall(function()
    script.Destroying:Connect(function()
        for name, _ in pairs(activeConnections) do
            disconnectByName(name)
        end
        stripQueue = {}
    end)
end)

-- ============================================
-- WATER REMOVAL
-- ============================================

local GameSettings = UserSettings():GetService("UserGameSettings")
local BASE_RENDER_DISTANCE = 400
local WATER = Enum.Material.Water
local AIR = Enum.Material.Air

local QUALITY_MULTIPLIERS = {
    [1] = 0.25, [2] = 0.35, [3] = 0.45, [4] = 0.55, [5] = 0.70,
    [6] = 0.85, [7] = 1.00, [8] = 1.15, [9] = 1.30, [10] = 1.50
}

local function getRenderDistance()
    local quality = GameSettings.SavedQualityLevel.Value
    local multiplier = QUALITY_MULTIPLIERS[quality] or 1.0
    return math.floor(BASE_RENDER_DISTANCE * multiplier)
end

local function align(pos)
    return Vector3.new(
        math.floor(pos.X / 4) * 4 + 2,
        math.floor(pos.Y / 4) * 4 + 2,
        math.floor(pos.Z / 4) * 4 + 2
    )
end

local function clearWaterAround(pos, renderDist)
    local center = align(pos)
    local half = renderDist / 2
    local region = Region3.new(
        center - Vector3.new(half, 100, half),
        center + Vector3.new(half, 100, half)
    ):ExpandToGrid(4)
    local materials, occupancy = Terrain:ReadVoxels(region, 4)
    local size = materials.Size
    local changed = 0
    for x = 1, size.X do
        for y = 1, size.Y do
            for z = 1, size.Z do
                if materials[x][y][z] == WATER then
                    materials[x][y][z] = AIR
                    occupancy[x][y][z] = 0
                    changed = changed + 1
                end
            end
        end
    end
    if changed > 0 then
        Terrain:WriteVoxels(region, 4, materials, occupancy)
    end
    return changed
end

task.spawn(function()
    local lastPos = nil
    local lastQuality = nil
    while true do
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = root.Position
                local currentQuality = GameSettings.SavedQualityLevel.Value
                local renderDist = getRenderDistance()
                local movedEnough = not lastPos or (pos - lastPos).Magnitude > 50
                local qualityChanged = lastQuality ~= currentQuality
                if movedEnough or qualityChanged then
                    local removed = clearWaterAround(pos, renderDist)
                    if removed > 0 or qualityChanged then
                        print(string.format("[Q%d | %dstuds] Water: %d blocks", currentQuality, renderDist, removed))
                    end
                    lastPos = pos
                    lastQuality = currentQuality
                end
            end
        end
        task.wait(0.5)
    end
end)
