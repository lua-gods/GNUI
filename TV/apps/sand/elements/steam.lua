local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "steam"
element.colour = vec(0.8, 0.8, 0.8, 1)
element.gas = true
element.components = {
    components.rise,
    components.condense,
    components.gas,
}
element.transitions = {
    condense = function(self) self.element = ElementManager:get("water") end
}

return element
