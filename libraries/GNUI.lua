--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]

--[[ NOTES
Everything is in one file to make sure it is possible to load this script from a config file, 
allowing me to put as much as I want without worrying about storage space.
]]

local main = {}

local config = {
   debug_visible = true,
   debug_event_name = "__debug",
   internal_events_name = "__internal",
}

--#region EventLib
local eventLib = {}

---@class EventLib
local eventMetatable = {__type = "Event", __index = {}}
local eventsMetatable = {__index = {}}
eventMetatable.__index = eventMetatable

---@return EventLib
function eventLib.new()
   return setmetatable({subscribers = {}}, eventMetatable)
end
---@return EventLib
function eventLib.newEvent()
   return setmetatable({subscribers = {}}, eventMetatable)
end

function eventLib.table(tbl)
   return setmetatable({_table = tbl or {}}, eventsMetatable)
end

---Registers an event
---@param func function
---@param name string?
function eventMetatable:register(func, name)
   if name then
      self.subscribers[name] = {func = func}
   else
      table.insert(self.subscribers, {func = func})
   end
end

---Clears all event
function eventMetatable:clear()
   self.subscribers = {}
end

---Removes an event with the given name.
---@param match string
function eventMetatable:remove(match)
   self.subscribers[match] = nil
end

---Returns how much listerners there are.
---@return integer
function eventMetatable:getRegisteredCount()
   return #self.subscribers
end

function eventMetatable:__call(...)
   local returnValue = {}
   for _, data in pairs(self.subscribers) do
      table.insert(returnValue, {data.func(...)})
   end
   return returnValue
end

function eventMetatable:invoke(...)
   local returnValue = {}
   for _, data in pairs(self.subscribers) do
      table.insert(returnValue, {data.func(...)})
   end
   return returnValue
end

function eventMetatable:__len()
   return #self.subscribers
end

-- events table
function eventsMetatable.__index(t, i)
   return t._table[i] or (type(i) == "string" and getmetatable(t._table[i:upper()]) == eventMetatable) and t._table[i:upper()] or nil
end

function eventsMetatable.__newindex(t, i, v)
   if type(i) == "string" and type(v) == "function" and t._table[i:upper()] and getmetatable(t._table[i:upper()]) == eventMetatable then
      t._table[i:upper()]:register(v)
   else
      t._table[i] = v
   end
end

function eventsMetatable.__ipairs(t)
   return ipairs(t._table)
end
function eventsMetatable.__pairs(t)
   return pairs(t._table)
end

--#endregion

--#region-->========================================[ Utilities ]=========================================<--

local utils = {}

---Returns the same vector but the `X` `Y` are the **min** and `Z` `W` are the **max**.  
---vec4(1,2,0,-1) --> vec4(0,-1,1,2)
---@param vec4 Vector4
---@return Vector4
function utils.vec4FixNegativeBounds(vec4)
   return vectors.vec4(
      math.min(vec4.x,vec4.z),
      math.min(vec4.y,vec4.w),
      math.max(vec4.x,vec4.z),
      math.max(vec4.y,vec4.w)
   )
end

---Sets the position`(x,y)` while translating the other position`(x,z)`
---@param vec4 Vector4
---@param x number
---@param y number
---@return Vector4
function utils.vec4SetPos(vec4,x,y)
   local lpos = vec4.xy
   vec4.x,vec4.y = x,y
   vec4.z,vec4.w = x-lpos.x,y-lpos.y
   return vec4
end

---Sets the other position`(x,z)` while translating the position`(x,y)`
---@param vec4 Vector4
---@param z number
---@param w number
---@return Vector4
function utils.vec4SetOtherPos(vec4,z,w)
   local lpos = vec4.zw
   vec4.z,vec4.w = z,w
   vec4.x,vec4.y = z-lpos.x,w-lpos.y
   return vec4
end

---Gets the size of a vec4
---@param vec4 Vector4
---@return Vector2
function utils.vec4GetSize(vec4)
   return (vec4.zw - vec4.xy) ---@type Vector2
end

function utils.figureOutVec2(posx,y)
   local typa, typb = type(posx), type(y)
   
   if typa == "Vector2" and typb == "nil" then
      return posx:copy()
   elseif typa == "number" and typb == "number" then
      return vectors.vec2(posx,y)
   else
      error("Invalid Vector2 parameter, expected Vector2 or (number, number), instead got ("..typa..", "..typb..")")
   end
end

function utils.figureOutVec3(posx,y,z)
   local typa, typb, typc = type(posx), type(y), type(z)
   
   if typa == "Vector2" and typb == "nil" and typc == "nil" then
      return posx:copy()
   elseif typa == "number" and typb == "number" and typc == "number" then
      return vectors.vec3(posx,y,z)
   else
      error("Invalid Vector3 parameter, expected Vector3 or (number, number, number), instead got ("..typa..", "..typb..", "..typc..")")
   end
end

--#endregion

--#region-->========================================[ Debug ]=========================================<--

local debug = {}
debug.texture = textures:newTexture("1x1white",1,1):setPixel(0,0,vectors.vec3(1,1,1))

--#endregion

--#region Element

---@class GNUI.element
---@field Visible boolean
---@field VISIBILITY_CHANGED EventLib
---@field Children table<any,GNUI.element>
---@field ChildrenIndex integer
---@field CHILDREN_CHANGED table
---@field Parent GNUI.element 
---@field PARENT_CHANGED table
---@field ON_FREE EventLib
local element = {}
element.__index = function (t,i)
   return rawget(t,i)
end
element.__type = "GNUI.element"

---Creates a new basic element.
---@param preset table?
---@return GNUI.element
function element.new(preset)
   local new = preset or {}
   new.Visible = true
   new.VISIBILITY_CHANGED = eventLib.new()
   new.Children = {}
   new.ChildIndex = 0
   new.CHILDREN_CHANGED = eventLib.new()
   new.PARENT_CHANGED = eventLib.new()
   new.ON_FREE = eventLib.new()
   setmetatable(new,element)
   return new
end

function element:updateChildrenOrder()
   for i, c in pairs(self.Children) do
      c.ChildrenIndex = i
   end
   return self
end

---Adopts an element as its child.
---@param child GNUI.element
---@param order integer?
---@return GNUI.element
function element:addChild(child,order)
   order = order or #self.Children+1
   table.insert(self.Children,order,child)
   self:updateChildrenOrder()
   return self
end

---Abandons the child.
---@param child GNUI.element
---@return GNUI.element
function element:removeChild(child)
   if child.Parent == self then -- check if the parent is even the one registered in the child's birth certificate
      self.Children[child.ChildrenIndex] = nil -- lmao
      child.Parent = nil
      child.ChildrenIndex = 0
   end
   self:updateChildrenOrder()
   return self
end

---Frees all the data of the element. all thats left to do is to forget it ever existed.
function element:free()
   if self.Parent then
      self.Parent:removeChild(self)
   end
   self.ON_FREE:invoke()
end

--#endregion

--#region-->========================================[ Container ]=========================================<--

---@class GNUI.element.container
---@field Dimensions Vector4
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
   return container[i] or element.__index(t,i)
end

container.__type = "GNUI.element.container"

---Creates a new container.
---@param preset table?
---@return GNUI.element.container
function container.new(preset)
   local new = preset or {}
   new.Dimensions = vectors.vec4(0,0,1,1)
   new.DIMENSIONS_CHANGED = eventLib.new()
   new.Margin = vectors.vec4()
   new.MARGIN_CHANGED = eventLib.new()
   new.Padding = vectors.vec4()
   new.PADDING_CHANGED = eventLib.new()
   new.Anchor = vectors.vec4(0,0,1,1)
   new.ANCHOR_CHANGED = eventLib.new()
   new.Part = models:newPart("Container")

   -->==========[ Internals ]==========<--

   new.DIMENSIONS_CHANGED:register(function ()
      new.Part
      :setPos(
         -new.Dimensions.x-new.Margin.x-new.Padding.x,
         -new.Dimensions.y-new.Margin.y-new.Padding.y,0)
   end,config.internal_events_name)

   new.MARGIN_CHANGED:register(function ()
      new.DIMENSIONS_CHANGED:invoke(new.Dimensions)
   end,config.internal_events_name)

   new.PADDING_CHANGED:register(function ()
      new.DIMENSIONS_CHANGED:invoke(new.Dimensions)
   end,config.internal_events_name)

   -->==========[ Debug ]==========<--

   if config.debug_visible then
      local debug_container = new.Part:newSprite("container"):texture(debug.texture):setColor(0.5,0.5,0.5,0.3)
      local debug_margin    = new.Part:newSprite("margin"):texture(debug.texture):setColor(0,0,0,0.3)
      local debug_padding   = new.Part:newSprite("padding"):texture(debug.texture):setColor(1,1,1,0.3)

      new.DIMENSIONS_CHANGED:register(function ()
         debug_padding
         :scale(
            (new.Dimensions.z - new.Padding.x - new.Padding.z - new.Margin.x - new.Margin.z),
            (new.Dimensions.w - new.Padding.y - new.Padding.w - new.Margin.y - new.Margin.w),1):pos(0,0,-3)
         
         debug_margin
         :pos(
            new.Margin.x + new.Padding.x,
            new.Margin.y + new.Padding.y,
            1)
         :scale(
            (new.Dimensions.z),
            (new.Dimensions.w),1)
         debug_container
         :pos(
            new.Padding.x,
            new.Padding.y,
            -3)
         :scale(
            (new.Dimensions.z - new.Margin.x - new.Margin.z),
            (new.Dimensions.w - new.Margin.y - new.Margin.w),1)
      end,config.debug_event_name)
   end

   setmetatable(new,container)
   return new
end

-->====================[ Dimensions ]====================<--

---Sets the position of the container, the size stays the same.
---@param xpos number|Vector2
---@param y number?
---@return GNUI.element.container
function container:setPos(xpos,y)
   self.Dimensions.xy = utils.figureOutVec2(xpos,y)
   self.DIMENSIONS_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the size of the container
---@param xsize number|Vector2
---@param y number?
---@return GNUI.element.container
function container:setSize(xsize,y)
   self.Dimensions.zw = utils.figureOutVec2(xsize,y)
   self.DIMENSIONS_CHANGED:invoke(self,self.Dimensions)
   return self
end

---Sets the position of the top left part of the container, the bottom right stays in the same position
---@param xpos number|Vector2
---@param y number?
---@return GNUI.element.container
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
---@return GNUI.element.container
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
---@return GNUI.element.container
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
---@return GNUI.element.container
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
---@return GNUI.element.container
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
---@return GNUI.element.container
function container:setPadding(left,top,right,bottom)
   self.Padding.x = left   or 0
   self.Padding.y = top    or 0
   self.Padding.z = right  or 0
   self.Padding.w = bottom or 0
   self.MARGIN_CHANGED:invoke(self,self.Dimensions)
   return self
end

--#endregion
main.newContainer = container.new
main.utils = utils
return main