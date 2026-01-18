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
---@field childIndex integer
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
---@field render GNUI.RenderInstance
---@field id integer?
local Sprite = {}
Sprite.__index = Sprite


---@param box GNUI.Box
---@return GNUI.Sprite
function Sprite.new(box)
	assert(box,"no GNUI.Box given")
	
	local self = {
		pos = vec(0,0),
		size = vec(0,0),
		padding = vec(0,0,0,0),

		childIndex = 1,
		
		textColor = vec(1,1,1),
		textAlignment = vec(0,0),
		
		boxColor = vec(1,1,1),
		flagApply = false,
		
		render = box.canvas.render,
		id = box.canvas.render:newVisualQuad()
	}
	
	setmetatable(self, Sprite)
	box:setSprite(self)
	return self
end


SpriteStyle.setInstancer(Sprite.new)
---@return GNUI.Sprite.Style
function Sprite.newStyle()
	return SpriteStyle.new()
end


--────────────────────────-< API >-────────────────────────--

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
	
	self.render:setPos(self.id, self.pos.x,self.pos.y)
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
	self.render:setSize(self.id, self.size.x, self.size.y)
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
	self.render:setText(self.id,text)
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
		self.render:setTextColor(self.id,self.textColor.x,self.textColor.y,self.textColor.z)
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
	self.render:setPadding(self.id, self.padding.x, self.padding.y, self.padding.z, self.padding.w)
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
		self.render:setTextAlignment(self.id, self.textAlignment.x, self.textAlignment.y)
	end
	return self
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


---@param box GNUI.Box
---@generic self
---@param self self
---@return self
function Sprite:setBox(box)
	---@cast self GNUI.Sprite
	self.box = box
	if self.box then
		self:applyAll()
	end
	return self
end


---@param id integer
---@param index integer
function Sprite:setParent(id,index)
	if self.childIndex ~= index or self.parentID ~= id then
		self.childIndex = index
		self.parentID = id
		self.render:setParent(self.id,id,index)
	end
end

return Sprite