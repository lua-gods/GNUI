local eventLib = require("libraries.figui.eventHandler")
local utils = require("libraries.figui.utils")

local element = require("libraries.figui.elements.element")
local sprite = require("libraries.figui.spriteLib")
local core = require("libraries.figui.core")

---@class GNUI.container : GNUI.element
---@field Dimensions Vector4
---@field Z number
---@field ContainmentRect Vector4
---@field DIMENSIONS_CHANGED EventLib
---@field Margin Vector4
---@field MARGIN_CHANGED EventLib
---@field Padding Vector4
---@field PADDING_CHANGED EventLib
---@field Anchor Vector4
---@field ANCHOR_CHANGED EventLib
---@field Sprite Sprite
---@field SPRITE_CHANGED EventLib
---@field Cursor Vector2?
---@field CURSOR_CHANGED EventLib
---@field Hovering boolean
---@field CaptureCursor boolean
---@field PRESSED EventLib
---@field MOUSE_ENTERED EventLib
---@field MOUSE_EXITED EventLib
---@field Part ModelPart
local container = {}
container.__index = function (t,i)
   return container[i] or element[i]
end

container.__type = "GNUI.element.container"

---Creates a new container.
---@param preset GNUI.container?
---@return GNUI.container
function container.new(preset)
   local new = preset or element.new()
   setmetatable(new,container)
   new.Dimensions = vectors.vec4(0,0,0,0) 
   new.Z = 0
   new.DIMENSIONS_CHANGED = eventLib.new()
   new.Margin = vectors.vec4()
   new.ContainmentRect = vectors.vec4() -- Dimensions but with margins and anchored applied
   new.MARGIN_CHANGED = eventLib.new()
   new.Padding = vectors.vec4()
   new.PADDING_CHANGED = eventLib.new()
   new.Anchor = vectors.vec4(0,0,0,0)
   new.ANCHOR_CHANGED = eventLib.new()
   new.Part = models:newPart("container"..new.id)
   new.PARENT_CHANGED = eventLib.new()
   models:removeChild(new.Part)
   new.Cursor = vectors.vec2() -- in local space
   new.CURSOR_CHANGED = eventLib.new()
   new.SPRITE_CHANGED = eventLib.new()
   new.Hovering = false
   new.PRESSED = eventLib.new()
   new.CaptureCursor = true
   new.MOUSE_ENTERED = eventLib.new()
   new.MOUSE_EXITED = eventLib.new()
   new.Sprite = nil
   
   -->==========[ Internals ]==========<--
   local debug_container 
   local debug_margin    
   local debug_padding   
   local debug_cursor
   if core.debug_visible then
      debug_container = sprite.new():setModelpart(new.Part):setTexture(textures.outline):setBorderThickness(1,1,1,1):setRenderType("EMISSIVE_SOLID"):setScale(core.debug_scale):setColor(0,1,0):excludeMiddle(true)
      debug_margin    = sprite.new():setModelpart(new.Part):setTexture(textures.outline):setBorderThickness(1,1,1,1):setRenderType("EMISSIVE_SOLID"):setScale(core.debug_scale):setColor(1,0,0):excludeMiddle(true)
      debug_padding   = sprite.new():setModelpart(new.Part):setTexture(textures.outline):setBorderThickness(1,1,1,1):setRenderType("EMISSIVE_SOLID"):setScale(core.debug_scale):excludeMiddle(true)
      debug_cursor   = sprite.new():setModelpart(new.Part):setTexture(textures.ui):setUV(6,23,6,23):setRenderType("EMISSIVE_SOLID"):setSize(1,1)
   end

   new.DIMENSIONS_CHANGED:register(function ()
      -- generate the containment rect
      new.ContainmentRect = vectors.vec4(0,0,
         (new.Dimensions.z - new.Padding.x - new.Padding.z - new.Margin.x - new.Margin.z),
         (new.Dimensions.w - new.Padding.y - new.Padding.w - new.Margin.y - new.Margin.w)
      )
      -- adjust based on parent if this has one
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
         -new.Dimensions.y-new.Margin.y-new.Padding.y,
         (-(new.Z + 1) * core.clipping_margin)
      )
      for key, value in pairs(new.Children) do
         if value.DIMENSIONS_CHANGED then
            value.DIMENSIONS_CHANGED:invoke(value.DIMENSIONS_CHANGED)
         end
      end
      if new.Sprite then
         local contain = new.ContainmentRect
         local padding = new.Padding
         new.Sprite
            :setPos(
               padding.x - contain.x,
               padding.y - contain.y,
               0)
            :setSize(
               (contain.z+padding.x+padding.z - contain.x),
               (contain.w+padding.y+padding.w - contain.y)
            )
      end
      if core.debug_visible then
         local contain = new.ContainmentRect
         local margin = new.Margin
         local padding = new.Padding

         
         debug_padding
         :setSize(
            contain.z - contain.x,
            contain.w - contain.y)
         :setPos(
            - contain.x,
            - contain.y,(-(new.Z + 1) * core.clipping_margin) * 0.8)
         
         debug_margin
         :setPos(
            margin.x + padding.x - contain.x,
            margin.y + padding.y - contain.y,
            -(-(new.Z + 1) * core.clipping_margin) * 0.3)
         :setSize(
            (contain.z - contain.x + margin.z + margin.x + padding.x + padding.z),
            (contain.w - contain.y + margin.w + margin.y + padding.y + padding.w)
         )
         debug_container
         :setPos(
            padding.x - contain.x,
            padding.y - contain.y,
            -(-(new.Z + 1) * core.clipping_margin) * 0.6)
         :setSize(
            (contain.z+padding.x+padding.z - contain.x),
            (contain.w+padding.y+padding.w - contain.y)
         )
      end
   end,core.internal_events_name)

   new.CURSOR_CHANGED:register(function ()
      if core.debug_visible then
         -- Display the cursor in local space
         if new.Hovering then
            debug_cursor:setPos(
               -new.Cursor.x - new.ContainmentRect.x + new.Padding.x,
               -new.Cursor.y - new.ContainmentRect.y + new.Padding.y,
               (-(new.Z + 1) * core.clipping_margin) * 0.1
            ):setVisible(true)
         else
            debug_cursor:setVisible(false)
         end
      end
   end,core.debug_event_name)

   new.MARGIN_CHANGED:register(function ()
      new.DIMENSIONS_CHANGED:invoke(new.Dimensions)
   end,core.internal_events_name)

   new.PADDING_CHANGED:register(function ()
      new.DIMENSIONS_CHANGED:invoke(new.Dimensions)
   end,core.internal_events_name)

   new.PARENT_CHANGED:register(function ()
      if new.Parent then
         new.Part:moveTo(new.Parent.Part)
      else
         new.Part:getParent():removeChild(new.Part)
      end
      new.DIMENSIONS_CHANGED:invoke(new.Dimensions)
   end)
   return new
end


---Sets the backdrop of the container.  
---note: the object dosent get applied directly, its duplicated and the clone is used instead of the original.
---@param sprite_obj Sprite
---@return GNUI.container
function container:setSprite(sprite_obj)
   if self.Sprite then
      self.Sprite:_deleteRenderTasks()
      self.Sprite = nil
   end
   self.Sprite = sprite_obj
   self.Sprite:setModelpart(self.Part)
   self.SPRITE_CHANGED:invoke()
   self.DIMENSIONS_CHANGED:invoke()
   return self
end

-->====================[ Dimensions ]====================<--

---Sets the position of the container, the size stays the same.
---@param xpos number|Vector2
---@param y number?
function container:setPos(xpos,y)
   self.Dimensions.xy = utils.figureOutVec2(xpos,y)
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the size of the container
---@param xsize number|Vector2
---@param y number?
function container:setSize(xsize,y)
   self.Dimensions.zw = utils.figureOutVec2(xsize,y)
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the position of the top left part of the container, the bottom right stays in the same position
---@param xpos number|Vector2
---@param y number?
function container:setTopLeft(xpos,y)
   local old,new = self.Dimensions.xy,utils.figureOutVec2(xpos,y)
   local delta = new-old
   self.Dimensions.xy,self.Dimensions.zw = new,self.Dimensions.zw - delta
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the position of the top left part of the container, the top left stays in the same position
---@param zpos number|Vector2
---@param w number?
function container:setBottomRight(zpos,w)
   local old,new = self.Dimensions.xy+self.Dimensions.zw,utils.figureOutVec2(zpos,w)
   local delta = new-old
   self.Dimensions.zw = self.Dimensions.zw + delta
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Checks if the cursor in local coordinates is inside the bounding box of this container.
---@param x number|Vector2
---@param y number?
---@return boolean
function container:isHovering(x,y)
   local pos = utils.figureOutVec2(x,y)
   return (
      pos.x > 0 and pos.y > 0
      and pos.x < self.ContainmentRect.z-self.ContainmentRect.x+self.Padding.x+self.Padding.z 
      and pos.y < self.ContainmentRect.w-self.ContainmentRect.y+self.Padding.y+self.Padding.w)
end

---Sets the Cursor position relative to the top left of the container.  
---Returns true if the cursor is hovering over the container.  
---if press is true, the container on the top most pressed position will have its PRESSED event invoked.
---if forced is true, the container will have its PRESSED event invoked.
---@param xpos number|Vector2
---@param y number?
---@param press boolean?
---@param forced boolean?
---@return boolean
function container:setCursor(xpos,y,press,forced)
   press = press or false
   forced = forced or false
   local pos = utils.figureOutVec2(xpos,y)
   local lhovering = self.Hovering
   self.Hovering = self:isHovering(pos)
   self.Cursor = pos
   if self.Hovering and not forced then
      local hovering
      for i, child in pairs(self.Children) do
         if not hovering then
            if child.CaptureCursor then
               hovering = child:setCursor(
                  self.Cursor.x-child.ContainmentRect.x-child.Dimensions.x-child.Margin.x-self.Padding.x,
                  self.Cursor.y-child.ContainmentRect.y-child.Dimensions.y-child.Margin.y-self.Padding.y,
                  press)
               if hovering then -- obstructed by child
                  self.Hovering = false
               end
            end
         else
            if child.Hovering then
               child.Hovering = false
            end
         end
      end
   end
   if self.Hovering ~= lhovering then
      if self.Hovering then
         self.MOUSE_ENTERED:invoke()
      else
         self.MOUSE_EXITED:invoke()
      end
   end
   if forced then
      self.PRESSED:invoke()
   else
      if self.Hovering and self.CaptureCursor then
         if press then
            self.PRESSED:invoke()
         end
         self.CURSOR_CHANGED:invoke(pos)
      end
   end
   --self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self.Hovering
end

---Sets the offset of the depth for this container, a work around to fixing Z fighting issues when two elements overlap.
---@param depth number
---@return GNUI.container
function container:setZ(depth)
   self.Z = depth
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---If this container should be able to capture the cursor from its parent if obstructed.
---@param capture boolean
---@return GNUI.container
function container:canCaptureCursor(capture)
   self.CaptureCursor = capture
   return self
end

-->====================[ Margins ]====================<--

---Sets the top margin.
---@param units number?
function container:setMarginTop(units)
   self.Margin.y = units or 0
   self.MARGIN_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the left margin.
---@param units number?
function container:setMarginLeft(units)
   self.Margin.x = units or 0
   self.MARGIN_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the down margin.
---@param units number?
function container:setMarginDown(units)
   self.Margin.z = units or 0
   self.MARGIN_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the right margin.
---@param units number?
function container:setMarginRight(units)
   self.Margin.w = units or 0
   self.MARGIN_CHANGED:invoke(self.Dimensions)
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
   self.MARGIN_CHANGED:invoke(self.Dimensions)
   return self
end

-->====================[ Padding ]====================<--

---Sets the top padding.
---@param units number?
function container:setPaddingTop(units)
   self.Padding.y = units or 0
   self.MARGIN_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the left padding.
---@param units number?
function container:setPaddingLeft(units)
   self.Padding.x = units or 0
   self.MARGIN_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the down padding.
---@param units number?
function container:setPaddingDown(units)
   self.Padding.z = units or 0
   self.MARGIN_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the right padding.
---@param units number?
function container:setPaddingRight(units)
   self.Padding.w = units or 0
   self.MARGIN_CHANGED:invoke(self.Dimensions)
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
   self.MARGIN_CHANGED:invoke(self.Dimensions)
   return self
end

-->====================[ Anchor ]====================<--

---Sets the top anchor.  
--- 0 = top part of the container is fully anchored to the top of its parent  
--- 1 = top part of the container is fully anchored to the bottom of its parent
---@param units number?
function container:setAnchorTop(units)
   self.Anchor.y = units or 0
   self.MARGIN_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the left anchor.  
--- 0 = left part of the container is fully anchored to the left of its parent  
--- 1 = left part of the container is fully anchored to the right of its parent
---@param units number?
function container:setAnchorLeft(units)
   self.Anchor.x = units or 0
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the down anchor.  
--- 0 = bottom part of the container is fully anchored to the top of its parent  
--- 1 = bottom part of the container is fully anchored to the bottom of its parent
---@param units number?
function container:setAnchorDown(units)
   self.Anchor.z = units or 0
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the right anchor.  
--- 0 = right part of the container is fully anchored to the left of its parent  
--- 1 = right part of the container is fully anchored to the right of its parent  
---@param units number?
function container:setAnchorRight(units)
   self.Anchor.w = units or 0
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the anchor for all sides.  
--- x 0 <-> 1 = left <-> right  
--- y 0 <-> 1 = top <-> bottom
---@param left number|Vector4
---@param top number?
---@param right number?
---@param bottom number?
function container:setAnchor(left,top,right,bottom)
   self.Anchor = utils.figureOutVec4(left,top,right,bottom)
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

return container