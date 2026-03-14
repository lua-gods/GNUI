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
---@class GNUI.Widget.Slider : GNUI.Widget.Button
---@field isVertical boolean #Tells if the slider is vertical
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


---@param canvas GNUI.Canvas
---@return GNUI.Widget.Slider
function SliderAPI.new(canvas)
	local self = Button.new(canvas)
	---@cast self GNUI.Widget.Slider
	setmetatable(self,Slider)
	
	self.isVertical = false
	self.value = 0
	self.min = 0
	self.max = 100
	self.step = 0
	self.softBoundary = false
	self.prefix = ""
	self.suffix = ""
	self.VALUE_CHANGED = Event.new()
	
	return self
end


---@param vertical boolean
---@generic self
---@param self self
---@return self
function Slider:setVertical(vertical)
	---@cast self GNUI.Widget.Slider
	self.isVertical = vertical
	self:update()
	return self
end


---@param value number
---@generic self
---@param self self
---@return self
function Slider:setValue(value)
	---@cast self GNUI.Widget.Slider
	self.value = value
	self.VALUE_CHANGED:invoke(value)
	self:update()
	return self
end


---@param min number
---@generic self
---@param self self
---@return self
function Slider:setMin(min)
	---@cast self GNUI.Widget.Slider
	self.min = min
	self:update()
	return self
end


---@param max number
---@generic self
---@param self self
---@return self
function Slider:setMax(max)
	---@cast self GNUI.Widget.Slider
	self.max = max
	self:update()
	return self
end


---@param min number
---@param max number
---@param softBoundary boolean?
---@generic self
---@param self self
---@return self
function Slider:setRange(min,max,softBoundary)
	---@cast self GNUI.Widget.Slider
	self.min = min
	self.max = max
	self.softBoundary = softBoundary or false
	self:update()
	return self
end


---@param stepSize number
---@generic self
---@param self self
---@return self
function Slider:setStepSize(stepSize)
	---@cast self GNUI.Widget.Slider
	self.step = stepSize
	self:update()
	return self
end


---@param prefix string
---@generic self
---@param self self
---@return self
function Slider:setPrefix(prefix)
	---@cast self GNUI.Widget.Slider
	self.prefix = prefix
	self:update()
	return self
end


---@param suffix string
---@generic self
---@param self self
---@return self
function Slider:setSuffix(suffix)
	---@cast self GNUI.Widget.Slider
	self.suffix = suffix
	self:update()
	return self
end


--────────────────────────-< Layout Parser >-────────────────────────--


---@diagnostic disable: duplicate-doc-field
---@class GNUI.Layout
---@field type "slider"
---
---@field value number
---@field min number
---@field max number
---@field step number
---
---@field softBoundary boolean
---
---@field prefix string
---@field suffix string

---@param layout any
---@param canvas GNUI.Canvas
---@param button GNUI.Widget.Button?
---@return GNUI.Widget.Button
function SliderAPI.parse(layout,canvas,button)
	local self = button or Box.parse(layout,canvas,SliderAPI.new(canvas))

	local style = Style.getStyle("box", "highlight", "normal")
	style:newInstance(self,"highlight"):setVisible(false)
	self:setToggle(false) -- force sliders to be non-toggleable
	
	return self
end

Layout.registerType("slider", SliderAPI.parse)
