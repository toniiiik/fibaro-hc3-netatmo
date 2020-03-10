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
    self.ic.main_icon       = 1011
    self.ic.blue_icon       = 1013
    self.ic.light_blue_icon = 1014
    self.ic.green_icon      = 1012
    self.ic.yellow_icon     = 1015
    self.ic.red_icon        = 1016
    self.ic.batt_icon       = 1017
    self.ic.error_icon      = 1018
end

function QuickApp:updateModule(m)
    self.module = m
    self:debug(json.encode(m))
    self.outm = self.module.OUTDOOR_MODULE
    self.base = self.module.BASE_MODULE
    self:debug(json.encode(self.outm))
    self:updateProperty("value", self.outm.temp)
    self:updateProperty("unit", self.base.temp_unit)
    self:refreshView()
    self:debug("updating module state.... DONE")
end

function QuickApp:displayNil()
  self:updateView("lblMain","text",string.format("%s - %s - %s - %s -",sy.wind,sy.dir,sy.gust,sy.dir))
  self:updateView("lblTemp", "text",string.format("%s %s - %s\194\176/- %s %s - %s\194\176/-",sy.wind,sy.arrowup,sy.dir,sy.gust,sy.arrowup,sy.dir))
  self:updateView("lblStation","text",string.format("%s %s %s -",sy.round_pushpin,sy.warning,sy.trackball))
  self:updateView("lblModule","text",string.format("%s - %s - %s - %%",sy.cd,sy.battery,sy.signal))
  if self.outm.last_seen ~= nil then
    self:updateView("lblSeen","text",string.format("%s %s %s",sy.eye,sy.warning,os.date("%d %m %Y %H:%M",self.outm.last_seen)))
  else self:updateView("lblSeen","text",string.format("%s %s -",sy.eye,sy.warning))end
  self:updateProperty("deviceIcon",self.ic.error_icon)
end

function QuickApp:refreshView()
    local icon_h, icon_d, icon_w, icon_m, label = ""
    local cTime = os.time();
    if ((cTime - self.outm.last_seen) < 1800) then
        self:debug("new data available")
        if self.outm.temp_trend == nil then
          self.outm.temp_trend = "N/A"
        end
        local temp_trend = ""
        if self.outm.temp_trend == "up" then
          temp_trend = sy.arrow_rraise
        elseif self.outm.temp_trend == "stable" then
          temp_trend = sy.arrow_right
        else
          temp_trend = sy.arrow_rfall
        end
        local press_trend = ""
        if self.base.press_trend == "up" then
          press_trend = sy.arrow_rraise
        elseif self.base.press_trend == "stable" then
          press_trend = sy.arrow_right
        else
          press_trend = sy.arrow_rfall
        end
        self:debug("setting labels...")
        local label =
          string.format(
          "%s %s%s %s %s %s%% %s %s%s %s",
          sy.temp,
          self.outm.temp,
          self.base.temp_unit,
          temp_trend,
          sy.humid,
          self.outm.humid,
          sy.arrow_dn,
          self.base.press,
          self.base.press_unit,
          press_trend
        )
        self:updateView("lblMain", "text", label)
        self:updateView("lblTemp", "text", string.format("%s %s %s%s %s %s%s %s %s %s%% %s %s%%",
                          sy.temp,
                          sy.arrowup,
                          self.outm.temp_max,
                          self.base.temp_unit,
                          sy.arrowdn,
                          self.outm.temp_min,
                          self.base.temp_unit,
                          sy.humid,
                          sy.arrowup,
                          self.outm.humid_max,
                          sy.arrowdn,
                          self.outm.humid_min
                        )   
        )
        self:updateView("lblPress", "text", string.format("%s %s%s%s %s%s%s",
                        sy.arrow_dn,
                        sy.arrowup,
                        self.base.press_max,
                        self.base.press_unit,
                        sy.arrowdn,
                        self.base.press_min,
                        self.base.press_unit
                      )
        )
        self:updateView("lblStation", "text",string.format("%s %s %s %s",
                      sy.round_pushpin,
                      self.base.name,
                      sy.trackball,
                      self.outm.name
                    )
        )
        self:updateView("lblModule", "text",string.format("%s %s %s %s%% %s %s%%",
                      sy.cd,
                      self.outm.firmware,
                      sy.battery,
                      self.outm.batt,
                      sy.signal,
                      self.outm._rf
                    )
        )
        self:updateView("lblSeen", "text", string.format("%s %s", sy.eye, os.date("%d.%m.%Y %H:%M", self.outm.last_seen))
        )
        self:debug("setting labels... DONE")
        if self.outm.batt > batt_level then
          if self.outm.temp <= 3 then
            self:updateProperty("deviceIcon", self.ic.blue_icon) --blue
          elseif self.outm.temp > 3 and self.outm.temp < 14 then
            self:updateProperty("deviceIcon", self.ic.light_blue_icon) -- light blue
          elseif self.outm.temp >= 14 and self.outm.temp <= 26 then
            self:updateProperty("deviceIcon", self.ic.green_icon) -- green
          elseif self.outm.temp > 26 and self.outm.temp < 33 then
            self:updateProperty("deviceIcon", self.ic.yellow_icon) -- yellow
          else
            self:updateProperty("deviceIcon", self.ic.red_icon)
          end
        else
          self:updateProperty("deviceIcon", self.ic.batt_icon)
        end
    else
        self:debug("ERROR - Out module not updated recently")
        self:debug(json.encode(self.outm))
        self:displayNil()
    end
end

function QuickApp:onInit()
    self:debug("onInit")
    self:initIcons()
    appSelf = self
    f = fibaro
    self.outm = {}
    self.base = {}
    self:displayNil()
    local s = fibaro.getGlobalVariable("netatmo_sy")
    sy = json.decode(s)
    post({type = "start"})
end
