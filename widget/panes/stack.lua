--[[______   __
  / ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / The Pane Class.
/ /_/ / /|  / a way to automatically arrange children into some order inside the box. by default does nothing
\____/_/ |_/ Source: link]]
---@diagnostic disable: assign-type-mismatch
local Pane = require("./../pane") ---@type GNUI.PaneAPI
local cfg = require("./../../config") ---@type GNUI.Config
local utils = cfg.utils ---@type GNUI.UtilsAPI
local Event = cfg.event ---@type Event

---@class GNUI.Pane.StackAPI
local StackAPI = {}

---@class GNUI.Pane.Stack : GNUI.Pane
---@field ItemSize Vector2
---@field Spacing Vector2
local Stack = {}
Stack.__index = function (t,i) return rawget(t,i) or Stack[i] or Pane.__index(t,i) end
Stack.__type = "GNUI.Pane"
StackAPI.__metamethod = Stack

---Creates a new GridStacker.
---@return GNUI.Pane.Stack
function StackAPI.new(parent)
   ---@type GNUI.Pane.Stack
   local box = Pane.new(parent)
   box._parent_class = Stack
   
   setmetatable(box,Stack)
   return box
end

---Rearanges the children. automatically called, but in case it dosent update, call this
---@generic self
---@param self self
---@return self
function Stack:rearangeChildren()
   ---@cast self GNUI.Pane
   local y = 0
   for i,child in pairs(self.Children) do
		local size = child:getSize()
      child:setPos(0,y)
		y = y + size.y
   end
   return self
end

return StackAPI