local BASE = (...):match(".+[./]GNUI"):gsub("/",".")
local config = require(BASE..".config") ---@type GNUI.config

local SpriteStyle = require(BASE..".style.styles.sprite") ---@type GNUI.Sprite.StyleAPI
local gncommon = require(config.GN_COMMON) ---@type GNCommon
local util = require(BASE..".utils") ---@type GNUI.utils


---@class GNUI.Sprite.Quad.StyleAPI
local QuadStyleAPI = {}


---@class GNUI.Sprite.Quad.Style : GNUI.Sprite.Style
---@field texturePath string
---@field color Vector3
---@field textColor Vector3
---@field uv Vector4
local QuadStyle = {}
QuadStyle.__index = function (t,i)
	return rawget(t,i) or QuadStyle[i] or SpriteStyle.index(i)
end


function QuadStyleAPI.index(i)
	return QuadStyle[i]
end


---@return GNUI.Sprite.Quad.Style
function QuadStyleAPI.new()
	local self = SpriteStyle.new()
	---@cast self GNUI.Sprite.Quad.Style
	self.texturePath = ""
	self.uv = gncommon.vec4(0,0,0,0)
	self.color = vec(1,1,1)
	self.textColor = vec(1,1,1)
	setmetatable(self,QuadStyle)
	return self
end


local newInstance

---@param new any
function QuadStyleAPI.setInstancer(new)
	newInstance = new
end


---@param box GNUI.Box
---@param slot (integer|string)?
---@return GNUI.Sprite
function QuadStyle:newInstance(box,slot)
	local instance = newInstance(box,slot):setStyle(self)
	return instance
end


--────────────────────────-< API >-────────────────────────--


---@generic self
---@param self self
---@return self
function QuadStyle:setTexture(path)
	---@cast self GNUI.Sprite.Quad.Style
	self.texturePath = path
	if path then
		local size = util.getTextureSize(path)
		self.uv = vec(0,0,size.x,size.y)
	end
	return self
end


---@overload fun(self: GNUI.Sprite.Quad.Style, uv1: Vector2, uv2: Vector2): self
---@param u1 number
---@param v1 number
---@param u2 number
---@param v2 number
---@generic self
---@param self self
---@return self
function QuadStyle:setUV(u1,v1,u2,v2)
	---@cast self GNUI.Sprite.Quad.Style
	self.uv = gncommon.vec4(u1,v1,u2,v2)
	return self
end


---@overload fun(self: self, rgb: Vector3): self
---@param r number
---@param g number
---@param b number
---@return GNUI.Sprite.Quad.Style
function QuadStyle:setColor(r,g,b)
	self.color = gncommon.vec3(r,g,b)
	return self
end


return QuadStyleAPI
