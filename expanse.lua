local logger = hs.logger.new("expanse", 'info')

MAX_LENGTH = 100

local function call_expanse(args)
    local command = os.getenv("HOME") .. "/bin/expanse " .. table.concat(args, " ")
    output, status = hs.execute(command)
    if not status then
        hs.alert.show("Error running expanse: " .. output)
    end
    return output
end

local function callback(choice)
    if not choice then
        return
    end
    local expando = call_expanse({'get', choice.text})
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

function pick_expanse()
    chooser = hs.chooser.new(callback)
    chooser:searchSubText(true)
    chooser:choices(get_expanses())
    chooser:show()
end

hs.hotkey.bind({"cmd", "alt"}, "e", pick_expanse)
