local BASE = (...):match(".+[./]GNUI"):gsub("/",".")

local config = require(BASE..".config") ---@type GNUI.config
local Box = require(BASE..".widgets.box") ---@type GNUI.BoxAPI

local Event = require(config.EVENT)

local Layout = require(BASE.."."..config.LAYOUT..".layout") ---@type GNUI.LayoutAPI
local Style = require(BASE.."."..config.STYLE..".style") ---@type GNUI.StyleAPI


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
	return rawget(t,i) or Button[i] or Box.index(t,i)
end
Button.__style = "button"
Button.__type = "Button"


function ButtonAPI.index(t,i)
	return Button.__index(t,i)
end


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
		self:applyButtonAction(button,state)
	end)
	self.CURSOR_PRESENCE_CHANGED:register(function (inside)
		self:applyApropriateStyle()
	end)
	setmetatable(self, Button)
	return self
end


---@param button integer
---@param state integer
function Button:applyButtonAction(button,state)
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
end


function Button:applyApropriateStyle()
	self.sprites.highlight:setVisible(self.isHovered)
	if self.down then
		self.sprites[1]:setStyle(Style.getKey(self,"pressed"))
	else
		self.sprites[1]:setStyle(Style.getKey(self,"normal"))
	end
end


---@generic self
---@param self self
---@return self
function Button:interact()
	---@cast self GNUI.Button
	self:applyButtonAction(0,1)
	if not self.toggle then
		self:applyButtonAction(0,0)
	end
	return self
end


---@generic self
---@param self self
---@return self
function Button:press()
	---@cast self GNUI.Button
	if not self.down then
		self:applyButtonAction(0,1)
	end
	return self
end


---@generic self
---@param self self
---@return self
function Button:release()
	---@cast self GNUI.Button
	if self.down then
		if self.toggle then
			self:applyButtonAction(0,1)
		else
			self:applyButtonAction(0,0)
		end
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

---@diagnostic disable: duplicate-doc-field
---@class GNUI.Layout
---@field type "button"?
---@field toggle boolean?

---@param layout any
---@param canvas GNUI.Canvas
---@param button GNUI.Button?
---@return GNUI.Button
function ButtonAPI.parse(layout,canvas,button)
	local box = button or Box.parse(layout,canvas,ButtonAPI.new(canvas))

	-- TODO: find out why this is shifting the entire box renderer
	local style = Style.getStyle("box", "highlight", "normal")
	style:newInstance(box,"highlight"):setVisible(false)
	
	if layout.toggle then box.toggle = layout.toggle end
	
	return box
end

Layout.registerType("button", ButtonAPI.parse)


return ButtonAPI
