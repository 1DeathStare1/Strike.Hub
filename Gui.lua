
-- Strike Hub GUI (Full Version)
-- All main tabs, sub tabs, toggle boxes, blur, draggable, mobile compatible

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

-- Tabs Frame (scrollable)
local tabsFrame = Instance.new("ScrollingFrame")
tabsFrame.Name = "TabsFrame"
tabsFrame.Parent = mainFrame
tabsFrame.Size = UDim2.new(0, 130, 1, -35)
tabsFrame.Position = UDim2.new(0, 0, 0, 35)
tabsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tabsFrame.BorderSizePixel = 0
tabsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
tabsFrame.ScrollBarThickness = 6
tabsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
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

-- Main Tabs & Sub Tabs
local tabNames = {"Current Event", "Optimization", "Auto Farm", "Egg", "Auto Quest", "Mailbox", "Huge Hunter", "Dupe", "Player", "Misc"}
local tabPages = {}

local subTabs = {
    ["Current Event"] = {"Auto place event eggs", "Auto place event pets", "Auto claim event pillars", "Auto buy event eggs"},
    ["Optimization"] = {"Disable breakables models", "Disable effects rendering", "Disable confetti rendering"},
    ["Auto Farm"] = {"Infinite pet speed", "Auto tap", "Auto efficient farm", "Collect orbs", "Auto use ultimate", "Auto rebirth"},
    ["Egg"] = {"Auto buy selected egg", "Disable egg animation"},
    ["Auto Quest"] = {"Auto rank quest", "Auto world quests"},
    ["Mailbox"] = {"Auto claim mailbox", "Auto mail pets"},
    ["Huge Hunter"] = {"Activate huge egg", "Activate titanic egg"},
    ["Dupe"] = {"Dupe mailbox", "Dupe current pets"},
    ["Player"] = {"Walk speed increase", "No clip enabler"},
    ["Misc"] = {"Auto claim free gifts", "Auto claim rank rewards", "Auto claim free forever pack", "Auto find shiny relics"}
}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 6
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = contentFrame

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = page
    pageLayout.Padding = UDim.new(0, 4)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    for _, subName in ipairs(subTabs[name] or {}) do
        local subFrame = Instance.new("Frame")
        subFrame.Size = UDim2.new(1, -10, 0, 30)
        subFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
        subFrame.BorderSizePixel = 0
        subFrame.Parent = page
        local subCorner = Instance.new("UICorner")
        subCorner.CornerRadius = UDim.new(0, 8)
        subCorner.Parent = subFrame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 20, 0, 20)
        toggle.Position = UDim2.new(1, -25, 0, 5)
        toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        toggle.BorderSizePixel = 0
        toggle.Text = ""
        toggle.Parent = subFrame
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 4)
        toggleCorner.Parent = toggle

        toggle.MouseButton1Click:Connect(function()
            if toggle.BackgroundColor3 == Color3.fromRGB(35,35,35) then
                toggle.BackgroundColor3 = Color3.fromRGB(180,200,220)
            else
                toggle.BackgroundColor3 = Color3.fromRGB(35,35,35)
            end
        end)

        local subLabel = Instance.new("TextLabel")
        subLabel.Parent = subFrame
        subLabel.BackgroundTransparency = 1
        subLabel.Position = UDim2.new(0,10,0,0)
        subLabel.Size = UDim2.new(1,-40,1,0)
        subLabel.Text = subName
        subLabel.Font = Enum.Font.Gotham
        subLabel.TextSize = 14
        subLabel.TextColor3 = Color3.fromRGB(255,255,255)
        subLabel.TextXAlignment = Enum.TextXAlignment.Left
    end

    return page
end

local activeTabButton
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

        for _, b in pairs(tabsFrame:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(45,45,45)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        activeTabButton = btn
    end)
end

tabPages["Current Event"].Visible = true
activeTabButton = tabsFrame:FindFirstChild("Current EventTab")
activeTabButton.BackgroundColor3 = Color3.fromRGB(70,70,70)

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

-- Blur functions
local function smoothBlur(targetSize)
    task.spawn(function()
        blur.Enabled = true
        for i = blur.Size, targetSize, (targetSize > blur.Size and 1 or -1) do
            blur.Size = i
            task.wait(0.02)
        end
        if targetSize == 0 then blur.Enabled = false end
    end)
end

-- Hide/Open GUI + blur
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

-- Dragging for all devices
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
task.delay(5, function() mainFrame.Active = true end)

-- Enable blur immediately on open
smoothBlur(15)
