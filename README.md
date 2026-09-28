--[[
    Project Nova ✦ | Ball Tracker & Trajectory ESP
    Style: Nova Purple UI + Advanced Trajectory Engine
--]]

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    TweenService = game:GetService("TweenService")
}

local LocalPlayer = Services.Players.LocalPlayer or Services.Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Безопасное удаление предыдущей версии UI
if PlayerGui:FindFirstChild("Nova_BallUI") then
    PlayerGui.Nova_BallUI:Destroy()
end

-- ==========================================================
-- ИНТЕРФЕЙС (GUI)
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nova_BallUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Главное Frame-окно (Увеличенный размер 450x260)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 260)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(140, 60, 255) -- Фиолетовая обводка
MainStroke.Thickness = 1.5

-- Шапка
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(1, -30, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "✦ Project Nova ✦"
TitleLabel.TextColor3 = Color3.fromRGB(170, 90, 255) -- Фиолетовый текст Nova
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Левая панель вкладок (Sidebar)
local LeftSidebar = Instance.new("Frame", MainFrame)
LeftSidebar.Position = UDim2.new(0, 0, 0, 35)
LeftSidebar.Size = UDim2.new(0, 115, 1, -35)
LeftSidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
LeftSidebar.BorderSizePixel = 0

-- Кнопка вкладки "Ball Trajectory"
local TabButton = Instance.new("TextButton", LeftSidebar)
TabButton.Position = UDim2.new(0, 8, 0, 10)
TabButton.Size = UDim2.new(0, 99, 0, 32)
TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TabButton.AutoButtonColor = false
TabButton.Font = Enum.Font.GothamMedium
TabButton.Text = "Ball Trajectory"
TabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
TabButton.TextSize = 11

local TabCorner = Instance.new("UICorner", TabButton)
TabCorner.CornerRadius = UDim.new(0, 6)

-- Интерактив зажатия кнопки
TabButton.MouseButton1Down:Connect(function()
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    TabButton.Size = UDim2.new(0, 103, 0, 34)
    TabButton.Position = UDim2.new(0, 6, 0, 9)
end)

TabButton.MouseButton1Up:Connect(function()
    TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TabButton.Size = UDim2.new(0, 99, 0, 32)
    TabButton.Position = UDim2.new(0, 8, 0, 10)
end)

-- Правый контент
local RightContent = Instance.new("Frame", MainFrame)
RightContent.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
RightContent.BorderSizePixel = 0
RightContent.Position = UDim2.new(0, 115, 0, 35)
RightContent.Size = UDim2.new(1, -115, 1, -35)

-- ЭЛЕМЕНТ 1: Trajectory Toggle
local Title1 = Instance.new("TextLabel", RightContent)
Title1.Position = UDim2.new(0, 15, 0, 20)
Title1.Size = UDim2.new(0, 200, 0, 20)
Title1.BackgroundTransparency = 1
Title1.Font = Enum.Font.GothamBold
Title1.Text = "Ball Trajectory Esp"
Title1.TextColor3 = Color3.fromRGB(220, 220, 220)
Title1.TextSize = 13
Title1.TextXAlignment = Enum.TextXAlignment.Left

local Checkbox1 = Instance.new("TextButton", RightContent)
Checkbox1.Position = UDim2.new(1, -35, 0, 20)
Checkbox1.Size = UDim2.new(0, 20, 0, 20)
Checkbox1.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Checkbox1.BorderColor3 = Color3.fromRGB(70, 70, 85)
Checkbox1.BorderSizePixel = 1
Checkbox1.AutoButtonColor = false
Checkbox1.Text = ""
Instance.new("UICorner", Checkbox1).CornerRadius = UDim.new(0, 4)

-- ЭЛЕМЕНТ 2: Ball Chams Toggle
local Title2 = Instance.new("TextLabel", RightContent)
Title2.Position = UDim2.new(0, 15, 0, 60)
Title2.Size = UDim2.new(0, 200, 0, 20)
Title2.BackgroundTransparency = 1
Title2.Font = Enum.Font.GothamBold
Title2.Text = "Ball Chams (Highlight)"
Title2.TextColor3 = Color3.fromRGB(220, 220, 220)
Title2.TextSize = 13
Title2.TextXAlignment = Enum.TextXAlignment.Left

local Checkbox2 = Instance.new("TextButton", RightContent)
Checkbox2.Position = UDim2.new(1, -35, 0, 60)
Checkbox2.Size = UDim2.new(0, 20, 0, 20)
Checkbox2.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Checkbox2.BorderColor3 = Color3.fromRGB(70, 70, 85)
Checkbox2.BorderSizePixel = 1
Checkbox2.AutoButtonColor = false
Checkbox2.Text = ""
Instance.new("UICorner", Checkbox2).CornerRadius = UDim.new(0, 4)

-- Статус
local StatusLabel = Instance.new("TextLabel", RightContent)
StatusLabel.Position = UDim2.new(0, 15, 1, -30)
StatusLabel.Size = UDim2.new(1, -30, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Searching ball..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ==========================================================
-- ЛОГИКА ТРАЕКТОРИИ И ПОДСВЕТКИ
-- ==========================================================
local trajectoryEnabled = false
local chamsEnabled = false

local currentBall = nil
local activeTrail = nil
local activeHighlight = nil
local att0, att1 = nil, nil

local function findBall()
    for _, obj in ipairs(Services.Workspace:GetChildren()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "ball") or obj.Name == "Football" or obj.Name == "SoccerBall") then
            return obj
        end
    end
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "ball") or obj.Name == "Football") then
            return obj
        end
    end
    return nil
end

local function ClearTrail()
    if activeTrail then activeTrail:Destroy() activeTrail = nil end
    if att0 then att0:Destroy() att0 = nil end
    if att1 then att1:Destroy() att1 = nil end
end

local function ClearHighlight()
    if activeHighlight then activeHighlight:Destroy() activeHighlight = nil end
end

local function AttachTrail(ball)
    ClearTrail()
    if not ball or not trajectoryEnabled then return end

    att0 = Instance.new("Attachment")
    att0.Name = "NovaAtt0"
    att0.Position = Vector3.new(0, 0, 0)
    att0.Parent = ball

    att1 = Instance.new("Attachment")
    att1.Name = "NovaAtt1"
    att1.Position = Vector3.new(0, 0, -0.6)
    att1.Parent = ball

    local trail = Instance.new("Trail")
    trail.Name = "NovaBallTrail"
    trail.Attachment0 = att0
    trail.Attachment1 = att1
    trail.Lifetime = 1.8 -- Длина видимости следа при полете
    trail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.8),
        NumberSequenceKeypoint.new(1, 0.2)
    })
    -- Яркий фиолетово-белый градиент
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 0, 255))
    })
    trail.FaceCamera = true
    trail.Parent = ball
    activeTrail = trail
end

local function AttachHighlight(ball)
    ClearHighlight()
    if not ball or not chamsEnabled then return end

    local hl = Instance.new("Highlight")
    hl.Name = "NovaBallHighlight"
    hl.Adornee = ball
    hl.FillColor = Color3.fromRGB(160, 32, 240)
    hl.FillTransparency = 0.35
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0
    hl.Parent = ball
    activeHighlight = hl
end

-- Обработка переключателей
Checkbox1.MouseButton1Click:Connect(function()
    trajectoryEnabled = not trajectoryEnabled
    Checkbox1.BackgroundColor3 = trajectoryEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(25, 25, 32)
    
    currentBall = findBall()
    if trajectoryEnabled and currentBall then
        AttachTrail(currentBall)
    else
        ClearTrail()
    end
end)

Checkbox2.MouseButton1Click:Connect(function()
    chamsEnabled = not chamsEnabled
    Checkbox2.BackgroundColor3 = chamsEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(25, 25, 32)

    currentBall = findBall()
    if chamsEnabled and currentBall then
        AttachHighlight(currentBall)
    else
        ClearHighlight()
    end
end)

-- Главный цикл контроля мяча (переприкрепляет эффекты, если мяч пересоздался или его отобрали)
Services.RunService.Heartbeat:Connect(function()
    local ball = findBall()
    
    if ball then
        StatusLabel.Text = "Status: Connected to (" .. ball.Name .. ")"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        
        -- Если объект мяча изменился
        if ball ~= currentBall then
            currentBall = ball
            if trajectoryEnabled then AttachTrail(ball) end
            if chamsEnabled then AttachHighlight(ball) end
        else
            -- Если след отвалился (например, при перехвате мяча)
            if trajectoryEnabled and (not activeTrail or not activeTrail.Parent) then
                AttachTrail(ball)
            end
            if chamsEnabled and (not activeHighlight or not activeHighlight.Parent) then
                AttachHighlight(ball)
            end
        end
    else
        StatusLabel.Text = "Status: Ball not found"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
    end
end)
