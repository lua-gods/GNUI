local elements = require(.....".elements")
local AIR = elements.air
local SAND = elements.sand

local Cell = {
    element = AIR,
}
Cell.__index = Cell

function Cell.new()
    local self = setmetatable({}, Cell)
    self.toggle = math.random() > 0.5
    return self
end

function Cell:neighbours(down, down_left, down_right, left, right, up_left, up_right, up)
    self.down = down
    self.down_left = down_left
    self.down_right = down_right
    self.left = left
    self.right = right
    self.up_left = up_left
    self.up_right = up_right
    self.up = up
end

function Cell:update()
    local components = self.element.components
    if components then
        for i = 1, #components do
            local component = components[i]
            if component.update(self) then
                return
            end
        end
    end
end

return Cell