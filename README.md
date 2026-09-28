--[[
    ✦ Project Nova ✦ | Blue Lock: Rivals
    Fluent UI (Cosmic Violet Theme) for Delta Executor
--]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "✦ Project Nova ✦",
    SubTitle = "Blue Lock: Rivals",
    TabWidth = 160,
    Size = UDim2.fromOffset(530, 360),
    Acrylic = true, -- Эффект размытия заднего фона
    Theme = "Amethyst", -- Фиолетовая тема (Cosmic Violet)
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Создаем вкладки
local Tabs = {
    Main = Window:AddTab({ Title = "Ball Features", Icon = "disc" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Переключатель 1: Trajectory ESP
local ToggleTrajectory = Tabs.Main:AddToggle("BallTrajectory", {
    Title = "Ball Trajectory ESP",
    Description = "Показывает фиолетовую траекторию движения мяча",
    Default = false
})

-- Переключатель 2: Ball Chams
local ToggleChams = Tabs.Main:AddToggle("BallChams", {
    Title = "Ball Chams (Highlight)",
    Description = "Подсвечивает мяч сквозь стены фиолетовым свечением",
    Default = false
})

-- ==========================================================
-- ЛОГИКА ТРАЕКТОРИИ И ПОДСВЕТКИ (СЕРВИСЫ)
-- ==========================================================
local Services = {
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players")
}

-- Улучшенный поиск мяча (работает при ведении, ударах и спавне)
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

local activeTrail, att0, att1 = nil, nil, nil
local activeHighlight = nil
local currentBall = nil

Services.RunService.Heartbeat:Connect(function()
    local ball = GetBall()

    if ball then
        if ball ~= currentBall then
            currentBall = ball
            if activeTrail then activeTrail:Destroy() activeTrail = nil end
            if activeHighlight then activeHighlight:Destroy() activeHighlight = nil end
        end

        -- Траектория
        if Options.BallTrajectory.Value then
            if not ball:FindFirstChild("NovaTrail") then
                att0 = Instance.new("Attachment")
                att0.Name = "NovaAtt0"
                att0.Parent = ball

                att1 = Instance.new("Attachment")
                att1.Name = "NovaAtt1"
                att1.Position = Vector3.new(0, 0, -0.6)
                att1.Parent = ball

                local trail = Instance.new("Trail")
                trail.Name = "NovaTrail"
                trail.Attachment0 = att0
                trail.Attachment1 = att1
                trail.Lifetime = 1.4
                trail.WidthScale = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 2.2),
                    NumberSequenceKeypoint.new(1, 0.1)
                })
                trail.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(180, 60, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 0, 255))
                })
                trail.FaceCamera = true
                trail.Parent = ball
                activeTrail = trail
            end
        else
            if ball:FindFirstChild("NovaTrail") then
                ball.NovaTrail:Destroy()
            end
        end

        -- Подсветка (Chams)
        if Options.BallChams.Value then
            if not ball:FindFirstChild("NovaHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "NovaHighlight"
                hl.Adornee = ball
                hl.FillColor = Color3.fromRGB(150, 40, 255)
                hl.FillTransparency = 0.35
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0
                hl.Parent = ball
                activeHighlight = hl
            end
        else
            if ball:FindFirstChild("NovaHighlight") then
                ball.NovaHighlight:Destroy()
            end
        end
    end
end)

-- Настройки меню
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Project Nova ✦",
    Content = "Скрипт успешно загружен в Delta Executor!",
    Duration = 5
})
