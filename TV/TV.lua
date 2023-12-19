local FiGUI = require("libraries.FiGUI")
local lorem = require("lorem")

local api = {}

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
local wallpaper = FiGUI.newSprite()
:setTexture(textures.ui)
:setUV(0,14,0,14)
:setRenderType("EMISSIVE_SOLID")

local size = vectors.vec2(7,3)
local origin = vectors.vec3(889,57,889)
local TV = models:newPart("TV","SKULL")
:pos(size.x*8,size.y*16,16+4)
:rot(0,180,0)

---create window
local window = FiGUI.newContainer()
:setSprite(wallpaper)
:setSize(size * 16)
:setPos(size.x * -16,0)
TV:addChild(window.Part)

events.SKULL_RENDER:register(function (delta, block, item,_,ctx)
   TV:setVisible(ctx == "BLOCK" and block:getPos() == origin)
end)
--local label = GNUI.newLabel()
--:setAlign(0,0)
--:setFontScale(0.1)
--:setText(lorem)
--:setMargin(5,5,5,5)
--:setPadding(2,2,2,2)

--window:addChild(label)

events.WORLD_RENDER:register(function (dt)
   local world_cursor = ray2plane(client:getCameraPos(),client:getCameraDir(),vectors.vec3(0,0,1),origin:copy():add(0,0,1.8))
   local time = client:getSystemTime() / 100
   --label:setAnchor(
   --   math.cos(time*0.25)*0.1 + 0.1,math.sin(time*0.23)*0.1 + 0.1,
   --   math.cos(time*0.23)*0.1 + 0.9,math.sin(time*0.21)*0.1 + 0.9
   --)
   --label:setFontScale(math.abs((time * 0.1) % 2 - 1)*0.1 + 0.2)
   --:setAlign(math.abs((time * 0.05) % 2 - 1),math.abs((time * 0.0513513) % 2 - 1))
   if world_cursor then
      local local_cursor = vectors.vec2(
         world_cursor.x-origin.x+size.x * 0.5 - 0.5,
         origin.y-world_cursor.y+size.y
      ) * 16 - window.Padding.xy
      
      --window:setCursor(local_cursor.x,local_cursor.y)
   end
end)


window:setPadding(2,2,2,2)

--local packed = textures:newTexture("atlas1",128,128)
--local packed_dim = packed:getDimensions()
--packed:fill(0,0,packed_dim.x,packed_dim.y,vectors.vec4(0,0,0,0))
--
--local packed_sprite = FiGUI.newSprite()
--:setTexture(packed)
--
--local packed_display = FiGUI.newContainer()
--:setSprite(packed_sprite)
--window:addChild(packed_display)
--packed_display:setAnchor(0,0,0,0)
--packed_display:setBottomRight(44,44)
--
--local debug_label = FiGUI.newLabel()
--debug_label:setAnchor(0,0,1,1)
--debug_label:setTopLeft(44,0)
--debug_label:setMargin(2,0,0,0)
--window:addChild(debug_label)
--
--debug_label:setText("Cool Text"):setFontScale(0.4)
--
--local rects = {}
--for i = 1, 200, 1 do
--   rects[#rects+1] = vectors.vec2(math.random(1,16),math.random(1,16))
--end
--
--events.WORLD_TICK:register(function ()
--   if #rects > 0 then
--      local box = rects[1]
--      local found_spot = false
--      for x = 0, packed_dim.x-box.x-1, 1 do
--         for y = 0, packed_dim.y-box.y-1, 1 do
--
--            local nvm = false
--            for bx = 0, box.x, 1 do
--               for by = 0, box.y, 1 do
--                  local pxl = packed:getPixel(x+bx,y+by)
--                  if pxl.x + pxl.y + pxl.z > 0 then
--                     nvm = true
--                     break
--                  end
--               end
--               if nvm then
--                  break
--               end
--            end
--            
--            if not nvm then
--               packed:fill(x,y,box.x,box.y,vectors.vec3(math.random(),math.random(),math.random()):normalize())
--               packed:update()
--               found_spot = true
--            end
--            if found_spot then break end
--         end
--         if found_spot then break end
--      end
--      table.remove(rects,1)
--      found_spot = false
--      local compose = "Cool Shoes\n"
--      for i, value in pairs(rects) do
--         compose = compose .. tostring(value) .. "\n"
--         if i > 10 then
--            compose = compose .. "..."
--            break
--         end
--      end
--      debug_label:setText(compose)
--   else
--      events.WORLD_TICK:remove("packer")
--   end
--end,"packer")

local apps = {}---@type table<any,{app:Application,id:string,name:string}>
local current_app = nil ---@type Application?

---@class Application
---@field START fun(window : GNUI.container)?
---@field TICK fun(window : GNUI.container)?
---@field FRAME fun(window : GNUI.container,delta_frame : number,delta_tick : number)?
---@field CLOSE fun(window : GNUI.container)?

---@param application Application
function api.registerApp(application,id,name)
   apps[id] = {app = application,id = id,name = name}
end

for _, path in pairs(listFiles("TV.apps")) do
   api.registerApp(require(path))
end

function api.setApp(id)
   if current_app then
      current_app.CLOSE(window)
   end
   window
   :setSprite(wallpaper)
   :setSize(size * 16)
   :setPos(size.x * -16,0)
   if apps[id] then
      apps[id].app.START(window)
      current_app = apps[id].app
   end
end

events.WORLD_TICK:register(function ()
   if current_app then
      current_app.TICK(window)
   end
end)

local last_system_time = client:getSystemTime()
events.WORLD_RENDER:register(function (dt)
   local system_time = client:getSystemTime()
   local delta = (system_time - last_system_time) / 1000
   if current_app then
      current_app.FRAME(window,delta,dt)
   end
end)

api.setApp("home")

return api