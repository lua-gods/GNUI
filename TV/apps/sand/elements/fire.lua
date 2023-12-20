local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")

local element = Element:new()
element.id = "fire"
element.colour = vec(0.8, 0.2, 0.2, 1)
element.gas = true
element.components = {
    components.heat,
    components.evaporate,
    components.gas,
}

return element
