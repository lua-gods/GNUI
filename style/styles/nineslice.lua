local BASE = (...):match(".+[./]GNUI"):gsub("/",".")
local config = require(BASE..".config") ---@type GNUI.config

local SpriteStyle = require(BASE..".style.styles.sprite") ---@type GNUI.Sprite.StyleAPI
local QuadStyle = require(BASE..".style.styles.quad") ---@type GNUI.Sprite.Quad.StyleAPI
local gncommon = require(config.GN_COMMON) ---@type GNCommon
local util = require(BASE..".utils") ---@type GNUI.utils


---@class GNUI.Sprite.Nineslice.StyleAPI
local NinesliceStyleAPI = {}


---@class GNUI.Sprite.Nineslice.Style : GNUI.Sprite.Quad.Style
---@field border Vector4
local NinesliceStyle = {}
NinesliceStyle.__index = function (t,i)
	return rawget(t,i) or NinesliceStyle[i] or QuadStyle.index(i) or SpriteStyle.index(i)
end


function NinesliceStyleAPI.index(i)
	return NinesliceStyle[i]
end


---@return GNUI.Sprite.Nineslice.Style
function NinesliceStyleAPI.new()
	local self = QuadStyle.new()
	---@cast self GNUI.Sprite.Nineslice.Style
	self.texturePath = ""
	self.uv = vec(0,0,0,0)
	self.border = vec(0,0,0,0)
	setmetatable(self,NinesliceStyle)
	return self
end


local newInstance

function NinesliceStyleAPI.setInstancer(new)
	newInstance = new
end


---@param box GNUI.Box
---@param slot (integer|string)?
---@return GNUI.Sprite
function NinesliceStyle:newInstance(box,slot)
	local instance = newInstance(box,slot):setStyle(self)
	return instance
end


--────────────────────────-< API >-────────────────────────--


---@generic self
---@param self self
---@return self
function NinesliceStyle:setTexture(path)
	---@cast self GNUI.Sprite.Nineslice.Style
	self.texturePath = path
	self.uv = vec(0,0,1,1)
	return self
end


---@overload fun(self: GNUI.Sprite.Nineslice.Style, xy1: Vector2, xy2: Vector2): self
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@generic self
---@param self self
---@return self
function NinesliceStyle:setUV(x1,y1,x2,y2)
	---@cast self GNUI.Sprite.Nineslice.Style
	self.uv = gncommon.vec4(x1,y1,x2,y2)
	return self
end


---@overload fun(self: GNUI.Sprite.Nineslice.Style, leftTop: Vector2, rightBottom: Vector2): self
---@param left number
---@param top number
---@param right number
---@param bottom number
---@generic self
---@param self self
---@return self
function NinesliceStyle:setBorder(left,top,right,bottom)
	---@cast self GNUI.Sprite.Nineslice.Style
	self.border = gncommon.vec4(left,top,right,bottom)
	return self
end


return NinesliceStyleAPI
