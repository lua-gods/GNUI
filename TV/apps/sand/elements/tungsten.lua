local Element = require("TV.apps.sand.Element")
local components = require("TV.apps.sand.components")
local ElementManager = require("TV.apps.sand.ElementManager")

local element = Element:new()
element.id = "tungsten"
element.colour = vec(0.3, 0.3, 0.35, 1)
element.heat_resistant = true
element.acid_immune = true
element.components = {
    components.heavy,
    components.gravity,
}

return element
