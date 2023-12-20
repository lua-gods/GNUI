local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "gunpowder"
element.colour = vec(0.2, 0.2, 0.2, 1)
element.components = {
    components.sink,
    components.gravity,
    components.slide,
}
element.transitions = {
    heat = function(self) self.element = ElementManager:get("fire") end
}

return element
