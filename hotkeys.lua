-- Global hotkeys. Every module binds through M.bind, which records only the
-- hotkeys that actually registered, and the leader's help lists M.list(), so
-- the help shows exactly the global keys that work right now.
local M = {}

-- Caps Lock, which Karabiner-Elements turns into all four modifiers.
M.hyper = {"cmd", "alt", "ctrl", "shift"}

-- { mods, key, label, hotkey } for every hotkey M.bind registered. Holding
-- the hotkey here also keeps it from being garbage-collected.
local bound = {}

-- Bind fn to mods+key system-wide, labelled for the help. Returns the
-- hs.hotkey, or nil after a console message if the key does not exist on
-- this layout or macOS refused the combination; either way a failed binding
-- never fails the reload and never appears in the help.
function M.bind(mods, key, label, fn)
    local ok, hotkey = pcall(hs.hotkey.bind, mods, key, fn)
    if not ok or not hotkey then
        print("hotkeys: could not bind " .. table.concat(mods, "+") .. "+" .. key .. " (" .. label .. "): "
            .. (ok and "macOS refused it" or tostring(hotkey)))
        return nil
    end
    bound[#bound + 1] = { mods = mods, key = key, label = label, hotkey = hotkey }
    return hotkey
end

local SYMBOLS = { ctrl = "⌃", alt = "⌥", shift = "⇧", cmd = "⌘" }
local ORDER = {"ctrl", "alt", "shift", "cmd"}

local KEY_NAMES = {
    space = "Space", ["return"] = "Return", tab = "Tab", escape = "Esc", delete = "Delete",
    left = "←", right = "→", up = "↑", down = "↓",
}

-- How a combination is written in the help: "Hyper K", "⌘⌥E", "Keypad /".
function M.display(mods, key)
    local has = {}
    for _, m in ipairs(mods) do has[m] = true end
    local prefix = ""
    if has.ctrl and has.alt and has.shift and has.cmd then
        prefix = "Hyper "
    else
        for _, m in ipairs(ORDER) do
            if has[m] then prefix = prefix .. SYMBOLS[m] end
        end
    end
    local name = KEY_NAMES[key]
        or (key:match("^pad.") and "Keypad " .. key:sub(4))
        or key:upper()
    return prefix .. name
end

-- { display, label } for each bound hotkey that is live now, in the order the
-- modules bound them. hs.hotkey.getHotkeys() returns the one hotkey that
-- answers each combination, so a disabled hotkey, or one shadowed by a later
-- binding of the same keys, is left out.
function M.list()
    local live = {}
    for _, h in ipairs(hs.hotkey.getHotkeys()) do live[h] = true end
    local out = {}
    for _, b in ipairs(bound) do
        if live[b.hotkey] then
            out[#out + 1] = { display = M.display(b.mods, b.key), label = b.label }
        end
    end
    return out
end

return M
