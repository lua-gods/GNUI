local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "acid"
element.colour = vec(0.2, 0.8, 0.2, 1)
element.liquid = true
element.acid_immune = true
element.components = {
    components.acid,
    components.gravity,
    components.slide,
    components.fluid,
} 
element.transitions = {
    heat = function(self) self.element = ElementManager:get("acid_gas") end,
}

return element
