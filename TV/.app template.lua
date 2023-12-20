local FiGUI = require("libraries.FiGUI")
---@type Application
local app = {}

-- gets called once, when the app is first opened
function app.INIT(window,tv)
end

-- gets called when the app is opened
function app.OPEN(window,tv)
end

-- gets called 20 times per second at a consistent rate
function app.TICK(window,tv)
end

-- gets called every frame, delta frame is the time between frames, delta tick is the time since the last tick
function app.FRAME(window,tv,delta_frame,delta_tick)
end

-- gets called when a key is pressed, autocomplete will explain the rest
function app.KEY_PRESS(window,tv, player, char, key_id, key_status, key_modifier)
end

-- gets called when the user exits the app
function app.CLOSE(window,tv)
end

return app, "id", "Application Name"