local appManager = require("TV.appManager")
local FiGUI = require("libraries.FiGUI")

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

appManager:registerApp(factory,"Example")