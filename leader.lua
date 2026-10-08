-- Double-tap right Ctrl (external keyboard) or right Shift (laptop),
-- then press a key to trigger an action.
local M = {}
local bindings = {}
local modal = hs.hotkey.modal.new()
local lastRelease = 0
local lastKey = nil
local pressedKey = nil
local timeout = nil

-- keycode -> { flag name, alert symbol }
local triggers = {
    [62] = { flag = "ctrl",  symbol = "⌃⌃" },
    [60] = { flag = "shift", symbol = "⇧⇧" },
}
local alertSymbol = "⇧⇧"

local function deactivate()
    modal:exit()
    if timeout then timeout:stop(); timeout = nil end
    hs.alert.closeAll()
end

function modal:entered()
    hs.alert.show(alertSymbol, 0.5)
    timeout = hs.timer.doAfter(1, deactivate)
end

function modal:exited() end

function M.bind(key, fn)
    modal:bind({}, key, function()
        deactivate()
        fn()
    end)
end

modal:bind({}, "escape", deactivate)

local keyDown = hs.eventtap.event.types.keyDown

-- A tap is a press and release of a trigger with nothing else in between.
-- Any keyDown (including a letter typed while the trigger is held, as in
-- Shift+I) or other modifier change cancels the pending tap.
M.tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged, keyDown}, function(e)
    if e:getType() == keyDown then
        -- Never swallow: the modal's own keys arrive here too.
        lastRelease = 0; lastKey = nil; pressedKey = nil
        return false
    end
    local kc = e:getKeyCode()
    local trigger = triggers[kc]
    if not trigger then lastRelease = 0; lastKey = nil; pressedKey = nil; return end
    if e:getFlags()[trigger.flag] then pressedKey = kc; return end
    if pressedKey ~= kc then lastRelease = 0; lastKey = nil; return end
    pressedKey = nil
    local now = hs.timer.secondsSinceEpoch()
    if lastKey == kc and (now - lastRelease) < 0.5 then
        lastRelease = 0
        lastKey = nil
        alertSymbol = trigger.symbol
        modal:enter()
    else
        lastRelease = now
        lastKey = kc
    end
end):start()

return M
