local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "stone"
element.colour = vec(0.5, 0.5, 0.5, 1)
element.components = {
    components.group_gravity
}
element.transitions = {
    heat = function(self) if math.random() > 0.95 then self.element = ElementManager:get("magma") end end
}

return element
