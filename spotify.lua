local as = require "hs.applescript"

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

local function spotifyPlaying()
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

hs.hotkey.bind({}, "f14", spotifyPlaying)
hs.hotkey.bind({}, "pad/", spotifyPlaying)
