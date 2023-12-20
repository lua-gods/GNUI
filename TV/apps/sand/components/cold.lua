local Component = require("TV.apps.sand.Component")
local ElementManager = require("TV.apps.sand.ElementManager")

local component = Component:new()
component.id = "cold"
local directions = { "up", "left", "right", "down" }
function component.update(self)
    local side = self[directions[math.random(1, 4)]]
    if side and side.element.transitions.cold then
        side.element.transitions.cold(side)
        return true
    end
end
return component
