local Component = {
    id = "",
    colour = vec(1, 0, 0, 1)
}
Component.__index = Component

function Component.new()
    local self = setmetatable({}, Component)
    return self
end

return Component