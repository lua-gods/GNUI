--[[______   __
	/ ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / The Slider Class.
/ /_/ / /|  / a number range box.
\____/_/ |_/ Source: link]]
---@diagnostic disable: assign-type-mismatch
local Box = require("./../prims/box") ---@type GNUI.Box
local cfg = require("./../config") ---@type GNUI.Config
local Event = cfg.event ---@type Event
local Theme = require("./../theme") ---@type GNUI.ThemeAPI

local Button = require("./button") ---@type GNUI.ButtonAPI
local TextField = require("./textField") ---@type GNUI.TextFieldAPI

local DOUBLE_CLICK_TIME = 300


local function snap(value,step)
	if step > 0.0001 then
		return math.floor(value / step + 0.5) * step
	else
		return value
	end
end


---@class GNUI.SliderAPI
local SliderAPI = {}


---@class GNUI.Slider : GNUI.Button
---@field isVertical boolean
---@field loop boolean
---@field min number
---@field max number
---@field step number
---@field value number
---@field sliderBox GNUI.Box
---@field numberBox GNUI.Box
---@field allowInput boolean
---@field VALUE_CHANGED Event
local Slider = {}
Slider.__index = function (t,i) return rawget(t,i) or Slider[i] or Button.__metamethods[i] or Box[i] end
Slider.__type = "GNUI.Slider"
SliderAPI.__metamethods = Slider

---@param config {isVertical: boolean?,min: number?,max: number?,step: number,value: number?,showNumber: boolean?, loop: boolean, allowInput: boolean}
---@param variant string|"none"|"default"?
---@return GNUI.Slider
function SliderAPI.new(parent,config,variant)
	config = config or {}
	---@type GNUI.Slider
	local self = setmetatable(Button.new(parent,"none"),Slider)
	
	self.min = config.min or 0
	self.max = config.max or 1
	self.step = config.step or 0
	self.value = config.value or self.min
	self.loop = config.loop or false
	self.keybind = "key.mouse.left"
	self.sliderBox = Box.new(self):setCanCaptureCursor(false)
	self.numberBox = Box.new(self):setAnchor(0,0,1,1):setCanCaptureCursor(false)
	if type(config.isVertical) == "boolean" then
		self.isVertical = config.isVertical
	else
		-- makes the slider be based off of how squished the size is
		self.SIZE_CHANGED:register(function ()
			local aspectRatio = self.Size.x / self.Size.y
			if aspectRatio < 1 then
				self.isVertical = true
			else
				self.isVertical = false
			end
			self.SIZE_CHANGED:remove("verticalDeterminator")
		end,"verticalDeterminator")
	end
	
	if type(config.allowInput) == "boolean" then
		self.allowInput = config.allowInput
	else
		self.allowInput = true
	end
	
	self.VALUE_CHANGED = Event.new()
	
	self.VALUE_CHANGED:register(function () self:updateSliderBox() end)
	self:updateSliderBox()
	
	local lastClickTime = 0
	---@param event GNUI.InputEvent
	self.INPUT:register(function (event)
		if event.key == self.keybind then
			if event.state == 1 then
				local clickTime = client:getSystemTime()
				if self.allowInput and clickTime - lastClickTime < DOUBLE_CLICK_TIME then
					self.numberBox:setVisible(false)
					local numberField = TextField.new(self):setAnchor(0,0,1,1)
					numberField.FIELD_CONFIRMED:register(function (out)
						numberField:free()
						if tonumber(out) then
							self:setValue(tonumber(out))
						end
						self.numberBox:setVisible(true)
					end)
					numberField:press()
					self:release()
					return true
				end
				lastClickTime = clickTime
				self:press()
				return true
			else
				self:release()
			end
		elseif event.key == "key.mouse.scroll" then
			local dir = event.strength > 0 and 1 or -1
			self:setValue(self.value - math.max(self.step,0.1) * dir)
			return true
		end
	end,"GNUI.Input")
	
	---@param event GNUI.InputEventMouseMotion
	self.MOUSE_MOVED:register(function (event)
		if self.isPressed then
				local pos = self:toLocal(event.pos)/self:getFinalSize()
				local gsize = self.cache.grabber_size or 0
				if self.isVertical then
					self:setValue(math.map(pos.y,gsize,1-gsize,self.min,self.max))
				else
					self:setValue(math.map(pos.x,gsize,1-gsize,self.min,self.max))
				end
		end
	end,"GNUI.Input")
	self.spriteNormal = Theme.getStyle(self,"shaft",variant)
	self:setSprite(self.spriteNormal)
	self.sliderBox:setSprite(Theme.getStyle(self,"thumb",variant))
	self.numberBox:setSprite(Theme.getStyle(self,"number",variant))
	return self
end

---Sets the value of the slider.
---@param value number
---@generic self
---@param self self
---@return self
function Slider:setValue(value)
	---@cast self GNUI.Slider
	local lvalue = self.value
	local finalValue = snap(value,self.step)
	self.value = self.loop and ((finalValue - self.min) % (self.max - self.min) + self.min) or math.clamp(finalValue,self.min,self.max)
	if self.value ~= lvalue then
		self.VALUE_CHANGED:invoke(self.value)
		self:updateSliderBox()
	end
	return self
end

---Sets the minimum value of the slider.
---@param min number
---@generic self
---@param self self
---@return self
function Slider:setMin(min)
	---@cast self GNUI.Slider
	self.min = min
	return self
end

---Sets the maximum value of the slider.
---@param max number
---@generic self
---@param self self
---@return self
function Slider:setMax(max)
	---@cast self GNUI.Slider
	self.max = max
	return self
end

---Sets the step size of the slider.
---@param step number
---@generic self
---@param self self
---@return self
function Slider:setStep(step)
	---@cast self GNUI.Slider
	self.step = step
	return self
end

---Updates the displayed slider box.
---@generic self
---@param self self
---@return self
function Slider:updateSliderBox()
	---@cast self GNUI.Slider
	local diff = math.min(math.abs(self.max - self.min),20) + 1
	local mul = (diff-1) / (self.max - self.min)
	local l = self.value - self.min
	local a1,a2 = (l * mul)/diff,(l * mul+1)/diff
	self.cache.grabber_size = (a2 - a1) / 2
	if self.isVertical then self.sliderBox:setAnchor(0,a1,1,a2)
	else self.sliderBox:setAnchor(a1,0,a2,1)
	end
	self.numberBox:setText(self.value)
	return self
end


---Sets the font scale for this slider's elements.
---@param scale number
---@generic self
---@param self self
---@return self
function Slider:setFontScale(scale)
	---@cast self GNUI.Slider
	scale = scale or 1
	self.numberBox:setFontScale(scale)
	self.sliderBox:setFontScale(scale)
	return self
end

return SliderAPI