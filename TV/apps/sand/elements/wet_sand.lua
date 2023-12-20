local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "wet_sand"
element.colour = vec(0.7, 0.7, 0.35, 1)
element.components = {
    components.group_gravity,
    components.sink,
}
element.transitions = {
    heat = function(self) self.element = ElementManager:get("sand") end
}

return element
