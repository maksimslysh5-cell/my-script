--[[
    Blue Lock: Rivals - Ball Trajectory ESP Script
    Credits: maksimslysh5-cell
    Executor: Delta Mobile / Universal
--]]

local Services = {
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService")
}

local LocalPlayer = Services.Players.LocalPlayer
local UserId = LocalPlayer and LocalPlayer.UserId or 1

-- Защищенный контейнер интерфейса для Delta
local ParentContainer = (gethui and gethui()) or (syn and syn.protect_gui and syn.protect_gui(Instance.new("ScreenGui"))) or Services.Players.LocalPlayer:WaitForChild("PlayerGui")

if ParentContainer:FindFirstChild("BlueLock_Trajectory_UI") then
    ParentContainer:FindFirstChild("BlueLock_Trajectory_UI"):Destroy()
end

-- Палитра тем
local Themes = {
    BlackPurple = {
        MainBG = Color3.fromRGB(15, 15, 19),
        LeftBG = Color3.fromRGB(10, 10, 14),
        CardBG = Color3.fromRGB(25, 25, 32),
        Accent = Color3.fromRGB(160, 32, 240),
        TextPrimary = Color3.fromRGB(220, 220, 220),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(70, 70, 85)
    },
    WhiteOrangeRed = {
        MainBG = Color3.fromRGB(240, 240, 245),
        LeftBG = Color3.fromRGB(220, 220, 228),
        CardBG = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(255, 68, 0),
        TextPrimary = Color3.fromRGB(25, 25, 30),
        TextSecondary = Color3.fromRGB(200, 50, 0),
        Border = Color3.fromRGB(210, 210, 220)
    }
}

local CurrentTheme = Themes.BlackPurple

-- Основной ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlueLock_Trajectory_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentContainer

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
MainFrame.BackgroundColor3 = CurrentTheme.MainBG
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Левая панель с профилем
local LeftPanel = Instance.new("Frame", MainFrame)
LeftPanel.Size = UDim2.new(0, 115, 1, 0)
LeftPanel.BackgroundColor3 = CurrentTheme.LeftBG
LeftPanel.BorderSizePixel = 0

-- Круглая аватарка
local AvatarImage = Instance.new("ImageLabel", LeftPanel)
AvatarImage.Size = UDim2.new(0, 44, 0, 44)
AvatarImage.Position = UDim2.new(0.5, -22, 0, 12)
AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. UserId .. "&w=150&h=150"
AvatarImage.BackgroundTransparency = 1

local AvatarCorner = Instance.new("UICorner", AvatarImage)
AvatarCorner.CornerRadius = UDim.new(1, 0)

local AvatarStroke = Instance.new("UIStroke", AvatarImage)
AvatarStroke.Color = CurrentTheme.Accent
AvatarStroke.Thickness = 2

-- Никнейм
local UserLabel = Instance.new("TextLabel", LeftPanel)
UserLabel.Size = UDim2.new(1, -10, 0, 16)
UserLabel.Position = UDim2.new(0, 5, 0, 60)
UserLabel.BackgroundTransparency = 1
UserLabel.Font = Enum.Font.GothamBold
UserLabel.Text = LocalPlayer.Name
UserLabel.TextColor3 = CurrentTheme.TextPrimary
UserLabel.TextSize = 10
UserLabel.TextTruncate = Enum.TextTruncate.AtEnd

-- Кредиты
local CreditLabel = Instance.new("TextLabel", LeftPanel)
CreditLabel.Size = UDim2.new(1, -10, 0, 12)
CreditLabel.Position = UDim2.new(0, 5, 0, 76)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Font = Enum.Font.Gotham
CreditLabel.Text = "by " .. LocalPlayer.Name
CreditLabel.TextColor3 = CurrentTheme.TextSecondary
CreditLabel.TextSize = 8

-- Кнопка переключения вкладки Trajectory
local TabButton = Instance.new("TextButton", LeftPanel)
TabButton.Size = UDim2.new(0, 99, 0, 32)
TabButton.Position = UDim2.new(0, 8, 0, 98)
TabButton.BackgroundColor3 = CurrentTheme.CardBG
TabButton.AutoButtonColor = false
TabButton.Font = Enum.Font.GothamMedium
TabButton.Text = "Ball Trajectory"
TabButton.TextColor3 = CurrentTheme.TextPrimary
TabButton.TextSize = 10

local TabCorner = Instance.new("UICorner", TabButton)
TabCorner.CornerRadius = UDim.new(0, 6)

-- Кнопка настройки
local SettingsTabBtn = Instance.new("TextButton", LeftPanel)
SettingsTabBtn.Size = UDim2.new(0, 99, 0, 32)
SettingsTabBtn.Position = UDim2.new(0, 8, 0, 136)
SettingsTabBtn.BackgroundColor3 = CurrentTheme.CardBG
SettingsTabBtn.AutoButtonColor = false
SettingsTabBtn.Font = Enum.Font.GothamMedium
SettingsTabBtn.Text = "Settings"
SettingsTabBtn.TextColor3 = CurrentTheme.TextSecondary
SettingsTabBtn.TextSize = 10

local SettingsCorner = Instance.new("UICorner", SettingsTabBtn)
SettingsCorner.CornerRadius = UDim.new(0, 6)

-- Анимация левых кнопок
local function setupButtonAnimation(btn)
    btn.MouseButton1Down:Connect(function()
        Services.TweenService:Create(btn, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 103, 0, 34),
            Position = btn.Position - UDim2.new(0, 2, 0, 1)
        }):Play()
    end)

    btn.MouseButton1Up:Connect(function()
        Services.TweenService:Create(btn, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 99, 0, 32),
            Position = btn.Position + UDim2.new(0, 2, 0, 1)
        }):Play()
    end)
end

setupButtonAnimation(TabButton)
setupButtonAnimation(SettingsTabBtn)

-- Правая часть (Контент)
local RightContent = Instance.new("Frame", MainFrame)
RightContent.BackgroundColor3 = CurrentTheme.MainBG
RightContent.BorderSizePixel = 0
RightContent.Position = UDim2.new(0, 115, 0, 0)
RightContent.Size = UDim2.new(1, -115, 1, 0)

-- Страница Trajectory
local TrajectoryPage = Instance.new("Frame", RightContent)
TrajectoryPage.Size = UDim2.new(1, 0, 1, 0)
TrajectoryPage.BackgroundTransparency = 1

local ContentTitle = Instance.new("TextLabel", TrajectoryPage)
ContentTitle.BackgroundTransparency = 1
ContentTitle.Position = UDim2.new(0, 15, 0, 15)
ContentTitle.Size = UDim2.new(0, 200, 0, 20)
ContentTitle.Font = Enum.Font.GothamBold
ContentTitle.Text = "Ball Trajectory Esp"
ContentTitle.TextColor3 = CurrentTheme.TextPrimary
ContentTitle.TextSize = 13
ContentTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Чекбокс включения функции
local CheckboxLabel = Instance.new("TextLabel", TrajectoryPage)
CheckboxLabel.Position = UDim2.new(0, 15, 0, 48)
CheckboxLabel.Size = UDim2.new(0, 150, 0, 20)
CheckboxLabel.BackgroundTransparency = 1
CheckboxLabel.Font = Enum.Font.Gotham
CheckboxLabel.Text = "Enable ESP"
CheckboxLabel.TextColor3 = CurrentTheme.TextPrimary
CheckboxLabel.TextSize = 11
CheckboxLabel.TextXAlignment = Enum.TextXAlignment.Left

local Checkbox = Instance.new("TextButton", TrajectoryPage)
Checkbox.BackgroundColor3 = CurrentTheme.CardBG
Checkbox.BorderColor3 = CurrentTheme.Border
Checkbox.BorderSizePixel = 1
Checkbox.Position = UDim2.new(1, -35, 0, 48)
Checkbox.Size = UDim2.new(0, 20, 0, 20)
Checkbox.AutoButtonColor = false
Checkbox.Text = ""

local CheckboxCorner = Instance.new("UICorner", Checkbox)
CheckboxCorner.CornerRadius = UDim.new(0, 4)

-- Переключатель цвета следа
local ColorPickerLabel = Instance.new("TextLabel", TrajectoryPage)
ColorPickerLabel.Position = UDim2.new(0, 15, 0, 80)
ColorPickerLabel.Size = UDim2.new(0, 150, 0, 20)
ColorPickerLabel.BackgroundTransparency = 1
ColorPickerLabel.Font = Enum.Font.Gotham
ColorPickerLabel.Text = "Trajectory Color"
ColorPickerLabel.TextColor3 = CurrentTheme.TextPrimary
ColorPickerLabel.TextSize = 11
ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left

local ColorPreview = Instance.new("TextButton", TrajectoryPage)
ColorPreview.Position = UDim2.new(1, -35, 0, 80)
ColorPreview.Size = UDim2.new(0, 20, 0, 20)
ColorPreview.BackgroundColor3 = CurrentTheme.Accent
ColorPreview.AutoButtonColor = false
ColorPreview.Text = ""
Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 4)

-- Страница Настроек (Settings)
local SettingsPage = Instance.new("Frame", RightContent)
SettingsPage.Size = UDim2.new(1, 0, 1, 0)
SettingsPage.BackgroundTransparency = 1
SettingsPage.Visible = false

local ThemeToggleBtn = Instance.new("TextButton", SettingsPage)
ThemeToggleBtn.Position = UDim2.new(0, 15, 0, 48)
ThemeToggleBtn.Size = UDim2.new(1, -30, 0, 32)
ThemeToggleBtn.BackgroundColor3 = CurrentTheme.CardBG
ThemeToggleBtn.Font = Enum.Font.GothamMedium
ThemeToggleBtn.Text = "Theme: Black / Purple"
ThemeToggleBtn.TextColor3 = CurrentTheme.TextPrimary
ThemeToggleBtn.TextSize = 11
Instance.new("UICorner", ThemeToggleBtn).CornerRadius = UDim.new(0, 6)

-- Навигация по страницам
TabButton.MouseButton1Click:Connect(function()
    TrajectoryPage.Visible = true
    SettingsPage.Visible = false
    TabButton.TextColor3 = CurrentTheme.TextPrimary
    SettingsTabBtn.TextColor3 = CurrentTheme.TextSecondary
end)

SettingsTabBtn.MouseButton1Click:Connect(function()
    TrajectoryPage.Visible = false
    SettingsPage.Visible = true
    SettingsTabBtn.TextColor3 = CurrentTheme.TextPrimary
    TabButton.TextColor3 = CurrentTheme.TextSecondary
end)

-- Переключение тем оформления
local isBlackTheme = true
ThemeToggleBtn.MouseButton1Click:Connect(function()
    isBlackTheme = not isBlackTheme
    CurrentTheme = isBlackTheme and Themes.BlackPurple or Themes.WhiteOrangeRed
    ThemeToggleBtn.Text = isBlackTheme and "Theme: Black / Purple" or "Theme: White / Orange-Red"

    Services.TweenService:Create(MainFrame, TweenInfo.new(0.25), {BackgroundColor3 = CurrentTheme.MainBG}):Play()
    Services.TweenService:Create(RightContent, TweenInfo.new(0.25), {BackgroundColor3 = CurrentTheme.MainBG}):Play()
    Services.TweenService:Create(LeftPanel, TweenInfo.new(0.25), {BackgroundColor3 = CurrentTheme.LeftBG}):Play()
    Services.TweenService:Create(AvatarStroke, TweenInfo.new(0.25), {Color = CurrentTheme.Accent}):Play()

    ContentTitle.TextColor3 = CurrentTheme.TextPrimary
    CheckboxLabel.TextColor3 = CurrentTheme.TextPrimary
    ColorPickerLabel.TextColor3 = CurrentTheme.TextPrimary
    UserLabel.TextColor3 = CurrentTheme.TextPrimary
    CreditLabel.TextColor3 = CurrentTheme.TextSecondary
    TabButton.BackgroundColor3 = CurrentTheme.CardBG
    SettingsTabBtn.BackgroundColor3 = CurrentTheme.CardBG
    ThemeToggleBtn.BackgroundColor3 = CurrentTheme.CardBG
end)

-- Логика траектории
local trajectoryEnabled = false
local currentTrailColor = Color3.fromRGB(160, 32, 240)

Checkbox.MouseButton1Click:Connect(function()
    trajectoryEnabled = not trajectoryEnabled
    Services.TweenService:Create(Checkbox, TweenInfo.new(0.15), {
        BackgroundColor3 = trajectoryEnabled and CurrentTheme.Accent or CurrentTheme.CardBG
    }):Play()
end)

ColorPreview.MouseButton1Click:Connect(function()
    if currentTrailColor == Color3.fromRGB(160, 32, 240) then
        currentTrailColor = Color3.fromRGB(0, 255, 150)
    elseif currentTrailColor == Color3.fromRGB(0, 255, 150) then
        currentTrailColor = Color3.fromRGB(255, 68, 0)
    else
        currentTrailColor = Color3.fromRGB(160, 32, 240)
    end
    ColorPreview.BackgroundColor3 = currentTrailColor
end)

-- Отрисовка траектории мяча (Beam)
local TrajectoryFolder = Instance.new("Folder", Services.Workspace)
TrajectoryFolder.Name = "Trajectory_Folder"

local Att0 = Instance.new("Attachment", TrajectoryFolder)
local Att1 = Instance.new("Attachment", TrajectoryFolder)

local Beam = Instance.new("Beam", TrajectoryFolder)
Beam.Attachment0 = Att0
Beam.Attachment1 = Att1
Beam.Width0 = 0.5
Beam.Width1 = 0.5
Beam.FaceCamera = true
Beam.Enabled = false

local function findBall()
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "ball") or obj.Name == "Football" or obj.Name == "SoccerBall") then
            return obj
        end
    end
    return nil
end

Services.RunService.RenderStepped:Connect(function()
    if not trajectoryEnabled then
        Beam.Enabled = false
        return
    end

    local ball = findBall()

    if ball and ball.AssemblyLinearVelocity.Magnitude > 2 then
        local startPos = ball.Position
        local velocity = ball.AssemblyLinearVelocity
        local gravity = Vector3.new(0, -Services.Workspace.Gravity, 0)
        local timeAhead = 1.0

        local predictedPos = startPos + (velocity * timeAhead) + (0.5 * gravity * (timeAhead ^ 2))

        Att0.WorldPosition = startPos
        Att1.WorldPosition = predictedPos
        Beam.Color = ColorSequence.new(currentTrailColor)
        Beam.Enabled = true
    else
        Beam.Enabled = false
    end
end)
