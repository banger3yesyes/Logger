local SoundLogger = {}
SoundLogger.__index = SoundLogger

function SoundLogger.new()
	local self = setmetatable({}, SoundLogger)
	self.sounds = {}
	self.connections = {}
	self.isScanning = false
	self:createGui()
	return self
end

function SoundLogger:createGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "SoundLoggerGui"
	gui.ResetOnSpawn = false

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 400, 0, 300)
	mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
	mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	mainFrame.BackgroundTransparency = 0.5
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = gui

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 4)
	UICorner.Parent = mainFrame

	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	mainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)

	mainFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = "Sound Logger by Banger"
	title.TextSize = 18
	title.Font = Enum.Font.SourceSans
	title.Parent = mainFrame

	local buttonsFrame = Instance.new("Frame")
	buttonsFrame.Name = "ButtonsFrame"
	buttonsFrame.Size = UDim2.new(1, 0, 0, 40)
	buttonsFrame.Position = UDim2.new(0, 0, 0, 35)
	buttonsFrame.BackgroundTransparency = 1
	buttonsFrame.Parent = mainFrame

	local buttonNames = {"Scan All", "Workspace", "Auto Scan", "Stop", "Clear"}
	local buttonFunctions = {
		self.scanEverything,
		self.scanWorkspace,
		self.autoScan,
		self.stopScanning,
		self.clear
	}

	for i, name in ipairs(buttonNames) do
		local button = Instance.new("TextButton")
		button.Name = name:gsub(" ", "") .. "Button"
		button.Size = UDim2.new(0.18, 0, 0, 30)
		button.Position = UDim2.new(0.02 + (0.2 * (i-1)), 0, 0, 0)
		button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		button.BackgroundTransparency = 0.4
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.Text = name
		button.TextSize = 14
		button.Font = Enum.Font.Gotham
		button.Parent = buttonsFrame

		local UICorner2 = Instance.new("UICorner")
		UICorner2.CornerRadius = UDim.new(0, 4)
		UICorner2.Parent = button

		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		end)
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		end)

		button.MouseButton1Click:Connect(function()
			buttonFunctions[i](self)
			self:updateSoundList()
		end)
	end

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "SoundList"
	scrollFrame.Size = UDim2.new(1, -20, 1, -85)
	scrollFrame.Position = UDim2.new(0, 10, 0, 80)
	scrollFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	scrollFrame.BackgroundTransparency = 0.7
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.Parent = mainFrame

	local UICorner3 = Instance.new("UICorner")
	UICorner3.CornerRadius = UDim.new(0, 4)
	UICorner3.Parent = scrollFrame

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 20, 0, 20)
	closeButton.Position = UDim2.new(1, -25, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	closeButton.BackgroundTransparency = 0.4
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 14
	closeButton.Font = Enum.Font.SourceSans
	closeButton.Parent = mainFrame

	local UICorner6 = Instance.new("UICorner")
	UICorner6.CornerRadius = UDim.new(0, 4)
	UICorner6.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	closeButton.MouseEnter:Connect(function()
		closeButton.BackgroundTransparency = 0.2
	end)
	closeButton.MouseLeave:Connect(function()
		closeButton.BackgroundTransparency = 0.4
	end)

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Size = UDim2.new(0, 20, 0, 20)
	minimizeButton.Position = UDim2.new(1, -50, 0, 5)
	minimizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	minimizeButton.BackgroundTransparency = 0.4
	minimizeButton.Text = "-"
	minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeButton.TextSize = 14
	minimizeButton.Font = Enum.Font.SourceSans
	minimizeButton.Parent = mainFrame

	local UICorner7 = Instance.new("UICorner")
	UICorner7.CornerRadius = UDim.new(0, 4)
	UICorner7.Parent = minimizeButton

	local isMinimized = false
	minimizeButton.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		if isMinimized then
			local originalSize = mainFrame.Size
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			local tween = game:GetService("TweenService"):Create(mainFrame, tweenInfo, {
				Size = UDim2.new(0, originalSize.X.Offset, 0, 35)
			})

			scrollFrame.Visible = false
			buttonsFrame.Visible = false
			tween:Play()
		else
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			local tween = game:GetService("TweenService"):Create(mainFrame, tweenInfo, {
				Size = UDim2.new(0, 400, 0, 300)
			})

			tween.Completed:Connect(function()
				scrollFrame.Visible = true
				buttonsFrame.Visible = true
			end)

			tween:Play()
		end
	end)

	minimizeButton.MouseEnter:Connect(function()
		minimizeButton.BackgroundTransparency = 0.2
	end)
	minimizeButton.MouseLeave:Connect(function()
		minimizeButton.BackgroundTransparency = 0.4
	end)

	self.gui = gui
	self.scrollFrame = scrollFrame

	local Player = game:GetService("Players")
	gui.Parent = Player.LocalPlayer.PlayerGui
end

function SoundLogger:updateSoundList()
	for _, child in ipairs(self.scrollFrame:GetChildren()) do
		child:Destroy()
	end

	local function getNumericID(assetId)
		return assetId:match("%d+") or assetId
	end

	local yPos = 0
	for i, soundData in ipairs(self.sounds) do
		local container = Instance.new("Frame")
		container.Name = "SoundItem_" .. i
		container.Size = UDim2.new(1, -50, 0, 60)
		container.Position = UDim2.new(0, 5, 0, yPos)
		container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		container.BackgroundTransparency = 0.4
		container.BorderSizePixel = 0
		container.Parent = self.scrollFrame

		local UICorner4 = Instance.new("UICorner")
		UICorner4.CornerRadius = UDim.new(0, 4)
		UICorner4.Parent = container

		local playButton = Instance.new("TextButton")
		playButton.Size = UDim2.new(0, 35, 0, 35)
		playButton.Position = UDim2.new(1, 5, 0.5, -17.5)
		playButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		playButton.BackgroundTransparency = 0.4
		playButton.Text = "▶"
		playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		playButton.TextSize = 18
		playButton.Font = Enum.Font.GothamBold
		playButton.Parent = container

		local UICorner5 = Instance.new("UICorner")
		UICorner5.CornerRadius = UDim.new(0, 4)
		UICorner5.Parent = playButton

		local originalLooped = soundData.sound.Looped
		local isPlaying = false

		playButton.MouseButton1Click:Connect(function()
			if isPlaying then
				soundData.sound:Stop()
				soundData.sound.Looped = originalLooped
				playButton.Text = "▶"
				playButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			else
				for _, otherItem in ipairs(self.scrollFrame:GetChildren()) do
					if otherItem:IsA("Frame") and otherItem ~= container then
						local otherButton = otherItem:FindFirstChild("TextButton")
						if otherButton then
							local otherSoundData = self.sounds[tonumber(otherItem.Name:match("%d+"))]
							if otherSoundData then
								otherSoundData.sound:Stop()
								otherSoundData.sound.Looped = originalLooped
								otherButton.Text = "▶"
								otherButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
							end
						end
					end
				end

				soundData.sound.Looped = true
				soundData.sound:Play()
				playButton.Text = ">"
				playButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
			end
			isPlaying = not isPlaying
		end)

		playButton.MouseEnter:Connect(function()
			playButton.BackgroundTransparency = 0.2
		end)
		playButton.MouseLeave:Connect(function()
			playButton.BackgroundTransparency = 0.4
		end)

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -10, 0, 20)
		nameLabel.Position = UDim2.new(0, 5, 0, 5)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = "Name: " .. soundData.name
		nameLabel.TextSize = 14
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.Parent = container

		local idBox = Instance.new("TextBox")
		idBox.Size = UDim2.new(1, -10, 0, 20)
		idBox.Position = UDim2.new(0, 5, 0, 25)
		idBox.BackgroundTransparency = 1
		idBox.TextColor3 = Color3.fromRGB(200, 200, 200)
		idBox.TextXAlignment = Enum.TextXAlignment.Left
		idBox.Text = getNumericID(soundData.id)
		idBox.TextEditable = false
		idBox.ClearTextOnFocus = false
		idBox.TextSize = 12
		idBox.Font = Enum.Font.Gotham
		idBox.Parent = container

		local statusLabel = Instance.new("TextLabel")
		statusLabel.Size = UDim2.new(1, -10, 0, 20)
		statusLabel.Position = UDim2.new(0, 5, 0, 45)
		statusLabel.BackgroundTransparency = 1
		statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		statusLabel.TextXAlignment = Enum.TextXAlignment.Left
		local timeAgo = soundData.timeLogged and os.time() - soundData.timeLogged or 0
		statusLabel.Text = string.format("Parent: %s | Volume: %.1f | %s ago", 
			soundData.parent, soundData.volume, timeAgo .. "s")
		statusLabel.TextSize = 12
		statusLabel.Font = Enum.Font.Gotham
		statusLabel.Parent = container

		yPos = yPos + 65
	end

	self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

local function scanInstance(self, instance)
	for _, child in ipairs(instance:GetDescendants()) do
		if child:IsA("Sound") then
			table.insert(self.sounds, {
				sound = child,
				name = child.Name,
				id = child.SoundId,
				parent = child.Parent.Name,
				volume = child.Volume,
				playing = child.Playing
			})
		end
	end

	local connection = instance.DescendantAdded:Connect(function(child)
		if child:IsA("Sound") then
			table.insert(self.sounds, {
				sound = child,
				name = child.Name,
				id = child.SoundId,
				parent = child.Parent.Name,
				volume = child.Volume,
				playing = child.Playing
			})
			self:updateSoundList()
		end
	end)
	table.insert(self.connections, connection)
	self:updateSoundList()
end

function SoundLogger:scanEverything()
	if self.isScanning then
		self:stopScanning()
	end
	self.isScanning = true
	scanInstance(self, game)
end

function SoundLogger:scanWorkspace()
	if self.isScanning then
		self:stopScanning()
	end
	self.isScanning = true
	scanInstance(self, game.Workspace)
end

function SoundLogger:autoScan()
	if self.isScanning then
		self:stopScanning()
	end
	self.isScanning = true

	local function onSoundPlayed(sound)
		if not sound:IsA("Sound") then return end

		for _, soundData in ipairs(self.sounds) do
			if soundData.sound == sound then
				return
			end
		end

		table.insert(self.sounds, {
			sound = sound,
			name = sound.Name,
			id = sound.SoundId,
			parent = sound.Parent.Name,
			volume = sound.Volume,
			playing = sound.Playing,
			timeLogged = os.time()
		})
		self:updateSoundList()
	end

	for _, instance in ipairs(game:GetDescendants()) do
		if instance:IsA("Sound") then
			local connection = instance:GetPropertyChangedSignal("Playing"):Connect(function()
				if instance.Playing then
					onSoundPlayed(instance)
				end
			end)
			table.insert(self.connections, connection)
		end
	end

	local connection = game.DescendantAdded:Connect(function(instance)
		if instance:IsA("Sound") then
			local connection = instance:GetPropertyChangedSignal("Playing"):Connect(function()
				if instance.Playing then
					onSoundPlayed(instance)
				end
			end)
			table.insert(self.connections, connection)
		end
	end)
	table.insert(self.connections, connection)
end

function SoundLogger:stopScanning()
	self.isScanning = false
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
	self.connections = {}
end

function SoundLogger:getSounds()
	return self.sounds
end

function SoundLogger:clear()
	self.sounds = {}
	self:updateSoundList()
end

local logger = SoundLogger.new()
return logger
