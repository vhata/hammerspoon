local hotkeys = require("hotkeys")
local M = {}

local PASTE_TIMEOUT = 3
local pendingPaste = nil

local MAX_LENGTH = 100
-- a failure alert shows only the last few lines of expanse's stderr (the end
-- of a Python traceback); the console gets all of it
local MAX_ERROR_LINES = 3

-- hs.execute runs the command through /bin/sh, so wrap each word in single
-- quotes (closing, escaping and reopening around any embedded single quote)
-- to pass it through as one literal argument.
local function shell_quote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- Runs expanse and returns its stdout, or nil after alerting if it failed.
-- stderr goes to a temporary file rather than into the output, so a warning
-- can never end up on the clipboard or in the chooser, and a failure alert
-- can still say what went wrong.
local function call_expanse(args)
    local words = {shell_quote(os.getenv("HOME") .. "/bin/expanse")}
    for _, arg in ipairs(args) do
        table.insert(words, shell_quote(arg))
    end
    local errfile = os.tmpname()
    local command = table.concat(words, " ") .. " 2>" .. shell_quote(errfile)
    local output, status, exit_type, rc = hs.execute(command)
    local f = io.open(errfile, "r")
    local stderr = f and f:read("a") or ""
    if f then
        f:close()
    end
    os.remove(errfile)
    if not status then
        local lines = {}
        for line in stderr:gmatch("[^\r\n]+") do
            if line:find("%S") then
                table.insert(lines, line)
            end
        end
        local detail = table.concat(lines, "\n", math.max(1, #lines - MAX_ERROR_LINES + 1))
        if detail == "" then
            detail = tostring(exit_type) .. " " .. tostring(rc)
        end
        print("expanse: " .. command .. " failed (" .. tostring(exit_type) .. " " .. tostring(rc) .. "):\n" .. stderr)
        hs.alert.show("Error running expanse: " .. detail)
        return nil
    end
    return output
end

-- Both paths discard only the newline added by expanse's print(), keeping
-- whitespace and line breaks that belong to the expansion itself.
local function expansion_text(name, output)
    local expando = output:gsub("\r?\n$", "", 1)
    if expando == "" then
        -- expanse get prints nothing and exits 0 for an unknown name
        if output == "" then
            hs.alert.show('No expansion named "' .. name .. '"')
        else
            hs.alert.show('Expansion "' .. name .. '" is empty')
        end
        return nil
    end
    return expando
end

local function callback(choice)
    if not choice then
        return
    end
    -- "--" stops expanse reading a name that starts with "-" as an option
    local output = call_expanse({'get', '--', choice.text})
    if not output then
        return
    end
    local expando = expansion_text(choice.text, output)
    if expando then hs.pasteboard.setContents(expando) end
end

-- Fetch a named expansion without opening the picker or blocking the leader.
-- Keep the task and deadline referenced; allow only one paste at a time.
function M.paste(name)
    if pendingPaste then
        hs.alert.show("Expanse: a paste is still running")
        return
    end
    local window = hs.window.focusedWindow()
    local app = window and window:application()
    if not app or hs.application.frontmostApplication() ~= app then
        hs.alert.show("Expanse: focus a window before pasting")
        return
    end
    local job = {}
    pendingPaste = job
    job.task = hs.task.new(os.getenv("HOME") .. "/bin/expanse", function(code, stdout)
        if job.timer then job.timer:stop() end
        pendingPaste = nil
        if job.timedOut then return end
        if code ~= 0 then
            hs.alert.show("Expanse: couldn't read expansion " .. name)
            return
        end
        local expando = expansion_text(name, stdout)
        if not expando then return end
        -- A slow lookup must not send Cmd+V to a different window or app.
        if hs.window.focusedWindow() ~= window or hs.application.frontmostApplication() ~= app then
            hs.alert.show("Expanse: focus changed; paste cancelled")
            return
        end
        if not hs.pasteboard.setContents(expando) then
            hs.alert.show("Expanse: couldn't write to the clipboard")
            return
        end
        hs.eventtap.keyStroke({"cmd"}, "v", 0, app)
    end, {"get", "--", name})
    if not job.task or not job.task:start() then
        pendingPaste = nil
        hs.alert.show("Expanse: couldn't start the expansion lookup")
        return
    end
    job.timer = hs.timer.doAfter(PASTE_TIMEOUT, function()
        job.timedOut = true
        hs.alert.show("Expanse: expansion lookup timed out; paste cancelled")
        job.task:terminate()
    end)
end

local function get_expanses()
    local output = call_expanse({"dump"}) or ""
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

hotkeys.bind(hotkeys.hyper, "e", "Text-expansion picker", pick_expanse)

return M
