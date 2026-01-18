---@diagnostic disable: param-type-mismatch
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Nineslice Module
/ /_/ / /|  /  desc: an extension of sprite which can display a texture
\____/_/ |_/ source: link ]]

local gncommon = require("lib.gncommon") ---@type GNCommon
local Style = require("../styles/nineslice") ---@type GNUI.Sprite.Nineslice.StyleAPI
local config = require("../../config") ---@type GNUI.config

local Sprite = require("./sprite") ---@type GNUI.Sprite
local Quad = require("./quad") ---@type GNUI.Sprite.Quad

---@class GNUI.Sprite.Nineslice : GNUI.Sprite.Quad
---@field style GNUI.Sprite.Nineslice.Style 
---
---@field idTopLeft integer
---@field idTop integer
---@field idTopRight integer
---
---@field idLeft integer
---@field idCenter integer
---@field idRight integer
---
---@field idBottomRight integer
---@field idBottom integer
---@field idBottomLeft integer
---
---@field ids integer[]
local Nineslice = {}
Nineslice.__index = function (t,i)
	return rawget(t,i) or Nineslice[i] or Quad[i] or Sprite[i]
end


function Nineslice.getIndex() return Nineslice.__index end


---A representation of a quad that will get drawn
---@param box GNUI.Box
---@return GNUI.Sprite.Nineslice
function Nineslice.new(box)
	assert(box,"no GNUI.Box given")
	local self = Sprite.new(box)
	---@cast self GNUI.Sprite.Nineslice
	
	self.idTopLeft = self.render:newVisualQuad()
	self.idTop = self.render:newVisualQuad()
	self.idTopRight = self.render:newVisualQuad()
	
	self.idLeft = self.render:newVisualQuad()
	self.idCenter = self.render:newVisualQuad()
	self.idRight = self.render:newVisualQuad()
	
	self.idBottomRight = self.render:newVisualQuad()
	self.idBottom = self.render:newVisualQuad()
	self.idBottomLeft = self.render:newVisualQuad()
	
	self.ids = {
		self.idTopLeft,
		self.idTop,
		self.idTopRight,
		
		self.idLeft,
		self.idCenter,
		self.idRight,
		
		self.idBottomLeft,
		self.idBottom,
		self.idBottomRight,
	}
	
	setmetatable(self, Nineslice)
	self:setBox(box)
	return self
end


Style.setInstancer(Nineslice.new)
---@return GNUI.Sprite.Nineslice.Style
function Nineslice.newStyle()
	return Style.new()
end


--────────────────────────-< API >-────────────────────────--

---@overload fun(self: GNUI.Sprite.Nineslice)
---@param x number
---@param y number
function Nineslice:setPos(x,y)
	if x then
		local pos = gncommon.vec2(x,y)
		if self.pos == pos then return end
		self.pos = pos
		self:applyDimensions()
	end
end


---@overload fun(self: GNUI.Sprite.Nineslice)
---@param x number
---@param y number
function Nineslice:setSize(x,y)
	if x then
		local size = vec(x,y)
		if size == self.size then return end
		self.size = size
		self:applyDimensions()
	end
	return self
end


function Nineslice:applyDimensions()
	local border = self.style and self.style.border or vec(0,0,0,0)
	local expand = self.style and self.style.expand or vec(0,0,0,0)
	local size = self.size + expand.xy + expand.zw
	local pos = self.pos - expand.xy
	
	self.render:setSize(self.id,      size.x, size.y)
	
	self.render:setSize(self.idTopLeft,  border.x, border.y)
	self.render:setSize(self.idTop,      size.x-border.x-border.z, border.y)
	self.render:setSize(self.idTopRight, border.z, border.y)
	
	self.render:setSize(self.idLeft,  border.x, size.y-border.y-border.w)
	self.render:setSize(self.idCenter,      size.x-border.x-border.z, size.y-border.y-border.w)
	self.render:setSize(self.idRight, border.z, size.y-border.y-border.w)
	
	self.render:setSize(self.idBottomLeft,  border.x, border.w)
	self.render:setSize(self.idBottom,      size.x-border.x-border.z, border.w)
	self.render:setSize(self.idBottomRight, border.z, border.w)
	
	self.render:setPos(self.id,  self.pos.x,self.pos.y)
	
	self.render:setPos(self.idTopLeft,  pos.x, pos.y)
	self.render:setPos(self.idTop,      pos.x+border.x, pos.y)
	self.render:setPos(self.idTopRight, pos.x+size.x-border.z, pos.y)
	
	self.render:setPos(self.idLeft,  pos.x, pos.y+border.y)
	self.render:setPos(self.idCenter,      pos.x+border.x, pos.y+border.y)
	self.render:setPos(self.idRight, pos.x+size.x-border.z, pos.y+border.y)
	
	self.render:setPos(self.idBottomLeft,  pos.x, pos.y+size.y-border.w)
	self.render:setPos(self.idBottom,      pos.x+border.x,pos.y+size.y-border.w)
	self.render:setPos(self.idBottomRight, pos.x+size.x-border.z,pos.y+size.y-border.w)
end


---@overload fun(self: GNUI.Sprite.Nineslice)
---@param path string
function Nineslice:setTexture(path)
	---@cast self GNUI.Sprite.Nineslice
	if path then
		if self.texturePath == path then return end
		self.texturePath = path
	end
	if self.texturePath then
		self.render:setTexture(self.idTopLeft,self.texturePath)
		self.render:setTexture(self.idTop,self.texturePath)
		self.render:setTexture(self.idTopRight,self.texturePath)
		
		self.render:setTexture(self.idLeft,self.texturePath)
		self.render:setTexture(self.idCenter,self.texturePath)
		self.render:setTexture(self.idRight,self.texturePath)
		
		self.render:setTexture(self.idBottomLeft,self.texturePath)
		self.render:setTexture(self.idBottom,self.texturePath)
		self.render:setTexture(self.idBottomRight,self.texturePath)
	end
end


function Nineslice:setUV(u1,v1,u2,v2)
	if u1 then
		local uv = vec(u1,v1,u2,v2)
		if uv == self.uv then return end
		uv = uv:copy():add(0,0,1,1)
		self.uv = uv
	end
	if self.uv then
		local uv = self.uv
		local border = self.style and self.style.border or vec(0,0,0,0)
		self.render:setUV(self.idTopLeft,  uv.x,             uv.y,      uv.x+border.x,       uv.y+border.y)
		self.render:setUV(self.idTop,      uv.x+border.x,    uv.y,      uv.z-border.z,       uv.y+border.y)
		self.render:setUV(self.idTopRight, uv.z-border.z,    uv.y,      uv.z,                uv.y+border.y)
		
		self.render:setUV(self.idLeft,  uv.x,                uv.y+border.y,       uv.x+border.x,   uv.w-border.w)
		self.render:setUV(self.idCenter,      uv.x+border.x, uv.y+border.y,       uv.z-border.z,   uv.w-border.w)
		self.render:setUV(self.idRight, uv.z-border.z,       uv.y+border.y,       uv.z,            uv.w-border.w)
		
		self.render:setUV(self.idBottomLeft,  uv.x,          uv.w-border.w, uv.x+border.x, uv.w)
		self.render:setUV(self.idBottom,      uv.x+border.x, uv.w-border.w, uv.z-border.z, uv.w)
		self.render:setUV(self.idBottomRight, uv.z-border.z, uv.w-border.w, uv.z, uv.w)
	end
end


---@overload fun(self: GNUI.Sprite.Quad)
---@param r number
---@param g number
---@param b number
---@return GNUI.Sprite.Quad
function Nineslice:setBoxColor(r,g,b)
	if r then
		local color = vec(r,g,b)
		if self.style then color = color * self.style.color end
		if self.color == color then return end
		self.color = color
	end
	if self.color then
		for index, id in ipairs(self.ids) do
			self.render:setBoxColor(id,self.color.x,self.color.y,self.color.z)
		end
	end
end


---@param style GNUI.Sprite.Quad.Style
function Nineslice:applyAll(style)
	if style then
		self:setTexture(style.texturePath)
		self:setUV(style.uv:unpack())
		self:setBoxColor(style.color:unpack())
		self:setTextColor(style.textColor:unpack())
		self:setPadding(style.padding:unpack())
	end
	self:setText()
	self:setPos()
	self:setSize()
	self:applyDimensions()
	self:setPadding()
end


---@overload fun(self: GNUI.Sprite.Nineslice)
---@param style GNUI.Sprite.Nineslice.Style
function Nineslice:setStyle(style)
	---@cast self GNUI.Sprite.Nineslice
	if style then
		if self.style == style then return end
		self.style = style
	end
	self:applyAll(self.style)
	return self
end


---@param spriteID integer
---@param index integer
function Nineslice:setParent(spriteID,index)
	assert(spriteID,"no spriteID given")
	
	self.render:setParent(self.idTopLeft,spriteID,index)
	self.render:setParent(self.idTop,spriteID,index)
	self.render:setParent(self.idTopRight,spriteID,index)
	
	self.render:setParent(self.idLeft,spriteID,index)
	self.render:setParent(self.idCenter,spriteID,index)
	self.render:setParent(self.idRight,spriteID,index)
	
	self.render:setParent(self.idBottomLeft,spriteID,index)
	self.render:setParent(self.idBottom,spriteID,index)
	self.render:setParent(self.idBottomRight,spriteID,index)
	
	self.render:setParent(self.id,spriteID,index)
end


return Nineslice