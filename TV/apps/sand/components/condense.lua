local Component = require("TV.apps.sand.Component")
local ElementManager = require("TV.apps.sand.ElementManager")

local component = Component:new()
component.id = "condense"
function component.update(self)
    if math.random() > 0.999 then
        self.element.transitions.condense(self)
        return true
    end
end

return component
