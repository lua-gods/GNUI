local eventLib = require("libraries.eventLib")
local utils = require("libraries.gnui.utils")

local debug_texture = textures['gnui_debug_outline'] or textures:newTexture("gnui_debug_outline",3,3):fill(0,0,3,3,vectors.vec3(1,1,1)):setPixel(1,1,vectors.vec3(0,0,0))
local element = require("libraries.gnui.elements.element")
local sprite = require("libraries.gnui.spriteLib")
local core = require("libraries.gnui.core")

---@class GNUI.anchorPoint : GNUI.element # A point version of a container, used to anchor ModelParts into the container.
---@field Offset Vector2                  # Determins the offset of each side from the final output
---@field FinalPosition Vector2           # Determins the offset of each side from the final output
---@field OFFSET_CHANGED eventLib         # Triggered when the final container Offset has changed.
---@field Z number                        # Offsets the container forward(+) or backward(-) if Z fighting is occuring, also affects its children.
---@field Anchor Vector2                  # Determins where to attach to its parent, (`0`-`1`, left-right, up-down)
---@field ANCHOR_CHANGED eventLib         # Triggered when the anchors applied to the container is changed.
---@field ClipOnParent boolean            # when `true`, the container will go invisible once touching outside the parent container.
---@field isClipping boolean              # `true` when the container is touching outside the parent's container.
---@field ModelPart ModelPart             # The `ModelPart` used to handle where to display debug features and the sprite.
local container = {}
container.__index = function (t,i)
   return rawget(t,i) or container[i] or element[i]
end
container.__type = "GNUI.element.anchor"

---Creates a new container.
---if `preset` is applied, it will just get duplicated into its own thing. 
---@param preset GNUI.anchorPoint?
---@param force_debug boolean?
---@return self
function container.new(preset,force_debug)
   preset = preset or {}
   ---@type GNUI.anchorPoint
---@diagnostic disable-next-line: assign-type-mismatch
   local new = element.new()
   setmetatable(new,container)
   new.Offset = preset.Offset or vectors.vec2(0,0) 
   new.Z = preset.Z or 0
   new.Anchor = preset.Anchor or vectors.vec2(0,0)
   new.ModelPart = preset.ModelPart and preset.ModelPart:copy("anchor_point"..new.id) or models:newPart("anchor_point"..new.id)
   new.ClipOnParent = preset.ClipOnParent or false
   new.isClipping = preset.isClipping or false
   new.OFFSET_CHANGED = eventLib.new()
   new.ANCHOR_CHANGED = eventLib.new()
   new.PARENT_CHANGED = eventLib.new()
   models:removeChild(new.ModelPart)
   
   -->==========[ Internals ]==========<--
   local debug_point
   if core.debug_visible or force_debug then
      debug_point = sprite.new():setModelpart(new.ModelPart):setTexture(debug_texture):setUV(0,0,0,0):setRenderType("EMISSIVE_SOLID"):setSize(1,1):setColor(1,1,0)
   end

   new.VISIBILITY_CHANGED:register(function (v)
      new.OFFSET_CHANGED:invoke(new.Offset)
   end)
   new.OFFSET_CHANGED:register(function ()
      -- generate the containment rect
      new.FinalPosition = vectors.vec2(
         new.Offset.x,
         new.Offset.y
      )
      -- adjust based on parent if this has one
      local clipping = false
      if new.Parent then 
         local dim
         if type(new.Parent) == "GNUI.element.anchor" then
            dim = new.Parent.FinalPosition.xyxy
         elseif type(new.Parent) == "GNUI.element.container" then
            dim = new.Parent.Dimensions
         end
         local parent_containment = dim - dim.xyxy
         local anchor_shift = vectors.vec2(
---@diagnostic disable-next-line: param-type-mismatch
math.lerp(parent_containment.x,parent_containment.z,new.Anchor.x), 
---@diagnostic disable-next-line: param-type-mismatch
            math.lerp(parent_containment.y,parent_containment.w,new.Anchor.y) 
         )
         new.FinalPosition.x = new.FinalPosition.x + anchor_shift.x
         new.FinalPosition.y = new.FinalPosition.y + anchor_shift.y

         -- calculate clipping
         if new.ClipOnParent then
            clipping = parent_containment.x > new.FinalPosition.x
            or parent_containment.y > new.FinalPosition.y
            or parent_containment.z < new.FinalPosition.x
            or parent_containment.w < new.FinalPosition.y
         end
      end
      for _, child in pairs(new.Children) do
         if child.OFFSET_CHANGED then
            child.OFFSET_CHANGED:invoke(child.Offset)
         end
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
            -new.FinalPosition.x,
            -new.FinalPosition.y,
            -((new.Z + new.ChildIndex / (new.Parent and #new.Parent.Children or 1) * 0.99) * core.clipping_margin)
         )
         if core.debug_visible or force_debug then
            local contain = new.FinalPosition
            debug_point
            :setPos(
               -new.FinalPosition.x + 1,
               new.FinalPosition.y  + 1,
               -((new.Z + 1 + new.ChildIndex / (new.Parent and #new.Parent.Children or 1)) * core.clipping_margin) * 0.6)
               :setSize(2,2)
         end
      end
      
   end,core.internal_events_name)

   new.PARENT_CHANGED:register(function ()
      if new.Parent then 
         new.ModelPart:moveTo(new.Parent.ModelPart)
      else
         new.ModelPart:getParent():removeChild(new.ModelPart)
      end
      new.OFFSET_CHANGED:invoke(new.Offset)
   end)
   return new
end

---Sets the flag if this container should go invisible once touching outside of its parent.
---@generic self
---@param self self
---@param clip any
---@return self
function container:setClipOnParent(clip)
   ---@cast self GNUI.anchorPoint
   self.ClipOnParent = clip
   self.OFFSET_CHANGED:invoke()
   return self
end
-->====================[ Offset ]====================<--

---Sets the Offset of this container.  
---x,y is top left
---z,w is bottom right  
--- if Z or W is missing, they will use X and Y instead

---@generic self
---@param self self
---@overload fun(self : self, vec2 : Vector4): GNUI.anchorPoint
---@param x number
---@param y number
---@return self
function container:setOffset(x,y)
   ---@cast self GNUI.anchorPoint
   local new = utils.figureOutVec2(x,y)
   self.Offset = new
   self.OFFSET_CHANGED:invoke(self.Offset)
   return self
end

---Checks if the cursor in local coordinates is inside the bounding box of this container.
---@param x number|Vector2
---@param y number?
---@return boolean
function container:isHovering(x,y)
   ---@cast self GNUI.anchorPoint
   local pos = utils.figureOutVec2(x,y)
   return (
          pos.x > 0
      and pos.y > 0
      and pos.x < self.FinalPosition.z-self.FinalPosition.x 
      and pos.y < self.FinalPosition.w-self.FinalPosition.y)
end

---Sets the offset of the depth for this container, a work around to fixing Z fighting issues when two elements overlap.
---@param depth number
---@generic self
---@param self self
---@return self
function container:setZ(depth)
   ---@cast self GNUI.anchorPoint
   self.Z = depth
   self.OFFSET_CHANGED:invoke(self.Offset)
   return self
end

---Sets the anchor for all sides.  
--- x 0 <-> 1 = left <-> right  
--- y 0 <-> 1 = top <-> bottom  
---if right and bottom are not given, they will use left and top instead.
---@overload fun(self : GNUI.anchorPoint, xz : Vector2): GNUI.anchorPoint
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function container:setAnchor(x,y)
   ---@cast self GNUI.anchorPoint
   self.Anchor = utils.figureOutVec2(x,y)
   self.OFFSET_CHANGED:invoke(self.Offset)
   return self
end

return container
