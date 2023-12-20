local Component = require("TV.apps.sand.Component")
local AIR = require("TV.apps.sand.elements.air")

local component = Component:new()
component.id = "thermite"
local directions = { "up", "left", "right", "down", "up_left", "up_right", "down_left", "down_right" }
function component.update(self)
    if math.random() > 0.9 then return end

    local side = self[directions[math.random(8)]]
    if side and side.element ~= AIR and side.element ~= self.element and not side.element.heat_resistant then
        side.element = AIR
        return true
    end
end

return component
