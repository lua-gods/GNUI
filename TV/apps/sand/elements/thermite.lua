local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "thermite"
element.colour = vec(0.7, 0.4, 0, 1)
element.liquid = true
element.components = {
    components.gravity,
    components.slide,
    components.fluid,
}
element.transitions = {
    heat = function(self) self.element = ElementManager:get("activated_thermite") end
}

return element
