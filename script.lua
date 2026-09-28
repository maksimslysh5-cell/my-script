--[[
    Project Nova | Football Trajectory & Ball ESP
    Designed specifically for Delta Executor
--]]

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    TweenService = game:GetService("TweenService")
}

local LocalPlayer = Services.Players.LocalPlayer

-- Безопасный контейнер UI для Delta
local ParentContainer = (gethui and gethui()) or (syn and syn.protect_gui and syn.protect_gui(Instance.new("ScreenGui"))) or LocalPlayer:WaitForChild("PlayerGui")

if ParentContainer:FindFirstChild("ProjectNova_BallUI") then
    ParentContainer:FindFirstChild("ProjectNova_BallUI"):Destroy()
end

-- Основной ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectNova_BallUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentContainer

-- Компактное окно (уменьшенный размер)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 190)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -95)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Thickness = 1

-- Верхняя панель (Header)
local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Position = UDim2.new(0, 12, 0, 8)
TitleLabel.Size = UDim2.new(0, 200, 0, 20)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Project Nova | Ball Tracker"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Вкладка Trajectory (Toggle 1)
local TrailToggle = Instance.new("TextButton", MainFrame)
TrailToggle.Position = UDim2.new(0, 12, 0, 38)
TrailToggle.Size = UDim2.new(1, -24, 0, 32)
TrailToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
TrailToggle.Font = Enum.Font.GothamMedium
TrailToggle.Text = "  Enable Ball Trail"
TrailToggle.TextColor3 = Color3.fromRGB(200, 200, 210)
TrailToggle.TextSize = 11
TrailToggle.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", TrailToggle).CornerRadius = UDim.new(0, 6)

local TrailCheck = Instance.new("Frame", TrailToggle)
TrailCheck.Position = UDim2.new(1, -26, 0.5, -8)
TrailCheck.Size = UDim2.new(0, 16, 0, 16)
TrailCheck.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Instance.new("UICorner", TrailCheck).CornerRadius = UDim.new(0, 4)

-- Вкладка Chams (Toggle 2)
local ChamsToggle = Instance.new("TextButton", MainFrame)
ChamsToggle.Position = UDim2.new(0, 12, 0, 76)
ChamsToggle.Size = UDim2.new(1, -24, 0, 32)
ChamsToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
ChamsToggle.Font = Enum.Font.GothamMedium
ChamsToggle.Text = "  Enable Ball Chams (Highlight)"
ChamsToggle.TextColor3 = Color3.fromRGB(200, 200, 210)
ChamsToggle.TextSize = 11
ChamsToggle.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", ChamsToggle).CornerRadius = UDim.new(0, 6)

local ChamsCheck = Instance.new("Frame", ChamsToggle)
ChamsCheck.Position = UDim2.new(1, -26, 0.5, -8)
ChamsCheck.Size = UDim2.new(0, 16, 0, 16)
ChamsCheck.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Instance.new("UICorner", ChamsCheck).CornerRadius = UDim.new(0, 4)

-- Кнопка Re-detect Ball
local RedetectBtn = Instance.new("TextButton", MainFrame)
RedetectBtn.Position = UDim2.new(0, 12, 0, 114)
RedetectBtn.Size = UDim2.new(1, -24, 0, 32)
RedetectBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
RedetectBtn.Font = Enum.Font.GothamBold
RedetectBtn.Text = "Re-detect Ball"
RedetectBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
RedetectBtn.TextSize = 11
Instance.new("UICorner", RedetectBtn).CornerRadius = UDim.new(0, 6)

-- Копирайт
local FootNote = Instance.new("TextLabel", MainFrame)
FootNote.Position = UDim2.new(0, 12, 0, 155)
FootNote.Size = UDim2.new(1, -24, 0, 20)
FootNote.BackgroundTransparency = 1
FootNote.Font = Enum.Font.Gotham
FootNote.Text = "Status: Ready | Blue Lock: Rivals"
FootNote.TextColor3 = Color3.fromRGB(120, 120, 140)
FootNote.TextSize = 9

-- ==========================================================
-- ЛОГИКА МЯЧА, TRAIL И CHAMS
-- ==========================================================
local TrailEnabled = false
local ChamsEnabled = false

local currentBall = nil
local currentTrail = nil
local currentHighlight = nil
local att0, att1 = nil, nil

local function IsBallPart(part)
    if not part or not part:IsA("BasePart") then return false end
    local n = string.lower(part.Name)
    local keywords = {"ball", "soccer", "football", "sphere", "matchball"}
    for _, kw in ipairs(keywords) do
        if n:find(kw) then return true end
    end
    return false
end

local function FindBall()
    for _, desc in ipairs(Services.Workspace:GetDescendants()) do
        if IsBallPart(desc) then
            return desc
        end
    end
    return nil
end

local function RemoveEffects()
    if currentTrail then currentTrail:Destroy() currentTrail = nil end
    if currentHighlight then currentHighlight:Destroy() currentHighlight = nil end
    if att0 then att0:Destroy() att0 = nil end
    if att1 then att1:Destroy() att1 = nil end
end

local function ApplyEffects(ball)
    RemoveEffects()
    if not ball then return end

    if TrailEnabled then
        att0 = Instance.new("Attachment", ball)
        att0.Position = Vector3.new(0, 0, 0)
        att1 = Instance.new("Attachment", ball)
        att1.Position = Vector3.new(0, 0, -1)

        local trail = Instance.new("Trail", ball)
        trail.Name = "NovaTrail"
        trail.Attachment0 = att0
        trail.Attachment1 = att1
        trail.Lifetime = 1.0
        trail.WidthScale = NumberSequence.new(1.2)
        trail.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150))
        trail.FaceCamera = true
        currentTrail = trail
    end

    if ChamsEnabled then
        local hl = Instance.new("Highlight")
        hl.Name = "NovaChams"
        hl.Adornee = ball
        hl.FillColor = Color3.fromRGB(160, 32, 240)
        hl.FillTransparency = 0.3
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.Parent = ball
        currentHighlight = hl
    end
end

-- События кнопок
TrailToggle.MouseButton1Click:Connect(function()
    TrailEnabled = not TrailEnabled
    Services.TweenService:Create(TrailCheck, TweenInfo.new(0.15), {
        BackgroundColor3 = TrailEnabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(40, 40, 50)
    }):Play()
    if currentBall then ApplyEffects(currentBall) end
end)

ChamsToggle.MouseButton1Click:Connect(function()
    ChamsEnabled = not ChamsEnabled
    Services.TweenService:Create(ChamsCheck, TweenInfo.new(0.15), {
        BackgroundColor3 = ChamsEnabled and Color3.fromRGB(160, 32, 240) or Color3.fromRGB(40, 40, 50)
    }):Play()
    if currentBall me then ApplyEffects(currentBall) end
end)

RedetectBtn.MouseButton1Click:Connect(function()
    currentBall = FindBall()
    if currentBall then
        ApplyEffects(currentBall)
        FootNote.Text = "Status: Ball Connected (" .. currentBall.Name .. ")"
        FootNote.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        FootNote.Text = "Status: Ball Not Found!"
        FootNote.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

-- Автопоиск при изменении объекта мяча
task.spawn(function()
    while task.wait(1) do
        local ball = FindBall()
        if ball and ball ~= currentBall then
            currentBall = ball
            ApplyEffects(ball)
            FootNote.Text = "Status: Ball Connected (" .. ball.Name .. ")"
            FootNote.TextColor3 = Color3.fromRGB(0, 255, 150)
        end
    end
end)
