-- Quick capture: type one line into a chooser and get a new note in a
-- vault's Intake folder, the same note ~/bin/intake makes for the Personal
-- vault from the menu-bar shortcut. init.lua binds a key per vault.
local M = {}

-- Percent-encode everything except unreserved characters, as jq's @uri does
-- in ~/bin/intake. UTF-8 is encoded byte by byte.
function M.encode(s)
    return (s:gsub("[^%w%-%._~]", function(c) return string.format("%%%02X", c:byte()) end))
end

-- The obsidian:// URL that creates the note, named for time as ~/bin/intake
-- names it. Empty text makes an empty note.
function M.noteURL(vault, text, time)
    local url = "obsidian://new?vault=" .. M.encode(vault)
        .. "&file=" .. M.encode("Intake/" .. os.date("%Y-%m-%d %H%M%S", time))
    if text ~= "" then url = url .. "&content=" .. M.encode(text) end
    return url
end

-- One chooser per vault, created on first use and held here so the garbage
-- collector cannot drop it while it is open.
local prompts = {}

local function newPrompt(vault)
    local p = {}
    p.chooser = hs.chooser.new(function(choice)
        if not choice then return end
        local url = M.noteURL(vault, choice.note, os.time())
        if not hs.urlevent.openURL(url) then
            print("capture: could not open " .. url)
            hs.alert.show("Could not open Obsidian for the " .. vault .. " note")
        end
    end)
    -- Return picks the selected row, so there is always exactly one: the text
    -- as typed. Setting a queryChangedCallback also stops the chooser
    -- filtering that row against the query.
    function p.update(query)
        p.chooser:choices({{
            text = query ~= "" and query or "(empty note)",
            subText = "Return: new note in " .. vault .. " › Intake    Esc: cancel",
            note = query,
        }})
    end
    p.chooser:placeholderText("Note for " .. vault .. " › Intake")
    p.chooser:queryChangedCallback(p.update)
    return p
end

-- Open the capture prompt for vault, empty.
function M.prompt(vault)
    local p = prompts[vault]
    if not p then
        p = newPrompt(vault)
        prompts[vault] = p
    end
    p.chooser:query("")
    p.update("")
    p.chooser:show()
end

return M
