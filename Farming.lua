--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║  BOOGA BOOGA REBORN - ANIMATED LIGHT SWITCH                 ║
    ║  Toggles rendering on/off with smooth slide animation        ║
    ║  For: LDPlayer 9 | Delta Executor | Multi-Instance         ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════════════════════════

local RenderEnabled = true
local AnimationRunning = false
local SwitchPosition = 0  -- 0 = off (left), 1 = on (right)
local TargetPosition = 1

-- Store original values to restore later
local OriginalSettings = {
    GlobalShadows = Lighting.GlobalShadows,
    Outlines = Lighting.Outlines,
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Technology = Lighting.Technology,
}

-- ══════════════════════════════════════════════════════════════
-- RENDER TOGGLE FUNCTIONS
-- ══════════════════════════════════════════════════════════════

local DisabledObjects = {}  -- Track what we disabled

local function DisableRendering()
    -- Kill all particles
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            if obj.Enabled then
                obj.Enabled = false
                DisabledObjects[obj] = true
            end
        end
        if obj:IsA("Trail") then
            if obj.Enabled then
                obj.Enabled = false
                DisabledObjects[obj] = true
            end
        end
        if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            if obj.Enabled then
                obj.Enabled = false
                DisabledObjects[obj] = true
            end
        end
        -- Hide far terrain/decorations
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if obj.Parent and obj.Parent:IsA("BasePart") then
                local dist = (obj.Parent.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude
                if dist > 50 then
                    obj.Transparency = 1
                    DisabledObjects[obj] = true
                end
            end
        end
    end

    -- Darken lighting
    Lighting.GlobalShadows = false
    Lighting.Outlines = false
    Lighting.Brightness = 0.2
    Lighting.Ambient = Color3.fromRGB(30, 30, 30)
    Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 30)

    -- Disable terrain decoration
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.Decoration = false
    end

    print("[Light Switch] Rendering DISABLED - CPU/GPU saved")
end

local function EnableRendering()
    -- Restore particles/lights we disabled
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

    -- Restore lighting
    Lighting.GlobalShadows = OriginalSettings.GlobalShadows
    Lighting.Outlines = OriginalSettings.Outlines
    Lighting.Brightness = OriginalSettings.Brightness
    Lighting.Ambient = OriginalSettings.Ambient
    Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient

    -- Restore terrain
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.Decoration = true
    end

    print("[Light Switch] Rendering ENABLED")
end

-- ══════════════════════════════════════════════════════════════
-- ANIMATED SWITCH GUI
-- ══════════════════════════════════════════════════════════════

local function CreateLightSwitch()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LightSwitch"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 120, 0, 50)
    container.Position = UDim2.new(0, 20, 0, 20)  -- Top left
    container.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    container.BorderSizePixel = 0
    container.Parent = screenGui

    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 25)
    corner.Parent = container

    -- Track (the rail the knob slides on)
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(0, 100, 0, 30)
    track.Position = UDim2.new(0.5, -50, 0.5, -15)
    track.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
    track.BorderSizePixel = 0
    track.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 15)
    trackCorner.Parent = track

    -- Knob (the sliding circle)
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 36, 0, 36)
    knob.Position = UDim2.new(0, 52, 0.5, -18)  -- Start on right (ON)
    knob.BackgroundColor3 = Color3.fromRGB(0, 255, 100)  -- Green = ON
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)  -- Perfect circle
    knobCorner.Parent = knob

    -- Glow effect when ON
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1316045210"  -- Soft glow
    glow.ImageColor3 = Color3.fromRGB(0, 255, 100)
    glow.ImageTransparency = 0.6
    glow.ZIndex = 1
    glow.Parent = knob

    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Name = "Status"
    statusText.Size = UDim2.new(0, 100, 0, 20)
    statusText.Position = UDim2.new(0.5, -50, 0, 55)
    statusText.BackgroundTransparency = 1
    statusText.Text = "RENDER: ON"
    statusText.TextColor3 = Color3.fromRGB(0, 255, 100)
    statusText.TextSize = 12
    statusText.Font = Enum.Font.GothamBold
    statusText.Parent = container

    -- Click area (invisible, covers whole container)
    local clickArea = Instance.new("TextButton")
    clickArea.Name = "ClickArea"
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = container

    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- ══════════════════════════════════════════════════════════════
    -- ANIMATION SYSTEM
    -- ══════════════════════════════════════════════════════════════

    local TweenService = game:GetService("TweenService")

    local function AnimateSwitch(toOn)
        if AnimationRunning then return end
        AnimationRunning = true

        TargetPosition = toOn and 1 or 0
        local targetX = toOn and 52 or 2  -- Right = 52, Left = 2
        local targetColor = toOn and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 60, 60)
        local targetText = toOn and "RENDER: ON" or "RENDER: OFF"
        local targetTextColor = toOn and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 60, 60)
        local glowTransparency = toOn and 0.6 or 1

        -- Animate knob position
        local positionTween = TweenService:Create(
            knob,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, targetX, 0.5, -18)}
        )

        -- Animate knob color
        local colorTween = TweenService:Create(
            knob,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundColor3 = targetColor}
        )

        -- Animate glow
        local glowTween = TweenService:Create(
            glow,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {ImageTransparency = glowTransparency}
        )

        -- Animate text
        local textColorTween = TweenService:Create(
            statusText,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {TextColor3 = targetTextColor}
        )

        positionTween:Play()
        colorTween:Play()
        glowTween:Play()
        textColorTween:Play()

        statusText.Text = targetText

        -- Toggle rendering after animation starts
        if toOn then
            EnableRendering()
        else
            DisableRendering()
        end

        positionTween.Completed:Connect(function()
            AnimationRunning = false
            SwitchPosition = TargetPosition
        end)
    end

    -- Click handler
    clickArea.MouseButton1Click:Connect(function()
        RenderEnabled = not RenderEnabled
        AnimateSwitch(RenderEnabled)
    end)

    -- Hover effect
    clickArea.MouseEnter:Connect(function()
        TweenService:Create(
            container,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}
        ):Play()
    end)

    clickArea.MouseLeave:Connect(function()
        TweenService:Create(
            container,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}
        ):Play()
    end)

    print("[Light Switch] Created - Click to toggle rendering")
    return {
        Toggle = function() 
            RenderEnabled = not RenderEnabled
            AnimateSwitch(RenderEnabled)
        end,
        IsOn = function() return RenderEnabled end
    }
end

-- ══════════════════════════════════════════════════════════════
-- AUTO-OFF AFTER 30 SECONDS (OPTIONAL)
-- ══════════════════════════════════════════════════════════════
-- Automatically turns off rendering after 30s if farming
-- This saves GPU while you're not watching
-- ══════════════════════════════════════════════════════════════

local function AutoOffTimer(switch)
    task.wait(30)
    if switch.IsOn() then
        print("[Light Switch] Auto-off after 30s - Saving GPU")
        switch.Toggle()
    end
end

-- ══════════════════════════════════════════════════════════════
-- INIT
-- ══════════════════════════════════════════════════════════════

spawn(function()
    task.wait(3)  -- Wait for game to load
    local switch = CreateLightSwitch()

    -- Optional: Auto-off after 30 seconds
    -- spawn(function() AutoOffTimer(switch) end)

    -- Bind to key (optional) - RightCtrl + L
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.L and UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            switch.Toggle()
        end
    end)
end)

print("[Light Switch] Script loaded - RightCtrl+L to toggle")
