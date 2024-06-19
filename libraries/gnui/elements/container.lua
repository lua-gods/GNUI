local eventLib = require("libraries.eventLib")
local utils = require("libraries.gnui.utils")

local debug_texture = textures['gnui_debug_outline'] or textures:newTexture("gnui_debug_outline",3,3):fill(0,0,3,3,vectors.vec3(1,1,1)):setPixel(1,1,vectors.vec3(0,0,0))
local element = require("libraries.gnui.elements.element")
local sprite = require("libraries.gnui.spriteLib")
local core = require("libraries.gnui.core")

---@class GNUI.container : GNUI.element
---@field Dimensions Vector4           # Determins the offset of each side from the final output
---@field Z number                     # Offsets the container forward(+) or backward(-) if Z fighting is occuring, also affects its children.
---@field ContainmentRect Vector4      # The final output dimensions with anchors applied. incredibly handy piece of data.
---@field DIMENSIONS_CHANGED eventLib  # Triggered when the final container dimensions has changed.
---@field SIZE_CHANGED eventLib        # Triggered when the size of the final container dimensions is different from the last tick.
---@field Anchor Vector4               # Determins where to attach to its parent, (`0`-`1`, left-right, up-down)
---@field ANCHOR_CHANGED eventLib      # Triggered when the anchors applied to the container is changed.
---@field Sprite Sprite                # the sprite that will be used for displaying textures.
---@field SPRITE_CHANGED eventLib      # Triggered when the sprite object set to this container has changed.
---@field Cursor Vector2?              # where the cursor will be from the top left of the final container dimensions.
---@field CURSOR_CHANGED eventLib      # Triggered when the Cursor set for this container changed
---@field Hovering boolean             # True when the cursor is hovering over it, compared with the parent container.
---@field CaptureCursor boolean        # if `true` will capture the cursor from its parent once `Hovering` over itself over the parent.
---@field PRESSED eventLib             # Triggered when `setCursor` is called with the press argument set to true
---@field MOUSE_ENTERED eventLib       # Triggered once the cursor is hovering over the container
---@field MOUSE_EXITED eventLib        # Triggered once the cursor leaves the confinement of this container.
---@field ClipOnParent boolean         # when `true`, the container will go invisible once touching outside the parent container.
---@field ScaleFactor number           # Scales the displayed sprites and its children based on the factor.
---@field AccumulatedScaleFactor number# Scales the displayed sprites and its children based on the factor.
---@field isClipping boolean           # `true` when the container is touching outside the parent's container.
---@field ModelPart ModelPart          # The `ModelPart` used to handle where to display debug features and the sprite.
local container = {}
container.__index = function (t,i)
   return rawget(t,i) or container[i] or element[i]
end
container.__type = "GNUI.element.container"

---Creates a new container.
---if `preset` is applied, it will just get duplicated into its own thing. 
---@param preset GNUI.container?
---@param force_debug boolean?
---@return self
function container.new(preset,force_debug)
   preset = preset or {}
   ---@type GNUI.container
---@diagnostic disable-next-line: assign-type-mismatch
   local new = element.new()
   setmetatable(new,container)
   new.Dimensions = preset.Dimensions or vectors.vec4(0,0,0,0) 
   new.Z = preset.Z or 0
   new.SIZE_CHANGED = eventLib.new()
   new.ContainmentRect = preset.ContainmentRect or vectors.vec4() -- Dimensions but with margins and anchored applied
   new.Anchor = preset.Anchor or vectors.vec4(0,0,0,0)
   new.ModelPart = preset.ModelPart and preset.ModelPart:copy("container"..new.id) or models:newPart("container"..new.id)
   new.Cursor = preset.Cursor or vectors.vec2() -- in local space
   new.Hovering = preset.Hovering or false
   new.CaptureCursor = preset.CaptureCursor or true
   new.ClipOnParent = preset.ClipOnParent or false
   new.isClipping = preset.isClipping or false
   new.Sprite = preset.Sprite or nil
   new.ScaleFactor = preset.ScaleFactor or 1
   new.AccumulatedScaleFactor = preset.AccumulatedScaleFactor or 1
   new.DIMENSIONS_CHANGED = eventLib.new()
   new.SPRITE_CHANGED = eventLib.new()
   new.ANCHOR_CHANGED = eventLib.new()
   new.MOUSE_EXITED = eventLib.new()
   new.PARENT_CHANGED = eventLib.new()
   new.CURSOR_CHANGED = eventLib.new()
   new.PRESSED = eventLib.new()
   new.MOUSE_ENTERED = eventLib.new()
   models:removeChild(new.ModelPart)
   
   -->==========[ Internals ]==========<--
   local debug_container 
   local debug_cursor
   local debug_cursor_x
   local debug_cursor_y
   if core.debug_visible or force_debug then
      debug_container  = sprite.new():setModelpart(new.ModelPart):setTexture(debug_texture):setBorderThickness(1,1,1,1):setRenderType("EMISSIVE_SOLID"):setScale(core.debug_scale):setColor(1,1,1):excludeMiddle(true)
      debug_cursor     = sprite.new():setModelpart(new.ModelPart):setTexture(debug_texture):setUV(0,0,0,0):setRenderType("EMISSIVE_SOLID"):setSize(1,1):setColor(1,1,0)
      debug_cursor_x   = sprite.new():setModelpart(new.ModelPart):setTexture(debug_texture):setUV(0,0,0,0):setRenderType("EMISSIVE_SOLID"):setSize(1,1):setColor(1,0,0)
      debug_cursor_y   = sprite.new():setModelpart(new.ModelPart):setTexture(debug_texture):setUV(0,0,0,0):setRenderType("EMISSIVE_SOLID"):setSize(1,1):setColor(0,1,0)
   end

   new.VISIBILITY_CHANGED:register(function (v)
      new.DIMENSIONS_CHANGED:invoke(new.Dimensions)
   end)
   new.DIMENSIONS_CHANGED:register(function ()
      new.AccumulatedScaleFactor = (new.Parent and new.Parent.AccumulatedScaleFactor or 1) * new.ScaleFactor
      local scale = new.AccumulatedScaleFactor
      local unscale = 1 / scale
      local scale_self = new.ScaleFactor
      local unscale_self = 1 / new.ScaleFactor
      new.Dimensions:scale(scale)
      local last_size = new.ContainmentRect.zw - new.ContainmentRect.xy
      -- generate the containment rect
      new.ContainmentRect = vectors.vec4(
         new.Dimensions.x,
         new.Dimensions.y,
         new.Dimensions.z,
         new.Dimensions.w
      )
      -- adjust based on parent if this has one
      local clipping = false
      if new.Parent and new.Parent.ContainmentRect then 
         local parent_scale = 1 / new.Parent.ScaleFactor
         local parent_containment = new.Parent.ContainmentRect - new.Parent.ContainmentRect.xyxy
         local anchor_shift = vectors.vec4(
            math.lerp(parent_containment.x,parent_containment.z,new.Anchor.x),
            math.lerp(parent_containment.y,parent_containment.w,new.Anchor.y),
            math.lerp(parent_containment.x,parent_containment.z,new.Anchor.z),
            math.lerp(parent_containment.y,parent_containment.w,new.Anchor.w)
         ) * parent_scale * scale_self
         new.ContainmentRect.x = new.ContainmentRect.x + anchor_shift.x
         new.ContainmentRect.y = new.ContainmentRect.y + anchor_shift.y
         new.ContainmentRect.z = new.ContainmentRect.z + anchor_shift.z
         new.ContainmentRect.w = new.ContainmentRect.w + anchor_shift.w

         -- calculate clipping
         if new.ClipOnParent then
            clipping = parent_containment.x > new.ContainmentRect.x
            or parent_containment.y > new.ContainmentRect.y
            or parent_containment.z < new.ContainmentRect.z
            or parent_containment.w < new.ContainmentRect.w
         end
      end
      for _, child in pairs(new.Children) do
         if child.DIMENSIONS_CHANGED then
            child.DIMENSIONS_CHANGED:invoke(child.Dimensions)
         end
      end

      local size = new.ContainmentRect.zw - new.ContainmentRect.xy
      local size_changed = false
      if last_size ~= size then
         new.SIZE_CHANGED:invoke(size)
         size_changed = true
      end

      local visible = new.cache.final_visible
      if new.ClipOnParent and visible then
         if clipping then
            visible = false
         end
      end
      new.ModelPart:setVisible(new.Visible)
      if visible then
         new.ModelPart
         :setPos(
            -new.ContainmentRect.x * unscale_self,
            -new.ContainmentRect.y * unscale_self,
            -((new.Z + new.ChildIndex / (new.Parent and #new.Parent.Children or 1) * 0.99) * core.clipping_margin)
         )
         if new.Sprite then
            local contain = new.ContainmentRect
            new.Sprite
               :setSize(
                  (contain.z - contain.x) * unscale_self,
                  (contain.w - contain.y) * unscale_self
               )
         end
         if core.debug_visible or force_debug then
            local contain = new.ContainmentRect
            debug_container
            :setPos(
               0,
               0,
               -((new.Z + 1 + new.ChildIndex / (new.Parent and #new.Parent.Children or 1)) * core.clipping_margin) * 0.6)
            if size_changed then
               debug_container:setSize(
                  contain.z - contain.x,
                  contain.w - contain.y)
            end
         end
      end
      new.Dimensions:scale(unscale)
   end,core.internal_events_name)

   new.CURSOR_CHANGED:register(function ()
      if core.debug_visible or force_debug then
         -- Display the cursor in local space
         if new.Hovering then
            debug_cursor:setPos(
               -new.Cursor.x,
               -new.Cursor.y,
               -((new.Z + 1 + new.ChildIndex / (new.Parent and #new.Parent.Children or 1)) * core.clipping_margin) * 0.9
            ):setVisible(true)

            debug_cursor_x
            :setSize(1,new.Cursor.y)
            :setPos(
               -new.Cursor.x,
               0,
               -((new.Z + 1 + new.ChildIndex / (new.Parent and #new.Parent.Children or 1)) * core.clipping_margin) * 0.9
            ):setVisible(true)

            debug_cursor_y
            :setSize(new.Cursor.x,1)
            :setPos(
               0,
               -new.Cursor.y,
               -((new.Z + 1 + new.ChildIndex / (new.Parent and #new.Parent.Children or 1)) * core.clipping_margin) * 0.9
            ):setVisible(true)
         else
            debug_cursor:setVisible(false)
            debug_cursor_x:setVisible(false)
            debug_cursor_y:setVisible(false)
         end
      end
   end,core.debug_event_name)

   new.PARENT_CHANGED:register(function ()
      if new.Parent then 
         new.ModelPart:moveTo(new.Parent.ModelPart)
      else
         new.ModelPart:getParent():removeChild(new.ModelPart)
      end
      new.DIMENSIONS_CHANGED:invoke(new.Dimensions)
   end)
   return new
end

---Sets the backdrop of the container.  
---note: the object dosent get applied directly, its duplicated and the clone is used instead of the original.
---@generic self
---@param self self
---@param sprite_obj Sprite?
---@return self
function container:setSprite(sprite_obj)
   ---@cast self self
   if self.Sprite then
      self.Sprite:deleteRenderTasks()
      self.Sprite = nil
   end
   if sprite_obj then
      self.Sprite = sprite_obj
      sprite_obj:setModelpart(self.ModelPart)
   end
   self.DIMENSIONS_CHANGED:invoke()
   self.SPRITE_CHANGED:invoke()
   return self
end



---Sets the flag if this container should go invisible once touching outside of its parent.
---@generic self
---@param self self
---@param clip any
---@return self
function container:setClipOnParent(clip)
   ---@cast self GNUI.container
   self.ClipOnParent = clip
   self.DIMENSIONS_CHANGED:invoke()
   return self
end
-->====================[ Dimensions ]====================<--

---Sets the dimensions of this container.  
---x,y is top left
---z,w is bottom right  
--- if Z or W is missing, they will use X and Y instead

---@generic self
---@param self self
---@overload fun(self : self, vec4 : Vector4): GNUI.container
---@param x number
---@param y number?
---@param w number?
---@param t number?
---@return self
function container:setDimensions(x,y,w,t)
   ---@cast self GNUI.container
   local new = utils.figureOutVec4(x,y,w or x,t or y)
   self.Dimensions = new
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---@generic self
---@param self self
---@overload fun(self : self, vec2 : Vector4): GNUI.container
---@param x number
---@param y number?
---@return self
function container:offsetDimensions(x,y)
   ---@cast self GNUI.container
   local new = utils.figureOutVec2(x,y)
   self.Dimensions:add(new.x,new.y,new.x,new.y)
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the top left offset from the origin anchor of its parent.
---@generic self
---@param self self
---@overload fun(self : self, vec2 : Vector4): GNUI.container
---@param x number
---@param y number
---@return self
function container:setTopLeft(x,y)
   ---@cast self GNUI.container
   self.Dimensions.xy = utils.figureOutVec2(x,y)
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the bottom right offset from the origin anchor of its parent.
---@generic self
---@param self self
---@overload fun(self : self, vec2 : Vector4): GNUI.container
---@param x number
---@param y number
---@return self
function container:setBottomRight(x,y)
   ---@cast self GNUI.container
   self.Dimensions.zw = utils.figureOutVec2(x,y)
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Shifts the container based on the top left.
---@overload fun(self : self, vec2 : Vector4): GNUI.container
---@param x number
---@param y number
---@return self
function container:offsetTopLeft(x,y)
   ---@cast self GNUI.container
   local old,new = self.Dimensions.xy,utils.figureOutVec2(x,y)
   local delta = new-old
   self.Dimensions.xy,self.Dimensions.zw = new,self.Dimensions.zw - delta
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Shifts the container based on the bottom right.
---@overload fun(self : self, vec2 : Vector4): GNUI.container
---@param z number
---@param w number
---@return self
function container:offsetBottomRight(z,w)
   ---@cast self GNUI.container
   local old,new = self.Dimensions.xy+self.Dimensions.zw,utils.figureOutVec2(z,w)
   local delta = new-old
   self.Dimensions.zw = self.Dimensions.zw + delta
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Checks if the cursor in local coordinates is inside the bounding box of this container.
---@overload fun(self : self, vec2 : Vector4): boolean
---@param x number|Vector2
---@param y number?
---@return boolean
function container:isHovering(x,y)
   ---@cast self GNUI.container
   local pos = utils.figureOutVec2(x,y)
   return (
          pos.x > 0
      and pos.y > 0
      and pos.x < (self.ContainmentRect.z-self.ContainmentRect.x) / self.ScaleFactor 
      and pos.y < (self.ContainmentRect.w-self.ContainmentRect.y) / self.ScaleFactor)
end

---Sets the Cursor position relative to the top left of the container.  
---Returns true if the cursor is hovering over the container.  
---@overload fun(self: GNUI.container, vec2 : Vector2, press : boolean?): GNUI.container
---@overload fun(press : boolean): GNUI.container
---@overload fun(): GNUI.container
---@param x number?
---@param y number?
---@param press boolean?
---@return boolean
function container:setCursor(x,y,press)
   local xt = type(x)
   ---@cast self GNUI.container
   local pos
   if xt == "nil" then
      self.Cursor = nil
      self.Hovering = false
      self.CURSOR_CHANGED:invoke()
      for key, value in pairs(self.Children) do
         value:setCursor(nil)
      end
      return false
   elseif self.Cursor and xt == "boolean" and x then
      press = true
      pos = self.Cursor
      if not self.Cursor then return false end -- not selected at all
   else
      press = press or false
      if x and y then
         pos = utils.figureOutVec2(x,y)
      else
         return false
      end
   end
   local lhovering = self.Hovering
   self.Cursor = pos
   self.Hovering = self:isHovering(self.Cursor)
   if self.Hovering then
      local hovering
      for i = #self.Children, 1, -1 do
         local child = self.Children[i]
         if not hovering then
            if child.CaptureCursor then
               hovering = child:setCursor(
                  self.Cursor.x-child.ContainmentRect.x,
                  self.Cursor.y-child.ContainmentRect.y,press)
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
   if self.Hovering and press then
      self.PRESSED:invoke()
   end
   if self.Hovering ~= lhovering then
      if self.Hovering then
         self.MOUSE_ENTERED:invoke()
      else
         self.MOUSE_EXITED:invoke()
      end
   end
   if self.Hovering and self.CaptureCursor then
      self.CURSOR_CHANGED:invoke(pos)
   end
   --self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self.Hovering
end

---Sets the offset of the depth for this container, a work around to fixing Z fighting issues when two elements overlap.
---@param depth number
---@generic self
---@param self self
---@return self
function container:setZ(depth)
   ---@cast self GNUI.container
   self.Z = depth
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---If this container should be able to capture the cursor from its parent if obstructed.
---@param capture boolean
---@generic self
---@param self self
---@return self
function container:setCanCaptureCursor(capture)
   ---@cast self GNUI.container
   self.CaptureCursor = capture
   return self
end

---@param factor number
---@generic self
---@param self self
---@return self
function container:setScaleFactor(factor)
   ---@cast self GNUI.container
   self.ScaleFactor = factor
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

-->====================[ Anchor ]====================<--

---Sets the top anchor.  
--- 0 = top part of the container is fully anchored to the top of its parent  
--- 1 = top part of the container is fully anchored to the bottom of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function container:setAnchorTop(units)
   ---@cast self GNUI.container
   self.Anchor.y = units or 0
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the left anchor.  
--- 0 = left part of the container is fully anchored to the left of its parent  
--- 1 = left part of the container is fully anchored to the right of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function container:setAnchorLeft(units)
   ---@cast self GNUI.container
   self.Anchor.x = units or 0
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the down anchor.  
--- 0 = bottom part of the container is fully anchored to the top of its parent  
--- 1 = bottom part of the container is fully anchored to the bottom of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function container:setAnchorDown(units)
   ---@cast self GNUI.container
   self.Anchor.z = units or 0
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the right anchor.  
--- 0 = right part of the container is fully anchored to the left of its parent  
--- 1 = right part of the container is fully anchored to the right of its parent  
---@param units number?
---@generic self
---@param self self
---@return self
function container:setAnchorRight(units)
   ---@cast self GNUI.container
   self.Anchor.w = units or 0
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

---Sets the anchor for all sides.  
--- x 0 <-> 1 = left <-> right  
--- y 0 <-> 1 = top <-> bottom  
---if right and bottom are not given, they will use left and top instead.
---@overload fun(self : GNUI.container, xz : Vector2, yw : Vector2): GNUI.container
---@overload fun(self : GNUI.container, rect : Vector4): GNUI.container
---@param left number
---@param top number
---@param right number?
---@param bottom number?
---@generic self
---@param self self
---@return self
function container:setAnchor(left,top,right,bottom)
   ---@cast self GNUI.container
   self.Anchor = utils.figureOutVec4(left,top,right or left,bottom or top)
   self.DIMENSIONS_CHANGED:invoke(self.Dimensions)
   return self
end

return container
