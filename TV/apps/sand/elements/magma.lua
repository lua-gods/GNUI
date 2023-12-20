local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "magma"
element.colour = vec(0.9, 0.4, 0.1, 1)
element.liquid = true
element.components = {
    components.heat,
    components.gravity,
    components.slide,
    components.fluid,
}
element.transitions = {
    cold = function(self) self.element = ElementManager:get("stone") end
}

return element
