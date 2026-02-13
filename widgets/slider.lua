local BASE = ((...):gsub("/",".")):match(".+%.GNUI")

local config = require(BASE..".config") ---@type GNUI.config
local Box = require(BASE..".widgets.box") ---@type GNUI.BoxAPI
local Event = require(config.EVENT)
local Button = require(BASE..".widgets.button") ---@type GNUI.Widget.ButtonAPI

local Style = require(BASE .. ".".. config.STYLE..".style") ---@type GNUI.StyleAPI
local Layout = require(BASE ..".".. config.LAYOUT..".layout") ---@type GNUI.LayoutAPI
local utils = require("../utils") ---@type GNUI.utils

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

