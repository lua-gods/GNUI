local dir = .....".elements."

local ElementManager = {
    elements = {}
}
ElementManager.__index = ElementManager

function ElementManager:get(id)
    if not self.elements[id] then
        self.elements[id] = require(dir..id)
    end
    return self.elements[id]
end

return ElementManager