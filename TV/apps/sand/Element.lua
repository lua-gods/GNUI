local Element = {
    id = "",
    colour = vec(1, 0, 0, 1),
    transitions = {}
}
Element.__index = Element

function Element.new()
    local self = setmetatable({}, Element)
    return self
end

return Element