
---@class WorldSkull
---@field last_seen number
---@field model ModelPart
---@field pos Vector3
---@field rot number
---@field dir Vector3
---@field offset_model Vector3

---@type table<any,WorldSkull>
local skulls = {}
local eventLib = require("libraries.figui.eventHandler")

local worldPart = models:newPart("worldPart","SKULL")
local inviskull = models:newPart("inviskull","SKULL"):newBlock("placeholder"):block("dirt"):scale(0,0,0)


local config = {
   expire = 40, -- seconds
}

local api = {
   skulls = skulls,
   INIT = eventLib.new(),
   EXIT = eventLib.new(),
   TICK = eventLib.new(),
   FRAME = eventLib.new(),
}

local half = vectors.vec3(.5, .5, .5)
local lookup = {
   dir = {
      wall = {
         north = vectors.vec3( 0,  0, -1),
         east  = vectors.vec3( 1,  0,  0),
         south = vectors.vec3( 0,  0,  1),
         west  = vectors.vec3(-1,  0,  0),
      },
      floor = {},
   },
   rot = {
      wall = {
         north = 0,
         east = 270,
         south = 180,
         west = 90,
      },
      floor = {}
   }
}

for i = 0, 15, 1 do
   local angle = -i * (360 / 16)
   lookup.dir.floor[tostring(i)] = vectors.rotateAroundAxis(angle, vectors.vec3(0, 0, -1),vectors.vec3(0, 1, 0))
   lookup.rot.floor[tostring(i)] = angle
end

local systime = client:getSystemTime() / 1000
local order = 0
events.SKULL_RENDER:register(function(delta, block, item, entity, context)
   inviskull:setVisible(context == "BLOCK")
   worldPart:setVisible(order == 0 and context == "BLOCK")
   if context == "BLOCK" then
      order = order + 1
      local pos = block:getPos()
      local id = "x" .. pos.x .. "y" .. pos.y .. "z" .. pos.z
      
      if skulls[id] then
         skulls[id].last_seen = systime
      else
         local dir
         local rot
         local offset
         local properties = block:getProperties()
         if block.id == "minecraft:player_wall_head" then
            dir = lookup.dir.wall[properties.facing]
            rot = lookup.rot.wall[properties.facing]
            offset = vectors.vec3(-8,-4,-8) + dir * 4
         else
            dir = lookup.dir.floor[properties.rotation]
            rot = lookup.rot.floor[properties.rotation]
            offset = vectors.vec3(-8,0,-8)
         end
         local part = worldPart:newPart(id)
         skulls[id] = {
            model = part,
            block = block,
            pos = pos,
            dir = dir,
            rot = rot,
            last_seen = systime,
            offset_model = offset,
         }
         part:setPos(pos * 16)
         api.INIT:invoke(skulls[id])
      end

      if order == 1 then
         local mat = matrices.mat4()
         :translate(-pos * 16)
         :translate(skulls[id].offset_model)
         :rotateY(-skulls[id].rot)
         worldPart:setMatrix(mat)
      end
   end
end)

events.WORLD_TICK:register(function()
   for id, skull in pairs(skulls) do
      api.TICK:invoke(skull)
      if not (world.getBlockState(skull.pos).id:find("player") and systime - skull.last_seen < config.expire) then
         api.EXIT:invoke(skulls[id])
         skull.model:getParent():removeChild(skull.model)
         skulls[id] = nil
      end
   end
end)

events.WORLD_RENDER:register(function (delta_tick)
   order = 0
   local t = client:getSystemTime() / 1000
   local delta_frame = t-systime
   systime = t
   for id, skull in pairs(skulls) do
      api.FRAME:invoke(skull,delta_tick,delta_frame)
   end
end)

return api
