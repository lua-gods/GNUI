---@diagnostic disable: duplicate-doc-field
local config = require("../config") ---@type GNUI.config
local Box = require("../core/prims/box") ---@type GNUI.BoxAPI
local Event = require("../" .. config.EVENT)


local Style = require("../" .. config.STYLE) ---@type GNUI.StyleAPI
local Layout = require("../" .. config.LAYOUT) ---@class GNUI.LayoutAPI


---@class GNUI.ButtonAPI
local ButtonAPI = {}


---@class GNUI.Button : GNUI.Box
---@field down boolean
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
	self.PRESSED = Event.new()
	self.MOUSE_INPUT:register(function (button, state)
		if button == 0 then
			if state == 1 then
				self.down = true
				self.sprite:setStyle(Style.getStyle(self,self.variant,"pressed"))
			elseif state == 0 and self.down then
				self.PRESSED:invoke()
				self.down = false
				self.sprite:setStyle(Style.getStyle(self,self.variant,"normal"))
			end
		end
	end)
	setmetatable(self, Button)
	return self
end


--────────────────────────-< Layout Parser >-────────────────────────--

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