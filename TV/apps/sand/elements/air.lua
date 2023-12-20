local Element = require("TV.apps.sand.Element")

local element = Element:new()
element.id = "air"
element.colour = vec(0, 0, 0, 1)
element.acid_immune = true
element.gas = true

return element
