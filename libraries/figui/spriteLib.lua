
local default_texture = textures:newTexture("1x1white",1,1):setPixel(0,0,vectors.vec3(1,1,1))
local eventLib = require("libraries.figui.eventHandler")
local utils = require("libraries.figui.utils")
local core = require("libraries.figui.core")


---@class Sprite
---@field Texture Texture
---@field TEXTURE_CHANGED EventLib
---@field Modelpart ModelPart?
---@field MODELPART_CHANGED EventLib
---@field UV Vector4
---@field Size Vector2
---@field Position Vector3
---@field Color Vector3
---@field Scale number
---@field DIMENSIONS_CHANGED EventLib
---@field RenderTasks table<any,SpriteTask>
---@field RenderType ModelPart.renderType
---@field BorderThickness Vector4
---@field BORDER_THICKNESS_CHANGED EventLib
---@field ExcludeMiddle boolean
---@field Visible boolean
---@field id integer
local sprite = {}
sprite.__index = sprite

local sprite_next_free = 0
---@return Sprite
function sprite.new(obj)
   local new = obj or {}
   setmetatable(new,sprite)
   new.Texture = new.Texture or default_texture
   new.TEXTURE_CHANGED = eventLib.new()
   new.MODELPART_CHANGED = eventLib.new()
   new.Position = new.Position or vectors.vec3()
   new.UV = new.UV or vectors.vec4(0,0,1,1)
   new.Size = new.Size or vectors.vec2(16,16)
   new.Color = new.Color or vectors.vec3(1,1,1)
   new.Scale = new.Scale or 4
   new.DIMENSIONS_CHANGED = eventLib.new()
   new.RenderTasks = {}
   new.RenderType = new.RenderType or "EMISSIVE_SOLID"
   new.BorderThickness = new.BorderThickness or vectors.vec4(0,0,0,0)
   new.BORDER_THICKNESS_CHANGED = eventLib.new()
   new.ExcludeMiddle = new.ExcludeMiddle or false
   new.Cursor = vectors.vec2()
   new.CURSOR_CHANGED = eventLib.new()
   new.Visible = true
   new.id = new.id or sprite_next_free
   sprite_next_free = sprite_next_free + 1
   
   new.TEXTURE_CHANGED:register(function ()
      new:_updateRenderTasks()
   end,core.internal_events_name)

   new.MODELPART_CHANGED:register(function ()
      new:_deleteRenderTasks()
      new:_buildRenderTasks()
   end,core.internal_events_name)

   new.BORDER_THICKNESS_CHANGED:register(function ()
      new:_deleteRenderTasks()
      new:_buildRenderTasks()
   end,core.internal_events_name)
   
   new.DIMENSIONS_CHANGED:register(function ()
      new:_updateRenderTasks()
   end,core.internal_events_name)

   return new
end

---Sets the modelpart to parent to.
---@param part ModelPart
---@return Sprite
function sprite:setModelpart(part)
   self.Modelpart = part
   self.MODELPART_CHANGED:invoke(self.Modelpart)
   return self
end


---Sets the displayed image texture on the sprite.
---@param texture Texture
---@return Sprite
function sprite:setTexture(texture)
   if type(texture) ~= "Texture" then error("Invalid texture, recived "..type(texture)..".",2) end
   self.Texture = texture
   local dim = texture:getDimensions()
   self.UV = vectors.vec4(0,0,dim.x-1,dim.y-1)
   self.TEXTURE_CHANGED:invoke(self,self.Texture)
   return self
end

---Sets the position of the Sprite, relative to its parent.
---@param xpos number
---@param y number
---@param depth number?
---@return Sprite
function sprite:setPos(xpos,y,depth)
   self.Position = utils.figureOutVec3(xpos,y,depth or 0)
   self.DIMENSIONS_CHANGED:invoke(self,self.Position,self.Size)
   return self
end

---Tints the Sprite multiplicatively
---@param rgb number|Vector3
---@param g number?
---@param b number?
---@return Sprite
function sprite:setColor(rgb,g,b)
   self.Color = utils.figureOutVec3(rgb,g,b)
   self.DIMENSIONS_CHANGED:invoke(self,self.Position,self.Size)
   return self
end

---Sets the size of the sprite duh.
---@param xpos number
---@param y number
---@return Sprite
function sprite:setSize(xpos,y)
   self.Size = utils.figureOutVec2(xpos,y)
   self.DIMENSIONS_CHANGED:invoke(self,self.Position,self.Size)
   return self
end

---@param scale number
---@return Sprite
function sprite:setScale(scale)
   self.Scale = scale
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

-->====================[ Border ]====================<--

---Sets the top border thickness.
---@param units number?
---@return Sprite
function sprite:setBorderThicknessTop(units)
   self.BorderThickness.y = units or 0
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

---Sets the left border thickness.
---@param units number?
---@return Sprite
function sprite:setBorderThicknessLeft(units)
   self.BorderThickness.x = units or 0
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

---Sets the down border thickness.
---@param units number?
---@return Sprite
function sprite:setBorderThicknessDown(units)
   self.BorderThickness.z = units or 0
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

---Sets the right border thickness.
---@param units number?
---@return Sprite
function sprite:setBorderThicknessRight(units)
   self.BorderThickness.w = units or 0
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

---Sets the padding for all sides.
---@param left number?
---@param top number?
---@param right number?
---@param bottom number?
---@return Sprite
function sprite:setBorderThickness(left,top,right,bottom)
   self.BorderThickness.x = left   or 0
   self.BorderThickness.y = top    or 0
   self.BorderThickness.z = right  or 0
   self.BorderThickness.w = bottom or 0
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

---Sets the UV region of the sprite.
---@param x number
---@param y number
---@param width number
---@param height number
---@return Sprite
function sprite:setUV(x,y,width,height)
   self.UV = vectors.vec4(x,y,width,height)
   self.BORDER_THICKNESS_CHANGED:invoke(self.BorderThickness)
   return self
end

---Sets the render type of your sprite
---@param renderType ModelPart.renderType
---@return Sprite
function sprite:setRenderType(renderType)
   self.RenderType = renderType
   self:_deleteRenderTasks()
   self:_buildRenderTasks()
   return self
end

---Set to true if you want a hole in the middle of your ninepatch
---@param toggle boolean
---@return Sprite
function sprite:excludeMiddle(toggle)
   self.ExcludeMiddle = toggle
   return self
end

function sprite:duplicate()
   local copy = {}
   for key, value in pairs(self) do
      if type(value):find("Vector") then
         value = value:copy()
      end
      copy[key] = value
   end
   return sprite.new(copy)
end

function sprite:setVisible(visibility)
   self:_updateRenderTasks()
   self.Visible = visibility
   return self
end

function sprite:_deleteRenderTasks()
   for _, task in pairs(self.RenderTasks) do
      self.Modelpart:removeTask(task:getName())
   end
   return self
end

function sprite:_buildRenderTasks()
   if not self.Modelpart then return self end
   local b = self.BorderThickness
   self.is_ninepatch = not (b.x == 0 and b.y == 0 and b.z == 0 and b.w == 0)
   if not self.is_ninepatch then -- not 9-Patch
      self.RenderTasks[1] = self.Modelpart:newSprite("patch"..self.id)
   else
      self.RenderTasks = {
         self.Modelpart:newSprite("patch_tl"..self.id),
         self.Modelpart:newSprite("patch_t"..self.id),
         self.Modelpart:newSprite("patch_tr"..self.id),
         self.Modelpart:newSprite("patch_ml"..self.id),
         self.Modelpart:newSprite("patch_m"..self.id),
         self.Modelpart:newSprite("patch_mr"..self.id),
         self.Modelpart:newSprite("patch_bl"..self.id),
         self.Modelpart:newSprite("patch_b"..self.id),
         self.Modelpart:newSprite("patch_br"..self.id)
      }
   end
   self:_updateRenderTasks()
end

function sprite:_updateRenderTasks()
   if not self.Modelpart then return self end
   local dim = self.Texture:getDimensions()
   local uv = self.UV:copy():add(0,0,1,1)
   if not self.is_ninepatch then
      self.RenderTasks[1]
      :setTexture(self.Texture)
      :setPos(self.Position)
      :setScale(self.Size.x/dim.x,self.Size.y/dim.y)
      :setColor(self.Color)
      :setRenderType(self.RenderType)
      :setUVPixels(
         uv.x,
         uv.y
      ):region(
         uv.z-uv.x,
         uv.w-uv.y
      ):setVisible(self.Visible)
   else
      local sborder = self.BorderThickness*self.Scale
      local pxborder = self.BorderThickness
      local pos = self.Position
      local size = self.Size
      local uvsize = vectors.vec2(uv.z-uv.x,uv.w-uv.y)
      for _, task in pairs(self.RenderTasks) do
         task
         :setTexture(self.Texture)
         :setColor(self.Color)
         :setRenderType(self.RenderType)
      end
      self.RenderTasks[1]
      :setPos(
         pos
      ):setScale(
         sborder.x/dim.x,
         sborder.y/dim.y
      ):setUVPixels(
         uv.x,
         uv.y
      ):region(
         pxborder.x,
         pxborder.y
      ):setVisible(self.Visible)
      
      self.RenderTasks[2]
      :setPos(
         pos.x-sborder.x,
         pos.y,
         pos.z
      ):setScale(
         (size.x-sborder.z-sborder.x)/dim.x,
         sborder.y/dim.y
      ):setUVPixels(
         uv.x+pxborder.x,
         uv.y
      ):region(
         uvsize.x-pxborder.x-pxborder.z,
         pxborder.y
      ):setVisible(self.Visible)

      self.RenderTasks[3]
      :setPos(
         pos.x-size.x+sborder.z,
         pos.y,
         pos.z
      ):setScale(
         sborder.z/dim.x,sborder.y/dim.y
      ):setUVPixels(
         uv.z-pxborder.z,
         uv.y
      ):region(
         pxborder.z,
         pxborder.y
      ):setVisible(self.Visible)

      self.RenderTasks[4]
      :setPos(
         pos.x,
         pos.y-sborder.y,
         pos.z
      ):setScale(
         sborder.x/dim.x,
         (size.y-sborder.y-sborder.w)/dim.y
      ):setUVPixels(
         uv.x,
         uv.y+pxborder.y
      ):region(
         pxborder.x,
         uvsize.y-pxborder.y-pxborder.w
      ):setVisible(self.Visible)
      if not self.ExcludeMiddle then
         self.RenderTasks[5]
         :setPos(
            pos.x-sborder.x,
            pos.y-sborder.y,
            pos.z
         )
         :setScale(
            (size.x-sborder.x-sborder.z)/dim.x,
            (size.y-sborder.y-sborder.w)/dim.y
         ):setUVPixels(
            uv.x+pxborder.x,
            uv.y+pxborder.y
         ):region(
            uvsize.x-pxborder.x-pxborder.z,
            uvsize.y-pxborder.y-pxborder.w
         ):setVisible(self.Visible)
      else
         self.RenderTasks[5]:setVisible(false)
      end

      self.RenderTasks[6]
      :setPos(
         pos.x-size.x+sborder.z,
         pos.y-sborder.y,
         pos.z
      )
      :setScale(
         sborder.z/dim.x,
         (size.y-sborder.y-sborder.w)/dim.y
      ):setUVPixels(
         uv.z-pxborder.z,
         uv.y+pxborder.y
      ):region(
         pxborder.z,
         uvsize.y-pxborder.y-pxborder.w
      ):setVisible(self.Visible)
      
      
      self.RenderTasks[7]
      :setPos(
         pos.x,
         pos.y-size.y+sborder.w,
         pos.z
      )
      :setScale(
         sborder.x/dim.x,
         sborder.w/dim.y
      ):setUVPixels(
         uv.x,
         uv.w-pxborder.w
      ):region(
         pxborder.x,
         pxborder.w
      ):setVisible(self.Visible)

      self.RenderTasks[8]
      :setPos(
         pos.x-sborder.x,
         pos.y-size.y+sborder.w,
         pos.z
      ):setScale(
         (size.x-sborder.z-sborder.x)/dim.x,
         sborder.w/dim.y
      ):setUVPixels(
         uv.x+pxborder.x,
         uv.w-pxborder.w
      ):region(
         uvsize.x-pxborder.x-pxborder.z,
         pxborder.w
      ):setVisible(self.Visible)

      self.RenderTasks[9]
      :setPos(
         pos.x-size.x+sborder.z,
         pos.y-size.y+sborder.w,
         pos.z
      ):setScale(
         sborder.z/dim.x,
         sborder.w/dim.y
      ):setUVPixels(
         uv.z-pxborder.z,
         uv.w-pxborder.w
      ):region(
         pxborder.z,
         pxborder.w
      ):setVisible(self.Visible)
   end
end

return sprite