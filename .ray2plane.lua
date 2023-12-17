
---@param dir Vector3
---@param planeNormal Vector3
---@param planePoint Vector3
---@return Vector3?
function ray2plane(dirOrigin, dir, planeNormal, planePoint)
   dir = dir:normalize()
   planeNormal = planeNormal:normalize()

   local dotProduct = dir:dot(planeNormal)
   if math.abs(dotProduct) < 1e-6 then return nil end

   local t = (planePoint - dirOrigin):dot(planeNormal) / dotProduct
   if t < 0 then return nil end

   local intersectionPoint = dirOrigin + dir * t
   return intersectionPoint
end
events.TICK:register(function ()
   local point = ray2plane(player:getPos():add(0,player:getEyeHeight(),0),player:getLookDir(),vectors.vec3(0,0,1),vectors.vec3(892,56,892))
   --print(point)
   particles:newParticle("minecraft:end_rod",point or vectors.vec3())
end)