hs.loadSpoon("AClock")
hs.loadSpoon("Emojis")
hs.loadSpoon("FloatCalendar")
hs.loadSpoon("ReloadConfiguration")
local expanse = require("expanse")
local spotify = require("spotify")

spoon.AClock:init()
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function()
    spoon.AClock:toggleShow()
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "L", function()
    spoon.FloatCalendar:toggleShow()
end)

spoon.Emojis:bindHotkeys({
    toggle = {{"cmd", "alt", "ctrl"}, "E"}
})

spoon.ReloadConfiguration:start()
