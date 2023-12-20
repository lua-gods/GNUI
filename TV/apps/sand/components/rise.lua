local Component = require("TV.apps.sand.Component")
local AIR = require("TV.apps.sand.elements.air")

local component = Component:new()
component.id = "rise"
function component.update(self)
    local above = self.up
    if above and above.element.liquid then
        above.element, self.element = self.element, above.element
        return true
    end
end

return component
