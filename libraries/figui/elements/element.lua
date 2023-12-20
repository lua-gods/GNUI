local eventLib = require("libraries.figui.eventHandler")
local utils = require("libraries.figui.utils")

local element_next_free = 0
---@class GNUI.element
---@field Visible boolean
---@field VISIBILITY_CHANGED EventLib
---@field Children table<any,GNUI.element|GNUI.container>
---@field ChildrenIndex integer
---@field CHILDREN_CHANGED table
---@field Parent GNUI.element|GNUI.container
---@field PARENT_CHANGED table
---@field ON_FREE EventLib
---@field id EventLib
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
   new.id = element_next_free
   setmetatable(new,element)
   element_next_free = element_next_free + 1
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
   child.Parent = self
   child.PARENT_CHANGED:invoke(self)
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
      child.PARENT_CHANGED:invoke(nil)
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
return element