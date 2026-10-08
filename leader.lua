-- Double-tap right Ctrl (external keyboard) or right Shift (laptop), then
-- press keys to walk the tree passed to M.setup. Each group in the tree is
-- its own hs.hotkey.modal: pressing a group's key swaps to that group's
-- modal and restarts the timeout; pressing an action's key closes the
-- leader and runs the action. Escape closes it and "?" shows the whole tree
-- from any layer.
local help = require("leaderhelp")

local M = {}

-- How long each layer waits for a key, in seconds.
local TIMEOUT = 1

-- Every modal built by M.setup, held so the garbage collector cannot stop it.
local modals = {}
local root = nil
-- The items M.setup actually bound, for the help overlay.
local tree = {}
local active = nil
local timer = nil

local lastRelease = 0
local lastKey = nil
local pressedKey = nil

-- keycode -> { flag name, alert symbol, name in the help }
local triggers = {
    [62] = { flag = "ctrl",  symbol = "⌃⌃", name = "right Ctrl" },
    [60] = { flag = "shift", symbol = "⇧⇧", name = "right Shift" },
}
local alertSymbol = "⇧⇧"

local function triggerText()
    local names = {}
    for _, t in pairs(triggers) do names[#names + 1] = t.name end
    table.sort(names)
    return "Double-tap " .. table.concat(names, " or ")
end

local function deactivate()
    if active then active:exit(); active = nil end
    if timer then timer:stop(); timer = nil end
    hs.alert.closeAll()
end

local function activate(modal, crumb)
    deactivate()
    active = modal
    modal:enter()
    hs.alert.show(crumb == "" and alertSymbol or (alertSymbol .. "  " .. crumb), TIMEOUT)
    timer = hs.timer.doAfter(TIMEOUT, deactivate)
end

-- Keys the leader binds in every layer itself. display and label are for
-- the help overlay.
local builtins
local function showHelp()
    deactivate()
    help.toggle(tree, builtins, triggerText())
end
builtins = {
    { mods = {"shift"}, key = "/", display = "?", label = "Show this help", fn = showHelp },
    { mods = {}, key = "escape", display = "esc", label = "Close the leader", fn = deactivate },
}

-- Unmodified keys taken by builtins, which tree items cannot use.
local reserved = {}
for _, b in ipairs(builtins) do
    if #b.mods == 0 then reserved[b.key] = true end
end

-- Why an item cannot be bound, or nil if it can.
local function problem(item, seen)
    if type(item) ~= "table" then return "not a table" end
    if type(item.key) ~= "string" or not hs.keycodes.map[item.key] then return "unknown key" end
    if reserved[item.key] then return "reserved key" end
    if seen[item.key] then return "duplicate key" end
    if type(item.label) ~= "string" then return "missing label" end
    if (type(item.fn) == "function") == (type(item.items) == "table") then
        return "needs exactly one of fn or items"
    end
end

-- Build a modal for one group's items. Returns the modal and the items that
-- were bound, so anything rendered from the tree matches what the keys do.
local function build(items, crumb)
    local modal = hs.hotkey.modal.new()
    modals[#modals + 1] = modal
    for _, b in ipairs(builtins) do modal:bind(b.mods, b.key, b.fn) end
    local bound, seen = {}, {}
    for _, item in ipairs(items) do
        local why = problem(item, seen)
        if why then
            print("leader: skipping " .. crumb .. " " .. tostring(type(item) == "table" and item.key) .. ": " .. why)
        elseif item.items then
            local childCrumb = crumb == "" and item.label or (crumb .. " › " .. item.label)
            local child, childItems = build(item.items, childCrumb)
            modal:bind({}, item.key, function() activate(child, childCrumb) end)
            seen[item.key] = true
            bound[#bound + 1] = { key = item.key, label = item.label, items = childItems }
        else
            local fn = item.fn
            modal:bind({}, item.key, function()
                deactivate()
                fn()
            end)
            seen[item.key] = true
            bound[#bound + 1] = { key = item.key, label = item.label, fn = fn }
        end
    end
    return modal, bound
end

-- Bind the leader tree. Each item is a table with a key (an hs.keycodes.map
-- name), a label, and either fn (an action) or items (a group of further
-- items). Call once; invalid items are skipped with a console message rather
-- than failing the reload.
function M.setup(items)
    root, tree = build(items, "")
end

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
        if root then activate(root, "") end
    else
        lastRelease = now
        lastKey = kc
    end
end):start()

return M
