local Component = require("TV.apps.sand.Component")
local AIR = require("TV.apps.sand.elements.air")

local component = Component:new()
component.id = "acid"
local directions = { "up", "left", "right", "down", "up_left", "up_right", "down_left", "down_right" }
function component.update(self)
    if math.random() < 0.9 then return end

    local side = self[directions[math.random(8)]]
    if side and not side.element.acid_immune then
        side.element = AIR
        self.element = AIR
        return true
    end
end

return component
