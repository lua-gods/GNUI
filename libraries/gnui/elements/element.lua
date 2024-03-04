local eventLib = require("libraries.eventHandler")
local utils = require("libraries.gnui.utils")

local element_next_free = 0
---@class GNUI.element
---@field id integer                                       # A unique integer for this element. (next-free based)
---@field Visible boolean                                  # `true` to see
---@field Parent GNUI.element|GNUI.container               
---@field Children table<any,GNUI.element|GNUI.container>  
---@field ChildIndex integer                               # the element's place order on its parent
---@field VISIBILITY_CHANGED EventLib                      # on change of visibility
---@field CHILDREN_CHANGED table                           # when the order of the children changes.
---@field PARENT_CHANGED table                             # when the parent changes
---@field ON_FREE EventLib                                 # when the element is wiped from history.
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
   new.id = element_next_free
   new.Visible            = true
   new.VISIBILITY_CHANGED = eventLib.new()
   new.Children           = {}
   new.ChildIndex         = 0
   new.CHILDREN_CHANGED   = eventLib.new()
   new.PARENT_CHANGED     = eventLib.new()
   new.ON_FREE            = eventLib.new()
   setmetatable(new,element)
   element_next_free = element_next_free + 1
   return new
end

---Sets the visibility of the container and its children
---@param visible boolean
---@return GNUI.element
function element:setVisible(visible)
   if self.isVisible ~= visible then
      self.VISIBILITY_CHANGED:invoke(visible)
      self.isVisible = visible
   end
   return self
end

function element:updateChildrenOrder()
   for i, c in pairs(self.Children) do
      c.ChildIndex = i
   end
   return self
end

---Adopts an element as its child.
---@param child GNUI.element
---@param index integer?
---@return GNUI.element
function element:addChild(child,index)
   if not type(child):find("^GNUI.element") then
      error("invalid child given, recived"..type(child),2)
   end
   table.insert(self.Children, index or #self.Children+1, child)
   child.Parent = self
   child.PARENT_CHANGED:invoke(self)
   self:updateChildrenIndex()
   return self
end

---Abandons the child into the street.
---@param child GNUI.element
---@return GNUI.element
function element:removeChild(child)
   if child.Parent == self then -- check if the parent is even the one registered in the child's birth certificate
      table.remove(self.Children, child.ChildIndex)
      child.Parent = nil
      child.ChildIndex = 0
      child.PARENT_CHANGED:invoke(nil)
      self:updateChildrenIndex()
   end
   return self
end

function element:updateChildrenIndex()
   for i, child in pairs(self.Children) do
      child.ChildIndex = i
      child.DIMENSIONS_CHANGED:invoke()
   end
end

---Frees all the data of the element. all thats left to do is to forget it ever existed.
function element:free()
   if self.Parent then
      self.Parent:removeChild(self)
   end
   self.ON_FREE:invoke()
   self = nil
end
return element