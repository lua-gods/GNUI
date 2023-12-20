local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "sand"
element.colour = vec(0.8, 0.8, 0.4, 1)
element.components = {
    components.sink,
    components.gravity,
    components.slide,
}
element.transitions = {
    wet = function(self) self.element = ElementManager:get("wet_sand") end,
}

return element
