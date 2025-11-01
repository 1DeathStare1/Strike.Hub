-- gui.lua (with Player and Misc tabs, scrollable content)
local Player = game.Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StrikeGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Helper function to make rounded frames
local function roundFrame(frame, radius)
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = radius
    uicorner.Parent = frame
end

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 500)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
roundFrame(mainFrame, UDim.new(0, 10))
mainFrame.Visible = true
mainFrame.Parent = ScreenGui

-- Shadow
local shadow = Instance.new("Frame")
shadow.Size = mainFrame.Size + UDim2.new(0, 10, 0, 10)
shadow.Position = mainFrame.Position + UDim2.new(0, -5, 0, -5)
shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0
roundFrame(shadow, UDim.new(0, 12))
shadow.ZIndex = mainFrame.ZIndex - 1
shadow.Parent = ScreenGui

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
roundFrame(closeButton, UDim.new(0,5))
closeButton.Parent = mainFrame

-- Reopen button
local reopenButton = Instance.new("TextButton")
reopenButton.Size = UDim2.new(0, 50, 0, 25)
reopenButton.Position = UDim2.new(0, 10, 0, 10)
reopenButton.Text = "GUI"
reopenButton.Visible = false
reopenButton.TextColor3 = Color3.fromRGB(255,255,255)
reopenButton.BackgroundColor3 = Color3.fromRGB(0,180,0)
roundFrame(reopenButton, UDim.new(0,5))
reopenButton.Parent = ScreenGui

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    shadow.Visible = false
    reopenButton.Visible = true
end)

reopenButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    shadow.Visible = true
    reopenButton.Visible = false
end)

-- Draggable after 5 seconds
task.delay(5, function()
    mainFrame.Active = true
    mainFrame.Draggable = true
end)

-- Tab container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 35)
tabContainer.Position = UDim2.new(0, 0, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

-- Content container
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -10, 1, -80)
contentContainer.Position = UDim2.new(0, 5, 0, 70)
contentContainer.BackgroundColor3 = Color3.fromRGB(30,30,30)
roundFrame(contentContainer, UDim.new(0,8))
contentContainer.Parent = mainFrame

-- Tabs
local tabs = {"Current Event", "Optimization", "Auto Farm", "Egg", "Auto Quest", "Mailbox", "Huge Hunter", "Dupe", "Player", "Misc"}
local tabButtons = {}

local function switchTab(tabName)
    for _, frame in ipairs(contentContainer:GetChildren()) do
        if frame:IsA("ScrollingFrame") then
            frame.Visible = frame.Name == tabName
        end
    end
    for _, btn in ipairs(tabButtons) do
        if btn.Name == tabName then
            btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
        else
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        end
    end
end

-- Function to add placeholder elements
local function addPlaceholderContent(frame)
    for i = 0, 20 do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 25)
        label.Position = UDim2.new(0, 10, 0, 10 + i*30)
        label.Text = "Placeholder "..(i+1)
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.TextScaled = true
        label.Parent = frame
    end
end

-- Create tabs and content
for index, tabName in ipairs(tabs) do
    -- Tab button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 1, 0)
    button.Position = UDim2.new(0, (index-1)*105, 0, 0)
    button.Text = tabName
    button.BackgroundColor3 = Color3.fromRGB(50,50,50)
    button.TextColor3 = Color3.fromRGB(255,255,255)
    roundFrame(button, UDim.new(0,5))
    button.Name = tabName
    button.Parent = tabContainer
    table.insert(tabButtons, button)

    -- Hover effect
    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 ~= Color3.fromRGB(80,80,80) then
            button.BackgroundColor3 = Color3.fromRGB(70,70,70)
        end
    end)
    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 ~= Color3.fromRGB(80,80,80) then
            button.BackgroundColor3 = Color3.fromRGB(50,50,50)
        end
    end)

    -- Content scrolling frame
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1,0,1,0)
    content.Position = UDim2.new(0,0,0,0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Name = tabName
    content.CanvasSize = UDim2.new(0,0,0,650)
    content.ScrollBarThickness = 8
    content.Parent = contentContainer

    -- Add placeholder content
    addPlaceholderContent(content)

    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end

-- Show first tab by default
switchTab(tabs[1])
