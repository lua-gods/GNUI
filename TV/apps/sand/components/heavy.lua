local Component = require("TV.apps.sand.Component")
local AIR = require("TV.apps.sand.elements.air")

local component = Component:new()
component.id = "heavy"
function component.update(self)
    if world.getTime() % 2 == 0 then return end
    local below = self.down
    if below and below.element ~= AIR and below.element ~= self.element then
        below.element = self.element
        self.element = AIR
        return true
    end
end

return component
