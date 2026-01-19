---@diagnostic disable: duplicate-doc-field
local config = require("../config") ---@type GNUI.config
local Box = require("./box") ---@type GNUI.BoxAPI
local Event = require("../" .. config.EVENT)


local Style = require("../" .. config.STYLE) ---@type GNUI.StyleAPI
local Layout = require("../" .. config.LAYOUT) ---@class GNUI.LayoutAPI


---@class GNUI.ButtonAPI
local ButtonAPI = {}


---@class GNUI.Button : GNUI.Box
---@field down boolean
---@field toggle boolean
---
---@field PRESSED Event
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
	self.toggle = true
	self.PRESSED = Event.new()
	self.MOUSE_INPUT:register(function (button, state)
		if button == 0 then
			if state == 1 then
				if self.toggle then
					self.down = not self.down
				else
					self.down = true
				end
			elseif state == 0 and self.down then
				self.PRESSED:invoke()
				if not self.toggle then
					self.down = false
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


--────────────────────────-< Layout Parser >-────────────────────────--

function Button:applyApropriateStyle()
	if self.down then
		self.sprite:setStyle(Style.getKey(self,"pressed"))
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