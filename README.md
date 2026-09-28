--[[\
    Project Nova - Blue Lock: Rivals (Ball Trajectory Script)
    Created for Delta Executor
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Защита от повторного запуска
if CoreGui:FindFirstChild("ProjectNovaUI") then
    CoreGui.ProjectNovaUI:Destroy()
end

-- Создание главного контейнера GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectNovaUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главное окно меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
MainFrame.Size = UDim2.new(0, 450, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true

-- Скругление углов главного меню
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Верхняя панель (Header)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1, 0, 0, 35)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Parent = Header
HeaderFix.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
HeaderFix.BorderSizePixel = 0
HeaderFix.Position = UDim2.new(0, 0, 1, -5)
HeaderFix.Size = UDim2.new(1, 0, 0, 5)

-- Название сверху: Project Nova + фиолетовая звезда
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Header
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "★ Project Nova"
TitleLabel.TextColor3 = Color3.fromRGB(168, 85, 247)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопки управления (Минус и Крестик)
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = Header
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseButton.TextSize = 18

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Parent = Header
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(150, 150, 150)
MinimizeButton.TextSize = 18

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child ~= Header and child ~= UICorner then
            child.Visible = not isMinimized
        end
    end
    MainFrame.Size = isMinimized and UDim2.new(0, 450, 0, 35) or UDim2.new(0, 450, 0, 280)
end)

-- Левая панель
local LeftPanel = Instance.new("Frame")
LeftPanel.Parent = MainFrame
LeftPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
LeftPanel.BorderSizePixel = 0
LeftPanel.Position = UDim2.new(0, 0, 0, 35)
LeftPanel.Size = UDim2.new(0, 115, 1, -35)

-- Кнопка вкладки
local TabButton = Instance.new("TextButton")
TabButton.Parent = LeftPanel
TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TabButton.BorderSizePixel = 0
TabButton.Position = UDim2.new(0, 8, 0, 10)
TabButton.Size = UDim2.new(0, 99, 0, 32)
TabButton.AutoButtonColor = false
TabButton.Font = Enum.Font.GothamMedium
TabButton.Text = "Ball Trajectory"
TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
TabButton.TextSize = 11

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 6)
TabCorner.Parent = TabButton

-- Правая большая вкладка (~75%)
local RightContent = Instance.new("Frame")
RightContent.Parent = MainFrame
RightContent.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
RightContent.BorderSizePixel = 0
RightContent.Position = UDim2.new(0, 115, 0, 35)
RightContent.Size = UDim2.new(1, -115, 1, -35)

local ContentTitle = Instance.new("TextLabel")
ContentTitle.Parent = RightContent
ContentTitle.BackgroundTransparency = 1
ContentTitle.Position = UDim2.new(0, 15, 0, 15)
ContentTitle.Size = UDim2.new(0, 200, 0, 20)
ContentTitle.Font = Enum.Font.GothamBold
ContentTitle.Text = "Ball Trajectory Esp"
ContentTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
ContentTitle.TextSize = 13
ContentTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Чекбокс включения функции
local Checkbox = Instance.new("TextButton")
Checkbox.Parent = RightContent
Checkbox.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Checkbox.BorderColor3 = Color3.fromRGB(70, 70, 85)
Checkbox.BorderSizePixel = 1
Checkbox.Position = UDim2.new(1, -35, 0, 15)
Checkbox.Size = UDim2.new(0, 20, 0, 20)
Checkbox.AutoButtonColor = false
Checkbox.Text = ""

local CheckboxCorner = Instance.new("UICorner")
CheckboxCorner.CornerRadius = UDim.new(0, 4)
CheckboxCorner.Parent = Checkbox

-- Анимация зажатия левой кнопки
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

-- Логика переключения чекбокса
local trajectoryEnabled = false

Checkbox.MouseButton1Click:Connect(function()
    trajectoryEnabled = not trajectoryEnabled
    if trajectoryEnabled then
        Checkbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    else
        Checkbox.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    end
end)

-- Логика визуализации траектории мяча
RunService.RenderStepped:Connect(function()
    if not trajectoryEnabled then return end
    -- Основной функционал расчета траектории и отображения метром
end)
