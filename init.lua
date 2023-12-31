require("TV.initTV")
require("TV.remote")

local value = vectors.vec3(1,2,3)

--[[
local mat = matrices.mat4()


print("normal:",value)

mat:scale(5):rotate(14,15,3)
value = mat:apply(value)
print("applied:",value)

mat:invert()
value = mat:apply(value)
print("returned:",value)
]]