local Component = require("TV.apps.sand.Component")
local AIR = require("TV.apps.sand.elements.air")

local component = Component:new()
component.id = "sink"
function component.update(self)
    local below = self.down
    if below and below.element.liquid then
        below.element, self.element = self.element, below.element
        return true
    end
end

return component
