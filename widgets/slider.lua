local BASE = ((...):gsub("/",".")):match(".+%.GNUI")
local paths = require(BASE..".paths") ---@type GNUI.config

local Box = require(paths.WIDGETS..".box") ---@type GNUI.BoxAPI
local Event = require(paths.EVENT)
local Button = require(paths.WIDGETS..".button") ---@type GNUI.Widget.ButtonAPI

local Style = require(paths.THEME..".init") ---@type GNUI.ThemeAPI
local Layout = require(paths.LAYOUT..".init") ---@type GNUI.LayoutAPI

local utils = require(paths.UTILS) ---@type GNUI.utils

---@class Event.GNUI.Button.ValueChanged : Event
---@field register fun(self,func:fun(value: number))


---@class GNUI.Widget.SliderAPI
local SliderAPI = {}


---@class GNUI.Widget.Slider
---@field value number
---@field min number
---@field max number
---@field step number
---@field softBoundary boolean Tells if the slider is allowed to go out of bounds
---@field suffix string
---@field prefix string
---@field VALUE_CHANGED Event.GNUI.Button.ValueChanged
---@field PRESSED Event.GNUI.Button.PRESSED
local Slider = {}
Slider.__index = function (t,i)
	return rawget(t,i)
	or Slider[i]
	or Button.index(t,i)
	or Box.index(t,i)
end
Slider.__style = "slider"
Slider.__type = "Slider"

