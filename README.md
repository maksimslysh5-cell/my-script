--[[
    Project Nova | Ball Tracker (Delta Optimized)
    Game: Blue Lock: Rivals
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Безопасное удаление старого UI
if PlayerGui:FindFirstChild("NovaBallTracker") then
    PlayerGui.NovaBallTracker:Destroy()
end

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NovaBallTracker"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Главное меню (Компактное)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 280, 0, 160)
Main.Position = UDim2.new(0.5, -140, 0.4, -80)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 8)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(50, 50, 70)
Stroke.Thickness = 1.5

-- Шапка
local Title = Instance.new("TextLabel", Main)
Title.Position = UDim2.new(0, 12, 0, 8)
Title.Size = UDim2.new(0, 200, 0, 20)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Project Nova | Ball Tracker"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка 1: Trail
local TrailBtn = Instance.new("TextButton", Main)
TrailBtn.Position = UDim2.new(0, 12, 0, 36)
TrailBtn.Size = UDim2.new(1, -24, 0, 30)
TrailBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TrailBtn.Font = Enum.Font.GothamMedium
TrailBtn.Text = "Ball Trail [OFF]"
TrailBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
TrailBtn.TextSize = 11
Instance.new("UICorner", TrailBtn).CornerRadius = UDim.new(0, 6)

-- Кнопка 2: Highlight / Chams
local ChamsBtn = Instance.new("TextButton", Main)
ChamsBtn.Position = UDim2.new(0, 12, 0, 72)
ChamsBtn.Size = UDim2.new(1, -24, 0, 30)
ChamsBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ChamsBtn.Font = Enum.Font.GothamMedium
ChamsBtn.Text = "Ball Chams [OFF]"
ChamsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ChamsBtn.TextSize = 11
Instance.new("UICorner", ChamsBtn).CornerRadius = UDim.new(0, 6)

-- Информационная строка
local Status = Instance.new("TextLabel", Main)
Status.Position = UDim2.new(0, 12, 0, 112)
Status.Size = UDim2.new(1, -24, 0, 30)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.Gotham
Status.Text = "Status: Loaded"
Status.TextColor3 = Color3.fromRGB(0, 255, 150)
Status.TextSize = 10

-- Логика функционала
local trailOn = false
local chamsOn = false
local currentBall = nil
local activeTrail = nil
local activeHighlight = nil

local function GetBall()
    for _, item in ipairs(Workspace:GetChildren()) do
        if item:IsA("BasePart") and (item.Name:lower():find("ball") or item.Name == "Football") then
            return item
        end
    end
    return nil
end

local function UpdateEffects()
    if activeTrail then activeTrail:Destroy() activeTrail = nil end
    if activeHighlight then activeHighlight:Destroy() activeHighlight = nil end

    currentBall = GetBall()
    if not currentBall then
        Status.Text = "Status: Ball not found"
        Status.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    Status.Text = "Status: Ball Found (" .. currentBall.Name .. ")"
    Status.TextColor3 = Color3.fromRGB(0, 255, 150)

    if trailOn then
        local a0 = Instance.new("Attachment", currentBall)
        local a1 = Instance.new("Attachment", currentBall)
        a1.Position = Vector3.new(0, 0, -0.5)

        local tr = Instance.new("Trail", currentBall)
        tr.Attachment0 = a0
        tr.Attachment1 = a1
        tr.Lifetime = 0.8
        tr.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150))
        tr.WidthScale = NumberSequence.new(1)
        activeTrail = tr
    end

    if chamsOn then
        local hl = Instance.new("Highlight", currentBall)
        hl.FillColor = Color3.fromRGB(160, 32, 240)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        activeHighlight = hl
    end
end

TrailBtn.MouseButton1Click:Connect(function()
    trailOn = not trailOn
    TrailBtn.Text = trailOn and "Ball Trail [ON]" or "Ball Trail [OFF]"
    TrailBtn.TextColor3 = trailOn and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
    UpdateEffects()
end)

ChamsBtn.MouseButton1Click:Connect(function()
    chamsOn = not chamsOn
    ChamsBtn.Text = chamsOn and "Ball Chams [ON]" or "Ball Chams [OFF]"
    ChamsBtn.TextColor3 = chamsOn and Color3.fromRGB(160, 32, 240) or Color3.fromRGB(200, 200, 200)
    UpdateEffects()
end)

-- Периодическая проверка наличия мяча
task.spawn(function()
    while task.wait(2) do
        if trailOn or chamsOn then
            UpdateEffects()
        end
    end
end)
