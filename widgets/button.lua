--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Button Class
/ /_/ / /|  /  desc: the button widget for GNUI
\____/_/ |_/ source: link ]]

local BASE = ((...):gsub("/",".")):match(".+%.GNUI")
local cfg = require(BASE..".config") ---@type GNUI.config

local Box = require(BASE..".widgets.box") ---@type GNUI.BoxAPI
local Event = require(cfg.EVENT)

local Style = require(cfg.THEME..".init") ---@type GNUI.ThemeAPI
local Layout = require(cfg.LAYOUT..".init") ---@type GNUI.LayoutAPI
local utils = require(cfg.UTILS)

---@class GNUI.Widget.ButtonAPI
local ButtonAPI = {}


---@class Event.GNUI.Button.PRESSED : GN.Event
---@field register fun(self,func:fun(down: boolean))|fun(func:fun(toggle: boolean))

---@class GNUI.Widget.Button : GNUI.Box
---@field down boolean
---@field toggle boolean
---
---@field BUTTON_DOWN GN.Event
---@field BUTTON_UP GN.Event
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
---@return GNUI.Widget.Button
function ButtonAPI.new(canvas)
	local self = Box.new(canvas)
	---@cast self GNUI.Widget.Button
	setmetatable(self, Button)
	
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
	
	return self
end


---Applies the given button action to this button.
---@param button GNUI.InputButton.Type
---@param state GNUI.InputButton.State
---@generic self
---@param self self
---@return self
function Button:applyButtonAction(button,state)
	---@cast self GNUI.Widget.Button
	if button == 0 then
		local lastDown = self.down
		if state == 1 then
			if self.toggle then
				self.down = not self.down
				self.PRESSED:invoke(self.down)
			else
				self.down = true
				self.PRESSED:invoke(true)
			end
		elseif state == 0 and self.down then
			if not self.toggle then
				self.down = false
				self.PRESSED:invoke(false)
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
	return self
end


---Applies the appropriate style to the button, based on its state.
---
---this is called automatically by built in events
---@generic self
---@param self self
---@return self
function Button:applyApropriateStyle()
	---@cast self GNUI.Widget.Button
	self.sprites.highlight:setVisible(self.isHovered)
	if self.down then
		self.sprites[1]:setStyle(Style.getStyleFromBox(self,"pressed"))
	else
		self.sprites[1]:setStyle(Style.getStyleFromBox(self,"normal"))
	end
	return self
end


---Presses the button and immidiately unpresses it.
---@generic self
---@param self self
---@return self
function Button:interact()
	---@cast self GNUI.Widget.Button
	self:applyButtonAction(0,1)
	if not self.toggle then
		self:applyButtonAction(0,0)
	end
	return self
end


---Presses the button, holding it down.
---@generic self
---@param self self
---@return self
function Button:press()
	---@cast self GNUI.Widget.Button
	if not self.down then
		self:applyButtonAction(0,1)
	end
	return self
end


---Releases the button, if it was pressed down in the first place.
---@generic self
---@param self self
---@return self
function Button:release()
	---@cast self GNUI.Widget.Button
	if self.down then
		if self.toggle then
			self:applyButtonAction(0,1)
		else
			self:applyButtonAction(0,0)
		end
	end
	return self
end


---Sets if the button should act as a toggle or not.
---@param toggle boolean
---@generic self
---@param self self
---@return self
function Button:setToggle(toggle)
	---@cast self GNUI.Widget.Button
	self.toggle = toggle
	return self
end


---Sets the style of the sprite of this box, if no sprite exists, it will create one for that given style
---
---@generic self
---@param self self
---@return self
---@param variant string?
function Button:setStyleVariant(variant)
	variant = variant or "default"
	---@cast self GNUI.Box
	
	self.variant = variant
	local style = Style.getStyle(self, variant, "normal")
	
	-- replaces existing style or creates a new one
	--TODO: replace styling method with a cleaner one.
	if self.sprites[1] then
		self.sprites[1]:setStyle(style)
	else
		style:newInstance(self,1)
	end
	
	Style.getStyle("box", "highlight", "normal")
	:newInstance(self,"highlight"):setVisible(false)
	
	self:recalculateMargin()
	self:recalculatePadding()
	self:recalculateMinimumSize()
	self:update()
	return self
end


--────────────────────────-< Layout Parser >-────────────────────────--

---@diagnostic disable: duplicate-doc-field
---@class GNUI.Layout
---@field type "button"?
---@field toggle boolean?

---@param layout any
---@param canvas GNUI.Canvas
---@param button GNUI.Widget.Button?
---@return GNUI.Widget.Button
function ButtonAPI.parse(layout,canvas,button)
	local self = button or Box.parse(layout,canvas,ButtonAPI.new(canvas))

	
	self:setStyleVariant(layout.variant)
	
	if layout.toggle then self.toggle = layout.toggle end
	
	return self
end

Layout.registerType("button", ButtonAPI.parse)


return ButtonAPI