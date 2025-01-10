hs.loadSpoon("AClock")
hs.loadSpoon("Emojis")
hs.loadSpoon("FloatCalendar")
hs.loadSpoon("ReloadConfiguration")
local expanse = require("expanse")
local spotify = require("spotify")
local hyper = require("hyper")

spoon.AClock:init()
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "C", function()
    spoon.AClock:toggleShow()
end)

hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "L", function()
    spoon.FloatCalendar:toggleShow()
end)

spoon.Emojis:bindHotkeys({
    toggle = {{"cmd", "alt", "ctrl", "shift"}, "E"}
})

spoon.ReloadConfiguration:start()
