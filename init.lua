hs.loadSpoon("AClock")
hs.loadSpoon("Emojis")
hs.loadSpoon("FloatCalendar")
hs.loadSpoon("ReloadConfiguration")
local expanse = require("expanse")
local spotify = require("spotify")
local hyper = require("hyper")
local cheatsheet = require("cheatsheet")
local leader = require("leader")

spoon.AClock:init()

local function app(key, name)
    return { key = key, label = name, fn = function() hs.application.launchOrFocus(name) end }
end

-- The leader tree: double-tap right Ctrl or right Shift, then press keys.
-- See leader.setup for the item format.
leader.setup({
    { key = "o", label = "Overlays", items = {
        { key = "c", label = "Clock", fn = function() spoon.AClock:toggleShow() end },
        { key = "l", label = "Calendar", fn = function() spoon.FloatCalendar:toggleShow() end },
        { key = "e", label = "Emoji picker", fn = function()
            local c = spoon.Emojis.chooser
            if c:isVisible() then c:hide() else c:show() end
        end },
        { key = "v", label = "Neovim cheatsheet", fn = function() cheatsheet.toggle() end },
    } },
    { key = "a", label = "Apps", items = {
        app("c", "Google Chrome"),
        -- app("s", "Spotify"),
        app("v", "Vivaldi"),
        app("o", "Obsidian"),
        app("d", "Discord"),
        -- app("w", "Discord Canary"),
        -- app("g", "Signal"),
    } },
})

spoon.ReloadConfiguration:start()
