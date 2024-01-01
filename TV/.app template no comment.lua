local appManager = require("TV.appManager")
local FiGUI = require("libraries.FiGUI")

local factory = function ()
    ---@type Application
    local app = {}
    app.capture_keyboard = false
    
    function app.INIT(window,tv)
    end

    function app.OPEN(window,tv)
    end
    
    function app.CLOSE(window,tv)
    end

    function app.TICK(window,tv)
    end
    
    function app.FRAME(window,tv,delta_tick,delta_frame)
    end
    
    function app.KEY_PRESS(window,tv, char, key_id, key_status, key_modifier)
    end
    
    return app
end

appManager:registerApp(factory,"Example")