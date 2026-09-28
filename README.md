local Services = {
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players")
}

-- Элементы интерфейса
AutoButtonColor = false 
TabButton.Font = Enum.Font.GothamMedium 
TabButton.Text = "Ball Trajectory" 
TabButton.TextColor3 = Color3.fromRGB(180, 180, 180) 
TabButton.TextSize = 11

local TabCorner = Instance.new("UICorner") 
TabCorner.CornerRadius = UDim.new(0, 6) 
TabCorner.Parent = TabButton

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

local trajectoryEnabled = false

Checkbox.MouseButton1Click:Connect(function() 
    trajectoryEnabled = not trajectoryEnabled 
    if trajectoryEnabled then 
        Checkbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    else 
        Checkbox.BackgroundColor3 = Color3.fromRGB(25, 25, 32) 
    end 
end)

-- Глобальный поиск мяча по всему Workspace
local function findBall() 
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do 
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "ball") or obj.Name == "Football" or obj.Name == "SoccerBall") then 
            return obj 
        end 
    end 
    return nil 
end

-- Создание визуализации (Beam и Attachments)
local beamFolder = Instance.new("Folder")
beamFolder.Name = "TrajectoryFolder"
beamFolder.Parent = Services.Workspace

local att0 = Instance.new("Attachment", beamFolder)
local att1 = Instance.new("Attachment", beamFolder)

local beam = Instance.new("Beam")
beam.Attachment0 = att0
beam.Attachment1 = att1
beam.Width0 = 0.5
beam.Width1 = 0.5
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

    if ball and ball.AssemblyLinearVelocity.Magnitude > 2 then 
        local startPos = ball.Position 
        local velocity = ball.AssemblyLinearVelocity 
        
        -- Простой расчет траектории с учетом гравитации
        local timeToTarget = 1.2
        local predictedPos = startPos + (velocity * timeToTarget) + Vector3.new(0, -0.5 * Services.Workspace.Gravity * (timeToTarget ^ 2), 0) 

        att0.WorldPosition = startPos
        att1.WorldPosition = predictedPos
        beam.Enabled = true
    else
        beam.Enabled = false
    end 
end)
