local FiGUI = require("libraries.FiGUI")
 or (world.avatarVars()["dc912a38-2f0f-40f8-9d6d-57c400185362"] 
 and world.avatarVars()["dc912a38-2f0f-40f8-9d6d-57c400185362"].FiGUI or nil)

local factory = function (window,tv)
    ---@type Application
    local app = {}
    app.capture_keyboard = false
    
    function app.CLOSE()
    end

    function app.TICK()
    end
    
    function app.FRAME(delta_tick,delta_frame)
    end
    
    function app.KEY_PRESS(char, key_id, key_status, key_modifier)
    end
    
    return app
end

local icon

avatar:store("app1",{
    factory = factory,
    name    = "Life",
    icon    = icon,
    uuid    = client:getSystemTime()})