-- A centred, borderless webview overlay that Escape dismisses. Each call to
-- M.new returns an independent overlay with its own toggle.
local M = {}

function M.new()
    local o = {}
    local webview = nil
    local escTap = nil

    function o.hide()
        if webview then webview:delete(); webview = nil end
        if escTap then escTap:stop(); escTap = nil end
    end

    -- build(screenFrame) returns html, width, height, or nil to show nothing.
    function o.toggle(build)
        if webview then o.hide(); return end

        local screen = hs.screen.mainScreen():frame()
        local html, w, h = build(screen)
        if not html then return end

        webview = hs.webview.new(hs.geometry.rect(screen.x + (screen.w - w) / 2, screen.y + (screen.h - h) / 2, w, h))
            :windowStyle({"borderless", "utility", "HUD"})
            :level(hs.drawing.windowLevels.overlay)
            :shadow(true):alpha(0.95):html(html)
            :show():bringToFront(true)

        -- Escape to dismiss
        escTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
            if e:getKeyCode() == 53 then o.hide(); return true end
        end):start()
    end

    return o
end

return M
