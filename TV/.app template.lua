-- app template version 2.2.1

-- if FiGUI dosent exist in the host avatar, this attempts to get it from the TV itself.
local FiGUI = require("libraries.FiGUI") 
 or (world.avatarVars()["dc912a38-2f0f-40f8-9d6d-57c400185362"] 
 and world.avatarVars()["dc912a38-2f0f-40f8-9d6d-57c400185362"].FiGUI or nil)

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

-- set this into a texture you want to represent as the icon for this app.
local icon


avatar:store("app1",{
    factory = factory,
    name    = "Life",
    icon    = icon,
    uuid    = client:getSystemTime()})