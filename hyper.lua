local hyper = { "cmd", "alt", "ctrl", "shift" }

local applicationHotkeys = {
    c = 'Google Chrome',
    t = 'iTerm',
    s = 'Spotify',
    v = 'Visual Studio Code',
    o = 'Obsidian',
    d = 'Discord',
    w = 'Discord Canary',
    g = 'Signal',
    l = 'Slack',
  }
  for key, app in pairs(applicationHotkeys) do
    hs.hotkey.bind(hyper, key, function()
      hs.application.launchOrFocus(app)
      app_name = string.gsub(app, " ", "_") .. "_0"
      local j, st, t, rc = hs.execute("embiggen " .. app_name, true)
    end)
  end