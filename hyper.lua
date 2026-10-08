local hyper = { "cmd", "alt", "ctrl"}

-- embiggen lives on the login-shell PATH and itself calls yabai and jq by name.
-- Resolve its path and that PATH once per reload; this is the only blocking call
-- here. The escaped quotes and dollars survive hs.execute's own double quoting.
local resolved = hs.execute([[printf '%s\n%s\n' \"\$(command -v embiggen)\" \"\$PATH\"]], true) or ""
local embiggenPath, userPath = resolved:match("([^\n]*)\n([^\n]*)\n$")
if not embiggenPath or embiggenPath == "" then
  print("hyper: embiggen not found on the login-shell PATH; app hotkeys will only launch or focus")
  embiggenPath = nil
end

-- Running embiggen tasks and pending window waits, held so the garbage
-- collector cannot stop them mid-flight.
local tasks = {}
local waiting = {}

local function embiggen(app)
  if not embiggenPath then return end
  local app_name = (string.gsub(app, " ", "_")) .. "_0"
  local task
  task = hs.task.new(embiggenPath, function(rc, _, stdErr)
    tasks[task] = nil
    if rc ~= 0 then
      print("hyper: embiggen " .. app_name .. " exited " .. rc .. ": " .. stdErr)
    end
  end, { app_name })
  if not task then return end
  local env = task:environment()
  env.PATH = userPath
  task:setEnvironment(env)
  tasks[task] = true
  if not task:start() then tasks[task] = nil end
end

local function hasWindow(app)
  local running = hs.application.find(app, true)
  return running ~= nil and running:mainWindow() ~= nil
end

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
      local wasRunning = hs.application.find(app, true) ~= nil
      hs.application.launchOrFocus(app)
      -- A wait from an earlier press is still pending: leave it to embiggen.
      if waiting[app] then return end
      if wasRunning then
        embiggen(app)
        return
      end
      -- A cold launch has no window yet; wait up to 10 s for one.
      local deadline = hs.timer.secondsSinceEpoch() + 10
      waiting[app] = hs.timer.waitUntil(function()
        return hasWindow(app) or hs.timer.secondsSinceEpoch() > deadline
      end, function()
        waiting[app] = nil
        if hasWindow(app) then embiggen(app) end
      end, 0.2)
    end)
  end
