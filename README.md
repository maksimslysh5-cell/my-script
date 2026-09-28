--[[
    ✦ Project Nova ✦ | Blue Lock: Rivals
    Cosmic Violet Custom UI (Mobile / Delta Executor Ready)
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Безопасное получение контейнера UI под Delta Executor
local function GetUIContainer()
    if gethui then
        local success, res = pcall(gethui)
        if success and res then return res end
    end
    local okCore, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if okCore and coreGui then
        return coreGui
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ParentContainer = GetUIContainer()

-- Удаление прошлых копий интерфейса при перезапуске
if ParentContainer:FindFirstChild("Nova_CosmicUI") then
    ParentContainer.Nova_CosmicUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nova_CosmicUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentContainer

-- Главная рамка
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 300)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 17, 32)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(150, 70, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2

-- Шапка окна
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 23, 44)
TopBar.BorderSizePixel = 0

local TopBarCorner = Instance.new("UICorner", TopBar)
TopBarCorner.CornerRadius = UDim.new(0, 10)

local TopBarFix = Instance.new("Frame", TopBar)
TopBarFix.Position = UDim2.new(0, 0, 1, -8)
TopBarFix.Size = UDim2.new(1, 0, 0, 8)
TopBarFix.BackgroundColor3 = Color3.fromRGB(30, 23, 44)
TopBarFix.BorderSizePixel = 0

-- Заголовок
local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.Size = UDim2.new(0, 250, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "✦ Project Nova ✦  <font color=\"rgb(160,140,200)\">| Blue Lock</font>"
TitleLabel.RichText = true
TitleLabel.TextColor3 = Color3.fromRGB(200, 130, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопки шапки (Закрыть / Свернуть)
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Name = "CloseBtn"
CloseBtn.Position = UDim2.new(1, -32, 0, 7)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 33, 62)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(220, 200, 255)
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = true
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local MinimizeBtn = Instance.new("TextButton", TopBar)
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Position = UDim2.new(1, -62, 0, 7)
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 33, 62)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 200, 255)
MinimizeBtn.TextSize = 12
MinimizeBtn.AutoButtonColor = true
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

-- Плавающая кнопка для открытия/закрытия на телефоне
local ToggleFloatingBtn = Instance.new("TextButton", ScreenGui)
ToggleFloatingBtn.Name = "NovaFloatingBtn"
ToggleFloatingBtn.Position = UDim2.new(0, 15, 0.2, 0)
ToggleFloatingBtn.Size = UDim2.new(0, 42, 0, 42)
ToggleFloatingBtn.BackgroundColor3 = Color3.fromRGB(30, 22, 45)
ToggleFloatingBtn.Font = Enum.Font.GothamBold
ToggleFloatingBtn.Text = "✦"
ToggleFloatingBtn.TextColor3 = Color3.fromRGB(180, 80, 255)
ToggleFloatingBtn.TextSize = 20
ToggleFloatingBtn.Visible = false
Instance.new("UICorner", ToggleFloatingBtn).CornerRadius = UDim.new(1, 0)

local FloatingStroke = Instance.new("UIStroke", ToggleFloatingBtn)
FloatingStroke.Color = Color3.fromRGB(160, 70, 255)
FloatingStroke.Thickness = 1.5

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleFloatingBtn.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

ToggleFloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        ToggleFloatingBtn.Visible = false
    end
end)

-- Перетаскивание меню (Мышка + Сенсор)
local dragging, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Левая боковая панель
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.Size = UDim2.new(0, 135, 1, -38)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 12, 24)
Sidebar.BorderSizePixel = 0

-- Логотип планеты (как на скриншоте)
local LogoLabel = Instance.new("TextLabel", Sidebar)
LogoLabel.Position = UDim2.new(0, 0, 0, 10)
LogoLabel.Size = UDim2.new(1, 0, 0, 45)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.Text = "🪐"
LogoLabel.TextSize = 32

local TabButton = Instance.new("Frame", Sidebar)
TabButton.Position = UDim2.new(0, 8, 0, 65)
TabButton.Size = UDim2.new(0, 119, 0, 34)
TabButton.BackgroundColor3 = Color3.fromRGB(42, 30, 64)
Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

local TabLabel = Instance.new("TextLabel", TabButton)
TabLabel.Size = UDim2.new(1, 0, 1, 0)
TabLabel.BackgroundTransparency = 1
TabLabel.Font = Enum.Font.GothamMedium
TabLabel.Text = "⚽ Ball Trajectory"
TabLabel.TextColor3 = Color3.fromRGB(235, 220, 255)
TabLabel.TextSize = 11

-- Правая область
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 135, 0, 38)
Content.Size = UDim2.new(1, -135, 1, -38)
Content.BackgroundColor3 = Color3.fromRGB(22, 17, 32)
Content.BorderSizePixel = 0

-- Конструктор переключателей
local function CreateToggleCard(parent, posY, titleText, descText)
    local Card = Instance.new("TextButton", parent)
    Card.Position = UDim2.new(0, 12, 0, posY)
    Card.Size = UDim2.new(1, -24, 0, 50)
    Card.BackgroundColor3 = Color3.fromRGB(28, 22, 40)
    Card.AutoButtonColor = false
    Card.Text = ""
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = Color3.fromRGB(60, 45, 85)
    Stroke.Thickness = 1

    local Title = Instance.new("TextLabel", Card)
    Title.Position = UDim2.new(0, 12, 0, 8)
    Title.Size = UDim2.new(1, -65, 0, 16)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(240, 230, 255)
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Desc = Instance.new("TextLabel", Card)
    Desc.Position = UDim2.new(0, 12, 0, 26)
    Desc.Size = UDim2.new(1, -65, 0, 16)
    Desc.BackgroundTransparency = 1
    Desc.Font = Enum.Font.Gotham
    Desc.Text = descText
    Desc.TextColor3 = Color3.fromRGB(150, 135, 175)
    Desc.TextSize = 10
    Desc.TextXAlignment = Enum.TextXAlignment.Left

    local SwitchBG = Instance.new("Frame", Card)
    SwitchBG.Position = UDim2.new(1, -44, 0.5, -10)
    SwitchBG.Size = UDim2.new(0, 34, 0, 20)
    SwitchBG.BackgroundColor3 = Color3.fromRGB(45, 35, 62)
    Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", SwitchBG)
    Knob.Position = UDim2.new(0, 2, 0.5, -7)
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.BackgroundColor3 = Color3.fromRGB(170, 160, 190)
    Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = false
    Card.MouseButton1Click:Connect(function()
        state = not state
        if state then
            SwitchBG.BackgroundColor3 = Color3.fromRGB(160, 60, 255)
            Knob.Position = UDim2.new(1, -16, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Stroke.Color = Color3.fromRGB(150, 70, 255)
        else
            SwitchBG.BackgroundColor3 = Color3.fromRGB(45, 35, 62)
            Knob.Position = UDim2.new(0, 2, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(170, 160, 190)
            Stroke.Color = Color3.fromRGB(60, 45, 85)
        end
    end)

    return function() return state end
end

local isTrajectoryOn = CreateToggleCard(Content, 15, "Ball Trajectory ESP", "Яркая фиолетовая линия полёта мяча")
local isChamsOn = CreateToggleCard(Content, 75, "Ball Chams (Highlight)", "Фиолетовая подсветка мяча сквозь стены")

-- Статус мяча
local StatusLabel = Instance.new("TextLabel", Content)
StatusLabel.Position = UDim2.new(0, 12, 1, -28)
StatusLabel.Size = UDim2.new(1, -24, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Text = "Статус: Поиск мяча..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 140, 180)
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Функция поиска мяча
local function findBall()
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("BasePart") then
            local n = child.Name:lower()
            if n:find("ball") or n == "football" or n == "soccerball" then
                return child
            end
        end
    end
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("BasePart") then
            local n = desc.Name:lower()
            if (n:find("ball") or n == "football" or n == "soccerball") and not desc:IsDescendantOf(LocalPlayer.Character) then
                if desc.Parent and not desc.Parent:FindFirstChildOfClass("Humanoid") then
                    return desc
                end
            end
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, item in ipairs(player.Character:GetChildren()) do
                if item:IsA("BasePart") then
                    local n = item.Name:lower()
                    if n:find("ball") or n == "football" then
                        return item
                    end
                end
            end
        end
    end
    return nil
end

local currentBall = nil

-- Цикл отрисовки
RunService.Heartbeat:Connect(function()
    local ball = findBall()

    if ball then
        StatusLabel.Text = "Статус: Мяч найден [" .. ball.Name .. "]"
        StatusLabel.TextColor3 = Color3.fromRGB(120, 255, 170)

        if ball ~= currentBall then
            if currentBall then
                local oldTrail = currentBall:FindFirstChild("NovaTrail")
                if oldTrail then oldTrail:Destroy() end
                local oldHl = currentBall:FindFirstChild("NovaHighlight")
                if oldHl then oldHl:Destroy() end
            end
            currentBall = ball
        end

        -- Траектория
        if isTrajectoryOn() then
            if not ball:FindFirstChild("NovaTrail") then
                local att0 = ball:FindFirstChild("NovaAtt0") or Instance.new("Attachment", ball)
                att0.Name = "NovaAtt0"

                local att1 = ball:FindFirstChild("NovaAtt1") or Instance.new("Attachment", ball)
                att1.Name = "NovaAtt1"
                att1.Position = Vector3.new(0, 0, -0.6)

                local trail = Instance.new("Trail")
                trail.Name = "NovaTrail"
                trail.Attachment0 = att0
                trail.Attachment1 = att1
                trail.Lifetime = 1.6
                trail.WidthScale = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 2.4),
                    NumberSequenceKeypoint.new(1, 0.05)
                })
                trail.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(210, 80, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 0, 230))
                })
                trail.LightEmission = 1
                trail.LightInfluence = 0
                trail.FaceCamera = true
                trail.Parent = ball
            end
        else
            local trail = ball:FindFirstChild("NovaTrail")
            if trail then trail:Destroy() end
        end

        -- Подсветка (Chams)
        if isChamsOn() then
            if not ball:FindFirstChild("NovaHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "NovaHighlight"
                hl.Adornee = ball
                hl.FillColor = Color3.fromRGB(160, 50, 255)
                hl.FillTransparency = 0.35
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = ball
            end
        else
            local hl = ball:FindFirstChild("NovaHighlight")
            if hl then hl:Destroy() end
        end
    else
        StatusLabel.Text = "Статус: Ожидание появления мяча..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 140, 140)
    end
end)
