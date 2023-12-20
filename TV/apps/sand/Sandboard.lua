local elements = require(.....".elements")
local INITIAL_ELEMENTS = { elements.sand, elements.water, elements.stone }

local Sandboard = {}
Sandboard.__index = Sandboard

function Sandboard.new(width, height, Cell)
    local self = setmetatable({}, Sandboard)
    self.width = width
    self.height = height

    self.cells = {}
    for x = 1, width do
        self.cells[x] = {}
        for y = 1, height do
            self.cells[x][y] = Cell:new(x, y)
            if math.random() > 0.9 then
                self.cells[x][y].element = INITIAL_ELEMENTS[math.random(#INITIAL_ELEMENTS)]
            end
        end
    end

    for x = 1, width do
        for y = 1, height do
            local down = self.cells[x] and self.cells[x][y+1]
            local down_left = self.cells[x-1] and self.cells[x-1][y+1]
            local down_right = self.cells[x+1] and self.cells[x+1][y+1]
            local left = self.cells[x-1] and self.cells[x-1][y]
            local right = self.cells[x+1] and self.cells[x+1][y]
            local up_left = self.cells[x-1] and self.cells[x-1][y-1]
            local up_right = self.cells[x+1] and self.cells[x+1][y-1]
            local up = self.cells[x] and self.cells[x][y-1]
            self.cells[x][y]:neighbours(down, down_left, down_right, left, right, up_left, up_right, up)
        end
    end

    return self
end

function Sandboard:update()
    for x = self.width, 1, -1 do
        for y = self.height, 1, -1 do
            local cell = self.cells[x][y]
            if cell then
                cell:update()
            end
        end
    end
end

function Sandboard:draw(texture)
    local cells = self.cells
    texture:applyFunc(0, 0, self.width, self.height, function(_, x, y)
        return cells[x+1][y+1].element.colour
    end)
end

return Sandboard