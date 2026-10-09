-- Reloads the config once files it loads stop changing. Only .lua and .json
-- files count; anything under a hidden directory (.git, .worktrees, editor
-- swap files) or inside a nested checkout (a directory holding a .git entry,
-- such as a worktree) is ignored. Each matching change restarts a one-second
-- countdown, so a git pull reloads once, after its last write, rather than
-- on its first. init.lua starts this before loading anything else; see
-- docs/DECISIONS.md.
local M = {}

-- Seconds without a matching change before the reload.
M.delay = 1

-- Extensions of files the config reads while loading: modules, spoons, and
-- the spoons' JSON (docs.json, the Emojis data).
local EXTENSIONS = { lua = true, json = true }

-- Watcher and timer live at module level so the garbage collector, which
-- would stop them, cannot reach them while the module is loaded.
local watcher, timer

-- Returns path relative to the first root it lies under ("" for a root
-- itself) and that root, or nil if it is under none of them.
function M.relative(path, roots)
    for _, root in ipairs(roots) do
        if path == root then return "", root end
        if path:sub(1, #root + 1) == root .. "/" then return path:sub(#root + 2), root end
    end
    return nil
end

-- Whether a change at rel (relative to the config directory, "/"-separated)
-- should reload. isDir is true for an event that names a directory to be
-- rescanned rather than a file. hasGit(dir) reports whether the relative
-- directory dir contains a .git entry.
function M.isConfigPath(rel, isDir, hasGit)
    local parts = {}
    for part in rel:gmatch("[^/]+") do
        if part:sub(1, 1) == "." then return false end
        parts[#parts + 1] = part
    end
    local dirs = #parts
    if not isDir then
        if dirs == 0 then return false end
        if not EXTENSIONS[parts[dirs]:match("%.([^.]+)$")] then return false end
        dirs = dirs - 1
    end
    local dir = nil
    for i = 1, dirs do
        dir = dir and (dir .. "/" .. parts[i]) or parts[i]
        if hasGit(dir) then return false end
    end
    return true
end

function M.start()
    local configdir = hs.configdir:gsub("/+$", "")
    local roots = { configdir }
    -- FSEvents reports resolved paths, so also match a symlinked config dir.
    local real = hs.fs.pathToAbsolute(configdir)
    if real and real ~= configdir then roots[2] = real end

    timer = hs.timer.delayed.new(M.delay, hs.reload)
    watcher = hs.pathwatcher.new(configdir, function(paths, flagTables)
        for i, path in ipairs(paths) do
            local flags = flagTables and flagTables[i] or {}
            local rel, root = M.relative(path, roots)
            local function hasGit(dir)
                return hs.fs.attributes(root .. "/" .. dir .. "/.git") ~= nil
            end
            if rel and M.isConfigPath(rel, flags.mustScanSubDirs, hasGit) then
                if not timer:running() then print("reload: " .. (rel ~= "" and rel or "config directory") .. " changed, reloading when changes settle") end
                timer:start()
                return
            end
        end
    end):start()
end

return M
