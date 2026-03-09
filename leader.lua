-- Double-tap right Ctrl, then press a key to trigger an action.
local M = {}
local bindings = {}
local modal = hs.hotkey.modal.new()
local lastRelease = 0
local timeout = nil

local function deactivate()
    modal:exit()
    if timeout then timeout:stop(); timeout = nil end
    hs.alert.closeAll()
end

function modal:entered()
    hs.alert.show("⌃⌃", 0.5)
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

-- Double-tap right ctrl detection
M.tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(e)
    if e:getKeyCode() ~= 62 then lastRelease = 0; return end
    if e:getFlags().ctrl then return end
    local now = hs.timer.secondsSinceEpoch()
    if (now - lastRelease) < 0.5 then
        lastRelease = 0
        modal:enter()
    else
        lastRelease = now
    end
end):start()

return M
