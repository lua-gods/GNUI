local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "virus"
element.colour = vec(1, 0.5, 1, 1)
element.liquid = true
element.components = {
    components.spread,
    components.gravity,
    components.slide,
    components.fluid,
}

return element
