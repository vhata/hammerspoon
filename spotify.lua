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

local function albumart()
    uri = tell('artwork url of current track')
    if uri == nil then
        return nil
    end
    return hs.image.imageFromURL(uri)
end

function spotifyPlaying()
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

    local notification = hs.notify.new({
        title = "Now Playing",
        informativeText = message,
        contentImage = albumart()
    }):send()
end

hs.hotkey.bind({}, "f14", spotifyPlaying)
hs.hotkey.bind({}, "pad/", spotifyPlaying)
