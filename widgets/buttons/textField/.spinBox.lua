local BASE = ((...):gsub("/", ".")):match(".+%.GNUI")
local cfg = require(BASE .. ".config") ---@type GNUI.config

local Box = require(cfg.WIDGETS .. ".box") ---@type GNUI.BoxAPI
local Event = require(cfg.EVENT)
local Button = require(cfg.WIDGETS .. ".button") ---@type GNUI.Widget.ButtonAPI
local TextField = require(cfg.WIDGETS .. ".buttons.textField") ---@type GNUI.Widget.TextFieldAPI

local Style = require(cfg.THEME .. ".init") ---@type GNUI.ThemeAPI
local Layout = require(cfg.LAYOUT .. ".init") ---@type GNUI.LayoutAPI

local utils = require(cfg.UTILS) ---@type GNUI.utils

---@class GNUI.Widget.SpinBoxAPI
local SpinBoxAPI = {}


---A widget that allows users to select a single value or a range of predefined spectrum  by dragging a handle (thumb) along a bar.
---@class GNUI.Widget.SpinBox : GNUI.Widget.TextField
---@field isVertical boolean #Tells if the TextField is vertical
---@field boxKnob GNUI.Box
---@field value number # The default value
---@field min number # the minimum allowed value
---@field max number # the maximum allowed value
---@field step number # the step size of the TextField, 0 for none
---@field prefix string # the prefix when the value is displayed
---@field suffix string # the suffix when the value is displayed
---@field loop boolean # if true, the value will loop between min and max
---@field validator nil
---@field VALUE_CHANGED Event.GNUI.Button.ValueChanged # triggered when the value is changed	
local SpinBox = {}
SpinBox.__index = function(t, i)
	return rawget(t, i)
		 or SpinBox[i]
		 or Button.index(t, i)
		 or Box.index(t, i)
end
SpinBox.__style = "spinBox"
SpinBox.__type = "SpinBox"

local function snap(value, step, offset)
	offset = offset or 0
	if step < 0.0001 then
		return value
	end
	return math.floor((value + offset) / step + 0.5) * step - offset
end


---@param box GNUI.Box
---@param canvas GNUI.Canvas
---@return GNUI.Widget.SpinBox
function SpinBoxAPI.new(box,canvas,children)
	local self = TextField.new(box,canvas,children)
	---@cast self GNUI.Widget.SpinBox
	
	self.isVertical = false
	self.value = 0
	self.min = 0
	self.max = 100
	self.step = 10
	self.softBoundary = false
	self.prefix = ""
	self.suffix = ""
	self.VALUE_CHANGED = Event.new()
	self.loop = false
	
	
	setmetatable(self, SpinBox)
	return self
end


function SpinBox:setValue(value)
	value = value or self.value
	value = snap(value, self.step)
	value = math.clamp(value, self.min, self.max)
	if self.value ~= value then
		self.value = value
		self:setField(tostring(value))
		self.VALUE_CHANGED:invoke(value)
	end
	return self
end

function SpinBox:setValueSilent(value)
	value = value or self.value
	value = snap(value, self.step)
	value = math.clamp(value, self.min, self.max)
	if self.value ~= value then
		self.value = value
	end
	return self
end


---@param min number
---@generic self
---@param self self
---@return self
function SpinBox:setMin(min)
	---@cast self GNUI.Widget.SpinBox
	self.min = min
	self:setValue()
	return self
end

---@param max number
---@generic self
---@param self self
---@return self
function SpinBox:setMax(max)
	---@cast self GNUI.Widget.SpinBox
	self.max = max
	self:setValue()
	return self
end

---@param min number
---@param max number
---@param softBoundary boolean?
---@generic self
---@param self self
---@return self
function SpinBox:setRange(min, max, softBoundary)
	---@cast self GNUI.Widget.SpinBox
	self.min = min
	self.max = max
	self.softBoundary = softBoundary or false
	self:setValue()
	return self
end

---@param stepSize number
---@generic self
---@param self self
---@return self
function SpinBox:setStepSize(stepSize)
	---@cast self GNUI.Widget.SpinBox
	self.step = stepSize
	self:setValue()
	return self
end


function SpinBox:processTextField(offset, original)
	local value = original + math.map(offset.x, 0, 200, self.min, self.max)
	self:setValue(value)
end


---@generic self
---@param self self
---@return self
function SpinBox:applyApropriateStyle()
	---@cast self GNUI.Widget.SpinBox
	if self.down then
		if self.validField then
			self.sprites[1]:setStyle(Style.getStyleFromBox(self,"active"))
		else
			self.sprites[1]:setStyle(Style.getStyleFromBox(self,"invalid"))
		end
	else
		if #self.field == 0 then
			self.sprites[1]:setStyle(Style.getStyleFromBox(self,"empty"))
		else
			self.sprites[1]:setStyle(Style.getStyleFromBox(self,"normal"))
		end
	end
	return self
end


--────────────────────────-< SpinBox >-────────────────────────--

---@diagnostic disable: duplicate-doc-field
---@class GNUI.Layout
---@field type "textField"?
---@field field string?
---@field placeholder string?
---@field multiline boolean?
---@field validator (GNUI.TextField.Verifier|fun(field: string):boolean)?
---@field prefix string?
---@field suffix string?

---@param layout any
---@param canvas GNUI.Canvas
---@param textField GNUI.Widget.TextField?
---@return GNUI.Widget.TextField
function TextFieldAPI.parse(layout,canvas, children,textField)
	local box = textField or Box.parse(layout,canvas,children,TextFieldAPI.new)
	if layout.field then box:setField(layout.field) end
	if layout.placeholder then box:setPlaceholder(layout.placeholder) end
	if layout.multiline then box:setMultiline(layout.multiline) end
	if layout.prefix then box:setPrefix(layout.prefix) end
	if layout.suffix then box:setSuffix(layout.suffix) end
	
	if layout.validator then 
		if type(layout.validator) == "function" then
			box.validator = layout.validator
		else
			box.validator = TextFieldAPI.validators[layout.validator]
		end
	end
	box:applyApropriateStyle()
	return box
end

Layout.registerType("textField", TextFieldAPI.parse)
