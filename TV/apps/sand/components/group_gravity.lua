local Component = require("TV.apps.sand.Component")
local AIR = require("TV.apps.sand.elements.air")

local component = Component:new()
component.id = "group_gravity"
function component.update(self)
    local below = self.down
    if below and below.element.gas then
        local left = self.left
        if left and left.element == self.element then
            return
        end 

        local right = self.right
        if right and right.element == self.element then
            return
        end
        
        self.element, below.element = below.element, self.element
        return true
    end
end

return component
