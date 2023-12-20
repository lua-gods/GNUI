local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "acid_gas"
element.colour = vec(0.7, 1, 0.7, 1)
element.acid_immune = true
element.gas = true
element.components = {
    components.acid,
    components.condense,
    components.rise,
    components.gas,
}
element.transitions = {
    condense = function(self) self.element = ElementManager:get("acid") end,
}

return element
