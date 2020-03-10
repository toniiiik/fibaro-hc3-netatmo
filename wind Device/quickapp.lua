-- Wind sensor type have no actions to handle
-- To update wind value, update property "value" with floating point number
-- Eg. self:updateProperty("value", 81.42) 

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
    self.ic.error_icon=1001
    self.ic.batt_icon=1002
    self.ic.tornado_icon=1003
    self.ic.wind_icon=1004
    self.ic.gale_icon=1005
    self.ic.main_icon=1006
end

function QuickApp:updateModule(m)
    self.module = m
    self:debug("updating module state....")
    self.wind = self.module.WIND_MODULE
    self.base = self.module.BASE_MODULE
    self:updateProperty("value", self.wind.speed)
    self:updateProperty("unit", self.base.wind_unit)
    self:refreshView()
    self:debug("updating module state.... DONE")
end

function QuickApp:displayNil()
  self:updateView("Label1","text",string.format("%s - %s - %s - %s -",sy.wind,sy.dir,sy.gust,sy.dir))
  self:updateView("lblWind", "text",string.format("%s %s - %s\194\176/- %s %s - %s\194\176/-",sy.wind,sy.arrowup,sy.dir,sy.gust,sy.arrowup,sy.dir))
  self:updateView("lblStation","text",string.format("%s %s %s -",sy.round_pushpin,sy.warning,sy.trackball))
  self:updateView("lblModule","text",string.format("%s - %s - %s - %%",sy.cd,sy.battery,sy.signal))
  if self.wind.last_seen ~= nil then
    self:updateView("lblSeen","text",string.format("%s %s %s",sy.eye,sy.warning,os.date("%d %m %Y %H:%M",self.wind.last_seen)))
  else self:updateView("lblSeen","text",string.format("%s %s -",sy.eye,sy.warning))end
  self:updateProperty("deviceIcon",self.ic.error_icon)
end

function QuickApp:refreshView()
    local wind_deg, gust_deg = ""
    local cTime = os.time();
    if ((cTime - self.wind.last_seen) < 1800) then
        self:debug("new data available")
        if self.wind.deg < 0 then
            wind_deg = " -"
        else
            wind_deg = self.wind.deg
        end
        if self.wind.gust_deg < 0 then
            gust_deg = " -"
        else
            gust_deg = self.wind.gust_deg
        end
        local label = string.format("%s %s %s %s%s %s %s %s %s%s",
                        sy.wind,
                        self.wind.speed,
                        self.base.wind_unit,
                        sy.dir,
                        self.wind.dir,
                        sy.gust,
                        self.wind.gust,
                        self.base.wind_unit,
                        sy.dir,
                        self.wind.gust_dir
                        )
        self:updateView("Label1", "text", label)
        self:updateView("lblWind", "text", string.format("%s %s %s%s %s%s\194\176/%s %s %s %s%s %s%s\194\176/%s",
                            sy.wind,
                            sy.arrowup,
                            self.wind.speed_max,
                            self.base.wind_unit,
                            sy.dir,
                            wind_deg,
                            self.wind.dir,
                            sy.gust,
                            sy.arrowup,
                            self.wind.gust_max,
                            self.base.wind_unit,
                            sy.dir,
                            gust_deg,
                            self.wind.gust_dir
                        )
        )
        self:updateView("lblStation", "text", string.format("%s %s %s %s",
                        sy.round_pushpin,
                        self.base.name,
                        sy.trackball,
                        self.wind.name
                    )
        )
        self:updateView("lblModule", "text", string.format("%s %s %s %s%% %s %s%%",
                        sy.cd,
                        self.wind.firmware,
                        sy.battery,
                        self.wind.batt,
                        sy.signal,
                        self.wind._rf
                    )
        )
        self:updateView("lblSeen", "text",string.format("%s %s", 
                        sy.eye, 
                        os.date("%d %m %Y %H:%M", self.wind.last_seen)
                    )
        )
        if self.wind.batt > batt_level then
            if self.base.wind_unit == " mph" then
                if self.wind.gust < 7 then
                    self:updateProperty("deviceIcon", self.ic.main_icon)
                elseif self.wind.gust >= 7 and self.wind.gust < 31 then
                    self:updateProperty("deviceIcon", self.ic.wind_icon)
                elseif self.wind.gust >= 31 and self.wind.gust < 54 then
                    self:updateProperty("deviceIcon", self.ic.gale_icon)
                elseif self.wind.gust >= 54 then
                    self:updateProperty("deviceIcon", self.ic.tornado_icon)
                end
            elseif self.base.wind_unit == " m/s" then
                if self.wind.gust < 3.3 then
                    self:updateProperty("deviceIcon", self.ic.main_icon)
                elseif self.wind.gust >= 3.3 and self.wind.gust < 13.8 then
                    self:updateProperty("deviceIcon", self.ic.wind_icon)
                elseif self.wind.gust >= 13.8 and self.wind.gust < 24.4 then
                    self:updateProperty("deviceIcon", self.ic.gale_icon)
                elseif self.wind.gust >= 24.4 then
                    self:updateProperty("deviceIcon", self.ic.tornado_icon)
                end
            elseif self.base.wind_unit == " B" then
                if self.wind.gust < 2 then
                    self:updateProperty("deviceIcon", self.ic.main_icon)
                elseif self.wind.gust >= 2 and self.wind.gust < 6 then
                    self:updateProperty("deviceIcon", self.ic.wind_icon)
                elseif self.wind.gust >= 6 and self.wind.gust < 9 then
                    self:updateProperty("deviceIcon", self.ic.gale_icon)
                elseif self.wind.gust >= 9 then
                    self:updateProperty("deviceIcon", self.ic.tornado_icon)
                end
            elseif self.base.wind_unit == " kt." then
                if self.wind.gust < 6 then
                    self:updateProperty("deviceIcon", self.ic.main_icon)
                elseif self.wind.gust >= 6 and self.wind.gust < 27 then
                    self:updateProperty("deviceIcon", self.ic.wind_icon)
                elseif self.wind.gust >= 27 and self.wind.gust < 47 then
                    self:updateProperty("deviceIcon", self.ic.gale_icon)
                elseif self.wind.gust >= 47 then
                    self:updateProperty("deviceIcon", self.ic.tornado_icon)
                end
            else
                if self.wind.gust < 11 then
                    self:updateProperty("deviceIcon", self.ic.main_icon)
                elseif self.wind.gust >= 11 and self.wind.gust < 49 then
                    self:updateProperty("deviceIcon", self.ic.wind_icon)
                elseif self.wind.gust >= 49 and self.wind.gust < 88 then
                    self:updateProperty("deviceIcon", self.ic.gale_icon)
                elseif self.wind.gust >= 88 then
                    self:updateProperty("deviceIcon", self.ic.tornado_icon)
                end
            end
        else
            self:updateProperty("deviceIcon", self.ic.batt_icon)
        end
    else
        self:debug("ERROR - Wind module not updated recently")
        self:debug(json.encode(self.wind))
        self:displayNil()
    end
end

function QuickApp:onInit()
    self:debug("onInit")
    self:initIcons()
    appSelf = self
    f = fibaro
    self.wind = {}
    self.base = {}
    local s = fibaro.getGlobalVariable("netatmo_sy")
    sy = json.decode(s)
    self:displayNil()
    post({type = "start"})
end
