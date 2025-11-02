-- Strike Hub GUI (with Blur Effect + Draggable + Rounded + Mobile Compatible)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create blur effect
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Enabled = false
blur.Parent = Lighting

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StrikeHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 520, 0, 340)
mainFrame.Position = UDim2.new(0, 20, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Rounded corners for GUI
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.Text = "Strike Hub"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Hide Button
local hideBtn = Instance.new("TextButton")
hideBtn.Name = "HideButton"
hideBtn.Parent = titleBar
hideBtn.Text = "Hide"
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 14
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
hideBtn.BorderSizePixel = 0
hideBtn.Size = UDim2.new(0, 60, 1, 0)
hideBtn.Position = UDim2.new(1, -65, 0, 0)
local hideCorner = Instance.new("UICorner")
hideCorner.CornerRadius = UDim.new(0, 10)
hideCorner.Parent = hideBtn

-- Tabs Frame
local tabsFrame = Instance.new("ScrollingFrame")
tabsFrame.Name = "TabsFrame"
tabsFrame.Parent = mainFrame
tabsFrame.Size = UDim2.new(0, 130, 1, -35)
tabsFrame.Position = UDim2.new(0, 0, 0, 35)
tabsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tabsFrame.BorderSizePixel = 0
tabsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
tabsFrame.ScrollBarThickness = 6
local tabsCorner = Instance.new("UICorner")
tabsCorner.CornerRadius = UDim.new(0, 10)
tabsCorner.Parent = tabsFrame

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.Parent = tabsFrame
tabsLayout.Padding = UDim.new(0, 6)
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Parent = mainFrame
contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
contentFrame.Position = UDim2.new(0, 135, 0, 40)
contentFrame.Size = UDim2.new(1, -145, 1, -50)
contentFrame.BorderSizePixel = 0
local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 10)
contentCorner.Parent = contentFrame

-- Tabs
local tabNames = {"Current Event", "Optimization", "Auto Farm", "Egg", "Auto Quest", "Mailbox", "Huge Hunter", "Dupe", "Player", "Misc"}
local tabPages = {}

local function createPage(name)
	local page = Instance.new("Frame")
	page.Name = name .. "Page"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = contentFrame

	local label = Instance.new("TextLabel")
	label.Parent = page
	label.Size = UDim2.new(1, -20, 0, 30)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.BackgroundTransparency = 1
	label.Text = name .. " Page"
	label.Font = Enum.Font.Gotham
	label.TextSize = 18
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextXAlignment = Enum.TextXAlignment.Left

	return page
end

for _, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton")
	btn.Name = name .. "Tab"
	btn.Parent = tabsFrame
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Gotham
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 14

	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 8)
	tabCorner.Parent = btn

	local page = createPage(name)
	tabPages[name] = page

	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(tabPages) do
			p.Visible = false
		end
		page.Visible = true
	end)
end

tabPages["Current Event"].Visible = true
tabsFrame.CanvasSize = UDim2.new(0, 0, 0, #tabNames * 36)

-- Open Button
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenStrikeHubButton"
openBtn.Parent = screenGui
openBtn.Size = UDim2.new(0, 160, 0, 40)
openBtn.Position = UDim2.new(0, 20, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 16
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Text = "Open Strike Hub"
openBtn.BorderSizePixel = 0
openBtn.Visible = false
local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 10)
openCorner.Parent = openBtn

-- Smooth blur functions
local function smoothBlur(targetSize)
	task.spawn(function()
		blur.Enabled = true
		for i = blur.Size, targetSize, (targetSize > blur.Size and 1 or -1) do
			blur.Size = i
			task.wait(0.02)
		end
		if targetSize == 0 then
			blur.Enabled = false
		end
	end)
end

-- Hide / Show GUI + blur
hideBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	openBtn.Visible = true
	smoothBlur(0)
end)

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openBtn.Visible = false
	smoothBlur(15)
end)

-- Enable drag on all devices
local dragging = false
local dragStart, startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

local function startDrag(input)
	dragging = true
	dragStart = input.Position
	startPos = mainFrame.Position

	local connection
	connection = input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			dragging = false
			connection:Disconnect()
		end
	end)
end

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		startDrag(input)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateDrag(input)
	end
end)

-- Enable drag after 5 seconds
mainFrame.Active = false
task.delay(5, function()
	mainFrame.Active = true
end)

-- Enable blur immediately on open
smoothBlur(15)
