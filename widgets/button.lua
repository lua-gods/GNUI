---@diagnostic disable: duplicate-doc-field
local config = require("../config") ---@type GNUI.config
local Box = require("./box") ---@type GNUI.BoxAPI
local Event = require("../" .. config.EVENT)


local Style = require("../" .. config.STYLE) ---@type GNUI.StyleAPI
local Layout = require("../" .. config.LAYOUT) ---@class GNUI.LayoutAPI


---@class GNUI.ButtonAPI
local ButtonAPI = {}

---@class Event.GNUI.Button.PRESSED : Event
---@field register fun(self,func:fun(down: boolean))|fun(func:fun(toggle: boolean))

---@class GNUI.Button : GNUI.Box
---@field down boolean
---@field toggle boolean
---
---@field BUTTON_DOWN Event
---@field BUTTON_UP Event
---
---@field PRESSED Event.GNUI.Button.PRESSED
local Button = {}
Button.__index = function (t,i)
	return rawget(t,i) or Button[i] or Box.index(i)
end
Button.__style = "button"
Button.__type = "Button"

---@param canvas GNUI.Canvas
---@return GNUI.Button
function ButtonAPI.new(canvas)
	local self = Box.new(canvas)
	---@cast self GNUI.Button
	
	self.down = false
	self.toggle = false
	self.PRESSED = Event.new()
	self.BUTTON_DOWN = Event.new()
	self.BUTTON_UP = Event.new()
	
	self.MOUSE_INPUT:register(function (button, state)
		if button == 0 then
			local lastDown = self.down
			if state == 1 then
				if self.toggle then
					self.down = not self.down
					self.PRESSED:invoke(self.down)
				else
					self.down = true
				end
			elseif state == 0 and self.down then
				if not self.toggle then
					self.PRESSED:invoke()
					self.down = false
				end
			end
			if lastDown ~= self.down then
				if self.down then
					self.BUTTON_DOWN:invoke()
				else
					self.BUTTON_UP:invoke()
				end
			end
			self:applyApropriateStyle()
		end
	end)
	self.CURSOR_PRESENCE_CHANGED:register(function (inside)
		self:applyApropriateStyle()
	end)
	setmetatable(self, Button)
	return self
end


---@generic self
---@param self self
---@return self
function Button:press()
	---@cast self GNUI.Button
	self.MOUSE_INPUT(0,1)
	if not self.toggle then
		self.MOUSE_INPUT(0,0)
	end
	return self
end




---@param toggle boolean
---@generic self
---@param self self
---@return self
function Button:setToggle(toggle)
	---@cast self GNUI.Button
	self.toggle = toggle
	return self
end


--────────────────────────-< Layout Parser >-────────────────────────--

function Button:applyApropriateStyle()
	if self.down then
		if self.isHovered then
			self.sprite:setStyle(Style.getKey(self,"pressedHovered"))
		else
			self.sprite:setStyle(Style.getKey(self,"pressed"))
		end
	else
		if self.isHovered then
			self.sprite:setStyle(Style.getKey(self,"hovered"))
		else
			self.sprite:setStyle(Style.getKey(self,"normal"))
		end
	end
end

---@class GNUI.Layout
---@field type "button"?

---@param layout any
---@param canvas GNUI.Canvas
---@param button GNUI.Button?
---@return GNUI.Button
function ButtonAPI.parse(layout,canvas,button)
	local box = button or Box.parse(layout,canvas,ButtonAPI.new(canvas))

	return box
end

Layout.registerType("button", ButtonAPI.parse)


return ButtonAPI