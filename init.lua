hs.loadSpoon("AClock")
hs.loadSpoon("Calendar")
hs.loadSpoon("Emojis")

spoon.AClock:init()
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function()
    spoon.AClock:toggleShow()
end)

spoon.Emojis:bindHotkeys({
    toggle = {{"cmd", "alt", "ctrl"}, "E"}
})

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
hs.alert.show("Config loaded")
