--[[
Script made by Banger (gen.ed.) on discord, this script is opensourced because i really dont see the issue
with opensourcing your projects. Hope the people who used this liked it!
I got a lot of inspiration from edge's audio logger for that audio information thing
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local BUTTON_SIZE = UDim2.new(0, 120, 0, 30)
local FRAME_SIZE = UDim2.new(0, 400, 0, 300)
local LOGGED_SOUNDS = {}
local SCAN_INTERVAL = 0.5
local lastScanTime = 0

local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local callString = tostring(self)
        if callString:lower():find("log") or callString:lower():find("analytics") or callString:lower():find("track") then
            return
        end
    end
    
    return old(self, ...)
end))

local existingGui = game.CoreGui:FindFirstChild("SoundLogger")
if existingGui then
    existingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoundLogger"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = FRAME_SIZE
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.6
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 5)
Corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Sound Logger"
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.TextColor3 = Color3.fromRGB(255,13,13)
closeButton.Text = "X"
closeButton.Parent = mainFrame
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local function CreateButton(text, position)
    local button = Instance.new("TextButton")
    button.Name = text:gsub(" ", "") .. "Button"
    button.Size = BUTTON_SIZE
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BackgroundTransparency = 0.4
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold
    button.AutoButtonColor = true
    button.Parent = mainFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 5)
    buttonCorner.Parent = button

    return button
end

local autoScanButton = CreateButton("Auto Scan", UDim2.new(0, 10, 0, 40))
local clearAllButton = CreateButton("Clear All", UDim2.new(0, 140, 0, 40))
local scanAllButton = CreateButton("Scan All", UDim2.new(0, 270, 0, 40))

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "SoundList"
scrollFrame.Size = UDim2.new(1, -20, 1, -90)
scrollFrame.Position = UDim2.new(0, 10, 0, 80)
scrollFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = mainFrame

local function CreateSoundInfoGui(sound)
    local existingInfo = game.CoreGui:FindFirstChild("SoundInfo")
    if existingInfo then
        existingInfo:Destroy()
    end

    local infoGui = Instance.new("ScreenGui")
    infoGui.Name = "SoundInfo"
    infoGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = infoGui

    local Corner4 = Instance.new("UICorner")
    Corner4.CornerRadius = UDim.new(0, 4)
    Corner4.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "Sound Information"
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame

    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 0, 100)
    infoText.Position = UDim2.new(0, 10, 0, 40)
    infoText.BackgroundTransparency = 1
    infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoText.Text = string.format(
        "Name: %s\nVolume: %.2f\nTimeLength: %.2f\nIsPlaying: %s",
        sound.Name,
        sound.Volume,
        sound.TimeLength,
        tostring(sound.IsPlaying)
    )
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.Parent = frame

    local idBox = Instance.new("TextBox")
    idBox.Size = UDim2.new(1, -20, 0, 30)
    idBox.Position = UDim2.new(0, 10, 0, 150)
    idBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    idBox.BackgroundTransparency = 0.4
    idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    idBox.Text = tostring(sound.SoundId)
    idBox.TextEditable = false
    idBox.ClearTextOnFocus = false
    idBox.Parent = frame

    local Corner5 = Instance.new("UICorner")
    Corner5.CornerRadius = UDim.new(0, 4)
    Corner5.Parent = idBox

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.TextColor3 = Color3.fromRGB(255, 13, 13)
    closeButton.Text = "X"
    closeButton.Parent = frame

    closeButton.MouseButton1Click:Connect(function()
        infoGui:Destroy()
    end)
end

local function PlaySound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 4
    sound.Parent = game:GetService("CoreGui")
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local function ScanSound(sound)
    local success, result = pcall(function()
        return {
            Name = sound.Name,
            SoundId = sound.SoundId,
            Volume = sound.Volume,
            IsPlaying = sound.IsPlaying,
            TimeLength = sound.TimeLength
        }
    end)
    
    if success then
        return result
    end
    return nil
end

local function LogSound(sound)
    local soundInfo = ScanSound(sound)
    if not soundInfo or not sound:IsA("Sound") or table.find(LOGGED_SOUNDS, soundInfo.SoundId) then
        return
    end

    table.insert(LOGGED_SOUNDS, soundInfo.SoundId)
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, (#LOGGED_SOUNDS - 1) * 35)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -75, 1, 0)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BackgroundTransparency = 0.4
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = soundInfo.SoundId
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextSize = 14
    button.Parent = container

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button

    local playButton = Instance.new("TextButton")
    playButton.Size = UDim2.new(0, 30, 1, 0)
    playButton.Position = UDim2.new(1, -65, 0, 0)
    playButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    playButton.BackgroundTransparency = 0.4
    playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    playButton.Text = "▶"
    playButton.TextSize = 14
    playButton.Parent = container

    local playCorner = Instance.new("UICorner")
    playCorner.CornerRadius = UDim.new(0, 4)
    playCorner.Parent = playButton

    local deleteButton = Instance.new("TextButton")
    deleteButton.Size = UDim2.new(0, 30, 1, 0)
    deleteButton.Position = UDim2.new(1, -30, 0, 0)
    deleteButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    deleteButton.BackgroundTransparency = 0.4
    deleteButton.TextColor3 = Color3.fromRGB(255, 13, 13)
    deleteButton.Text = "×"
    deleteButton.TextSize = 20
    deleteButton.Parent = container

    local deleteCorner = Instance.new("UICorner")
    deleteCorner.CornerRadius = UDim.new(0, 4)
    deleteCorner.Parent = deleteButton

    button.MouseButton1Click:Connect(function()
        CreateSoundInfoGui(sound)
    end)

    playButton.MouseButton1Click:Connect(function()
        PlaySound(soundInfo.SoundId)
    end)

    deleteButton.MouseButton1Click:Connect(function()
        for i, id in ipairs(LOGGED_SOUNDS) do
            if id == soundInfo.SoundId then
                table.remove(LOGGED_SOUNDS, i)
                break
            end
        end
        
        container:Destroy()
        
        local yOffset = 0
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child.Position = UDim2.new(0, 5, 0, yOffset)
                yOffset = yOffset + 35
            end
        end
        
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #LOGGED_SOUNDS * 35)
    end)

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #LOGGED_SOUNDS * 35)
end

local function IsPlayerSound(sound)
    local player = Players.LocalPlayer
    if not player then return false end
    
    local character = player.Character
    if character then
        if sound:IsDescendantOf(character) then
            return true
        end
    end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack and sound:IsDescendantOf(backpack) then
        return true
    end
    
    return false
end

local function SafeScan()
    local currentTime = tick()
    if currentTime - lastScanTime < SCAN_INTERVAL then
        return
    end
    lastScanTime = currentTime

    local player = Players.LocalPlayer
    if not player or not player.Character then return end

    local success, result = pcall(function()
        local soundsToCheck = {}
        
        if player.Character then
            for _, item in ipairs(player.Character:GetDescendants()) do
                if item:IsA("Sound") then
                    table.insert(soundsToCheck, item)
                end
            end
        end
        
        if player:FindFirstChild("Backpack") then
            for _, item in ipairs(player.Backpack:GetDescendants()) do
                if item:IsA("Sound") then
                    table.insert(soundsToCheck, item)
                end
            end
        end
        
        return soundsToCheck
    end)
    
    if success and result then
        for _, sound in ipairs(result) do
            if sound.IsPlaying then
                LogSound(sound)
            end
        end
    end
end

local autoScanEnabled = false
local autoScanConnection

autoScanButton.MouseButton1Click:Connect(function()
    autoScanEnabled = not autoScanEnabled
    autoScanButton.BackgroundColor3 = autoScanEnabled and 
        Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    
    if autoScanEnabled then
        if autoScanConnection then
            autoScanConnection:Disconnect()
        end
        
        local lastUpdate = 0
        autoScanConnection = RunService.RenderStepped:Connect(function()
            if not autoScanEnabled then return end
            
            local now = tick()
            if now - lastUpdate >= SCAN_INTERVAL then
                lastUpdate = now
                SafeScan()
            end
        end)
    else
        if autoScanConnection then
            autoScanConnection:Disconnect()
        end
    end
end)

clearAllButton.MouseButton1Click:Connect(function()
    table.clear(LOGGED_SOUNDS)
    for _, child in ipairs(scrollFrame:GetChildren()) do
        child:Destroy()
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

scanAllButton.MouseButton1Click:Connect(function()
    SafeScan()
end)

screenGui.AncestryChanged:Connect(function(_, parent)
    if not parent and autoScanConnection then
        autoScanConnection:Disconnect()
    end
end)
