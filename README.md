--[[
    Project Nova | Football Trajectory Script (Weave Lib)
    Game: Blue Lock: Rivals
    Executor: Delta Executor Compatible
--]]

local Weave = loadstring(game:HttpGet("https://raw.githubusercontent.com/SvenaEE/Testlibary-/refs/heads/main/Weave-Release"))()

local Window = Weave:CreateWindow({
    Name = "Project Nova",
    LoadingSubtitle = "Ball Tracker v1",
    ConfigurationSaving = { Enabled = true, FolderName = "NovaConfig", FileName = "BL_Ball" },
    KeySystem = false,
    ToggleKey = Enum.KeyCode.RightShift
})

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace")
}

local LocalPlayer = Services.Players.LocalPlayer

-- Табы управления
local MainTab = Window:CreateTab("Ball Tracker")
local SettingsTab = Window:CreateTab("Settings")

-- ==========================================================
-- ПОИСК МЯЧА
-- ==========================================================
local BallFinder = {
    AutoDetect = true,
    CurrentBall = nil
}

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

-- ==========================================================
-- BALL TRAIL (СЛЕД И ТРАЕКТОРИЯ)
-- ==========================================================
local BallTrail = {
    Enabled = false,
    Color = Color3.fromRGB(0, 255, 150),
    Lifetime = 1.2,
    Width = 1.2
}

local currentTrail = nil
local att0, att1 = nil, nil

local function RemoveTrail()
    if currentTrail then currentTrail:Destroy() currentTrail = nil end
    if att0 then att0:Destroy() att0 = nil end
    if att1 then att1:Destroy() att1 = nil end
end

local function AttachBallTrail(ball)
    RemoveTrail()
    if not ball or not BallTrail.Enabled then return end

    att0 = Instance.new("Attachment", ball)
    att0.Position = Vector3.new(0, 0, 0)

    att1 = Instance.new("Attachment", ball)
    att1.Position = Vector3.new(0, 0, -1)

    local trail = Instance.new("Trail", ball)
    trail.Name = "NovaBallTrail"
    trail.Attachment0 = att0
    trail.Attachment1 = att1
    trail.Lifetime = BallTrail.Lifetime
    trail.WidthScale = NumberSequence.new(BallTrail.Width)
    trail.Color = ColorSequence.new(BallTrail.Color)
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.FaceCamera = true
    currentTrail = trail
end

-- ==========================================================
-- BALL CHAMS (ПОДСВЕТКА МЯЧА)
-- ==========================================================
local BallChams = {
    Enabled = false,
    Color = Color3.fromRGB(160, 32, 240)
}

local currentHighlight = nil

local function RemoveChams()
    if currentHighlight then currentHighlight:Destroy() currentHighlight = nil end
end

local function AttachBallChams(ball)
    RemoveChams()
    if not ball or not BallChams.Enabled then return end

    local hl = Instance.new("Highlight")
    hl.Name = "NovaBallChams"
    hl.Adornee = ball
    hl.FillColor = BallChams.Color
    hl.FillTransparency = 0.4
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0
    hl.Parent = ball
    currentHighlight = hl
end

-- ==========================================================
-- ЭЛЕМЕНТЫ ИНТЕРФЕЙСА (WEAVE UI)
-- ==========================================================

MainTab:CreateToggle({
    Name = "Enable Ball Trail",
    CurrentValue = false,
    Callback = function(Value)
        BallTrail.Enabled = Value
        if BallFinder.CurrentBall then
            if Value then AttachBallTrail(BallFinder.CurrentBall) else RemoveTrail() end
        end
    end,
})

MainTab:CreateColorPicker({
    Name = "Trail Color",
    Color = BallTrail.Color,
    Callback = function(Value)
        BallTrail.Color = Value
        if currentTrail then
            currentTrail.Color = ColorSequence.new(Value)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Enable Ball Chams",
    CurrentValue = false,
    Callback = function(Value)
        BallChams.Enabled = Value
        if BallFinder.CurrentBall then
            if Value then AttachBallChams(BallFinder.CurrentBall) else RemoveChams() end
        end
    end,
})

MainTab:CreateColorPicker({
    Name = "Chams Color",
    Color = BallChams.Color,
    Callback = function(Value)
        BallChams.Color = Value
        if currentHighlight then
            currentHighlight.FillColor = Value
        end
    end,
})

SettingsTab:CreateButton({
    Name = "Re-detect Ball",
    Callback = function()
        BallFinder.CurrentBall = FindBall()
        if BallFinder.CurrentBall then
            if BallTrail.Enabled then AttachBallTrail(BallFinder.CurrentBall) end
            if BallChams.Enabled then AttachBallChams(BallFinder.CurrentBall) end
            Weave:Notify({Title = "Success", Content = "Ball Found: " .. BallFinder.CurrentBall.Name, Duration = 3})
        else
            Weave:Notify({Title = "Error", Content = "Ball not found!", Duration = 3})
        end
    end,
})

-- Цикл автоматического прикрепления при изменении мяча
task.spawn(function()
    while task.wait(1) do
        local ball = FindBall()
        if ball and ball ~= BallFinder.CurrentBall then
            BallFinder.CurrentBall = ball
            if BallTrail.Enabled then AttachBallTrail(ball) end
            if BallChams.Enabled then AttachBallChams(ball) end
        end
    end
end)
