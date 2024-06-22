local eventLib = require("libraries.eventLib")
local utils = require("libraries.gnui.utils")

local element_next_free = 0
---@class GNUI.element # The base element of every GNUI element
---@field name string                 # An optional property used to get the element by a name
---@field id integer                  # A unique integer for this element. (next-free based)
---@field Visible boolean             # `true` to see
---@field Parent GNUI.any             # the element's parents
---@field Children table<any,GNUI.any># A list of the element's children
---@field ChildIndex integer          # the element's place order on its parent
---@field VISIBILITY_CHANGED eventLib # on change of visibility
---@field CHILDREN_CHANGED table      # when the order of the children changes.
---@field PARENT_CHANGED table        # when the parent changes
---@field ON_FREE eventLib            # when the element is wiped from history.
---@field cache table
local element = {}
element.__index = element
element.__type = "GNUI.element"

---Creates a new basic element.
---@generic self
---@param preset table?
---@return self
function element.new(preset)
   local new = preset or {}
   new.id = element_next_free
   new.Visible            = true
   new.cache              = {final_visible = true}
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

---Sets the visibility of the element and its children
---@param visible boolean
---@generic self
---@param self self
---@return self
function element:setVisible(visible)
   ---@cast self GNUI.element
   if self.Visible ~= visible then
      self.Visible = visible
      self.VISIBILITY_CHANGED:invoke(visible)
      for key, child in pairs(self.Children) do
         child:_updateVisibility()
      end
      if not self.Parent then
         self:_updateVisibility()
      end
   end
   return self
end

function element:_updateVisibility()
   if self.Parent then
      self.cache.final_visible = self.Parent.Visible and self.Visible
   else
      self.cache.final_visible = self.Visible
   end
   return self
end

---Sets the name of the element. this is used to make it easier to find elements with getChild
---@param name string
---@generic self
---@param self self
---@return self
function element:setName(name)
   ---@cast self GNUI.element
   self.name = name
   return self
end

---@return string
function element:getName()
   return self.name
end

---Gets a child by username
---@param name string
---@return GNUI.any
function element:getChild(name)
   for _, child in pairs(self.Children) do
      if child.name and child.name == name then
         return child
      end
   end
   return self
end

function element:getChildByIndex(index)
   return self.Children[index]
end

---@generic self
---@param self self
---@return self
function element:updateChildrenOrder()
   ---@cast self GNUI.element
   for i, c in pairs(self.Children) do
      c.ChildIndex = i
   end
   return self
end

---Adopts an element as its child.
---@param child GNUI.any
---@param index integer?
---@generic self
---@param self self
---@return self
function element:addChild(child,index)
   ---@cast self GNUI.container
   if not child then return self end
   if not type(child):find("^GNUI.element") then
      error("invalid child given, recived: "..type(child),2)
   end
   if child.Parent then return self end
   table.insert(self.Children, index or #self.Children+1, child)
   child.Parent = self
   child.PARENT_CHANGED:invoke(self)
   self:updateChildrenIndex()
   return self
end

---Abandons the child into the street.
---@param child GNUI.element
---@generic self
---@param self self
---@return self
function element:removeChild(child)
   ---@cast self GNUI.container
   if child.Parent == self then -- birth certificate check
      table.remove(self.Children, child.ChildIndex)
      child.Parent = nil
      child.ChildIndex = 0
      child.PARENT_CHANGED:invoke(nil)
      self:updateChildrenIndex()
   end
   return self
end

---@return table<integer, GNUI.container|GNUI.element>
function element:getChildren()
   return self.Children
end

---@generic self
---@param self self
---@return self
function element:updateChildrenIndex()
   ---@cast self GNUI.element
   for i, child in pairs(self.Children) do
      child.ChildIndex = i
      child.PARENT_CHANGED:invoke()
   end
   return self
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