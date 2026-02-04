--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Sprite Module
/ /_/ / /|  /  desc: base class for all sprites
\____/_/ |_/ source: link ]]


local SpriteStyle = require("../styles/sprite") ---@type GNUI.Sprite.StyleAPI
local gncommon = require("lib.gncommon") ---@type GNCommon


---A base class for all sprites for boxes
---@class GNUI.Sprite
---@field style GNUI.Sprite.Style
---@field box GNUI.Box?
---@field index (integer|string)? # index of the sprite to the box it is attached to
---@field parentID integer
---@field boxColor Vector3
---
---@field flagApply boolean
---@field padding Vector4
---@field textColor Vector3
---@field textAlignment Vector2
---
---@field pos Vector2
---@field size Vector2
---
---@field display GNUI.Render.Display
---@field taskID integer # Task ID
---@field labelID integer # Task ID
local Sprite = {}
Sprite.__index = Sprite


---@param box GNUI.Box
---@param slot (integer|string)?
---@return GNUI.Sprite
function Sprite.new(box,slot)
	
	local self = {
		pos = vec(0,0),
		size = vec(0,0),
		padding = vec(0,0,0,0),

		childIndex = 1,
		
		textColor = vec(1,1,1),
		textAlignment = vec(0,0),
		
		boxColor = vec(1,1,1),
		flagApply = false,
		
	}
	setmetatable(self, Sprite)
	if box then
		self:setBox(box,slot)
	end
	
	return self
end


SpriteStyle.setInstancer(Sprite.new)
---@return GNUI.Sprite.Style
function Sprite.newStyle()
	return SpriteStyle.new()
end


--────────────────────────-< API >-────────────────────────--


---@param box GNUI.Box
---@param slot (integer|string)?
function Sprite:setBox(box,slot)
	if self.taskID then
		self.display:removeSprite(self.taskID)
	end
	self.display = box.canvas.display
	self.taskID = box.canvas.display:newSprite(box.visualID)
	self.labelID = box.canvas.display:newLabel(box.visualID)
	self.box = box
	
	self.index = slot or #box.sprites+1
	
	box.sprites[self.index] = self
	box:recalculateMargin()
	box:recalculatePadding()
	box:recalculateMinimumSize()
	
	if self.box then
		self:applyAll()
	end
end


---@overload fun(self: GNUI.Sprite)
---@param x number
---@param y number
function Sprite:setPos(x,y)
	if x then
		local pos = gncommon.vec2(x,y)
		local expand = self.style and self.style.expand.xy or vec(0,0)
		
		if self.pos == pos  then return end
		self.pos = pos - expand
	end
	self.display:setPos(self.box.visualID, self.pos.x,self.pos.y)
end


---@overload fun(self: GNUI.Sprite)
---@param x number
---@param y number
function Sprite:setSize(x,y)
	---@cast self GNUI.Sprite
	if x then
		local size = vec(x,y)
		if self.style then size = size + self.style.expand.xy end
		
		if size == self.size then return end
		self.size = size
	end
	self.display:setSpriteSize(self.box.visualID, self.taskID, self.size.x, self.size.y)
	return self
end


---@overload fun(self: GNUI.Sprite)
---@param text string
function Sprite:setText(text)
	---@cast self GNUI.Sprite
	if text then
		if self.text == text then return end
		self.text = text
	end
	self.display:setText(self.box.visualID,self.labelID,self.text)
end


---@overload fun(self: GNUI.Sprite)
---@param r number
---@param g number
---@param b number
function Sprite:setTextColor(r,g,b)
	if r then
		local color = vec(r,g,b)
		if self.style then color = color * self.style.textColor end
		if self.textColor == color then return end
		self.textColor = color
	end
	if self.textColor then
		self.display:setTextColor(self.box.visualID,self.labelID,self.textColor.x,self.textColor.y,self.textColor.z) -- FIXME
	end
end


---@overload fun(self: GNUI.Sprite)
---@param l number
---@param t number
---@param r number
---@param b number
---@return GNUI.Sprite
function Sprite:setPadding(l,t,r,b)
	---@cast self GNUI.Sprite
	if l then
		local padding = vec(l,t,r,b)
		if padding == self.padding then return end
		self.padding = padding
	end
	
	local expand = self.style and self.style.expand or vec(0,0,0,0)
	
	self.display:setLabelPadding(self.box.visualID,self.labelID,
		self.padding.x+expand.x,
		self.padding.y+expand.y,
		self.padding.z+expand.z,
		self.padding.w+expand.w
	)
	return self
end


---@param h (-1|0|1)?
---@param v (-1|0|1)?
function Sprite:setTextAlignment(h,v)
	---@cast self GNUI.Sprite
	local changed = false
	if h then self.textAlignment.x = h changed = true end
	if v then self.textAlignment.y = v changed = true end
	if changed then
		self.display:setTextAlignment(self.box.visualID,self.labelID, self.textAlignment.x, self.textAlignment.y)
	end
	return self
end


function Sprite:setVisible(visible)
	self.visible = visible
	self.display:setSpriteVisible(self.box.visualID, self.taskID, visible)
end


---@overload fun(self: GNUI.Sprite)
---@param style GNUI.Sprite.Style
function Sprite:setStyle(style)
	---@cast self GNUI.Sprite
	if style then
		if self.style == style then return end
		self.style = style
	end
	self:applyAll(style)
	if self.box then
		self.box:recalculateMargin()
		self.box:recalculatePadding()
		self.box:recalculateMinimumSize()
		self.box:update()
	end
	return self
end


--TODO: make reactive and only apply when a property is changed
function Sprite:applyAll(style)
	self:setPos()
	self:setSize()
	self:setText()
	self:setPadding()
	
	self:setTextColor()
	if style then
		self:setPadding(style)
		self:setTextColor(style.textColor:unpack())
		self:setTextAlignment(style.textAlignment:unpack())
	end
end


return Sprite