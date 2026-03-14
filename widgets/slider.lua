local BASE = ((...):gsub("/",".")):match(".+%.GNUI")
local cfg = require(BASE..".config") ---@type GNUI.config

local Box = require(cfg.WIDGETS..".box") ---@type GNUI.BoxAPI
local Event = require(cfg.EVENT)
local Button = require(cfg.WIDGETS..".button") ---@type GNUI.Widget.ButtonAPI

local Style = require(cfg.THEME..".init") ---@type GNUI.ThemeAPI
local Layout = require(cfg.LAYOUT..".init") ---@type GNUI.LayoutAPI

local utils = require(cfg.UTILS) ---@type GNUI.utils

---@class Event.GNUI.Button.ValueChanged : Event
---@field register fun(self,func:fun(value: number))


---@class GNUI.Widget.SliderAPI
local SliderAPI = {}


---A widget that allows users to select a single value or a range of predefined spectrum  by dragging a handle (thumb) along a bar.
---@class GNUI.Widget.Slider
---@field value number # The default value
---@field min number # the minimum allowed value
---@field max number # the maximum allowed value
---@field step number # the step size of the slider, 0 for none
---@field softBoundary boolean #Tells if the slider is allowed to go out of bounds
---@field prefix string # the prefix when the value is displayed
---@field suffix string # the suffix when the value is displayed
---@field VALUE_CHANGED Event.GNUI.Button.ValueChanged # triggered when the value is changed
---@field PRESSED Event.GNUI.Button.PRESSED # triggered when the slider is pressed
local Slider = {}
Slider.__index = function (t,i)
	return rawget(t,i)
	or Slider[i]
	or Button.index(t,i)
	or Box.index(t,i)
end
Slider.__style = "slider"
Slider.__type = "Slider"

