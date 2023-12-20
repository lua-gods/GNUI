local Component = require("TV.apps.sand.Component")
local AIR = require("TV.apps.sand.elements.air")

local component = Component:new()
component.id = "slide"
function component.update(self)
    local slide = math.random() > 0.5 and self.down_left or self.down_right
    if slide and slide.element.gas then
        self.element, slide.element = slide.element, self.element
        return true
    end
end

return component
