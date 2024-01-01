-- app template version 2.1.1
local appManager = require("TV.appManager")
local FiGUI = require("libraries.FiGUI")

-- gets called when an instance is created, aka init
local factory = function (window,tv) -- creates an instance of the app
    ---@type Application
    local app = {}
    
    -- put stuff that gets called on init here.


    -- gets called when the user exits the app.
    function app.CLOSE()
    end

    -- gets called 20 times per second at a consistent rate.
    function app.TICK()
    end
    
    -- gets called every render frame.
    -- delta frame is the time between frame,
    -- delta tick is the time since the last tick.
    function app.FRAME(delta_tick,delta_frame)
    end
    
    -- gets called when a key is pressed, hover over the parameters for definitions.
    function app.KEY_PRESS(char, key_id, key_status, key_modifier)
    end
    
    return app
end

appManager:registerApp(factory,"Example app"--[[,icon]])