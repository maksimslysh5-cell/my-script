-- Delta Executor Compatible Script for Blue Lock: Rivals

local Services = {
Workspace = game:GetService("Workspace"),
RunService = game:GetService("RunService"),
Players = game:GetService("Players"),
CoreGui = game:GetService("CoreGui")
}

-- Создаем интерфейс безопасно для Delta
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaTrajectoryUI"
ScreenGui.ResetOnSpawn = false

if gethui then
ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
syn.protect_gui(ScreenGui)
ScreenGui.Parent = Services.CoreGui
elseif Services.CoreGui:FindFirstChild("RobloxGui") then
ScreenGui.Parent = Services.CoreGui
else
ScreenGui.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 180)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 10)
TitleLabel.Size = UDim2.new(1, -30, 0, 20)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "BL: Rivals Trajectory"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Панель с контентом
local RightContent = Instance.new("Frame")
RightContent.Parent = MainFrame
RightContent.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
RightContent.BorderSizePixel = 0
RightContent.Position = UDim2.new(0, 15, 0, 40)
RightContent.Size = UDim2.new(1, -30, 1, -55)

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 6)
ContentCorner.Parent = RightContent

local ContentTitle = Instance.new("TextLabel")
ContentTitle.Parent = RightContent
ContentTitle.BackgroundTransparency = 1
ContentTitle.Position = UDim2.new(0, 15, 0, 15)
ContentTitle.Size = UDim2.new(0, 150, 0, 20)
ContentTitle.Font = Enum.Font.GothamBold
ContentTitle.Text = "Trajectory ESP"
ContentTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
ContentTitle.TextSize = 13
ContentTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Чекбокс
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

local trajectoryEnabled = false

Checkbox.MouseButton1Click:Connect(function()
trajectoryEnabled = not trajectoryEnabled
if trajectoryEnabled then
Checkbox.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
else
Checkbox.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
end
end)

-- Поиск мяча по всему Workspace
local function findBall()
for _, obj in ipairs(Services.Workspace:GetDescendants()) do
if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "ball") or obj.Name == "Football" or obj.Name == "SoccerBall") then
return obj
end
end
return nil
end

-- Отрисовка луча траектории
local beamFolder = Instance.new("Folder")
beamFolder.Name = "TrajectoryFolder"
beamFolder.Parent = Services.Workspace

local att0 = Instance.new("Attachment", beamFolder)
local att1 = Instance.new("Attachment", beamFolder)

local beam = Instance.new("Beam")
beam.Attachment0 = att0
beam.Attachment1 = att1
beam.Width0 = 0.8
beam.Width1 = 0.8
beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150))
beam.FaceCamera = true
beam.Parent = beamFolder
beam.Enabled = false

Services.RunService.RenderStepped:Connect(function()
if not trajectoryEnabled then
beam.Enabled = false
return
end

local ball = findBall()

if ball and ball.AssemblyLinearVelocity.Magnitude > 1 then
    local startPos = ball.Position
    local velocity = ball.AssemblyLinearVelocity
    
    local timeToTarget = 1.0
    local predictedPos = startPos + (velocity * timeToTarget) + Vector3.new(0, -0.5 * Services.Workspace.Gravity * (timeToTarget ^ 2), 0)

    att0.WorldPosition = startPos
    att1.WorldPosition = predictedPos
    beam.Enabled = true
else
    beam.Enabled = false
end


end)
