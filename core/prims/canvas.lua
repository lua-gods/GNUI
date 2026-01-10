---@diagnostic disable: return-type-mismatch
local gncommon = require("lib.gncommon") ---@type GNCommon
local Box = require("./box") ---@type GNUI.BoxAPI
local config = require("../../config") ---@type GNUI.config
local Render = require("../../"..config.RENDER) ---@type GNUI.RenderAPI


---@class GNUI.CanvasAPI
local CanvasAPI = {}

---A root node for boxes
---@class GNUI.Canvas : GNUI.Box
---@field render GNUI.RenderInstance
---@field queueUpdate GNUI.Box[]
---@field hoveredBox GNUI.Box
---@field pressedButtons GNUI.Box[]
local Canvas = {}
Canvas.__index = function (t,i)
	return rawget(t,i) or Canvas[i] or Box.index(i)
end




---Creates a new canvas for boxes to attach to, this box is special, 
---as it acts as the root node of all boxes
---@return GNUI.Canvas
function CanvasAPI.new()
---@diagnostic disable-next-line: missing-parameter its literally me!
	local self = Box.new()
	---@cast self GNUI.Canvas
	self.render = Render.new(self)
	self.queueUpdate = {}
	self.pressedButtons = {}
	setmetatable(self,Canvas)
	return self
end


---@return GNUI.Canvas
function Canvas:flushUpdates()
	self:forceUpdate()
	return self
end


---@param box GNUI.Box
---@param pos Vector2
local function findHoveredBox(box,pos)
	for index, childBox in ipairs(box.children) do
		if childBox:isPosInbounds(pos) then
			local hoveredBox = findHoveredBox(childBox,pos)
			if hoveredBox then return hoveredBox end
		end
	end
	return box
end


---@overload fun(self: GNUI.Canvas ,xy: Vector2): GNUI.Canvas
---@param x any
---@param y any
---@return GNUI.Canvas
function Canvas:setCursorPos(x,y)
	self.cursorPos = gncommon.vec2(x,y)
	
	local newHoveredBox = findHoveredBox(self,self.cursorPos)
	
	if self.hoveredBox ~= newHoveredBox then
		if self.hoveredBox then
			self.isHovered = false
			self.hoveredBox.CURSOR_PRESENCE_CHANGED:invoke(false)
		end
		self.hoveredBox = newHoveredBox
		if newHoveredBox then
			newHoveredBox.isHovered = true
			newHoveredBox.CURSOR_PRESENCE_CHANGED:invoke(true)
		end
	end
	
	return self
end



---@param scancode integer
---@param state integer
function Canvas:inputKey(scancode, state)
	if self.hoveredBox then
		self.hoveredBox.KEY_INPUT(scancode, state)
		
		if state == 1 then
			self.pressedButtons[scancode] = self.hoveredBox
		elseif state == 0 then
			self.pressedButtons[scancode].KEY_INPUT(scancode,state)
			self.pressedButtons[scancode] = nil
		end
	end
end


function Canvas:inputChar(char)
	if self.hoveredBox then
		self.hoveredBox.CHAR_INPUT(char)
	end
end


---NOTE button 0 is scroll, and sate becomes the scroll amount
---
---@overload fun(self: GNUI.Canvas ,button: 0, dist: number): GNUI.Canvas
---@param button integer
---@param state integer
function Canvas:inputMouse(button,state)
	if self.hoveredBox then
		self.hoveredBox.MOUSE_INPUT(button,state)
		
		if state == 1 then
			self.pressedButtons[button] = self.hoveredBox
		elseif state == 0 then
			self.pressedButtons[button].MOUSE_INPUT(button,state)
			self.pressedButtons[button] = nil
		end
	end
end


return CanvasAPI