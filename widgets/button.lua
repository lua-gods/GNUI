local config = require("../config") ---@type GNUI.config
local Box = require("../core/prims/box") ---@type GNUI.BoxAPI
local Event = require("../" .. config.EVENT)


---@class GNUI.ButtonAPI
local ButtonAPI = {}


---@class GNUI.Button : GNUI.Box
---@field pressed boolean
---@field PRESSED Event
local Button = {}
Button.__style = "button"
Button.__type = "Button"

---@param canvas GNUI.Canvas
---@return GNUI.Button
function ButtonAPI.new(canvas)
	local self = Box.new(canvas)
	---@cast self GNUI.Button
	
	self.pressed = false
	self.PRESSED = Event.new()
	self.MOUSE_INPUT:register(function (button, state)
		if button == 1 then
			if state == 1 then
				self.pressed = true
			elseif state == 0 and self.pressed then
				self.PRESSED:invoke()
				self.pressed = false
			end
		end
	end)
	
	return self
end


return ButtonAPI