local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
local MaterialService = game:GetService("MaterialService")

local LocalPlayer = Players.LocalPlayer
local pgui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================
-- MINIMAL SETUP
-- ============================================

pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
end)

pcall(function()
    if Terrain then
        Terrain.WaterTransparency = 1
        Terrain.Decoration = false
    end
end)

pcall(function()
    for _, v in pairs(MaterialService:GetChildren()) do
        v:Destroy()
    end
end)

-- ============================================
-- VISIBILITY HELPERS
-- ============================================

-- ONLY keep toes/feet and fingers/hands visible
local function shouldKeepVisible(obj)
    local name = obj.Name:lower()
    -- TOES / FEET / LOWER LEG
    if name:find("toe") or name:find("foot") or name:find("lowerleg") or name:find("lowerrightleg") or name:find("lowerleftleg") then
        return true
    end
    -- FINGERS / HANDS / LOWER ARM
    if name:find("finger") or name:find("hand") or name:find("lowerarm") or name:find("lowerrightarm") or name:find("lowerleftarm") then
        return true
    end
    return false
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
-- OTHER PLAYERS: FULLY INVISIBLE
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
-- LOCAL PLAYER: ONLY TOES & FINGERS VISIBLE
-- ============================================

local function setupLocalChar(char)
    if not char then return end
    pcall(function()
        -- First pass: hide EVERYTHING
        for _, obj in ipairs(char:GetDescendants()) do
            makeInvisible(obj)
        end

        -- Second pass: show only toes/feet and fingers/hands
        for _, obj in ipairs(char:GetDescendants()) do
            if shouldKeepVisible(obj) then
                makeVisible(obj)
            end
        end

        -- Monitor new descendants
        char.DescendantAdded:Connect(function(desc)
            pcall(function()
                if shouldKeepVisible(desc) then
                    makeVisible(desc)
                else
                    makeInvisible(desc)
                end
            end)
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
-- WORLD STRIPPING (Minimal)
-- ============================================

pcall(function()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            local c = obj.ClassName
            if c == "ParticleEmitter" or c == "Trail" or c == "Decal" or c == "Texture" or c == "Light" then
                obj:Destroy()
            elseif obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Reflectance = 0
            end
        end)
    end
end)

-- ============================================
-- RENDER TOGGLE + FPS (Big Centered)
-- ============================================

pcall(function()
    local old = pgui:FindFirstChild("RenderToggle")
    if old then old:Destroy() end
end)

local sg = Instance.new("ScreenGui")
sg.Name = "RenderToggle"
sg.Parent = pgui
sg.ResetOnSpawn = false

local fpsF = Instance.new("Frame")
fpsF.Parent = sg
fpsF.BackgroundColor3 = Color3.fromRGB(0,0,0)
fpsF.Size = UDim2.new(0,400,0,200)
fpsF.Position = UDim2.new(0.5,-200,0.5,-100)
fpsF.Visible = false

local fpsL = Instance.new("TextLabel")
fpsL.Parent = fpsF
fpsL.Size = UDim2.new(1,0,1,0)
fpsL.BackgroundTransparency = 1
fpsL.Text = "FPS: --"
fpsL.TextColor3 = Color3.fromRGB(255,255,255)
fpsL.Font = Enum.Font.SourceSansBold
fpsL.TextSize = 96

local mf = Instance.new("Frame")
mf.Parent = sg
mf.BackgroundColor3 = Color3.fromRGB(20,20,20)
mf.Size = UDim2.new(0,220,0,80)
mf.Position = UDim2.new(0,10,0,50)

local ttl = Instance.new("TextLabel")
ttl.Parent = mf
ttl.Text = "LYANNE IS CUTE"
ttl.Size = UDim2.new(1,0,0,24)
ttl.Position = UDim2.new(0,0,0,6)
ttl.BackgroundTransparency = 1
ttl.TextColor3 = Color3.fromRGB(255,255,255)
ttl.Font = Enum.Font.SourceSansBold
ttl.TextSize = 18

local btn = Instance.new("TextButton")
btn.Parent = mf
btn.Text = "RENDER: ON"
btn.Size = UDim2.new(1,-20,0,36)
btn.Position = UDim2.new(0,10,0,36)
btn.BackgroundColor3 = Color3.fromRGB(0,180,0)
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 20

local on = true
local fc = 0
local lt = tick()

RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local n = tick()
    if n - lt >= 1 then
        fpsL.Text = "FPS: " .. fc
        fc = 0
        lt = n
    end
end)

btn.MouseButton1Click:Connect(function()
    on = not on
    pcall(function() RunService:Set3dRenderingEnabled(on) end)
    if on then
        btn.Text = "RENDER: ON"
        btn.BackgroundColor3 = Color3.fromRGB(0,180,0)
        fpsF.Visible = false
    else
        btn.Text = "RENDER: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
        fpsF.Visible = true
    end
end)

-- ============================================
-- WATER DELETE (Minimal)
-- ============================================

pcall(function()
    if Terrain then
        Terrain.WaterTransparency = 1
        Terrain.WaterColor = Color3.fromRGB(0,0,0)
        Terrain.WaterReflectance = 0
    end
end)

task.spawn(function()
    while true do
        task.wait(10)
        pcall(function()
            if not Terrain then return end
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local pos = hrp.Position
            local r = Region3.new(pos - Vector3.new(500,100,500), pos + Vector3.new(500,100,500)):ExpandToGrid(4)
            local mat, occ = Terrain:ReadVoxels(r, 4)
            local sz = mat.Size
            local ch = 0

            for x = 1, sz.X do
                for y = 1, sz.Y do
                    for z = 1, sz.Z do
                        if mat[x][y][z] == Enum.Material.Water then
                            mat[x][y][z] = Enum.Material.Ground
                            occ[x][y][z] = 1
                            ch = ch + 1
                        end
                    end
                end
            end

            if ch > 0 then
                Terrain:WriteVoxels(r, 4, mat, occ)
            end
        end)
    end
end)

print("[FPS Booster] Toes + Fingers Only Loaded")
