local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "water"
element.colour = vec(0.2, 0.2, 0.8, 1)
element.liquid = true
element.components = {
    components.wet,
    components.cold,
    components.gravity,
    components.slide,
    components.fluid,
}
element.transitions = {
    heat = function(self) self.element = ElementManager:get("steam") end
}

return element
