-- To update controls you can use method self:updateView(<component ID>, <component property>, <desired value>). Eg:  
-- self:updateView("slider", "value", "55") 
-- self:updateView("button1", "text", "MUTE") 
-- self:updateView("label", "text", "TURNED ON") 

-- This is QuickApp inital method. It is called right after your QuickApp starts (after each save or on gateway startup). 
-- Here you can set some default values, setup http connection or get QuickApp variables.
-- To learn more, please visit: https://manuals.fibaro.com/
local batt_level = 16
local refresh_rate = 60 * 1
local sy={}

function post(e,t) 
    if trace then
        debug("event: ", json.encode(e))
        debug("timeout: ", t or 0)
    end
    setTimeout(function() main(e) end,t or 0) 
end

function main(e)
    ({
        start = function(e)
            appSelf:debug("starting device")
            local m = f.getGlobalVariable("netatmoModules")
            if m == "" then
                appSelf:debug("no data available... try after 10 min")
                post({type="start"}, 60 * 10 * 1000)
                return
            end
            post({type = "measure", data = m})
        end,
        measure = function(e)
            if e.data == nil then
                appSelf:debug("updating data from global state")
                e.data = f.getGlobalVariable("netatmoModules")
            end
            local module = json.decode(e.data)
            appSelf:updateModule(module)
            post({type = "measure"}, refresh_rate * 1000)
        end
    })[e.type](e)
end

function QuickApp:initIcons()
    self.ic = {}
    self.ic.main_icon  = 1007
    self.ic.rain_icon  = 1008
    self.ic.batt_icon  = 1009
    self.ic.error_icon = 1010
end

function QuickApp:updateModule(m)
    self.module = m
    self.rain = self.module.RAIN_MODULE
    self.base = self.module.BASE_MODULE
    self:debug(json.encode(self.rain))
    self:updateProperty("value", self.rain.sum_hour)
    self:updateProperty("unit", " mm/h")
    self:refreshView()
    self:debug("updating module state.... DONE")
end

function QuickApp:displayNil()
  self:updateView("lblMain","text",string.format("%s - %s - %s - %s -",sy.wind,sy.dir,sy.gust,sy.dir))
  self:updateView("lblRain", "text",string.format("%s %s - %s\194\176/- %s %s - %s\194\176/-",sy.wind,sy.arrowup,sy.dir,sy.gust,sy.arrowup,sy.dir))
  self:updateView("lblStation","text",string.format("%s %s %s -",sy.round_pushpin,sy.warning,sy.trackball))
  self:updateView("lblModule","text",string.format("%s - %s - %s - %%",sy.cd,sy.battery,sy.signal))
  if self.rain.last_seen ~= nil then
    self:updateView("lblSeen","text",string.format("%s %s %s",sy.eye,sy.warning,os.date("%d %m %Y %H:%M",self.rain.last_seen)))
  else self:updateView("lblSeen","text",string.format("%s %s -",sy.eye,sy.warning))end
  self:updateProperty("deviceIcon",self.ic.error_icon)
end

function QuickApp:refreshView()
    local icon_h, icon_d, icon_w, icon_m, label = ""
    local cTime = os.time();
    if ((cTime - self.rain.last_seen) < 1800) then
        self:debug("new data available")
        if self.rain.sum_hour > 0 then
          icon_h = sy.rainfall
        else
          icon_h = sy.closed_umbrella
        end
        if self.rain.sum_day > 0 then
          icon_d = sy.rainfall
        else
          icon_d = sy.closed_umbrella
        end
        if self.rain.sum_week > 0 then
          icon_w = sy.rainfall
        else
          icon_w = sy.closed_umbrella
        end
        if self.rain.sum_month > 0 then
          icon_m = sy.rainfall
        else
          icon_m = sy.closed_umbrella
        end
        if self.base.unit == "metric" then
          label =
            string.format(
            "1h%s %.1f %s 24h%s %.1f %s",
            icon_h,
            self.rain.sum_hour,
            self.base.rain_unit,
            icon_d,
            self.rain.sum_day,
            self.base.rain_unit
          )
          self:updateView("lblMain", "text", label)
          self:updateView("lblRain", "text",string.format("1w%s %.1f %s %s%s %.1f %s",
                              icon_w,
                              self.rain.sum_week,
                              self.base.rain_unit,
                              sy.month,
                              icon_m,
                              self.rain.sum_month,
                              self.base.rain_unit
                            )
          )
        else
          label =
            string.format(
            "1h%s %.3f %s 24h%s %.3f %s",
            icon_h,
            self.rain.sum_hour,
            self.base.rain_unit,
            icon_d,
            self.rainsum_.day,
            self.base.rain_unit
          )
          self:updateView("lblMain", "text", label)
          self:updateView("lblRain", "text", string.format("1w%s %.3f %s %s%s %.3f %s",
                            icon_w,
                            self.rain.sum_week,
                            self.base.rain_unit,
                            sy.month,
                            icon_m,
                            self.rain.sum_month,
                            self.base.rain_unit
                          )
          )
        end
        self:debug("updating tech labels")
        self:updateView("lblStation", "text",string.format("%s %s %s %s",
                            sy.round_pushpin,
                            self.base.name,
                            sy.trackball,
                            self.rain.name
                          )
        )
        self:updateView("lblModule","text",string.format("%s %s %s %s%% %s %s%%",
                            sy.cd,
                            self.rain.firmware,
                            sy.battery,
                            self.rain.batt,
                            sy.signal,
                            self.rain._rf
                          )
        )
        self:updateView("lblSeen", "text", string.format("%s %s", sy.eye, os.date("%d %m %Y %H:%M", self.rain.last_seen)))
        self:debug("updating tech labels... DONE")
        if self.rain.batt > batt_level then
          if self.rain.sum_hour > 0 then
            self:updateProperty("deviceIcon", self.ic.rain_icon)
          else
            self:updateProperty("deviceIcon", self.ic.main_icon)
          end
        else
          self:updateProperty("deviceIcon", self.ic.batt_icon)
        end
    else
        self:debug("ERROR - Rain module not updated recently")
        self:debug(json.encode(self.rain))
        self:displayNil()
    end
end

function QuickApp:onInit()
    self:debug("onInit")
    self:initIcons()
    appSelf = self
    f = fibaro
    self.rain = {}
    self.base = {}
    local s = fibaro.getGlobalVariable("netatmo_sy")
    sy = json.decode(s)
    self:displayNil()
    post({type = "start"})
end
