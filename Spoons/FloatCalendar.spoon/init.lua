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
            y = tostring(10 / self.calw),
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

function obj:isShowing()
    return self.canvas:isShowing()
end

function obj:show()
    local screen = hs.screen.mainScreen():frame()
    self.canvas:topLeft({
        x = screen.x + (screen.w - self.calw) / 2,
        y = screen.y + (screen.h - self.calh) / 2
    })
    self:updateCalCanvas()
    self.canvas:show()
    self.hotkeys = {hs.hotkey.bind({}, 'escape', function()
        self:hide()
    end), hs.hotkey.bind({}, 'left', function()
        self:prevMonth()
    end), hs.hotkey.bind({}, 'right', function()
        self:nextMonth()
    end), hs.hotkey.bind({}, 'up', function()
        self:prevYear()
    end), hs.hotkey.bind({}, 'down', function()
        self:nextYear()
    end), hs.hotkey.bind({}, 'r', function()
        self:resetDate()
    end)}
    return self
end

function obj:hide()
    if self.hotkeys then
        for _, hotkey in ipairs(self.hotkeys) do
            hotkey:delete()
        end
    end
    -- hotkey first, if anything goes wrong we don't want the hotkey stuck
    self.canvas:hide()
end

function obj:toggleShow()
    if self:isShowing() then
        self:hide()
    else
        self:show()
    end
end

return obj
