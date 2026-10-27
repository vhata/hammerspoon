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
local hotkeys = require("hotkeys")
local capture = require("capture")
require("expanse")
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
    { key = "s", label = "Spotify", items = {
        { key = "space", label = "Play / pause", fn = spotify.playPause },
        { key = "l", label = "Like current song", fn = spotify.like },
        { key = "/", label = "Now playing", fn = spotify.nowPlaying },
        { key = "n", label = "Next track", fn = spotify.next },
        { key = "p", label = "Previous track", fn = spotify.previous },
        { key = "left", label = "Rewind 10 seconds", fn = spotify.rewind },
        { key = "right", label = "Forward 10 seconds", fn = spotify.forward },
        { key = "r", label = "Restart track", fn = spotify.restart },
        { key = "s", label = "Toggle shuffle", fn = spotify.shuffle },
        { key = "up", label = "Volume up 5%", fn = spotify.volumeUp },
        { key = "down", label = "Volume down 5%", fn = spotify.volumeDown },
        app("o", "Spotify"),
    } },
    { key = "a", label = "Apps", items = {
        app("c", "Google Chrome"),
        app("v", "Vivaldi"),
        app("o", "Obsidian"),
        app("d", "Discord"),
        -- app("w", "Discord Canary"),
        app("t", "Todoist"),
        app("s", "Signal"),
        app("b", "Bitwarden"),
        app("w", "WhatsApp"),
        app("m", "Spotify"),
    } },
})

-- Global hotkeys, listed in the leader's help alongside the tree.
hotkeys.bind(hotkeys.hyper, "k", "New note in Personal › Intake", function() capture.prompt("Personal") end)
hotkeys.bind(hotkeys.hyper, "b", "New note in Books › Intake", function() capture.prompt("Books") end)
