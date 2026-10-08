-- Renders the leader tree as an overlay. The page is generated from the same
-- items leader.setup bound, so the help cannot drift from the keys.
local overlay = require("overlay")

local M = {}
local view = overlay.new()

local function esc(s)
    return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function row(key, label)
    return "<li><kbd>" .. esc(key) .. "</kbd> " .. esc(label) .. "</li>"
end

-- Nested list for a group's items; subgroups nest their own lists.
local function list(items)
    local out = {}
    for _, item in ipairs(items) do
        if item.items then
            out[#out + 1] = '<li class="group"><kbd>' .. esc(item.key) .. "</kbd> " .. esc(item.label)
                .. "<ul>" .. list(item.items) .. "</ul></li>"
        else
            out[#out + 1] = row(item.key, item.label)
        end
    end
    return table.concat(out)
end

local function section(title, body)
    return "<section><h2>" .. title .. "</h2><ul>" .. body .. "</ul></section>"
end

-- tree: the bound items from leader.setup. builtins: { display, label } for
-- keys the leader binds in every layer. trigger: how to open the leader.
local function render(tree, builtins, trigger)
    local actions, groups = {}, {}
    for _, item in ipairs(tree) do
        if item.items then
            groups[#groups + 1] = section("<kbd>" .. esc(item.key) .. "</kbd> " .. esc(item.label), list(item.items))
        else
            actions[#actions + 1] = row(item.key, item.label)
        end
    end
    local always = {}
    for _, b in ipairs(builtins) do always[#always + 1] = row(b.display, b.label) end

    local sections = {}
    if #actions > 0 then sections[#sections + 1] = section("Top level", table.concat(actions)) end
    for _, g in ipairs(groups) do sections[#sections + 1] = g end
    sections[#sections + 1] = section("In any layer", table.concat(always))

    return [[<html><head><style>
        body { font-family: -apple-system, system-ui, sans-serif; background: #1e1e2e; color: #cdd6f4; padding: 20px 28px; }
        h1 { color: #cba6f7; font-size: 20px; margin: 0 0 4px; }
        p { color: #a6adc8; font-size: 12px; margin: 0 0 16px; }
        #content { columns: 2; column-gap: 28px; }
        section { break-inside: avoid; margin-bottom: 14px; }
        h2 { color: #89b4fa; font-size: 13px; text-transform: uppercase; margin: 0 0 6px; }
        ul { list-style: none; margin: 2px 0 0 7px; padding: 0 0 0 14px; border-left: 2px solid #313244; }
        li { font-size: 12px; padding: 2px 0; }
        li.group { color: #94e2d5; }
        li.group li { color: #cdd6f4; }
        kbd { display: inline-block; min-width: 14px; text-align: center; background: #313244; color: #f38ba8; padding: 1px 5px; border-radius: 4px; font-family: "SF Mono", Menlo, monospace; font-size: 11px; margin-right: 6px; }
        h2 kbd { font-size: 12px; text-transform: none; }
    </style></head><body>
    <h1>Leader</h1>
    <p>]] .. esc(trigger) .. [[, then press the keys below.</p>
    <div id="content">]] .. table.concat(sections) .. [[</div>
    </body></html>]]
end

function M.toggle(tree, builtins, trigger)
    view.toggle(function(screen)
        return render(tree, builtins, trigger), math.min(900, screen.w * 0.7), math.min(640, screen.h * 0.8)
    end)
end

return M
