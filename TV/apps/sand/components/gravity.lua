local Component = require("TV.apps.sand.Component")

local component = Component:new()
component.id = "gravity"
function component.update(self)
    local below = self.down
    if below and below.element.gas then
        self.element, below.element = below.element, self.element
        return true
    end
end

return component
