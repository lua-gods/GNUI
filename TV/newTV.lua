local FigUI = require("libraries.FiGUI")
local skullHandler = require("libraries.skullHandler")
local lorem = require("lorem")

local model = models.core
models:removeChild(models.core)

---@class TV
---@field Window GNUI.container
---@field Dimensions Vector4
---@field current_app Application
local TV = {}
TV.__index = TV

local wallpaper = FigUI.newSprite()
:setTexture(textures.ui)
:setUV(0,16,0,16)
:setRenderType("EMISSIVE_SOLID")

---@param modelPart ModelPart
---@return TV
function TV:new(modelPart)
   local new = {}
   local window = FigUI.newContainer()
   new.Window = window
   modelPart:addChild(window.Part)
   setmetatable(new,TV)
   return new
end

function TV:free()
   self.Window:free()
   self = nil
end

local function check(pos)
   return world.getBlockState(pos).id
end

local MAX_SIZE = 500

---@param skull WorldSkull
skullHandler.INIT:register(function(skull)
   local rect = vectors.vec4(-MAX_SIZE,MAX_SIZE,-MAX_SIZE,MAX_SIZE)
   local mat = matrices.mat4()
   mat:translate(0,0,1)
   mat:rotateY(skull.rot)
   mat:translate(skull.pos)

   local s = vectors.vec2(0,0)
   local screen_block = world.getBlockState(skull.pos-skull.dir).id
   for i = 1, MAX_SIZE, 1 do
      local ws = mat:apply(s.x+i,s.y,0)
      if check(ws) ~= screen_block then
         rect.x = i-1
         break
      end
   end
   for i = 1, MAX_SIZE, 1 do
      local ws = mat:apply(s.x-i,s.y,0)
      if check(ws) ~= screen_block then
         rect.z = -i+1
         break
      end
   end
   for i = 1, MAX_SIZE, 1 do
      local ws = mat:apply(s.x,s.y+i,0)
      if check(ws) ~= screen_block then
         rect.y = i-1
         break
      end
   end
   for i = 1, MAX_SIZE, 1 do
      local ws = mat:apply(s.x,s.y-i,0)
      if check(ws) ~= screen_block then
         rect.w = -i+1
         break
      end
   end
   rect.y,rect.z,rect.w = rect.w,rect.x-rect.z+1,rect.y-rect.w+1 -- evaluate dimensions
   
   local part = model:copy("aa")
   local TVanchor = part:newPart("TVanchor")
   skull.model:addChild(part)
   part:setPos(8, 0, 8):setRot(0,180 + skull.rot)
   local tv = TV:new(TVanchor)
   skull.tv = tv
   tv.Window:setSize(16 * rect.z,16 * rect.w)
   tv.Window:setSprite(wallpaper:duplicate())
   TVanchor:setPos(8-(rect.x-rect.z+1)*16,(rect.y+rect.w)*16,-16-4-0.02)
end)

local appManager = require("TV.appManager")

function TV:setApp(id)
   if self.current_app then
      self.current_app.CLOSE(self.Window,self)
      self.current_app = nil
   end

   local new = appManager.apps[id].factory()
   self.current_app = new
   new.INIT(self.Window,self)
end

skullHandler.TICK:register(function (skull)
   if skull.tv and skull.tv.current_app and skull.tv.current_app.TICK then
      skull.tv.current_app.TICK(skull.tv.Window,skull.tv)
   end
end)

skullHandler.FRAME:register(function (skull,dt,df)
   if skull.tv and skull.tv.current_app and skull.tv.current_app.FRAME then
      skull.tv.current_app.FRAME(skull.tv.Window,skull.tv,dt,df)
   end
end)

skullHandler.INIT:register(function (skull)
   if skull.tv then
      skull.tv:setApp("home")
   end
end)

return TV