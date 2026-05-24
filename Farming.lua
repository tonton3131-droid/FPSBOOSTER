--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║  BOOGA BOOGA REBORN - ROCKER SWITCH WITH DOT ON ROCKER     ║
    ║  Dot moves WITH the rocker, not on the side                 ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════════════════════════

local SwitchOn = true
local AnimationRunning = false
local DisabledObjects = {}

local OriginalSettings = {
    GlobalShadows = Lighting.GlobalShadows,
    Outlines = Lighting.Outlines,
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

-- ══════════════════════════════════════════════════════════════
-- RENDER TOGGLE
-- ══════════════════════════════════════════════════════════════

local function DisableRendering()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            if obj.Enabled then obj.Enabled = false; DisabledObjects[obj] = true end
        end
        if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            if obj.Enabled then obj.Enabled = false; DisabledObjects[obj] = true end
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if obj.Parent and obj.Parent:IsA("BasePart") then
                local dist = (obj.Parent.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude
                if dist > 50 then obj.Transparency = 1; DisabledObjects[obj] = true end
            end
        end
    end

    Lighting.GlobalShadows = false
    Lighting.Outlines = false
    Lighting.Brightness = 0.2
    Lighting.Ambient = Color3.fromRGB(30, 30, 30)
    Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 30)

    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then terrain.Decoration = false end
end

local function EnableRendering()
    for obj, _ in pairs(DisabledObjects) do
        if obj and obj.Parent then
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = true
            end
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 0
            end
        end
    end
    DisabledObjects = {}

    Lighting.GlobalShadows = OriginalSettings.GlobalShadows
    Lighting.Outlines = OriginalSettings.Outlines
    Lighting.Brightness = OriginalSettings.Brightness
    Lighting.Ambient = OriginalSettings.Ambient
    Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient

    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then terrain.Decoration = true end
end

-- ══════════════════════════════════════════════════════════════
-- COMPACT DRAGGABLE ROCKER SWITCH
-- ══════════════════════════════════════════════════════════════

local function CreateSwitch()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RockerSwitch"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- ═══ MAIN CONTAINER (Draggable) ═══
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 70, 0, 70)
    container.Position = UDim2.new(0, 20, 0, 20)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Active = true
    container.Parent = screenGui

    -- ═══ WALL PLATE ═══
    local plate = Instance.new("Frame")
    plate.Name = "Plate"
    plate.Size = UDim2.new(1, 0, 1, 0)
    plate.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    plate.BorderSizePixel = 0
    plate.Parent = container

    local plateCorner = Instance.new("UICorner")
    plateCorner.CornerRadius = UDim.new(0, 4)
    plateCorner.Parent = plate

    -- Plate shadow
    local plateShadow = Instance.new("ImageLabel")
    plateShadow.Size = UDim2.new(1, 12, 1, 12)
    plateShadow.Position = UDim2.new(0, -6, 0, -6)
    plateShadow.BackgroundTransparency = 1
    plateShadow.Image = "rbxassetid://1316045210"
    plateShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    plateShadow.ImageTransparency = 0.85
    plateShadow.ZIndex = 0
    plateShadow.Parent = plate

    -- Inner recess
    local recess = Instance.new("Frame")
    recess.Size = UDim2.new(1, -10, 1, -10)
    recess.Position = UDim2.new(0, 5, 0, 5)
    recess.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
    recess.BorderSizePixel = 0
    recess.ZIndex = 2
    recess.Parent = plate

    local recessCorner = Instance.new("UICorner")
    recessCorner.CornerRadius = UDim.new(0, 3)
    recessCorner.Parent = recess

    -- ═══ SCREWS ═══
    local function CreateScrew(parent, pos)
        local screw = Instance.new("Frame")
        screw.Size = UDim2.new(0, 6, 0, 6)
        screw.Position = pos
        screw.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
        screw.BorderSizePixel = 0
        screw.ZIndex = 4
        screw.Parent = parent

        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(1, 0)
        sc.Parent = screw

        local slot = Instance.new("Frame")
        slot.Size = UDim2.new(0, 3, 0, 1)
        slot.Position = UDim2.new(0.5, -1.5, 0.5, -0.5)
        slot.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
        slot.BorderSizePixel = 0
        slot.ZIndex = 5
        slot.Parent = screw

        return screw
    end

    CreateScrew(plate, UDim2.new(0.5, -3, 0, 6))
    CreateScrew(plate, UDim2.new(0.5, -3, 1, -12))

    -- ═══ ROCKER ═══
    local rocker = Instance.new("Frame")
    rocker.Name = "Rocker"
    rocker.Size = UDim2.new(0, 22, 0, 42)
    rocker.Position = UDim2.new(0.5, -11, 0.5, -21)
    rocker.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
    rocker.BorderSizePixel = 0
    rocker.ZIndex = 5
    rocker.Parent = plate

    local rockerCorner = Instance.new("UICorner")
    rockerCorner.CornerRadius = UDim.new(0, 2)
    rockerCorner.Parent = rocker

    -- Rocker shadow
    local rShadow = Instance.new("ImageLabel")
    rShadow.Name = "Shadow"
    rShadow.Size = UDim2.new(1, 8, 1, 8)
    rShadow.Position = UDim2.new(0, -4, 0, -4)
    rShadow.BackgroundTransparency = 1
    rShadow.Image = "rbxassetid://1316045210"
    rShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    rShadow.ImageTransparency = 0.65
    rShadow.ZIndex = 4
    rShadow.Parent = rocker

    -- Top highlight
    local hTop = Instance.new("Frame")
    hTop.Name = "HTop"
    hTop.Size = UDim2.new(1, -4, 0, 1.5)
    hTop.Position = UDim2.new(0, 2, 0, 2)
    hTop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hTop.BorderSizePixel = 0
    hTop.ZIndex = 6
    hTop.Parent = rocker

    -- Bottom shadow line
    local hBot = Instance.new("Frame")
    hBot.Name = "HBot"
    hBot.Size = UDim2.new(1, -4, 0, 1.5)
    hBot.Position = UDim2.new(0, 2, 1, -3.5)
    hBot.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
    hBot.BorderSizePixel = 0
    hBot.ZIndex = 6
    hBot.Parent = rocker

    -- ═══ DOT ON THE ROCKER (NOT ON THE SIDE) ═══
    -- This dot is INSIDE the rocker and moves WITH it
    local rockerDot = Instance.new("Frame")
    rockerDot.Name = "RockerDot"
    rockerDot.Size = UDim2.new(0, 6, 0, 6)
    -- Position: centered horizontally, near bottom when ON (down position)
    rockerDot.Position = UDim2.new(0.5, -3, 1, -12)  -- Bottom of rocker
    rockerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)  -- Green = ON
    rockerDot.BorderSizePixel = 0
    rockerDot.ZIndex = 7
    rockerDot.Parent = rocker

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = rockerDot

    -- ═══ CLICK AREA ═══
    local clickArea = Instance.new("TextButton")
    clickArea.Name = "Click"
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 20
    clickArea.Parent = container

    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- ══════════════════════════════════════════════════════════════
    -- DRAGGING
    -- ══════════════════════════════════════════════════════════════

    local dragging = false
    local dragStart = nil
    local startPos = nil

    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = container.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            container.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- ══════════════════════════════════════════════════════════════
    -- ANIMATION - INVERTED: DOWN = ON, UP = OFF
    -- ══════════════════════════════════════════════════════════════

    local function Animate(toOn)
        if AnimationRunning then return end
        AnimationRunning = true

        -- INVERTED:
        -- ON = rocker DOWN (bottom sticks out, dot visible at bottom)
        -- OFF = rocker UP (top sticks out, dot moves to top or hides)

        local dotColor = toOn and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 60, 60)
        local dotPos = toOn and UDim2.new(0.5, -3, 1, -12) or UDim2.new(0.5, -3, 0, 6)  -- Bottom when ON, top when OFF
        local shadowPos = toOn and UDim2.new(0, -2, 0, -6) or UDim2.new(0, -6, 0, -2)
        local shadowTrans = toOn and 0.7 or 0.55

        -- Rocker height change
        local heightTween = TweenService:Create(
            rocker,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 22, 0, toOn and 44 or 40)}
        )

        -- Shadow moves
        local shadowTween = TweenService:Create(
            rShadow,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Position = shadowPos,
                ImageTransparency = shadowTrans
            }
        )

        -- Highlight/shadow edges swap
        local topTween = TweenService:Create(
            hTop,
            TweenInfo.new(0.2),
            {BackgroundColor3 = toOn and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(255, 255, 255)}
        )

        local botTween = TweenService:Create(
            hBot,
            TweenInfo.new(0.2),
            {BackgroundColor3 = toOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)}
        )

        -- DOT MOVES WITH ROCKER
        local dotTween = TweenService:Create(
            rockerDot,
            TweenInfo.new(0.2),
            {
                Position = dotPos,
                BackgroundColor3 = dotColor
            }
        )

        heightTween:Play()
        shadowTween:Play()
        topTween:Play()
        botTween:Play()
        dotTween:Play()

        if toOn then
            EnableRendering()
        else
            DisableRendering()
        end

        heightTween.Completed:Connect(function()
            AnimationRunning = false
        end)
    end

    -- Click to toggle
    clickArea.MouseButton1Click:Connect(function()
        SwitchOn = not SwitchOn
        Animate(SwitchOn)
    end)

    -- Hover
    clickArea.MouseEnter:Connect(function()
        TweenService:Create(plate, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(250, 250, 250)}):Play()
    end)

    clickArea.MouseLeave:Connect(function()
        TweenService:Create(plate, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(240, 240, 240)}):Play()
    end)

    print("[RockerSwitch] Dot is ON the rocker, moves with it")

    return {
        Toggle = function()
            SwitchOn = not SwitchOn
            Animate(SwitchOn)
        end,
        IsOn = function() return SwitchOn end
    }
end

-- ══════════════════════════════════════════════════════════════
-- INIT
-- ══════════════════════════════════════════════════════════════

spawn(function()
    task.wait(3)
    local switch = CreateSwitch()

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.L and UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            switch.Toggle()
        end
    end)
end)

print("[RockerSwitch] Loaded - Dot on rocker, inverted, draggable")
