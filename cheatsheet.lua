local M = {}
local webview = nil

function M.toggle()
    if webview then
        webview:delete()
        webview = nil
        if M._escTap then M._escTap:stop(); M._escTap = nil end
        return
    end

    local path = os.getenv("HOME") .. "/.config/nvim/CHEATSHEET.md"
    local f = io.open(path, "r")
    if not f then hs.alert.show("Cheatsheet not found"); return end
    local md = f:read("*a")
    f:close()

    local screen = hs.screen.mainScreen():frame()
    local w, h = math.min(900, screen.w * 0.7), screen.h * 0.85

    local jsPath = os.getenv("HOME") .. "/.hammerspoon/marked.min.js"
    local jf = io.open(jsPath, "r")
    local markedJs = jf:read("*a")
    jf:close()

    local html = [[<html><head>
    <script>]] .. markedJs .. [[</script>
    <style>
        body { font-family: -apple-system, system-ui, sans-serif; background: #1e1e2e; color: #cdd6f4; padding: 24px 32px; }
        h1 { color: #cba6f7; font-size: 22px; } h2 { color: #89b4fa; font-size: 15px; text-transform: uppercase; }
        table { width: 100%; border-collapse: collapse; } th { color: #6c7086; font-size: 11px; text-transform: uppercase; text-align: left; }
        td, th { padding: 4px 10px; border-bottom: 1px solid #313244; font-size: 13px; } tr:hover { background: #252536; }
        code { background: #313244; color: #f38ba8; padding: 1px 6px; border-radius: 4px; font-family: "SF Mono", Menlo, monospace; font-size: 12px; }
        p { color: #a6adc8; font-size: 13px; }
    </style></head><body><div id="content"></div>
    <script>document.getElementById('content').innerHTML = marked.parse(]] .. hs.json.encode(md) .. [[);
    </script></body></html>]]

    webview = hs.webview.new(hs.geometry.rect((screen.w - w) / 2, (screen.h - h) / 2, w, h))
        :windowStyle({"borderless", "utility", "HUD"})
        :level(hs.drawing.windowLevels.overlay)
        :shadow(true):alpha(0.95):html(html)
        :show():bringToFront(true)

    -- Escape to dismiss
    M._escTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
        if e:getKeyCode() == 53 then M.toggle(); return true end
    end):start()
end

return M
