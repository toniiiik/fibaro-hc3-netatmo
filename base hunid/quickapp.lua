-- Humidity sensor type have no actions to handle
-- To update humidity, update property "value" with floating point number
-- Eg. self:updateProperty("value", 90.28) 

-- To update controls you can use method self:updateView(<component ID>, <component property>, <desired value>). Eg:  
-- self:updateView("slider", "value", "55") 
-- self:updateView("button1", "text", "MUTE") 
-- self:updateView("label", "text", "TURNED ON") 

-- This is QuickApp inital method. It is called right after your QuickApp starts (after each save or on gateway startup). 
-- Here you can set some default values, setup http connection or get QuickApp variables.
-- To learn more, please visit: https://manuals.fibaro.com/

local refresh_rate=60*10

local trace = false
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

function QuickApp:updateModule(m)
    self.module = m
    -- self:debug(json.encode(m))
    self:updateProperty("value", m.BASE_MODULE.humid)
    self:debug("updating module state.... DONE")
end

function QuickApp:onInit()
    self:debug("onInit")
    appSelf = self
    debug = function(text, ...) self:debug(text, ...) end
    post({type="start"})     
end
