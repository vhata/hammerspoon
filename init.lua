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

-- Double-tap right Ctrl, then press a key:
leader.bind("c", function() spoon.AClock:toggleShow() end)
leader.bind("l", function() spoon.FloatCalendar:toggleShow() end)
leader.bind("e", function()
    local c = spoon.Emojis.chooser
    if c:isVisible() then c:hide() else c:show() end
end)
leader.bind("v", function() cheatsheet.toggle() end)

spoon.ReloadConfiguration:start()
