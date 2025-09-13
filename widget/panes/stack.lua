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

---@alias GNUI.Pane.Stack.Direction
---| "UP"
---| "DOWN"
---| "LEFT"
---| "RIGHT"

---@class GNUI.Pane.Stack : GNUI.Pane
---@field spacing number
---@field direction string
local Stack = {}
Stack.__index = function (t,i) return rawget(t,i) or Stack[i] or Pane.__index(t,i) end
Stack.__type = "GNUI.Pane.Stack"
StackAPI.__metamethod = Stack

---Creates a new GridStacker.
---@return GNUI.Pane.Stack
function StackAPI.new(parent,variant)
   ---@type GNUI.Pane.Stack
   local box = Pane.new(parent,"none")
	box.direction = "DOWN"
   setmetatable(box,Stack)
	
	box:setSprite(Theme.getStyle(box, "background", variant))
	box.spacing = Theme.getStyle(box, "spacing", variant) or 0
	return box
end


---@param direction GNUI.Pane.Stack.Direction
---@generic self
---@param self self
---@return self
function Stack:setStackDirection(direction)
	---@cast self GNUI.Pane.Stack
	self.direction = direction
	self:update()
	return self
end

local ANCHORS = {
	["UP"] = vec(0,1,1,1),
	["DOWN"] = vec(0,0,1,0),
	["LEFT"] = vec(1,0,1,1),
	["RIGHT"] = vec(0,0,0,1)
}

local GROW_DIRECTION = {
	["UP"] = vec(1,1),
	["DOWN"] = vec(1,1),
	["LEFT"] = vec(-1,1),
	["RIGHT"] = vec(1,1)
}

---Rearanges the children. automatically called, but in case it dosent update, call this
---@generic self
---@param self self
---@return self
function Stack:rearangeChildren()
   ---@cast self GNUI.Pane.Stack
	local dir = self.direction
   local w = 0
	local isVertical = dir == "UP" or dir == "DOWN"
	local isFlipped = dir == "UP" or dir == "LEFT"
	
	local anchor = ANCHORS[dir]
	
	local axis = isVertical and "y" or "x"
	
   for i,child in pairs(self.Children) do
		if child.Visible then
			local size = child:getDimensionSize()
			if isFlipped then
				w = w - size[axis] - self.spacing
			end
			child:setPos(
				isVertical and 0 or w,
				isVertical and w or 0
			)
			:setAnchor(anchor)
			if not isFlipped then
				w = w + size[axis] + self.spacing
			end
		end
   end
	self:setSystemMinimumSize(
	(not isVertical) and math.abs(w) or 0,
	isVertical and math.abs(w) or 0)
	:setGrowDirection(GROW_DIRECTION[dir])
   return self
end

return StackAPI