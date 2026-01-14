--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Sprite Module
/ /_/ / /|  /  desc: base class for all sprites
\____/_/ |_/ source: link ]]


local SpriteStyle = require("../styles/sprite") ---@type GNUI.Sprite.StyleAPI
local gncommon = require("lib.gncommon") ---@type GNCommon


---@class GNUI.SpriteAPI
local SpriteAPI = {}


---A base class for all sprites for boxes
---@class GNUI.Sprite
---@field style GNUI.Sprite.Style
---@field box GNUI.Box?
---@field childIndex integer
---@field parentID integer
---
---@field pos Vector2
---@field size Vector2
---
---@field render GNUI.RenderInstance
---@field id integer?
local Sprite = {}
Sprite.__index = Sprite


function SpriteAPI.index(i)
	return Sprite[i]
end


---@param box GNUI.Box
---@return GNUI.Sprite
function SpriteAPI.new(box)
	assert(box,"no GNUI.Box given")
	
	local self = {
		pos = vec(0,0),
		size = vec(0,0),
		padding = vec(0,0,0,0),
		margin = vec(0,0,0,0),
		childIndex = 1,
		
		boxColor = vec(1,1,1),
		
		render = box.canvas.render,
		id = box.canvas.render:newVisualQuad()
	}
	
	setmetatable(self, Sprite)
	box:setSprite(self)
	return self
end


SpriteStyle.setInstancer(SpriteAPI.new)
---@return GNUI.Sprite.Style
function SpriteAPI.newStyle()
	return SpriteStyle.new()
end


--────────────────────────-< API >-────────────────────────--

---@overload fun(self: GNUI.Sprite, xy: Vector2): self
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Sprite:setPos(x,y)
	---@cast self GNUI.Sprite
	self.pos = gncommon.vec2(x,y)
	local expand = self.style and self.style.expand.xy or vec(0,0)
	self.render:setPos(self.id, self.pos.x - expand.x, self.pos.y - expand.y)
	return self
end


---@overload fun(self: GNUI.Sprite, xy: Vector2): self
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Sprite:setSize(x,y)
	---@cast self GNUI.Sprite
	self.size = gncommon.vec2(x,y)
	local expand = self.style and (self.style.expand.xy + self.style.expand.zw) or vec(0,0)
	---@cast expand Vector2
	self.render:setSize(self.id, self.size.x+expand.x, self.size.y+expand.y)
	return self
end


---@generic self
---@param self self
---@return self
---@param text string
function Sprite:setText(text)
	---@cast self GNUI.Sprite
	self.render:setText(self.id,text)
	return self
end


---@overload fun(self: GNUI.Sprite ,leftTopRightBottom: Vector4): GNUI.Sprite
---@param left number
---@param top number
---@param right number
---@param bottom number
---@return GNUI.Sprite
function Sprite:setPadding(left,top,right,bottom)
	---@cast self GNUI.Sprite
	self.padding = gncommon.vec4(left,top,right,bottom)
	self.render:setPadding(self.id, self.padding.x, self.padding.y, self.padding.z, self.padding.w)
	return self
	
end


---Applies the given style to this sprite,
---@param style GNUI.Sprite.Style
---@generic self
---@param self self
---@return self
function Sprite:setStyle(style)
	---@cast self GNUI.Sprite
	
	if self.style ~= style then
		self.style = style
		self:applyStyle()
	end
	return self
end


function Sprite:applyStyle()
	self:setStyle(self.style)
	if self.box then
		self:setText(self.box.text)
		self:setPos(self.box.pos)
		self:setSize(self.box.size)
		self.render:setPadding(self.id, self.box.padding.x, self.box.padding.y, self.box.padding.z, self.box.padding.w)
	else
		self:setText("")
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
		self:setPadding(box:getPadding())
		self:applyStyle()
	end
	return self
end


---@param id integer
---@param index integer
function Sprite:setParent(id,index)
	self.childIndex = index
	self.parentID = id
	self.render:setParent(self.id,id,index)
end

return SpriteAPI