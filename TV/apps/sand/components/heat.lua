local Component = require("TV.apps.sand.Component")
local ElementManager = require("TV.apps.sand.ElementManager")

local component = Component:new()
component.id = "heat"
local directions = { "up", "left", "right", "down" }
function component.update(self)
    local side = self[directions[math.random(1, 4)]]
    if side and side.element.transitions.heat then
        side.element.transitions.heat(side)
        return true
    end
end

return component
