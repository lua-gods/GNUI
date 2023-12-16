---@type Elements, Utils, EventLibLib, Config, Debug
local elements, utils, eventLib, config, debug = ...

---@class Elements
---@field container GNUI.container

--#region-->========================================[ Container ]=========================================<--

---@class GNUI.container : GNUI.element
---@field Dimensions Vector4
---@field ContainmentRect Vector4
---@field DIMENSIONS_CHANGED EventLib
---@field Margin Vector4
---@field MARGIN_CHANGED EventLib
---@field Padding Vector4
---@field PADDING_CHANGED EventLib
---@field Anchor Vector4
---@field ANCHOR_CHANGED EventLib
---@field Part ModelPart
local container = {}
container.__index = function (t,i)
   return container[i] or elements.element[i]
end

container.__type = "GNUI.element.container"

---Creates a new container.
---@param preset GNUI.container?
function container.new(preset)
   local new = preset or elements.element.new()
   setmetatable(new,container)
   new.Dimensions = vectors.vec4(0,0,0,0)
   new.DIMENSIONS_CHANGED = eventLib.new()
   new.Margin = vectors.vec4()
   new.ContainmentRect = vectors.vec4()
   new.MARGIN_CHANGED = eventLib.new()
   new.Padding = vectors.vec4()
   new.PADDING_CHANGED = eventLib.new()
   new.Anchor = vectors.vec4(0,0,1,1)
   new.ANCHOR_CHANGED = eventLib.new()
   new.Part = models:newPart("container"..new.id)

   -->==========[ Internals ]==========<--

   new.DIMENSIONS_CHANGED:register(function ()
      new.ContainmentRect = vectors.vec4(0,0,
         (new.Dimensions.z - new.Padding.x - new.Padding.z - new.Margin.x - new.Margin.z),
         (new.Dimensions.w - new.Padding.y - new.Padding.w - new.Margin.y - new.Margin.w)
      )
      if new.Parent and new.Parent.ContainmentRect then
         local p = new.Parent.ContainmentRect
         local o = vectors.vec4(
            math.lerp(p.x,p.z,new.Anchor.x),
            math.lerp(p.y,p.w,new.Anchor.y),
            math.lerp(p.x,p.z,new.Anchor.z),
            math.lerp(p.y,p.w,new.Anchor.w)
         )
         new.ContainmentRect.x = new.ContainmentRect.y + o.x
         new.ContainmentRect.y = new.ContainmentRect.y + o.y
         new.ContainmentRect.z = new.ContainmentRect.z + o.z
         new.ContainmentRect.w = new.ContainmentRect.w + o.w
      end
      new.Part
      :setPos(
         -new.Dimensions.x-new.Margin.x-new.Padding.x,
         -new.Dimensions.y-new.Margin.y-new.Padding.y,-15)
      for key, value in pairs(new.Children) do
         if value.DIMENSIONS_CHANGED then
            value.DIMENSIONS_CHANGED:invoke(value.DIMENSIONS_CHANGED)
         end
      end
   end,config.internal_events_name)

   new.MARGIN_CHANGED:register(function ()
      new.DIMENSIONS_CHANGED:invoke(new.Dimensions)
   end,config.internal_events_name)

   new.PADDING_CHANGED:register(function ()
      new.DIMENSIONS_CHANGED:invoke(new.Dimensions)
   end,config.internal_events_name)

   new.PARENT_CHANGED:register(function ()
      new.Part:moveTo(new.Parent.Part)
   end)

   -->==========[ Debug ]==========<--

   if config.debug_visible then
      local debug_container = elements.sprite.new():setModelpart(new.Part):setTexture(textures.outline):setBorderThickness(1,1,1,1):setRenderType("EMISSIVE_SOLID"):setScale(1):setColor(0,1,0)
      local debug_margin    = elements.sprite.new():setModelpart(new.Part):setTexture(textures.outline):setBorderThickness(1,1,1,1):setRenderType("EMISSIVE_SOLID"):setScale(1):setColor(1,0,0)
      local debug_padding   = elements.sprite.new():setModelpart(new.Part):setTexture(textures.outline):setBorderThickness(1,1,1,1):setRenderType("EMISSIVE_SOLID"):setScale(1) -- :setColor(0,1,0)

      new.DIMENSIONS_CHANGED:register(function ()
         local contain = new.ContainmentRect
         local margin = new.Margin
         local padding = new.Padding
         debug_padding
         :setSize(
            contain.z - contain.x,
            contain.w - contain.y)
         :setPos(
            - contain.x,
            - contain.y,-0.6)
         
         debug_margin
         :setPos(
            margin.x + padding.x - contain.x,
            margin.y + padding.y - contain.y,
            1)
         :setSize(
            (contain.z - contain.x + margin.z + margin.x + padding.x + padding.z),
            (contain.w - contain.y + margin.w + margin.y + padding.y + padding.w),1)
         debug_container
         :setPos(
            padding.x - contain.x,
            padding.y - contain.y,
            -0.3)
         :setSize(
            (contain.z+padding.x+padding.z - contain.x),
            (contain.w+padding.y+padding.w - contain.y),1)
      end,config.debug_event_name)
   end
   return new
end

-->====================[ Dimensions ]====================<--

---Sets the position of the container, the size stays the same.
---@param xpos number|Vector2
---@param y number?
function container:setPos(xpos,y)
   self.Dimensions.xy = utils.figureOutVec2(xpos,y)
   self.DIMENSIONS_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the size of the container
---@param xsize number|Vector2
---@param y number?
function container:setSize(xsize,y)
   self.Dimensions.zw = utils.figureOutVec2(xsize,y)
   self.DIMENSIONS_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the position of the top left part of the container, the bottom right stays in the same position
---@param xpos number|Vector2
---@param y number?
function container:setTopLeft(xpos,y)
   local old,new = self.Dimensions.xy,utils.figureOutVec2(xpos,y)
   local delta = new-old
   self.Dimensions.xy,self.Dimensions.zw = new,self.Dimensions.zw - delta
   self.DIMENSIONS_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the position of the top left part of the container, the top left stays in the same position
---@param zpos number|Vector2
---@param w number?
function container:setBottomRight(zpos,w)
   local old,new = self.Dimensions.xy+self.Dimensions.zw,utils.figureOutVec2(zpos,w)
   local delta = new-old
   self.Dimensions.zw = self.Dimensions.zw + delta
   self.DIMENSIONS_CHANGED:invoke(self,self.Dimensions)
   return self
end

-->====================[ Margins ]====================<--

---Sets the top margin.
---@param units number?
function container:setMarginTop(units)
   self.Margin.y = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the left margin.
---@param units number?
function container:setMarginLeft(units)
   self.Margin.x = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the down margin.
---@param units number?
function container:setMarginDown(units)
   self.Margin.z = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the right margin.
---@param units number?
function container:setMarginRight(units)
   self.Margin.w = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the margin for all sides.
---@param left number?
---@param top number?
---@param right number?
---@param bottom number?
function container:setMargin(left,top,right,bottom)
   self.Margin.x = left   or 0
   self.Margin.y = top    or 0
   self.Margin.z = right  or 0
   self.Margin.w = bottom or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

-->====================[ Padding ]====================<--

---Sets the top padding.
---@param units number?
function container:setPaddingTop(units)
   self.Padding.y = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the left padding.
---@param units number?
function container:setPaddingLeft(units)
   self.Padding.x = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the down padding.
---@param units number?
function container:setPaddingDown(units)
   self.Padding.z = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the right padding.
---@param units number?
function container:setPaddingRight(units)
   self.Padding.w = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the padding for all sides.
---@param left number?
---@param top number?
---@param right number?
---@param bottom number?
function container:setPadding(left,top,right,bottom)
   self.Padding.x = left   or 0
   self.Padding.y = top    or 0
   self.Padding.z = right  or 0
   self.Padding.w = bottom or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

-->====================[ Anchor ]====================<--

---Sets the top anchor.  
--- 0 = top part of the container is fully anchored to the top of its parent  
--- 1 = top part of the container is fully anchored to the bottom of its parent
---@param units number?
function container:setAnchorTop(units)
   self.Anchor.y = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the left anchor.  
--- 0 = left part of the container is fully anchored to the left of its parent  
--- 1 = left part of the container is fully anchored to the right of its parent
---@param units number?
function container:setAnchorLeft(units)
   self.Anchor.x = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the down anchor.  
--- 0 = bottom part of the container is fully anchored to the top of its parent  
--- 1 = bottom part of the container is fully anchored to the bottom of its parent
---@param units number?
function container:setAnchorDown(units)
   self.Anchor.z = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the right anchor.  
--- 0 = right part of the container is fully anchored to the left of its parent  
--- 1 = right part of the container is fully anchored to the right of its parent  
---@param units number?
function container:setAnchorRight(units)
   self.Anchor.w = units or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the anchor for all sides.  
--- x 0 <-> 1 = left <-> right  
--- y 0 <-> 1 = top <-> bottom
---@param left number?
---@param top number?
---@param right number?
---@param bottom number?
function container:setAnchor(left,top,right,bottom)
   self.Anchor.x = left   or 0
   self.Anchor.y = top    or 0
   self.Anchor.z = right  or 0
   self.Anchor.w = bottom or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

--#endregion

return container