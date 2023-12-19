local GNUI = require("libraries.GNUI")
local lorem = require("lorem")

--[[ NOTE
This is a Skull specifically hard coded in the Figura SMP at the lua goofs base
Right behind the TV at 889,57,889 is the skull facing north.
]]

---@param dir Vector3
---@param plane_normal Vector3
---@param plane_origin Vector3
---@return Vector3?
local function ray2plane(ray_origin, dir, plane_normal, plane_origin)
   dir = dir:normalize()
   plane_normal = plane_normal:normalize()

   local dot = dir:dot(plane_normal)
   if math.abs(dot) < 1e-6 then return nil end

   local t = (plane_origin - ray_origin):dot(plane_normal) / dot
   if t < 0 then return nil end

   local intersection = ray_origin + dir * t
   return intersection
end

--- create theme
local panel_texture = GNUI.newSprite()
:setTexture(textures.ui)
:setUV(0,6,4,10)
:setBorderThickness(2,2,2,2)
:setScale(2)
:setRenderType("EMISSIVE_SOLID")

local size = vectors.vec2(7,3)
local origin = vectors.vec3(889,57,889)
local TV = models:newPart("TV","SKULL")
:pos(size.x*8,size.y*16,16+4)
:rot(0,180,0)

---create window
local window = GNUI.newContainer()
:setSprite(panel_texture)
:setSize(size * 16)
:setPos(size.x * -16,0)
TV:addChild(window.Part)

events.SKULL_RENDER:register(function (delta, block, item,_,ctx)
   TV:setVisible(ctx == "BLOCK" and block:getPos() == origin)
end)
local label = GNUI.newLabel()
:setText(lorem)
:setMargin(5,5,5,5)
:setPadding(2,2,2,2)
:setAlign(1,0.5)
label:setFontScale(0.25)

window:addChild(label)
window.Part:newPart("viewport"):scale(1,1,0):newBlock("icon"):block("minecraft:grass_block")

events.WORLD_RENDER:register(function (dt)
   local world_cursor = ray2plane(client:getCameraPos(),client:getCameraDir(),vectors.vec3(0,0,1),origin:copy():add(0,0,1.8))
   local time = client:getSystemTime() / 100
   label:setAnchor(
      math.cos(time*0.25)*0.1 + 0.1,math.sin(time*0.23)*0.1 + 0.1,
      math.cos(time*0.23)*0.1 + 0.9,math.sin(time*0.21)*0.1 + 0.9
   )
   --label:setFontScale(math.sin(time * 0.1) * 0.1 + 0.25)
   --:setAlign(math.abs((time * 0.05) % 2 - 1),math.abs((time * 0.0513513) % 2 - 1))
   if world_cursor then
      local local_cursor = vectors.vec2(
         world_cursor.x-origin.x+size.x * 0.5 - 0.5,
         origin.y-world_cursor.y+size.y
      ) * 16
      
      window:setCursor(local_cursor.x,local_cursor.y)
   end
end)