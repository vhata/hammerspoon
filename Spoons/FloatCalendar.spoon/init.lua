local obj = {}
obj.__index = obj

-- Metadata
obj.name = "FloatCalendar"
obj.version = "0.1"
obj.author = "Jonathan Hitchcock <jonathan.hitchcock@gmail.com>"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.calw = 260
obj.calh = 184

local logger = hs.logger.new("FloatCalendar", 'info')

local caltodaycolor = {
    red = 1,
    blue = 1,
    green = 1,
    alpha = 0.3
}
local calcolor = {
    red = 235 / 255,
    blue = 235 / 255,
    green = 235 / 255
}
local calbgcolor = {
    red = 0,
    blue = 0,
    green = 0,
    alpha = 0.8
}
local weeknumcolor = {
    red = 146 / 255,
    blue = 146 / 255,
    green = 246 / 255,
    alpha = 0.5
}
local othermonthcolor = {
    red = 246 / 255,
    blue = 246 / 255,
    green = 246 / 255,
    alpha = 0.3
}

function obj:updateCalCanvas()
    local now = os.date("*t")
    -- The date this drawing treats as today, for checkDate.
    self.today = {
        year = now.year,
        month = now.month,
        day = now.day
    }
    local titlestr = os.date("%B %Y", os.time {
        year = self.year,
        month = self.month,
        day = 1
    })
    self.canvas[2].text = titlestr
    local firstday_of_nextmonth = os.time {
        year = self.year,
        month = self.month + 1,
        day = 1
    }
    local maxday_of_currentmonth = os.date("*t", firstday_of_nextmonth - 24 * 60 * 60).day
    local maxday_of_lastmonth = os.date("*t", os.time {
        year = self.year,
        month = self.month,
        day = 0
    }).day
    local weekday_of_firstday = os.date("*t", os.time {
        year = self.year,
        month = self.month,
        day = 1
    }).wday
    -- os.date's wday is Sunday 1 .. Saturday 7; the grid is Monday-first
    local mweekday_of_firstday = (weekday_of_firstday + 5) % 7 + 1

    for i = 1, 6 do
        for k = 1, 7 do
            local caltable_idx = 7 * (i - 1) + k
            local pushbacked_value = caltable_idx - mweekday_of_firstday + 1
            if pushbacked_value <= 0 then
                self.canvas[9 + caltable_idx].text = maxday_of_lastmonth + pushbacked_value
                self.canvas[9 + caltable_idx].textColor = othermonthcolor
            elseif pushbacked_value > maxday_of_currentmonth then
                self.canvas[9 + caltable_idx].text = pushbacked_value - maxday_of_currentmonth
                self.canvas[9 + caltable_idx].textColor = othermonthcolor
            else
                self.canvas[9 + caltable_idx].text = pushbacked_value
                self.canvas[9 + caltable_idx].textColor = calcolor
            end
            if pushbacked_value == math.tointeger(now.day) then
                self.canvas[58].frame.x = tostring((10 + (self.calw - 20) / 8 * k) / self.calw)
                self.canvas[58].frame.y = tostring((10 + (self.calh - 20) / 8 * (i + 1)) / self.calh)
                if self.year == now.year and self.month == now.month then
                    self.canvas[58].action = 'fill'
                else
                    self.canvas[58].action = 'skip'
                end
            end
        end
    end
    -- update yearweek: ISO 8601 week of the Monday that starts each row.
    -- os.time normalises out-of-range days, and noon keeps DST from
    -- shifting the date.
    for i = 1, 6 do
        local monday_of_row = os.time {
            year = self.year,
            month = self.month,
            day = 1 - (mweekday_of_firstday - 1) + 7 * (i - 1),
            hour = 12
        }
        local yearweek_rowvalue = tonumber(os.date("%V", monday_of_row))
        self.canvas[51 + i].text = yearweek_rowvalue
        self.canvas[51 + i].textColor = weeknumcolor
    end
end

function obj:init()
    -- Positioned on each show(), on whichever screen is current then.
    if not self.canvas then
        self.canvas = hs.canvas.new({
            x = 0,
            y = 0,
            w = self.calw,
            h = self.calh
        })
    end

    self.canvas[1] = {
        id = "cal_bg",
        type = "rectangle",
        action = "fill",
        fillColor = calbgcolor,
        roundedRectRadii = {
            xRadius = 10,
            yRadius = 10
        }
    }

    self.canvas[2] = {
        id = "cal_title",
        type = "text",
        text = "",
        textFont = "Courier",
        textSize = 16,
        textColor = calcolor,
        textAlignment = "center",
        frame = {
            x = tostring(10 / self.calw),
            y = tostring(10 / self.calh),
            w = tostring(1 - 20 / self.calw),
            h = tostring((self.calh - 20) / 8 / self.calh)
        }
    }

    local weeknames = {"Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"}
    for i = 1, #weeknames do
        self.canvas[2 + i] = {
            id = "cal_weekday",
            type = "text",
            text = weeknames[i],
            textFont = "Courier",
            textSize = 16,
            textColor = calcolor,
            textAlignment = "center",
            frame = {
                x = tostring((10 + (self.calw - 20) / 8 * i) / self.calw),
                y = tostring((10 + (self.calh - 20) / 8) / self.calh),
                w = tostring((self.calw - 20) / 8 / self.calw),
                h = tostring((self.calh - 20) / 8 / self.calh)
            }
        }
    end

    -- Create 7x6 calendar table
    for i = 1, 6 do
        for k = 1, 7 do
            self.canvas[9 + 7 * (i - 1) + k] = {
                type = "text",
                text = "",
                textFont = "Courier",
                textSize = 16,
                textColor = calcolor,
                textAlignment = "center",
                frame = {
                    x = tostring((10 + (self.calw - 20) / 8 * k) / self.calw),
                    y = tostring((10 + (self.calh - 20) / 8 * (i + 1)) / self.calh),
                    w = tostring((self.calw - 20) / 8 / self.calw),
                    h = tostring((self.calh - 20) / 8 / self.calh)
                }
            }
        end
    end

    -- Create yearweek column
    for i = 1, 6 do
        self.canvas[51 + i] = {
            type = "text",
            text = "",
            textFont = "Courier",
            textSize = 16,
            textColor = weeknumcolor,
            textAlignment = "center",
            frame = {
                x = tostring(10 / self.calw),
                y = tostring((10 + (self.calh - 20) / 8 * (i + 1)) / self.calh),
                w = tostring((self.calw - 20) / 8 / self.calw),
                h = tostring((self.calh - 20) / 8 / self.calh)
            }
        }
    end

    -- today cover rectangle
    self.canvas[58] = {
        type = "rectangle",
        action = "fill",
        fillColor = caltodaycolor,
        roundedRectRadii = {
            xRadius = 3,
            yRadius = 3
        },
        frame = {
            x = tostring((10 + (self.calw - 20) / 8) / self.calw),
            y = tostring((10 + (self.calh - 20) / 8 * 2) / self.calh),
            w = tostring((self.calw - 20) / 8 / self.calw),
            h = tostring((self.calh - 20) / 8 / self.calh)
        }
    }

    self.year = tonumber(os.date("%Y"))
    self.month = tonumber(os.date("%m"))
end

function obj:prevMonth()
    self.month = self.month - 1
    if self.month < 1 then
        self.month = 12
        self.year = self.year - 1
    end
    self:updateCalCanvas()
end

function obj:nextMonth()
    self.month = self.month + 1
    if self.month > 12 then
        self.month = 1
        self.year = self.year + 1
    end
    self:updateCalCanvas()
end

function obj:prevYear()
    self.year = self.year - 1
    self:updateCalCanvas()
end

function obj:nextYear()
    self.year = self.year + 1
    self:updateCalCanvas()
end

function obj:resetDate()
    self.year = tonumber(os.date("%Y"))
    self.month = tonumber(os.date("%m"))
    self:updateCalCanvas()
end

-- How often, in seconds, the open calendar checks whether the date has
-- changed. A check every minute, rather than one timer set for midnight,
-- also catches a Mac that slept through midnight, and a clock or time zone
-- change.
local DATE_CHECK_INTERVAL = 60

-- Redraw when the date has changed since the last drawing. The calendar
-- follows today into a new month only if it was showing the month that
-- contained the previous today; a calendar the user has navigated to any
-- other month stays on it, and only its today highlight is updated.
function obj:checkDate()
    local now = os.date("*t")
    local seen = self.today
    if now.year == seen.year and now.month == seen.month and now.day == seen.day then
        return
    end
    if self.year == seen.year and self.month == seen.month then
        self.year = now.year
        self.month = now.month
    end
    self:updateCalCanvas()
end

function obj:isShowing()
    return self.canvas:isShowing()
end

-- Keys the open calendar answers, by keycode, each naming the method it
-- calls. Looked up on each show, as hs.hotkey.bind did, so a keyboard layout
-- change is picked up.
local function calendarKeys()
    local map = hs.keycodes.map
    return {
        [map.escape] = "hide",
        [map.left] = "prevMonth",
        [map.right] = "nextMonth",
        [map.up] = "prevYear",
        [map.down] = "nextYear",
        [map.r] = "resetDate"
    }
end

local eventTypes = hs.eventtap.event.types
local autorepeat = hs.eventtap.event.properties.keyboardEventAutorepeat

-- A toggle this soon after a key or click dismissed the calendar is taken to
-- come from that same keystroke sequence (a hotkey, or the leader's keys,
-- whose layers each wait one second) and leaves the calendar closed.
local TOGGLE_GRACE = 1

-- The calendar's keys reach it only while it is open, and only until the
-- user does anything else: any other key, a modified key or a mouse click
-- closes it and is passed on untouched, so the keys stop being taken as soon
-- as the user goes back to another app.
local function startKeys(self)
    local keys = calendarKeys()
    self.keyTap = hs.eventtap.new({eventTypes.keyDown, eventTypes.leftMouseDown, eventTypes.rightMouseDown,
                                   eventTypes.otherMouseDown}, function(e)
        if e:getType() == eventTypes.keyDown then
            -- Only unmodified keys are the calendar's. Arrow keys carry the
            -- fn flag, so fn is not checked.
            local flags = e:getFlags()
            local method = not (flags.cmd or flags.alt or flags.ctrl or flags.shift) and keys[e:getKeyCode()]
            if method then
                self[method](self)
                return true
            end
            -- A repeat of any other key is one held since before the
            -- calendar opened (its first press would have closed it).
            if e:getProperty(autorepeat) ~= 0 then
                return false
            end
        end
        self.dismissedAt = hs.timer.secondsSinceEpoch()
        self:hide()
        return false
    end):start()
end

local function stopKeys(self)
    if self.keyTap then
        self.keyTap:stop()
        self.keyTap = nil
    end
end

local function stopDateCheck(self)
    if self.dateTimer then
        self.dateTimer:stop()
        self.dateTimer = nil
    end
end

-- Opens on the current month, wherever it was left when last closed.
function obj:show()
    stopKeys(self)
    stopDateCheck(self)
    self.dismissedAt = nil
    self.year = tonumber(os.date("%Y"))
    self.month = tonumber(os.date("%m"))
    local screen = hs.screen.mainScreen():frame()
    self.canvas:topLeft({
        x = screen.x + (screen.w - self.calw) / 2,
        y = screen.y + (screen.h - self.calh) / 2
    })
    self:updateCalCanvas()
    self.canvas:show()
    startKeys(self)
    -- Held on self so the garbage collector cannot stop it.
    self.dateTimer = hs.timer.doEvery(DATE_CHECK_INTERVAL, function()
        self:checkDate()
    end)
    return self
end

function obj:hide()
    -- keys first, if anything goes wrong we don't want them stuck
    stopKeys(self)
    stopDateCheck(self)
    self.canvas:hide()
end

function obj:toggleShow()
    if self:isShowing() then
        self:hide()
    elseif self.dismissedAt and hs.timer.secondsSinceEpoch() - self.dismissedAt < TOGGLE_GRACE then
        self.dismissedAt = nil
    else
        self:show()
    end
end

return obj
