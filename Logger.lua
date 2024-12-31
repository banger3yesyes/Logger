if getgenv().AnimLogger then getgenv().AnimLogger:Destroy() end

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local loggedAnimations = {}

local gui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local titleBar = Instance.new("Frame")
local titleText = Instance.new("TextLabel")
local closeButton = Instance.new("TextButton")
local minimizeButton = Instance.new("TextButton")
local scrollFrame = Instance.new("ScrollingFrame")
local minimizedIcon = Instance.new("ImageButton")

-- GUI setup
gui.Name = "AnimationLogger"
gui.ResetOnSpawn = false

mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 5, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Animation Logger"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.TextSize = 14
titleText.Font = Enum.Font.SourceSansBold
titleText.Parent = titleBar

closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = titleBar

minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -60, 0, 0)
minimizeButton.BackgroundTransparency = 1
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 20
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.Parent = titleBar

scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = mainFrame

minimizedIcon.Name = "MinimizedIcon"
minimizedIcon.Size = UDim2.new(0, 30, 0, 30)
minimizedIcon.Position = UDim2.new(0.5, -15, 0, 0)
minimizedIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizedIcon.BorderSizePixel = 0
minimizedIcon.Image = "rbxassetid://4034483344"
minimizedIcon.Visible = false
minimizedIcon.Parent = gui

local function createLogEntry(animId)
    local entryFrame = Instance.new("Frame")
    entryFrame.Size = UDim2.new(1, -10, 0, 25)
    entryFrame.Position = UDim2.new(0, 5, 0, #scrollFrame:GetChildren() * 27)
    entryFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    entryFrame.BorderSizePixel = 0
    entryFrame.Parent = scrollFrame

    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(1, -30, 1, 0)
    idLabel.Position = UDim2.new(0, 5, 0, 0)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = animId
    idLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.TextSize = 14
    idLabel.Font = Enum.Font.SourceSans
    idLabel.Parent = entryFrame

    local playButton = Instance.new("TextButton")
    playButton.Size = UDim2.new(0, 25, 0, 25)
    playButton.Position = UDim2.new(1, -25, 0, 0)
    playButton.BackgroundTransparency = 1
    playButton.Text = "▶"
    playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    playButton.TextSize = 14
    playButton.Font = Enum.Font.SourceSansBold
    playButton.Parent = entryFrame

    local currentTrack = nil
    playButton.MouseButton1Click:Connect(function()
        if currentTrack and currentTrack.IsPlaying then
            currentTrack:Stop()
            playButton.Text = "▶"
            currentTrack = nil
        else
            if currentTrack then
                currentTrack:Stop()
            end
            currentTrack = playAnimation(animId)
            if currentTrack then
                playButton.Text = "⏹"
                currentTrack.Stopped:Connect(function()
                    playButton.Text = "▶"
                    currentTrack = nil
                end)
            end
        end
    end)

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #scrollFrame:GetChildren() * 27)
end

local function extractId(assetUrl)
    local id = assetUrl:match("rbxassetid://(%d+)")
    if id then return id end

    id = assetUrl:match("id=(%d+)")
    if id then return id end

    if assetUrl:match("^%d+$") then return assetUrl end

    return assetUrl
end

local function playAnimation(id)
    print("Attempting to play animation:", id)
    
    local player = Players.LocalPlayer
    if not player.Character then 
        print("No character found")
        return 
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then 
        print("No humanoid found")
        return 
    end
    
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then 
        print("No animator found")
        return 
    end
    
    print("Found all required components, playing animation")
    
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    
    local animation = Instance.new("Animation")
    if not id:match("^rbxassetid://") then
        id = "rbxassetid://" .. id
    end
    animation.AnimationId = id
    print("Created animation with ID:", animation.AnimationId)
    
    local success, animTrack = pcall(function()
        return animator:LoadAnimation(animation)
    end)
    
    if success and animTrack then
        print("Successfully loaded animation, playing...")
        animTrack:Play()
        animation:Destroy()
        return animTrack
    else
        print("Failed to load animation:", animTrack)
        return nil
    end
end

local function hookAnimations(character)
    print("Hooking animations for character:", character.Name)

    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    print("Got animator:", animator)

    animator.AnimationPlayed:Connect(function(animTrack)
        local animId = extractId(animTrack.Animation.AnimationId)
        if not loggedAnimations[animId] then
            loggedAnimations[animId] = true
            createLogEntry(animTrack.Animation.AnimationId)
        end
    end)
end

local function makeDraggable(frame)
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        frame.Position = position
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                updateInput(input)
            end
        end
    end)
end

makeDraggable(titleBar)

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

minimizeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minimizedIcon.Visible = true
end)

minimizedIcon.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    minimizedIcon.Visible = false
end)

local player = Players.LocalPlayer
getgenv().AnimLogger = gui
gui.Parent = game:GetService("CoreGui")

print("Setting up animation logger")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(hookAnimations)
end)

if player.Character then
    hookAnimations(player.Character)
end

player.CharacterAdded:Connect(hookAnimations)
