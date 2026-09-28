--[[
    ✦ Project Nova ✦ | Blue Lock: Rivals
    Optimized for Delta Executor
--]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "✦ Project Nova ✦",
    SubTitle = "Blue Lock: Rivals",
    TabWidth = 160,
    Size = UDim2.fromOffset(480, 320),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Ball Trajectory", Icon = "disc" })
}

-- Переменные состояния
local TrajectoryEnabled = false
local ChamsEnabled = false

local Services = {
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players")
}

-- Улучшенная функция поиска мяча
local function GetBall()
    for _, item in ipairs(Services.Workspace:GetChildren()) do
        if item:IsA("BasePart") and (item.Name:lower():find("ball") or item.Name == "Football") then
            return item
        end
    end
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player.Character then
            local ball = player.Character:FindFirstChild("Football") or player.Character:FindFirstChild("Ball")
            if ball and ball:IsA("BasePart") then
                return ball
            end
        end
    end
    return nil
end

-- Элементы управления в меню
local ToggleTrajectory = Tabs.Main:AddToggle("TrajectoryToggle", {
    Title = "Ball Trajectory ESP",
    Default = false
})

ToggleTrajectory:OnChanged(function(Value)
    TrajectoryEnabled = Value
end)

local ToggleChams = Tabs.Main:AddToggle("ChamsToggle", {
    Title = "Ball Chams (Highlight)",
    Default = false
})

ToggleChams:OnChanged(function(Value)
    ChamsEnabled = Value
end)

-- Основной цикл обновления эффектов
Services.RunService.Heartbeat:Connect(function()
    local ball = GetBall()

    if ball then
        -- Отрисовка траектории
        if TrajectoryEnabled then
            if not ball:FindFirstChild("NovaTrail") then
                local a0 = Instance.new("Attachment", ball)
                local a1 = Instance.new("Attachment", ball)
                a1.Position = Vector3.new(0, 0, -0.6)

                local trail = Instance.new("Trail")
                trail.Name = "NovaTrail"
                trail.Attachment0 = a0
                trail.Attachment1 = a1
                trail.Lifetime = 1.2
                trail.WidthScale = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 2.2),
                    NumberSequenceKeypoint.new(1, 0.1)
                })
                trail.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(170, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 0, 180))
                })
                trail.FaceCamera = true
                trail.Parent = ball
            end
        else
            if ball:FindFirstChild("NovaTrail") then
                ball.NovaTrail:Destroy()
            end
        end

        -- Отрисовка подсветки (Chams)
        if ChamsEnabled then
            if not ball:FindFirstChild("NovaHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "NovaHighlight"
                hl.Adornee = ball
                hl.FillColor = Color3.fromRGB(150, 0, 255)
                hl.FillTransparency = 0.3
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0
                hl.Parent = ball
            end
        else
            if ball:FindFirstChild("NovaHighlight") then
                ball.NovaHighlight:Destroy()
            end
        end
    end
end)

Window:SelectTab(1)
