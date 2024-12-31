-- Animation Logger by Codeium
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Remove any existing logger
for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
	if gui.Name == "AnimationLogger" then
		gui:Destroy()
	end
end

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "AnimationLogger"
gui.Parent = game.CoreGui

-- Create main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 0, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.5
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local DragDetector = Instance.new("UIDragDetector")
DragDetector.Parent = mainFrame

-- Add corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Create top bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
topBar.BackgroundTransparency = 1
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

-- Add top bar corner radius
local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 8)
topCorner.Parent = topBar

-- Create title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "Animation Logger by Banger"
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 14
title.Font = Enum.Font.SourceSans
title.Parent = topBar

-- Create buttons
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Text = "-"
minimizeButton.Size = UDim2.new(0, 30, 1, 0)
minimizeButton.Position = UDim2.new(1, -60, 0, 0)
minimizeButton.BackgroundTransparency = 1
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 20
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = topBar

local clearButton = Instance.new("TextButton")
clearButton.Name = "ClearButton"
clearButton.Text = "Clear"
clearButton.Size = UDim2.new(0, 40, 0.8, 0)
clearButton.Position = UDim2.new(1, -100, 0.1, 0)
clearButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
clearButton.BackgroundTransparency = 1 
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.TextSize = 12
clearButton.Font = Enum.Font.SourceSans
clearButton.BorderSizePixel = 0
clearButton.Parent = topBar

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 4)
UICorner2.Parent = clearButton

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Text = "×"
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = topBar

-- Create scroll frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -10, 1, -35)
scrollFrame.Position = UDim2.new(0, 5, 0, 32)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = scrollFrame
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Variables
local loggedAnimations = {}
local activeAnimations = {}
local isDragging = false
local dragStart = nil
local startPos = nil

-- Functions
local function updateScrollingFrame()
	local contentSize = UIListLayout.AbsoluteContentSize
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y)
end

local function stopAllAnimations(animator)
	for _, track in pairs(animator:GetPlayingAnimationTracks()) do
		track:Stop()
	end
end

local function stopAnimation(animator, animTrack)
	if activeAnimations[animator] and activeAnimations[animator][animTrack] then
		activeAnimations[animator][animTrack]:Stop()
		activeAnimations[animator][animTrack] = nil
	end
end

local function playAnimation(animator, animId)
	stopAllAnimations(animator)
	local animation = Instance.new("Animation")
	animation.AnimationId = animId
	local animTrack = animator:LoadAnimation(animation)

	if not activeAnimations[animator] then
		activeAnimations[animator] = {}
	end
	activeAnimations[animator][animId] = animTrack
	animTrack:Play()
end

local function createAnimationEntry(animator, animId, animName)
	local entry = Instance.new("Frame")
	entry.Size = UDim2.new(1, -4, 0, 45)
	entry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	entry.BackgroundTransparency = 0.4
	entry.BorderSizePixel = 0

	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 6)
	entryCorner.Parent = entry

	local idNumber = animId:match("rbxassetid://(%d+)") or animId:match("roblox.com/asset/%?id=(%d+)") or animId:match("(%d+)") or animId

	local animLabel = Instance.new("TextBox")
	animLabel.Size = UDim2.new(0.6, 0, 1, 0)
	animLabel.Position = UDim2.new(0, 8, 0, 0)
	animLabel.BackgroundTransparency = 1
	animLabel.Text = idNumber
	animLabel.PlaceholderText = ""
	animLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	animLabel.TextXAlignment = Enum.TextXAlignment.Left
	animLabel.TextSize = 14
	animLabel.Font = Enum.Font.Gotham
	animLabel.TextTruncate = Enum.TextTruncate.AtEnd
	animLabel.ClearTextOnFocus = false
	animLabel.TextEditable = false
	animLabel.ClipsDescendants = true
	animLabel.Parent = entry

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
	nameLabel.Position = UDim2.new(0, 8, 0.6, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = animName or "Animation"
	nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextSize = 12
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = entry

	local buttonContainer = Instance.new("Frame")
	buttonContainer.Size = UDim2.new(0.4, -10, 1, 0)
	buttonContainer.Position = UDim2.new(0.6, 5, 0, 0)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = entry

	local playButton = Instance.new("TextButton")
	playButton.Size = UDim2.new(0.5, -2, 0.7, 0)
	playButton.Position = UDim2.new(0, 0, 0.15, 0)
	playButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	playButton.BackgroundTransparency = 0.3
	playButton.Text = "Play"
	playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	playButton.TextSize = 12
	playButton.Font = Enum.Font.SourceSans
	playButton.BorderSizePixel = 0
	playButton.Parent = buttonContainer

	local clearButton = Instance.new("TextButton")
	clearButton.Size = UDim2.new(0.5, -2, 0.7, 0)
	clearButton.Position = UDim2.new(0.5, 2, 0.15, 0)
	clearButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	clearButton.Text = "Clear"
	clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	clearButton.TextSize = 12
	clearButton.Font = Enum.Font.SourceSans
	clearButton.BorderSizePixel = 0
	clearButton.Parent = buttonContainer

	local playCorner = Instance.new("UICorner")
	playCorner.CornerRadius = UDim.new(0, 4)
	playCorner.Parent = playButton

	local clearCorner = Instance.new("UICorner")
	clearCorner.CornerRadius = UDim.new(0, 4)
	clearCorner.Parent = clearButton

	local isPlaying = false
	playButton.MouseButton1Click:Connect(function()
		if isPlaying then
			stopAnimation(animator, animId)
			playButton.Text = "Play"
			playButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		else
			playAnimation(animator, animId)
			playButton.Text = "Stop"
			playButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		end
		isPlaying = not isPlaying
	end)

	clearButton.MouseButton1Click:Connect(function()
		if isPlaying then
			stopAnimation(animator, animId)
		end
		loggedAnimations[animId] = nil
		entry:Destroy()
		updateScrollingFrame()
	end)

	return entry
end

local function onAnimationPlayed(animator, animTrack)
	if not animator or not animTrack then return end
	local animId = animTrack.Animation.AnimationId
	if loggedAnimations[animId] then return end

	loggedAnimations[animId] = true
	local entry = createAnimationEntry(animator, animId, animTrack.Name)
	entry.Parent = scrollFrame
	updateScrollingFrame()
end

-- Setup dragging
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = false
	end
end)

-- Setup buttons
minimizeButton.MouseButton1Click:Connect(function()
	scrollFrame.Visible = not scrollFrame.Visible
	mainFrame.Size = scrollFrame.Visible and UDim2.new(0, 300, 0, 400) or UDim2.new(0, 300, 0, 30)
end)

clearButton.MouseButton1Click:Connect(function()
	for animator, tracks in pairs(activeAnimations) do
		for _, track in pairs(tracks) do
			if track.IsPlaying then
				track:Stop()
			end
		end
	end
	activeAnimations = {}

	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	loggedAnimations = {}
	updateScrollingFrame()
end)

closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Setup animation tracking
game.Workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Animator") then
		descendant.AnimationPlayed:Connect(function(animTrack)
			onAnimationPlayed(descendant, animTrack)
		end)
	end
end)

for _, descendant in ipairs(game.Workspace:GetDescendants()) do
	if descendant:IsA("Animator") then
		descendant.AnimationPlayed:Connect(function(animTrack)
			onAnimationPlayed(descendant, animTrack)
		end)
	end
end
