-- Roblox Aimbot Script with GUI
-- Features: Aimbot with visibility check, Triggerbot, Keybinds, Simple GUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Configuration
local Config = {
    AimbotEnabled = false,
    TriggerBotEnabled = false,
    VisibleCheck = true,
    Smoothness = 0.8,
    FovSize = 100,
    KeyBind = Enum.KeyCode.RightShift,
    TriggerKey = Enum.KeyCode.X
}

-- Variables
local AimbotConnection = nil
local TriggerBotConnection = nil
local CurrentTarget = nil
local MousePosition = Vector2.new(0, 0)

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGUI"
ScreenGui.Parent = PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 300)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Aimbot Settings"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Toggle Aimbot
local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Name = "AimbotToggle"
AimbotToggle.Size = UDim2.new(0, 200, 0, 30)
AimbotToggle.Position = UDim2.new(0, 50, 0, 40)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimbotToggle.BorderSizePixel = 1
AimbotToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
AimbotToggle.Text = "Aimbot: OFF"
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.TextScaled = true
AimbotToggle.Font = Enum.Font.SourceSans
AimbotToggle.Parent = MainFrame

-- Toggle TriggerBot
local TriggerBotToggle = Instance.new("TextButton")
TriggerBotToggle.Name = "TriggerBotToggle"
TriggerBotToggle.Size = UDim2.new(0, 200, 0, 30)
TriggerBotToggle.Position = UDim2.new(0, 50, 0, 80)
TriggerBotToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TriggerBotToggle.BorderSizePixel = 1
TriggerBotToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
TriggerBotToggle.Text = "TriggerBot: OFF"
TriggerBotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
TriggerBotToggle.TextScaled = true
TriggerBotToggle.Font = Enum.Font.SourceSans
TriggerBotToggle.Parent = MainFrame

-- Toggle Visibility Check
local VisCheckToggle = Instance.new("TextButton")
VisCheckToggle.Name = "VisCheckToggle"
VisCheckToggle.Size = UDim2.new(0, 200, 0, 30)
VisCheckToggle.Position = UDim2.new(0, 50, 0, 120)
VisCheckToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
VisCheckToggle.BorderSizePixel = 1
VisCheckToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
VisCheckToggle.Text = "Visible Check: ON"
VisCheckToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
VisCheckToggle.TextScaled = true
VisCheckToggle.Font = Enum.Font.SourceSans
VisCheckToggle.Parent = MainFrame

-- FOV Size Slider Label
local FovLabel = Instance.new("TextLabel")
FovLabel.Name = "FovLabel"
FovLabel.Size = UDim2.new(0, 200, 0, 20)
FovLabel.Position = UDim2.new(0, 50, 0, 160)
FovLabel.BackgroundTransparency = 1
FovLabel.Text = "FOV Size: " .. Config.FovSize
FovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FovLabel.TextScaled = true
FovLabel.Font = Enum.Font.SourceSans
FovLabel.Parent = MainFrame

-- FOV Size Slider
local FovSlider = Instance.new("TextBox")
FovSlider.Name = "FovSlider"
FovSlider.Size = UDim2.new(0, 100, 0, 25)
FovSlider.Position = UDim2.new(0, 100, 0, 185)
FovSlider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
FovSlider.BorderSizePixel = 1
FovSlider.BorderColor3 = Color3.fromRGB(100, 100, 100)
FovSlider.Text = tostring(Config.FovSize)
FovSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
FovSlider.TextScaled = true
FovSlider.Font = Enum.Font.SourceSans
FovSlider.Parent = MainFrame

-- Keybind Label
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Name = "KeybindLabel"
KeybindLabel.Size = UDim2.new(0, 200, 0, 20)
KeybindLabel.Position = UDim2.new(0, 50, 0, 220)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Aimbot Key: " .. Config.KeyBind.Name
KeybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindLabel.TextScaled = true
KeybindLabel.Font = Enum.Font.SourceSans
KeybindLabel.Parent = MainFrame

-- Functions
local function GetClosestPlayerToMouse()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and 
           Player.Character.Humanoid.Health > 0 and Player.Character:FindFirstChild("HumanoidRootPart") then
            
            -- Check if player is visible
            if Config.VisibleCheck then
                local PartToCheck = Player.Character:FindFirstChild("Head") or Player.Character:FindFirstChild("HumanoidRootPart")
                if PartToCheck then
                    local RayParams = RaycastParams.new()
                    RayParams.FilterDescendantsInstances = {LocalPlayer.Character, Player.Character}
                    RayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    local Result = workspace:Raycast(Camera.CFrame.Position, (PartToCheck.Position - Camera.CFrame.Position).Unit * 999, RayParams)
                    
                    if Result and Result.Instance and Result.Instance.Parent == Player.Character then
                        -- Player is visible
                    else
                        continue -- Skip this player as they're not visible
                    end
                end
            end
            
            local Position, OnScreen = Camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)
            local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
            
            if Distance <= Config.FovSize and Distance < ShortestDistance and OnScreen then
                ShortestDistance = Distance
                ClosestPlayer = Player
            end
        end
    end
    
    return ClosestPlayer
end

local function UpdateAimbot()
    if Config.AimbotEnabled then
        local Target = GetClosestPlayerToMouse()
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            CurrentTarget = Target
            local TargetPosition = Target.Character.HumanoidRootPart.Position
            
            -- Calculate look direction with smoothing
            local LookAtCF = Camera.CFrame.LookVector
            local TargetCF = CFrame.lookAt(Camera.CFrame.Position, TargetPosition)
            
            -- Apply smoothing
            local NewLook = Camera.CFrame + (TargetCF.LookVector - LookAtCF) * (1 - Config.Smoothness)
            Camera.CFrame = NewLook
        else
            CurrentTarget = nil
        end
    else
        CurrentTarget = nil
    end
end

local function UpdateTriggerBot()
    if Config.TriggerBotEnabled then
        local Target = GetClosestPlayerToMouse()
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            -- Simulate mouse click (this is just a simulation since we can't actually click in this context)
            print("Triggered on target: " .. Target.Name)
        end
    end
end

-- Event Handlers
AimbotToggle.MouseButton1Click:Connect(function()
    Config.AimbotEnabled = not Config.AimbotEnabled
    AimbotToggle.Text = "Aimbot: " .. (Config.AimbotEnabled and "ON" or "OFF")
    
    if Config.AimbotEnabled then
        AimbotConnection = RunService.Heartbeat:Connect(UpdateAimbot)
    elseif AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end
end)

TriggerBotToggle.MouseButton1Click:Connect(function()
    Config.TriggerBotEnabled = not Config.TriggerBotEnabled
    TriggerBotToggle.Text = "TriggerBot: " .. (Config.TriggerBotEnabled and "ON" or "OFF")
    
    if Config.TriggerBotEnabled then
        TriggerBotConnection = RunService.Heartbeat:Connect(UpdateTriggerBot)
    elseif TriggerBotConnection then
        TriggerBotConnection:Disconnect()
        TriggerBotConnection = nil
    end
end)

VisCheckToggle.MouseButton1Click:Connect(function()
    Config.VisibleCheck = not Config.VisibleCheck
    VisCheckToggle.Text = "Visible Check: " .. (Config.VisibleCheck and "ON" or "OFF")
end)

FovSlider.FocusLost:Connect(function()
    local NewValue = tonumber(FovSlider.Text)
    if NewValue and NewValue >= 10 and NewValue <= 500 then
        Config.FovSize = NewValue
        FovLabel.Text = "FOV Size: " .. Config.FovSize
    else
        FovSlider.Text = tostring(Config.FovSize)
    end
end)

-- Keybind handling
UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Config.KeyBind then
        Config.AimbotEnabled = not Config.AimbotEnabled
        AimbotToggle.Text = "Aimbot: " .. (Config.AimbotEnabled and "ON" or "OFF")
        
        if Config.AimbotEnabled then
            AimbotConnection = RunService.Heartbeat:Connect(UpdateAimbot)
        elseif AimbotConnection then
            AimbotConnection:Disconnect()
            AimbotConnection = nil
        end
    elseif Input.KeyCode == Config.TriggerKey then
        Config.TriggerBotEnabled = not Config.TriggerBotEnabled
        TriggerBotToggle.Text = "TriggerBot: " .. (Config.TriggerBotEnabled and "ON" or "OFF")
        
        if Config.TriggerBotEnabled then
            TriggerBotConnection = RunService.Heartbeat:Connect(UpdateTriggerBot)
        elseif TriggerBotConnection then
            TriggerBotConnection:Disconnect()
            TriggerBotConnection = nil
        end
    end
end)

-- Initialize GUI state
AimbotToggle.Text = "Aimbot: " .. (Config.AimbotEnabled and "ON" or "OFF")
TriggerBotToggle.Text = "TriggerBot: " .. (Config.TriggerBotEnabled and "ON" or "OFF")
VisCheckToggle.Text = "Visible Check: " .. (Config.VisibleCheck and "ON" or "OFF")

print("Aimbot script loaded! Press Right Shift to toggle aimbot, X to toggle triggerbot.")