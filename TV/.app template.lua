-- app template version 2.0.1
local appManager = require("TV.appManager")
local FiGUI = require("libraries.FiGUI")

local factory = function () -- creates an instance of the app
    ---@type Application
    local app = {}
    
    -- gets called once, when the app is first opened.
    function app.INIT(window,tv)
    end
    
    -- gets called when the app is opened.
    function app.OPEN(window,tv)
    end
    
    -- gets called 20 times per second at a consistent rate.
    function app.TICK(window,tv)
    end
    
    -- gets called every frame.
    -- delta frame is the time between frame,
    -- delta tick is the time since the last tick.
    function app.FRAME(window,tv,delta_tick,delta_frame)
    end
    
    -- gets called when a key is pressed, hover over the parameters for definitions.
    function app.KEY_PRESS(window,tv, player, char, key_id, key_status, key_modifier)
    end
    
    -- gets called when the user exits the app.
    function app.CLOSE(window,tv)
    end
    return app
end

appManager:registerApp(factory,"Example app"--[[,icon]])