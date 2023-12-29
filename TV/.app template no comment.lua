local appManager = require("TV.appManager")
local factory = function ()
    local FiGUI = require("libraries.FiGUI")
    ---@type Application
    local app = {}
    
    function app.INIT(window,tv)
    end
    
    function app.OPEN(window,tv)
    end
    
    function app.TICK(window,tv)
    end
    
    function app.FRAME(window,tv,delta_tick,delta_frame)
    end
    
    function app.KEY_PRESS(window,tv, player, char, key_id, key_status, key_modifier)
    end
    
    function app.CLOSE(window,tv)
    end
    return app
end

appManager:registerApp(factory,"Example app")