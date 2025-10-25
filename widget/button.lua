# flags: host_only
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name:
/ /_/ / /|  /  desc:
\____/_/ |_/ source: link ]]

---@diagnostic disable: assign-type-mismatch
local Box = require("./../prims/box") ---@type GNUI.Box
local cfg = require("./../config") ---@type GNUI.Config
local Event = cfg.event ---@type Event
local Theme = require("./../theme") ---@type GNUI.ThemeAPI

---@class GNUI.ButtonAPI
local ButtonAPI = {}


---@class GNUI.Button : GNUI.Box
---@field isPressed boolean
---@field isToggle boolean
---@field keybind GNUI.keyCode
---
---@field spriteNormal GNUI.Sprite
---@field spritePressed GNUI.Sprite
---@field spriteHover GNUI.Sprite
---
---@field BUTTON_CHANGED Event
---@field PRESSED Event
---@field BUTTON_DOWN Event
---@field BUTTON_UP Event
local Button = {}
Button.__index = function(t, i) return rawget(t, i) or Button[i] or Box[i] end
Button.__type = "GNUI.Button"
ButtonAPI.__metamethods = Button

---@param parent GNUI.Box?
---@param variant GNUI.Theme.Variants?
---@return GNUI.Button
function ButtonAPI.new(parent, variant)
	---@type GNUI.Button
	local box = setmetatable(Box.new(parent), Button)
	box.PRESSED = Event.new()
	box.BUTTON_DOWN = Event.new()
	box.BUTTON_UP = Event.new()
	box.keybind = "key.mouse.left"
	box.BUTTON_CHANGED = Event.new()
	box.isToggle = false
	box.isPressed = false

	box.MOUSE_PRESSENCE_CHANGED:register(function(isHovering)
		box.BUTTON_CHANGED:invoke(box.isPressed, box.isCursorHovering)
	end)

	---@param event GNUI.InputEvent
	box.INPUT:register(function(event)
		if event.key == box.keybind then
			if event.state == 1 then
				box:press()
			else
				box:release()
			end
			return true
		end
	end, "GNUI.Input")

	box.spriteNormal = Theme.getStyle(box, "normal", variant)
	box.spritePressed = Theme.getStyle(box, "pressed", variant)
	box.spriteHover = Theme.getStyle(box, "hover", variant)
	
	local wasPressed = true
	local function update(pressed, hovering, forced)
		if pressed then
			if wasPressed ~= pressed then
				box:setSprite(box.spritePressed or box.spriteNormal)
				if not forced then
					playUISound("minecraft:ui.button.click", 1) -- click
				end
			end
		else
			if hovering then
				box:setSprite(box.spriteHover or box.spriteNormal)
			else
				box:setSprite(box.spriteNormal)
			end
		end
		wasPressed = pressed
	end
	box.BUTTON_CHANGED:register(update)
	update(false, false, true)

	return box
end

---Sets whether the button is toggleable
---@param toggle boolean
---@generic self
---@param self self
---@return self
function Button:setToggle(toggle)
	---@cast self GNUI.Button
	self.isToggle = toggle or false
	return self
end

---Presses the button. or if the button is a toggle and is pressed, this releases the button.
---@generic self
---@param self self
---@return self
function Button:press()
	---@cast self GNUI.Button
	if self.isToggle then
		self.isPressed = not self.isPressed
	else
		self.isPressed = true
	end

	if self.isPressed then
		self.BUTTON_DOWN:invoke()
	else
		self.PRESSED:invoke()
		self.BUTTON_UP:invoke()
	end

	self.BUTTON_CHANGED:invoke(self.isPressed, self.isCursorHovering)
	return self
end

--- Presses and releases the button.
---@generic self
---@param self self
---@return self
function Button:click()
	---@cast self GNUI.Button
	self:press():release()
	return self
end

---Releases the button, if the button is not a toggle, if it is, call `press()` again to release.
---@generic self
---@param self self
---@return self
function Button:release()
	---@cast self GNUI.Button
	if not self.isToggle and self.isPressed then
		self.isPressed = false
		self.BUTTON_UP:invoke()
		self.PRESSED:invoke()
		self.BUTTON_CHANGED:invoke(self.isPressed, self.isCursorHovering)
	end
	return self
end

---Sets whether the button is pressed, only works if the button is a toggle.
---@generic self
---@param self self
---@return self
function Button:setPressed(pressed)
	---@cast self GNUI.Button
	if self.isToggle and self.isPressed ~= pressed then
		self:press()
	end
	return self
end

return ButtonAPI
