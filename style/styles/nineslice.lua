local SpriteStyle = require("../styles/sprite") ---@type GNUI.Sprite.StyleAPI
local QuadStyle = require("../styles/quad") ---@type GNUI.Sprite.Quad.StyleAPI
local gncommon = require("lib.gncommon") ---@type GNCommon
local util = require("../../utils") ---@type GNUI.utils


---@class GNUI.Sprite.Nineslice.StyleAPI
local NinesliceStyleAPI = {}


---@class GNUI.Sprite.Nineslice.Style : GNUI.Sprite.Style
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
	local self = SpriteStyle.new()
	---@cast self GNUI.Sprite.Nineslice.Style
	self.texture_path = ""
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
---@return GNUI.Sprite
function NinesliceStyle:newInstance(box)
	local instance = newInstance(box):setStyle(self)
	return instance
end


--────────────────────────-< API >-────────────────────────--


---@generic self
---@param self self
---@return self
function NinesliceStyle:setTexture(path)
	---@cast self GNUI.Sprite.Nineslice.Style
	self.texture_path = path
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
