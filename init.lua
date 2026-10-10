-- Start the reload watcher before loading anything that can fail, so a load
-- that breaks part-way (a half-applied git pull, a typo) still reloads on the
-- next change. If reload.lua itself fails, fall back to reloading on any
-- change; the global keeps that watcher from being garbage-collected.
local reloadOk, reloadErr = pcall(function() require("reload").start() end)
if not reloadOk then
    print("reload.lua failed, reloading on any change instead: " .. tostring(reloadErr))
    reloadFallbackWatcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()
end

hs.loadSpoon("AClock")
hs.loadSpoon("Emojis")
hs.loadSpoon("FloatCalendar")
local expanse = require("expanse")
local spotify = require("spotify")
local cheatsheet = require("cheatsheet")
local leader = require("leader")

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
