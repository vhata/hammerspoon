local hyper = { "cmd", "alt", "ctrl"}

local applicationHotkeys = {
    c = 'Google Chrome',
    -- s = 'Spotify',
    v = 'Vivaldi',
    o = 'Obsidian',
    d = 'Discord',
    -- w = 'Discord Canary',
    -- g = 'Signal',
}

for key, app in pairs(applicationHotkeys) do
  hs.hotkey.bind(hyper, key, function()
    hs.application.launchOrFocus(app)
  end)
end
