local MAX_LENGTH = 100

-- hs.execute runs the command through /bin/sh, so wrap each word in single
-- quotes (closing, escaping and reopening around any embedded single quote)
-- to pass it through as one literal argument.
local function shell_quote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function call_expanse(args)
    local words = {shell_quote(os.getenv("HOME") .. "/bin/expanse")}
    for _, arg in ipairs(args) do
        table.insert(words, shell_quote(arg))
    end
    local command = table.concat(words, " ")
    local output, status = hs.execute(command)
    if not status then
        hs.alert.show("Error running expanse: " .. output)
    end
    return output
end

local function callback(choice)
    if not choice then
        return
    end
    -- "--" stops expanse reading a name that starts with "-" as an option
    local expando = call_expanse({'get', '--', choice.text})
    -- expanse prints the expansion with Python's print(), which adds a newline
    expando = expando:gsub("\r?\n$", "", 1)
    hs.pasteboard.setContents(expando)
end

local function get_expanses()
    local output = call_expanse({"dump"})
    local choices = {}
    for short, expando in output:gmatch("(.-)\r?\n(.-)\r?\n") do
        -- show the beginning and end of expando if it's too long
        if #expando > MAX_LENGTH then
            expando = expando:sub(1, math.floor((MAX_LENGTH - 4) / 2)) .. "..." ..
                          expando:sub(#expando - math.floor((MAX_LENGTH - 4) / 2), #expando)
        end
        table.insert(choices, {
            ["text"] = short,
            ["subText"] = expando
        })
    end
    return choices
end

local function pick_expanse()
    local chooser = hs.chooser.new(callback)
    chooser:searchSubText(true)
    chooser:choices(get_expanses())
    chooser:show()
end

hs.hotkey.bind({"cmd", "alt"}, "e", pick_expanse)
