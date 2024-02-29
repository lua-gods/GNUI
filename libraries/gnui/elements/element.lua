local eventLib = require("libraries.eventHandler")
local utils = require("libraries.gnui.utils")

local element_next_free = 0
---@class GNUI.element
---@field Visible boolean
---@field VISIBILITY_CHANGED EventLib
---@field Children table<any,GNUI.element|GNUI.container>
---@field ChildIndex integer
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
   index = index or #self.Children+1
   for i = index, #self.Children, 1 do -- everything above index will get pushed up
      self.Children[i] = self.Children[i+1]
   end
   self.Children[index] = child
   child.ChildIndex = index
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
      self.Children[child.ChildIndex] = nil -- lmao
      for i = child.ChildIndex+1, #self.Children, 1 do -- everything above index will get pushed down
         self.Children[i].ChildIndex = i - 1
      end
      self.Children[#self.Children] = nil -- remove duplicate on last
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