local Component = require("TV.apps.sand.Component")

local component = Component:new()
component.id = "gas"
function component.update(self)
    local side = math.random() > 0.33 and self.up or math.random() > 0.5 and self.left or self.right
    if side and side.element.gas then
        self.element, side.element = side.element, self.element
        return true
    end
end


return component
