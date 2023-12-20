local Component = require("TV.apps.sand.Component")
local AIR = require("TV.apps.sand.elements.air")

local component = Component:new()
component.id = "evaporate"
function component.update(self)
    if math.random() > 0.9 then
        self.element = AIR
        return true
    end
end

return component
