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
local Theme = require("./../../theme") ---@type GNUI.ThemeAPI

---@class GNUI.Pane.StackAPI
local StackAPI = {}

---@class GNUI.Pane.Stack : GNUI.Pane
---@field ItemSize Vector2
---@field spacing Vector2
local Stack = {}
Stack.__index = function (t,i) return rawget(t,i) or Stack[i] or Pane.__index(t,i) end
Stack.__type = "GNUI.Pane.Stack"
StackAPI.__metamethod = Stack

---Creates a new GridStacker.
---@return GNUI.Pane.Stack
function StackAPI.new(parent,variant)
   ---@type GNUI.Pane.Stack
   local box = Pane.new(parent,"none")
   box._parent_class = Stack
   setmetatable(box,Stack)
	
	box:setSprite(Theme.getStyle(box, "background", variant))
	box.spacing = Theme.getStyle(box, "spacing", variant) or vec(0,0,0,0)
   return box
end

---Rearanges the children. automatically called, but in case it dosent update, call this
---@generic self
---@param self self
---@return self
function Stack:rearangeChildren()
   ---@cast self GNUI.Pane
   local y = self.spacing.y
   for i,child in pairs(self.Children) do
		local size = child:getSize()
      child:setPos(self.spacing.x,y)
		:setAnchor(0,0,1,0)
		y = y + size.y + self.spacing
   end
   return self
end

return StackAPI