---@type Elements, Utils, EventLibLib, Config, Debug
local elements, utils, eventLib, config, debug = ...

---@class Elements
---@field sprite Sprite

--#region-->========================================[ SpriteRenderer ]=========================================<--

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
---@field id integer
local sprite = {}
sprite.__index = sprite

local sprite_next_free = 0
---@return Sprite
function sprite.new()
   local new = {}
   setmetatable(new,sprite)
   new.Texture = debug.texture
   new.TEXTURE_CHANGED = eventLib.new()
   new.MODELPART_CHANGED = eventLib.new()
   new.Position = vectors.vec3()
   new.UV = vectors.vec4(0,0,1,1)
   new.Size = vectors.vec2(16,16)
   new.Color = vectors.vec3(1,1,1)
   new.Scale = 4
   new.DIMENSIONS_CHANGED = eventLib.new()
   new.RenderTasks = {}
   new.RenderType = "CUTOUT_CULL"
   new.BorderThickness = vectors.vec4(0,0,0,0)
   new.BORDER_THICKNESS_CHANGED = eventLib.new()
   new.ExcludeMiddle = false
   new.id = sprite_next_free
   sprite_next_free = sprite_next_free + 1
   
   new.TEXTURE_CHANGED:register(function ()
      new:_updateRenderTasks()
   end,config.internal_events_name)

   new.MODELPART_CHANGED:register(function ()
      new:_deleteRenderTasks()
      new:_buildRenderTasks()
   end,config.internal_events_name)

   new.BORDER_THICKNESS_CHANGED:register(function ()
      new:_deleteRenderTasks()
      new:_buildRenderTasks()
   end,config.internal_events_name)
   
   new.DIMENSIONS_CHANGED:register(function ()
      new:_updateRenderTasks()
   end,config.internal_events_name)

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
   self.Texture = texture
   local dim = texture:getDimensions()
   self.UV = vectors.vec4(0,0,dim.x,dim.y)
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

---Sets the UV region of the sprite, a and b are relative to the top left to the bottom right
---@param ax number
---@param ay number
---@param bx number
---@param by number
---@return Sprite
function sprite:setUV(ax,ay,bx,by)
   self.UV = vectors.vec4(ax,ay,bx,by)
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

function sprite:_deleteRenderTasks()
   for _, task in pairs(self.RenderTasks) do
      self.Modelpart:removeTask(task:getName())
   end
   return self
end

function sprite:_buildRenderTasks()
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
   local dim = self.Texture:getDimensions()
   local uv = self.UV:copy()
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
         uv.z,
         uv.w
      )
   else
      local border = self.BorderThickness*self.Scale
      local uvborder = self.BorderThickness
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
         border.x/dim.x,
         border.y/dim.y
      ):setUVPixels(
         uv.x,
         uv.y
      ):region(
         uvborder.x,
         uvborder.y
      )
      
      self.RenderTasks[2]
      :setPos(
         pos.x-border.x,
         pos.y,
         pos.z
      ):setScale(
         (size.x-border.z-border.x)/dim.x,
         border.y/dim.y
      ):setUVPixels(
         uv.x+uvborder.x,
         uv.y
      ):region(
         uvsize.x-uvborder.x-uvborder.z,
         uvborder.y
      )
      self.RenderTasks[3]
      :setPos(
         pos.x-size.x+border.z,
         pos.y,
         pos.z
      ):setScale(
         border.z/dim.x,border.y/dim.y
      ):setUVPixels(
         uv.z-uvborder.z,
         uv.y
      ):region(
         uvborder.z,
         uvborder.y
      )

      self.RenderTasks[4]
      :setPos(
         pos.x,
         pos.y-border.y,
         pos.z
      )
      :setScale(
         border.x/dim.x,
         (size.y-border.y-border.w)/dim.y
      ):setUVPixels(
         uv.x,
         uv.y+uvborder.y
      ):region(
         uvborder.x,
         uvsize.y-uvborder.y-uvborder.w
      )
      if self.ExcludeMiddle then
         self.RenderTasks[5]
         :setPos(
            pos.x-border.x,
            pos.y-border.y,
            pos.z
         )
         :setScale(
            (size.x-border.x-border.z)/dim.x,
            (size.y-border.y-border.w)/dim.y
         ):setUVPixels(
            uv.x+uvborder.x,
            uv.y+uvborder.y
         ):region(
            uvsize.x-uvborder.x-uvborder.z,
            uvsize.y-uvborder.y-uvborder.w
         ):setVisible(true)
      else
         self.RenderTasks[5]:setVisible(false)
      end

      self.RenderTasks[6]
      :setPos(
         pos.x-size.x+border.z,
         pos.y-border.y,
         pos.z
      )
      :setScale(
         border.z/dim.x,
         (size.y-border.y-border.w)/dim.y
      ):setUVPixels(
         uv.z-uvborder.z,
         uv.y+uvborder.y
      ):region(
         uvborder.z,
         uvsize.y-uvborder.y-uvborder.w
      )
      
      
      self.RenderTasks[7]
      :setPos(
         pos.x,
         pos.y-size.y+border.w,
         pos.z
      )
      :setScale(
         border.x/dim.x,
         border.w/dim.y
      ):setUVPixels(
         uv.x,
         uv.w-uvborder.w
      ):region(
         uvborder.x,
         uvborder.w
      )

      self.RenderTasks[8]
      :setPos(
         pos.x-border.x,
         pos.y-size.y+border.w,
         pos.z
      )
      :setScale(
         (size.x-border.z-border.x)/dim.x,
         border.w/dim.y
      ):setUVPixels(
         uv.x+uvborder.x,
         uv.w-uvborder.w
      ):region(
         uvsize.x-uvborder.x-uvborder.z,
         uvborder.w
      )

      self.RenderTasks[9]
      :setPos(
         pos.x-size.x+border.z,
         pos.y-size.y+border.w,
         pos.z
      )
      :setScale(
         border.z/dim.x,
         border.w/dim.y
      ):setUVPixels(
         uv.z-uvborder.z,
         uv.w-uvborder.w
      ):region(
         uvborder.z,
         uvborder.w
      )
   end
end

--#endregion

return sprite