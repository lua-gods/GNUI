local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "activated_thermite"
element.colour = vec(1, 0.6, 0.2, 1)
element.liquid = true
element.components = {
    components.heat,
    components.thermite,
    components.gravity,
    components.slide,
    components.fluid,
}

return element
