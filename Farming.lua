local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
local MaterialService = game:GetService("MaterialService")

local LocalPlayer = Players.LocalPlayer
local pgui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================
-- BLACK SCREEN BACKGROUND (For Render Off)
-- ============================================

local BlackScreen = Instance.new("Frame")
BlackScreen.Name = "BlackScreen"
BlackScreen.Parent = pgui
BlackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackScreen.BorderSizePixel = 0
BlackScreen.Size = UDim2.new(1, 0, 1, 0)
BlackScreen.ZIndex = -100
BlackScreen.Visible = false

-- ============================================
-- LIGHTING & TERRAIN
-- ============================================

pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.ShadowSoftness = 0
    Lighting.Brightness = 0
end)

pcall(function()
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
        Terrain.WaterColor = Color3.fromRGB(0, 0, 0)
        Terrain.Decoration = false
    end
end)

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
    return name:find("arm") or name:find("leg") or name:find("hand") or name:find("foot")
end

local function makeVisible(obj)
    pcall(function()
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
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
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
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
        elseif obj:IsA("Accessory") or obj:IsA("Clothing") then
            obj:Destroy()
        end
    end)
end

-- ============================================
-- PLAYER HIDING
-- ============================================

local function hideCharacter(char)
    if not char then return end
    if LocalPlayer.Character and char == LocalPlayer.Character then return end
    pcall(function()
        for _, obj in ipairs(char:GetDescendants()) do
            makeInvisible(obj)
        end
    end)
    pcall(function()
        char.DescendantAdded:Connect(function(desc)
            makeInvisible(desc)
        end)
    end)
end

pcall(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            hideCharacter(player.Character)
        end
    end
end)

pcall(function()
    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer then return end
        pcall(function()
            player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                hideCharacter(char)
            end)
        end)
    end)
end)

-- ============================================
-- LOCAL PLAYER
-- ============================================

local function setupLocalChar(char)
    if not char then return end
    pcall(function()
        for _, obj in ipairs(char:GetDescendants()) do
            makeInvisible(obj)
        end
        for _, obj in ipairs(char:GetDescendants()) do
            if isArmOrLeg(obj) then
                makeVisible(obj)
            end
        end
        char.DescendantAdded:Connect(function(desc)
            if isArmOrLeg(desc) then
                makeVisible(desc)
            else
                makeInvisible(desc)
            end
        end)
    end)
end

pcall(function()
    if LocalPlayer.Character then
        setupLocalChar(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(setupLocalChar)
end)

-- ============================================
-- WORLD STRIPPING
-- ============================================

local badClasses = {
    ParticleEmitter = true, Trail = true, Smoke = true,
    Fire = true, Sparkles = true, Beam = true,
    Decal = true, Texture = true, Light = true
}

local function stripObj(obj)
    pcall(function()
        if LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then return end

        local class = obj.ClassName
        local name = obj.Name:lower()

        if name:find("grass") and not name:find("glass") then
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Color = Color3.fromRGB(139, 69, 19)
                obj.CastShadow = false
            elseif obj:IsA("Folder") or obj:IsA("Model") then
                obj:Destroy()
                return
            end
        end

        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
            obj.Reflectance = 0
        elseif badClasses[class] then
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
            obj.Visible = false
        elseif obj:IsA("Clothing") or obj:IsA("SurfaceAppearance") then
            obj:Destroy()
        elseif obj:IsA("PostEffect") then
            obj.Enabled = false
        end
    end)
end

pcall(function()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        stripObj(obj)
    end
end)

local stripQueue = {}
local lastStrip = 0

pcall(function()
    game.DescendantAdded:Connect(function(obj)
        table.insert(stripQueue, obj)
    end)
end)

task.spawn(function()
    while true do
        local t = tick()
        if t - lastStrip >= 0.1 and #stripQueue > 0 then
            lastStrip = t
            for i = 1, math.min(10, #stripQueue) do
                local obj = table.remove(stripQueue, 1)
                if obj and obj.Parent then
                    stripObj(obj)
                end
            end
        end
        task.wait(0.05)
    end
end)

pcall(function()
    task.spawn(function()
        while true do
            task.wait(120)
            local count = #Workspace:GetDescendants()
            if count > 10000 then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    pcall(function()
                        local c = obj.ClassName
                        if c == "ParticleEmitter" or c == "Trail" or c == "Decal" or c == "Texture" then
                            obj:Destroy()
                        end
                    end)
                end
            end
        end
    end)
end)

-- ============================================
-- RENDER GUI + BIG CENTERED FPS
-- ============================================

pcall(function()
    local oldGui = pgui:FindFirstChild("RenderToggle")
    if oldGui then oldGui:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RenderToggle"
ScreenGui.Parent = pgui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local FpsFrame = Instance.new("Frame")
FpsFrame.Name = "FpsCounter"
FpsFrame.Parent = ScreenGui
FpsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FpsFrame.BackgroundTransparency = 0
FpsFrame.BorderSizePixel = 0
FpsFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
FpsFrame.Size = UDim2.new(0, 400, 0, 200)
FpsFrame.ZIndex = 100
FpsFrame.Visible = false

local fpsCorner = Instance.new("UICorner")
fpsCorner.CornerRadius = UDim.new(0, 20)
fpsCorner.Parent = FpsFrame

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Name = "FpsLabel"
FpsLabel.Parent = FpsFrame
FpsLabel.BackgroundTransparency = 1
FpsLabel.Size = UDim2.new(1, 0, 1, 0)
FpsLabel.Font = Enum.Font.SourceSansBold
FpsLabel.Text = "FPS: --"
FpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsLabel.TextSize = 96
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
        pcall(function()
            FpsLabel.Text = "FPS: " .. tostring(fps)
        end)
    end
end)

RenderButton.MouseButton1Click:Connect(function()
    renderOn = not renderOn
    pcall(function()
        RunService:Set3dRenderingEnabled(renderOn)
    end)
    if renderOn then
        RenderButton.Text = "RENDER: ON"
        RenderButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        FpsFrame.Visible = false
        BlackScreen.Visible = false
    else
        RenderButton.Text = "RENDER: OFF"
        RenderButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        FpsFrame.Visible = true
        BlackScreen.Visible = true
    end
end)

-- ============================================
-- WATER REMOVAL (Fixed - Replaces with Ground)
-- ============================================

local WATER = Enum.Material.Water
local GROUND = Enum.Material.Ground
local AIR = Enum.Material.Air

local function clearWater()
    pcall(function()
        if not Terrain then return end

        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local pos = hrp and hrp.Position or Vector3.new(0, 0, 0)

        local center = Vector3.new(
            math.floor(pos.X / 4) * 4 + 2,
            math.floor(pos.Y / 4) * 4 + 2,
            math.floor(pos.Z / 4) * 4 + 2
        )

        local region = Region3.new(
            center - Vector3.new(750, 300, 750),
            center + Vector3.new(750, 300, 750)
        ):ExpandToGrid(4)

        local materials, occupancy = Terrain:ReadVoxels(region, 4)
        local size = materials.Size
        local changed = 0

        for x = 1, size.X do
            for y = 1, size.Y do
                for z = 1, size.Z do
                    if materials[x][y][z] == WATER then
                        -- Replace water with GROUND instead of AIR
                        -- This makes it match surrounding terrain color
                        materials[x][y][z] = GROUND
                        occupancy[x][y][z] = 1  -- Full occupancy for solid ground
                        changed = changed + 1
                    end
                end
            end
        end

        if changed > 0 then
            Terrain:WriteVoxels(region, 4, materials, occupancy)
        end
    end)
end

-- Also try to fill water areas with rock/sand colored terrain
local function fillWaterWithTerrain()
    pcall(function()
        if not Terrain then return end

        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local pos = hrp and hrp.Position or Vector3.new(0, 0, 0)

        -- Fill a smaller region with rock material to blend in
        local center = Vector3.new(
            math.floor(pos.X / 4) * 4 + 2,
            math.floor(pos.Y / 4) * 4 + 2,
            math.floor(pos.Z / 4) * 4 + 2
        )

        local fillRegion = Region3.new(
            center - Vector3.new(500, 50, 500),
            center + Vector3.new(500, 50, 500)
        ):ExpandToGrid(4)

        -- Fill with rock material at water level
        Terrain:FillRegion(fillRegion, 4, Enum.Material.Rock)
    end)
end

local function killWaterParts()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if obj.Material == Enum.Material.Water then
                    obj:Destroy()
                end
                local name = obj.Name:lower()
                if (name:find("water") or name:find("lake") or name:find("ocean")) and not name:find("watermelon") then
                    obj:Destroy()
                end
            end
        end
    end)
end

task.defer(function()
    task.wait(3)
    clearWater()
    fillWaterWithTerrain()
    killWaterParts()
end)

task.spawn(function()
    while true do
        task.wait(5)
        clearWater()
        fillWaterWithTerrain()
        killWaterParts()
    end
end)

print("[Delta FPS Booster] Loaded | Water -> Ground Fixed")
