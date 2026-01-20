--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Quad Module
/ /_/ / /|  /  desc: an extension of sprite which can display a texture
\____/_/ |_/ source: link ]]

local Sprite = require("./sprite") ---@type GNUI.Sprite
local gncommon = require("lib.gncommon") ---@type GNCommon
local Style = require("../styles/quad") ---@type GNUI.Sprite.Quad.StyleAPI
local config = require("../../config") ---@type GNUI.config


---@class GNUI.Sprite.Quad : GNUI.Sprite
---@field style GNUI.Sprite.Quad.Style
---@field uv Vector4
---@field color Vector3
---@field texturePath string
---@
local Quad = {}
Quad.__index = function (t,i)
	return rawget(t,i) or Quad[i] or Sprite[i]
end


---A representation of a quad that will get drawn
---@param box GNUI.Box
---@return GNUI.Sprite.Quad
function Quad.new(box)
	assert(box,"no GNUI.Box given")
	local self = Sprite.new(box)
	---@cast self GNUI.Sprite.Quad
	
	self.id = self.render:newVisualQuad()
	
	setmetatable(self, Quad)
	return self
end


Style.setInstancer(Quad.new)
---@return GNUI.Sprite.Quad.Style
function Quad.newStyle()
	return Style.new()
end


--────────────────────────-< API >-────────────────────────--


---@overload fun(self: GNUI.Sprite.Quad)
---@param path string
function Quad:setTexture(path)
	---@cast self GNUI.Sprite.Quad
	if path then
		if self.texturePath == path then return end
		self.texturePath = path
	end
	
	self.render:setTexture(self.id,self.texturePath)
	return self
end


---@overload fun(self: GNUI.Sprite.Quad)
---@param r number
---@param g number
---@param b number
---@return GNUI.Sprite.Quad
function Quad:setBoxColor(r,g,b)
	if r then
		local color = vec(r,g,b)
		if self.style then color = color * self.style.color end
		if self.color == color then return end
		self.color = color
	end
	self.render:setBoxColor(self.id,self.color.x,self.color.y,self.color.z)

end


---@overload fun(self: GNUI.Sprite.Quad)
---@param u1 number
---@param v1 number
---@param u2 number
---@param v2 number
---@return GNUI.Sprite.Quad
function Quad:setUV(u1,v1,u2,v2)
	if u1 then
		local uv = vec(u1,v1,u2,v2)
		if self.uv == uv then return end
		self.uv = uv
	end
	self.render:setUV(self.id,self.uv.x,self.uv.y,self.uv.z,self.uv.w)
	return self
	
end


---@param style GNUI.Sprite.Quad.Style?
function Quad:applyAll(style)
	self:setText()
	self:setPos()
	self:setSize()
	
	self:setTexture(style and style.texturePath)
	self:setUV(style and style.uv:unpack())
	self:setBoxColor(style and style.color:unpack())
	self:setTextColor(style and style.textColor:unpack())
end


return Quad