--[[______   __
  / ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / The Pane Class.
/ /_/ / /|  / a way to automatically arrange children into some order inside the box. by default does nothing
\____/_/ |_/ Source: link]]
---@diagnostic disable: assign-type-mismatch
local Box = require("./../prims/box") ---@type GNUI.Box
local cfg = require("./../config") ---@type GNUI.Config
local utils = cfg.utils ---@type GNUI.UtilsAPI
local Event = cfg.event ---@type Event
local Theme = require("./../theme") ---@type GNUI.ThemeAPI

---@class GNUI.PaneAPI
local PaneAPI = {}


---@class GNUI.Pane : GNUI.Box
local Pane = {}
Pane.__index = function (t,i) return rawget(t,i) or Pane[i] or Box[i] end
Pane.__type = "GNUI.Pane"
PaneAPI.__index = Pane.__index

---Creates a new GridStacker.
---@return GNUI.Pane
function PaneAPI.new(parent,variant)
   ---@type GNUI.Pane
   local box = Box.new(parent)
   box._parent_class = Pane
   box.spacing = vec(0,0)
   
	box:setSprite(Theme.getStyle(box,"background",variant))
	
   setmetatable(box,Pane)
   local function update() box:rearangeChildren() end
   box.SIZE_CHANGED:register(update,"Pane")
	box.CHILDREN_ADDED:register(function (child)
		child.SIZE_CHANGED:register(update,"Pane")
	end)
	box.CHILDREN_REMOVED:register(function (child)
		child.SIZE_CHANGED:unregister(update,"Pane")
	end)
   return box
end

---Rearanges the children. automatically called, but in case it dosent update, call this
---@generic self
---@param self self
---@return self
function Pane:rearangeChildren()
   return self
end



return PaneAPI