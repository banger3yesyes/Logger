if getgenv().AnimLogger then getgenv().AnimLogger:Destroy() end

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local loggedAnimations = {}

local function extractId(assetUrl)
    local id = assetUrl:match("rbxassetid://(%d+)")
    if id then return id end

    id = assetUrl:match("id=(%d+)")
    if id then return id end

    if assetUrl:match("^%d+$") then return assetUrl end

    return assetUrl
end

local function hookAnimator(animator)
    animator.AnimationPlayed:Connect(function(animTrack)
        local animId = extractId(animTrack.Animation.AnimationId)
        if not loggedAnimations[animId] and animId ~= "" then
            loggedAnimations[animId] = true
            createLogEntry(animTrack.Animation.AnimationId)
        end
    end)
end

local function findHumanoidAnimations(instance)
    local humanoid = instance:FindFirstChild("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChild("Animator")
        if animator then
            hookAnimator(animator)
            -- Also check for any loaded animations
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local animId = extractId(track.Animation.AnimationId)
                if not loggedAnimations[animId] and animId ~= "" then
                    loggedAnimations[animId] = true
                    createLogEntry(track.Animation.AnimationId)
                end
            end
        end
        
        -- Watch for new Animator
        humanoid.ChildAdded:Connect(function(child)
            if child:IsA("Animator") then
                hookAnimator(child)
            end
        end)
    end
end

local function scanWorkspace()
    -- Scan existing models with humanoids
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") then
            findHumanoidAnimations(model)
        end
    end
    
    -- Watch for new models
    workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("Model") then
            findHumanoidAnimations(desc)
        end
    end)
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

local gui = Instance.new("ScreenGui")
gui.Name = "AnimationLogger"
gui.ResetOnSpawn = false

local minimizedIcon = Instance.new("ImageButton")
minimizedIcon.Size = UDim2.new(0, 30, 0, 30)
minimizedIcon.Position = UDim2.new(0.5, -15, 0, 10)
minimizedIcon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
minimizedIcon.BackgroundTransparency = 0.5
minimizedIcon.Image = "rbxassetid://6034925618"
minimizedIcon.Visible = false
minimizedIcon.Parent = gui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 6)
iconCorner.Parent = minimizedIcon

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0.5, -125, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.6
frame.BorderSizePixel = 0
frame.Parent = gui

local controlsContainer = Instance.new("Frame")
controlsContainer.Size = UDim2.new(0, 50, 0, 25)
controlsContainer.Position = UDim2.new(0, 5, 0, 5)
controlsContainer.BackgroundTransparency = 1
controlsContainer.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(0, 0, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.BackgroundTransparency = 0.5
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = controlsContainer

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 20, 0, 20)
minimizeButton.Position = UDim2.new(0, 25, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeButton.BackgroundTransparency = 0.5
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 14
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.Parent = controlsContainer

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 4)
minimizeCorner.Parent = minimizeButton

local isMinimized = false
local normalPosition = UDim2.new(0.5, -125, 0.5, -100)
local minimizedPosition = UDim2.new(1, 10, 0.5, -100)

local function minimize()
    if not isMinimized then
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(frame, tweenInfo, {Position = minimizedPosition})
        tween:Play()

        tween.Completed:Connect(function()
            minimizedIcon.Visible = true
        end)

        isMinimized = true
    end
end

local function maximize()
    if isMinimized then
        minimizedIcon.Visible = false

        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(frame, tweenInfo, {Position = normalPosition})
        tween:Play()
        isMinimized = false
    end
end

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

minimizeButton.MouseButton1Click:Connect(minimize)
minimizedIcon.MouseButton1Click:Connect(maximize)

makeDraggable(frame)

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Animation Logger"
title.TextSize = 14
title.Font = Enum.Font.SourceSans
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 6)
titleCorner.Parent = title

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "LogFrame"
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 3
scrollFrame.Parent = frame

local function createLogEntry(animId)
    print("Creating log entry for animation:", animId)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -4, 0, 25)
    container.Position = UDim2.new(0, 2, 0, (#scrollFrame:GetChildren() * 27))
    container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    container.BackgroundTransparency = 0.5
    container.BorderSizePixel = 0
    container.Parent = scrollFrame

    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 4)
    containerCorner.Parent = container

    local idBox = Instance.new("TextBox")
    idBox.Size = UDim2.new(1, -35, 1, 0)
    idBox.Position = UDim2.new(0, 0, 0, 0)
    idBox.BackgroundTransparency = 1
    idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    idBox.Text = extractId(animId)
    idBox.TextSize = 14
    idBox.Font = Enum.Font.Code
    idBox.ClearTextOnFocus = false
    idBox.TextEditable = false
    idBox.Parent = container

    local playButton = Instance.new("TextButton")
    playButton.Size = UDim2.new(0, 25, 0, 25)
    playButton.Position = UDim2.new(1, -25, 0, 0)
    playButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    playButton.BackgroundTransparency = 0.5
    playButton.Text = "▶"
    playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    playButton.TextSize = 14
    playButton.Font = Enum.Font.Code
    playButton.Parent = container

    local playButtonCorner = Instance.new("UICorner")
    playButtonCorner.CornerRadius = UDim.new(0, 4)
    playButtonCorner.Parent = playButton

    local currentTrack = nil

    idBox.Focused:Connect(function()
        idBox.TextEditable = true
        idBox.SelectionStart = 1
        idBox.CursorPosition = #idBox.Text + 1

        container.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        wait(0.2)
        container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    end)

    idBox.FocusLost:Connect(function()
        idBox.TextEditable = false
    end)

    playButton.MouseButton1Click:Connect(function()
        if currentTrack and currentTrack.IsPlaying then
            currentTrack:Stop()
            currentTrack = nil
            playButton.Text = "▶"
            playButton.BackgroundTransparency = 0.5
        else
            playButton.BackgroundTransparency = 0.5
            playButton.Text = "▶"

            currentTrack = playAnimation(idBox.Text)

            if currentTrack then
                currentTrack.Stopped:Connect(function()
                    playButton.Text = "▶"
                    playButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    playButton.BackgroundTransparency = 0.5
                    currentTrack = nil
                end)
            else
                playButton.Text = "▶"
                playButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end
    end)

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #scrollFrame:GetChildren() * 27)
end

local player = Players.LocalPlayer
getgenv().AnimLogger = gui
gui.Parent = game:GetService("CoreGui")

print("Setting up animation logger")

-- Scan workspace for existing humanoid rigs
scanWorkspace()

-- Watch for new players and their characters
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        findHumanoidAnimations(char)
    end)
end)

-- Hook existing players
for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then
        findHumanoidAnimations(plr.Character)
    end
    plr.CharacterAdded:Connect(function(char)
        findHumanoidAnimations(char)
    end)
end
