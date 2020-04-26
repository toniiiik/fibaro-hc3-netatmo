-- Device Controller is a little more advanced than other types. 
-- It can create child devices, so it can be used for handling multiple physical devices.
-- E.g. when connecting to a hub, some cloud service or just when you want to represent a single physical device as multiple endpoints.
-- 
-- Basic knowledge of object-oriented programming (oop) is required. 
-- Learn more about oop: https://en.wikipedia.org/wiki/Object-oriented_programming 
-- Learn more about managing child devices: https://manuals.fibaro.com/home-center-3-quick-apps/

local refresh_rate=60*10

function post(e,t) 
    appSelf:trace("event: ", json.encode(e))
    appSelf:trace("timeout: ", t or 0)

    setTimeout(function() main(e) end,t or 0) 
end

function main(e)
    ({
        start = function(e) 
             appSelf:debug("starting device")
            local m = fibaro.getGlobalVariable("netatmoModules")
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
                e.data = fibaro.getGlobalVariable("netatmoModules")
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
    self:trace(json.encode(m.INDOOR_MODULE[self.module_name]))
    if self.temperature ~= nil then
        self.temperature:setTemperature(m.INDOOR_MODULE[self.module_name].temp or 0)
    end

    if self.humid ~= nil then
        self.humid:setValue(m.INDOOR_MODULE[self.module_name].humid or 0)
    end

    if self.co ~= nil then
        self.co:setValue(m.INDOOR_MODULE[self.module_name].co2 or 0)
    end

    self:debug("updating module state.... DONE")
    self:refreshView(m)
end

function QuickApp:refreshView(m)
    local cTime = os.time();
    if ((cTime - m.last_seen) < 1800) then
        if m.batt > batt_level then
            self:debug("battery ok")
        else
            self:debug("battery low: ", m.batt)
        end
    else
        self:debug("ERROR - Indoor module not updated recently")
        self:debug(json.encode(m))
    end
end

function QuickApp:onInit()
    self:debug("QuickApp:onInit")
    self.module_name = self:getVariable("module_name")

    self:createTemperature()
    self:createHumid()
    self:createCO()

    self:debug("Starting indoor module: ", self.module_name)
    self:initIcons()
    appSelf=self
    -- Setup classes for child devices.
    -- Here you can assign how child instances will be created.
    -- If type is not defined, QuickAppChild will be used.
    self:initChildDevices({
        ["com.fibaro.temperatureSensor"] = NetatmoIndoorTemperature,
        ["com.fibaro.humiditySensor"] = NetatmoIndoorHumid,
        ["com.fibaro.multilevelSensor"] = NetatmoIndoorCO,
    })

    -- Print all child devices.
    self:debug("Child devices:")
    for id,device in pairs(self.childDevices) do
        self:debug("[", id, "]", device.name, ", type of: ", device.type)
        if device.type == "com.fibaro.temperatureSensor" then
            self.temperature = device
        end
        if device.type == "com.fibaro.humiditySensor" then
            self.humid = device
        end
        if device.type == "com.fibaro.multilevelSensor" then
            self.co = device
        end
    end

    post({type="start"})
end

-- Sample method to create a new child. It can be used in a button. 
function QuickApp:createTemperature()
    local tempOk = self:getVariable("tempOk") or "nok"
    if tempOk == "ok" then
        return
    end

    local child = self:createChildDevice({
        name = "Temperature",
        type = "com.fibaro.temperatureSensor",
    }, NetatmoIndoorTemperature)

    self:trace("Child device created: ", child.id)
    self:setVariable("tempOk", "ok")
end
-- Sample method to create a new child. It can be used in a button. 
function QuickApp:createHumid()
    local devOk = self:getVariable("humidOk") or "nok"
    if devOk == "ok" then
        return
    end

    local child = self:createChildDevice({
        name = "Humidity",
        type = "com.fibaro.humiditySensor",
    }, NetatmoIndoorHumid)

    self:trace("Child device created: ", child.id)
    self:setVariable("humidOk", "ok")
end
-- Sample method to create a new child. It can be used in a button. 
function QuickApp:createCO()
    local devOk = self:getVariable("coOk") or "nok"
    if devOk == "ok" then
        return
    end

    local child = self:createChildDevice({
        name = "CO 2",
        type = "com.fibaro.multilevelSensor",
    }, NetatmoIndoorHumid)

    self:trace("Child device created: ", child.id)
    self:setVariable("coOk", "ok")
end

-- TEMPERATURE
-- Sample class for handling your binary switch logic. You can create as many classes as you need.
-- Each device type you create should have its class which inherits from the QuickAppChild type.
class 'NetatmoIndoorTemperature' (QuickAppChild)

-- __init is a constructor for this class. All new classes must have it.
function NetatmoIndoorTemperature:__init(device)
    -- You should not insert code before QuickAppChild.__init. 
    QuickAppChild.__init(self, device) 

    self:debug("NetatmoIndoorTemperature init")   
end

function NetatmoIndoorTemperature:hello()
    self:debug("hello")
end

function NetatmoIndoorTemperature:setTemperature(value)
    self:debug("New value: ", value)
    self:updateProperty("value", value)
end

-- HUMIDITY
-- Sample class for handling your binary switch logic. You can create as many classes as you need.
-- Each device type you create should have its class which inherits from the QuickAppChild type.
class 'NetatmoIndoorHumid' (QuickAppChild)

-- __init is a constructor for this class. All new classes must have it.
function NetatmoIndoorHumid:__init(device)
    -- You should not insert code before QuickAppChild.__init. 
    QuickAppChild.__init(self, device) 

    self:debug("NetatmoIndoorHumid init")   
end

function NetatmoIndoorHumid:hello()
    self:debug("hello")
end

function NetatmoIndoorHumid:setValue(value)
    self:debug("New value: ", value)
    self:updateProperty("value", value)
end

-- CO2
-- Sample class for handling your binary switch logic. You can create as many classes as you need.
-- Each device type you create should have its class which inherits from the QuickAppChild type.
class 'NetatmoIndoorCO' (QuickAppChild)

-- __init is a constructor for this class. All new classes must have it.
function NetatmoIndoorCO:__init(device)
    -- You should not insert code before QuickAppChild.__init. 
    QuickAppChild.__init(self, device) 

    self:debug("NetatmoIndoorCO init")   
end

function NetatmoIndoorCO:hello()
    self:debug("hello")
end

function NetatmoIndoorCO:setValue(value)
    self:debug("New value: ", value)
    self:updateProperty("value", value)
    self:updateProperty("unit", "ppm")
end


