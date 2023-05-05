hs.loadSpoon("AClock")
hs.loadSpoon("Calendar")
hs.loadSpoon("Emojis")
hs.loadSpoon("ReloadConfiguration")
local spotify = require("spotify")

spoon.AClock:init()
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function()
    spoon.AClock:toggleShow()
end)

spoon.Emojis:bindHotkeys({
    toggle = {{"cmd", "alt", "ctrl"}, "E"}
})

spoon.ReloadConfiguration:start()
