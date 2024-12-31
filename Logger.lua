local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Create a table to track logged animations
local loggedAnimations = {}

-- Function to extract ID from asset URL
local function extractId(assetUrl)
	-- Handle rbxassetid:// format
	local id = assetUrl:match("rbxassetid://(%d+)")
	if id then return id end

	-- Handle http://www.roblox.com/asset/?id= format
	id = assetUrl:match("id=(%d+)")
	if id then return id end

	-- If it's already just a number, return it
	if assetUrl:match("^%d+$") then return assetUrl end

	-- If no ID found, return original
	return assetUrl
end

-- Function to play animation
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

	-- Stop all currently playing animations
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		track:Stop()
	end

	-- Create and play the animation
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
		animation:Destroy()  -- Clean up the animation object
		return animTrack  -- Return the track so we can stop it later
	else
		print("Failed to load animation:", animTrack)
		return nil
	end
end

-- Function to make a frame draggable
local function makeDraggable(frame)
	local dragToggle = nil
	local dragSpeed = 0.1
	local dragStart = nil
	local startPos = nil

	local function updateInput(input)
		local delta = input.Position - dragStart
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		game:GetService('TweenService'):Create(frame, TweenInfo.new(dragSpeed), {Position = position}):Play()
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

-- Create the ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "AnimationLogger"
gui.ResetOnSpawn = false

-- Create minimized icon (initially invisible)
local minimizedIcon = Instance.new("ImageButton")
minimizedIcon.Size = UDim2.new(0, 30, 0, 30)  -- Reduced from 40x40 to 30x30
minimizedIcon.Position = UDim2.new(0.5, -15, 0, 10)  -- Adjusted X offset to match new size
minimizedIcon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
minimizedIcon.BackgroundTransparency = 1
minimizedIcon.Image = "rbxassetid://13530555599" -- Animation icon
minimizedIcon.Visible = false
minimizedIcon.Parent = gui

-- Add rounded corners to icon
local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 6)
iconCorner.Parent = minimizedIcon

-- Create the main frame
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0.5, -125, 0.5, -100)  -- Center position
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.6
frame.BorderSizePixel = 0
frame.Parent = gui

-- Add control buttons container
local controlsContainer = Instance.new("Frame")
controlsContainer.Size = UDim2.new(0, 50, 0, 25)
controlsContainer.Position = UDim2.new(0, 5, 0, 5)
controlsContainer.BackgroundTransparency = 1
controlsContainer.Parent = frame

-- Create close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(0, 0, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 0, 0)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = controlsContainer

-- Add rounded corners to close button
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

-- Create minimize button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 20, 0, 20)
minimizeButton.Position = UDim2.new(0, 25, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeButton.BackgroundTransparency = 1
minimizeButton.Text = "--"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 14
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.Parent = controlsContainer

-- Add rounded corners to minimize button
local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 4)
minimizeCorner.Parent = minimizeButton

-- Variables to store positions
local isMinimized = false
local normalPosition = UDim2.new(0.5, -125, 0.5, -100)  -- Center
local minimizedPosition = UDim2.new(1, 10, 0.5, -100)   -- Off screen to the right

-- Function to minimize (slide out)
local function minimize()
	if not isMinimized then
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(frame, tweenInfo, {Position = minimizedPosition})
		tween:Play()

		-- Show icon after frame slides out
		tween.Completed:Connect(function()
			minimizedIcon.Visible = true
		end)

		isMinimized = true
	end
end

-- Function to maximize (slide in)
local function maximize()
	if isMinimized then
		-- Hide icon immediately
		minimizedIcon.Visible = false

		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(frame, tweenInfo, {Position = normalPosition})
		tween:Play()
		isMinimized = false
	end
end

-- Connect button events
closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

minimizeButton.MouseButton1Click:Connect(minimize)
minimizedIcon.MouseButton1Click:Connect(maximize)

-- Make the frame draggable
makeDraggable(frame)

-- Add rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame

-- Add title
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

-- Add rounded corners to title
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 6)
titleCorner.Parent = title

-- Create scrolling frame for logs
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "LogFrame"
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 3
scrollFrame.Parent = frame

-- Template for log entries
local function createLogEntry(animId)
	print("Creating log entry for animation:", animId)  -- Debug print

	-- Create container for the row
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -4, 0, 25)
	container.Position = UDim2.new(0, 2, 0, (#scrollFrame:GetChildren() * 27))
	container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	container.BackgroundTransparency = 0.5
	container.BorderSizePixel = 0
	container.Parent = scrollFrame

	-- Add rounded corners to container
	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 4)
	containerCorner.Parent = container

	-- Create the ID TextBox
	local idBox = Instance.new("TextBox")
	idBox.Size = UDim2.new(1, -35, 1, 0)  -- Make room for play button
	idBox.Position = UDim2.new(0, 0, 0, 0)
	idBox.BackgroundTransparency = 1
	idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	idBox.Text = extractId(animId)
	idBox.TextSize = 14
	idBox.Font = Enum.Font.Code
	idBox.ClearTextOnFocus = false
	idBox.TextEditable = false
	idBox.Parent = container

	-- Create play button
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

	-- Add rounded corners to play button
	local playButtonCorner = Instance.new("UICorner")
	playButtonCorner.CornerRadius = UDim.new(0, 4)
	playButtonCorner.Parent = playButton

	-- Store current animation track
	local currentTrack = nil

	-- Handle TextBox focus
	idBox.Focused:Connect(function()
		idBox.TextEditable = true
		idBox.SelectionStart = 1
		idBox.CursorPosition = #idBox.Text + 1

		-- Visual feedback
		container.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		wait(0.2)
		container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end)

	-- Handle TextBox unfocus
	idBox.FocusLost:Connect(function()
		idBox.TextEditable = false
	end)

	-- Play button click handler
	playButton.MouseButton1Click:Connect(function()
		if currentTrack and currentTrack.IsPlaying then
			-- Stop current animation
			currentTrack:Stop()
			currentTrack = nil
			playButton.Text = "▶"
			playButton.BackgroundTransparency = 0.5
		else
			-- Play new animation
			playButton.BackgroundTransparency = 0.5
			playButton.Text = "▶"

			currentTrack = playAnimation(idBox.Text)

			-- Set up track ended callback
			if currentTrack then
				currentTrack.Stopped:Connect(function()
					playButton.Text = "▶"
					playButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					playButton.BackgroundTransparency = 0.5
					currentTrack = nil
				end)
			else
				-- Animation failed to load
				playButton.Text = "▶"
				playButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			end
		end
	end)

	-- Update ScrollingFrame canvas size
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #scrollFrame:GetChildren() * 27)
end

-- Function to hook into animation plays
local function hookAnimations(character)
	print("Hooking animations for character:", character.Name)  -- Debug print

	local humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	print("Got animator:", animator)  -- Debug print

	animator.AnimationPlayed:Connect(function(animTrack)
		local animId = extractId(animTrack.Animation.AnimationId)
		-- Only log if we haven't seen this animation before
		if not loggedAnimations[animId] then
			loggedAnimations[animId] = true
			createLogEntry(animTrack.Animation.AnimationId)
		end
	end)
end

-- Hook into all characters
local function hookAllCharacters()
	-- Hook existing characters
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			hookAnimations(player.Character)
		end
	end

	-- Hook into workspace children for NPCs and other models
	for _, model in ipairs(workspace:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChild("Humanoid") then
			hookAnimations(model)
		end
	end
end

-- Set up the logger
local player = Players.LocalPlayer
gui.Parent = player.PlayerGui

print("Setting up animation logger")  -- Debug print

-- Hook into new players joining
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(hookAnimations)
end)

-- Hook into new models being added to workspace
workspace.ChildAdded:Connect(function(child)
	if child:IsA("Model") and child:FindFirstChild("Humanoid") then
		hookAnimations(child)
	end
end)

-- Hook into existing players and characters
hookAllCharacters()

-- Hook into character respawns for existing players
for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(hookAnimations)
end
