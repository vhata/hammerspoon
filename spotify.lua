local as = require "hs.applescript"
local M = {}

-- Internal function to pass a command to Applescript.
local function tell(cmd)
    local _cmd = 'tell application "Spotify" to ' .. cmd
    local ok, result = as.applescript(_cmd)
    if ok then
        return result
    else
        return nil
    end
end

-- Seconds to wait for album art before sending the notification without it.
local ARTWORK_TIMEOUT = 3

-- Fetch the current track's album art in the background and call fn exactly
-- once, within ARTWORK_TIMEOUT seconds: with an hs.image, or with nil if there
-- is no art, the fetch fails or it is too slow. Art that arrives later is
-- dropped.
local function albumart(fn)
    local uri = tell('artwork url of current track')
    -- imageFromURL never calls back for a URL it cannot parse, so check with
    -- the same parser (NSURL) first.
    if type(uri) ~= "string" or uri == "" or hs.http.urlParts(uri).absoluteString == nil then
        fn(nil)
        return
    end
    -- Whichever of the fetch and the timer finishes first calls fn; timer is
    -- nil from then on, so the other is a no-op. Both callbacks capture timer,
    -- which keeps it referenced until it fires or is stopped; clearing it
    -- then lets it be collected.
    local timer
    local function finish(image)
        if not timer then
            return
        end
        timer:stop()
        timer = nil
        fn(image)
    end
    timer = hs.timer.doAfter(ARTWORK_TIMEOUT, function() finish(nil) end)
    hs.image.imageFromURL(uri, finish)
end

function M.nowPlaying()
    if not hs.spotify.isRunning() then
        hs.alert.show("Spotify isn't running")
        return
    end

    local track = hs.spotify.getCurrentTrack()
    if not track then
        hs.alert.show("No track loaded")
        return
    end

    local artist = hs.spotify.getCurrentArtist() or "Unknown Artist"
    local album = hs.spotify.getCurrentAlbum() or "Unknown Album"
    local message = artist .. " - " .. track .. " [" .. album .. "]"

    if not hs.spotify.isPlaying() then
        message = message .. "\nPaused"
    end

    albumart(function(image)
        hs.notify.new({
            title = "Now Playing",
            informativeText = message,
            contentImage = image
        }):send()
    end)
end

local hotkeys = require("hotkeys")
hotkeys.bind({}, "f14", "Spotify now playing", M.nowPlaying)
hotkeys.bind({}, "pad/", "Spotify now playing", M.nowPlaying)


-- Retain background tasks and their deadlines until they exit. Playback
-- commands share one slot so a slow command cannot be overtaken by another;
-- liking uses its own slot so a network request does not block playback.
local pending = {}
local PYTHON = os.getenv("HOME") .. "/.venv/3.12/bin/python"
local LIKE_HELPER = hs.configdir .. "/scripts/spotify-like.py"

local function run(slot, executable, args, timeout, callback)
    if pending[slot] then
        hs.alert.show("Spotify: " .. slot .. " is still running")
        return
    end
    local job = {}
    pending[slot] = job
    job.task = hs.task.new(executable, function(code, stdout, stderr)
        if job.timer then job.timer:stop() end
        pending[slot] = nil
        if not job.timedOut then callback(code, stdout, stderr) end
    end, args)
    if not job.task or not job.task:start() then
        pending[slot] = nil
        hs.alert.show("Spotify: couldn't start " .. slot)
        return
    end
    job.timer = hs.timer.doAfter(timeout, function()
        job.timedOut = true
        hs.alert.show("Spotify: " .. slot .. " timed out; check Spotify before retrying")
        job.task:terminate()
    end)
end

local function command(script, callback, slot)
    if not hs.spotify.isRunning() then
        hs.alert.show("Spotify isn't running")
        return
    end
    -- Guard again in the subprocess, and bound Apple Events as well as the
    -- process itself. No shell is involved and only fixed scripts are used.
    local source = 'if application "Spotify" is not running then error "Spotify is not running"\n'
        .. 'with timeout of 5 seconds\ntell application "Spotify"\n'
        .. script .. '\nend tell\nend timeout'
    run(slot or "playback", "/usr/bin/osascript", {"-e", source}, 8, function(code, stdout, stderr)
        if code ~= 0 then
            hs.alert.show("Spotify: command failed; see the Hammerspoon Console")
            print("Spotify command failed: " .. stderr)
        elseif callback then
            callback((stdout:gsub("%s+$", "")))
        end
    end)
end

function M.playPause() command("playpause") end
function M.next() command("next track") end
function M.previous() command("previous track") end
function M.restart() command("set player position to 0") end

local function seek(seconds)
    command(string.format([[
        set targetPosition to player position + %d
        set trackDuration to (duration of current track) / 1000
        if trackDuration <= 0 then error "No track loaded"
        if targetPosition < 0 then set targetPosition to 0
        if targetPosition > trackDuration then set targetPosition to trackDuration
        set player position to targetPosition
    ]], seconds))
end

function M.rewind() seek(-10) end
function M.forward() seek(10) end

local function volume(delta)
    command(string.format([[
        set targetVolume to sound volume + %d
        if targetVolume < 0 then set targetVolume to 0
        if targetVolume > 100 then set targetVolume to 100
        set sound volume to targetVolume
        return sound volume
    ]], delta), function(value) hs.alert.show("Spotify volume: " .. value .. "%") end)
end

function M.volumeUp() volume(5) end
function M.volumeDown() volume(-5) end

function M.shuffle()
    command([[
        if not shuffling enabled then error "Shuffle is unavailable in this context"
        set shuffling to not shuffling
        return shuffling
    ]], function(value) hs.alert.show("Spotify shuffle: " .. (value == "true" and "on" or "off")) end)
end

function M.like()
    if pending.like then
        hs.alert.show("Spotify: like is still running")
        return
    end
    command("return id of current track", function(uri)
        local id = uri:match("^spotify:track:([A-Za-z0-9]+)$")
        if not id or #id ~= 22 then
            hs.alert.show("Spotify: only catalogue songs can be liked")
            return
        end
        run("like", PYTHON, {LIKE_HELPER, uri}, 30, function(code)
            if code == 0 then
                hs.alert.show("Spotify: song saved to Liked Songs")
            elseif code == 3 then
                hs.alert.show("Spotify: authorize library changes (see README → Spotify likes)", 6)
            elseif code == 4 then
                hs.alert.show("Spotify: spotify-cli is missing from ~/.venv/3.12 (see README)", 6)
            else
                hs.alert.show("Spotify: couldn't confirm the like; check your connection and Liked Songs", 6)
            end
        end)
    end, "like")
end

return M
