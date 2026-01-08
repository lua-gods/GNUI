local SpriteStyle = require("../styles/sprite") ---@type GNUI.Sprite.StyleAPI
local gncommon = require("lib.gncommon") ---@type GNCommon
local util = require("../../utils") ---@type GNUI.utils


---@class GNUI.Sprite.Quad.StyleAPI
local QuadStyleAPI = {}


---@class GNUI.Sprite.Quad.Style : GNUI.Sprite.Style
---@field texture_path string
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
	self.texture_path = ""
	self.uv = gncommon.vec4(0,0,0,0)
	setmetatable(self,QuadStyle)
	return self
end


local newInstance

function QuadStyleAPI.setInstancer(new)
	newInstance = new
end


---@param box GNUI.Box
---@return GNUI.Sprite
function QuadStyle:newInstance(box)
	local instance = newInstance(box):setStyle(self)
	return instance
end


--────────────────────────-< API >-────────────────────────--


---@generic self
---@param self self
---@return self
function QuadStyle:setTexture(path)
	---@cast self GNUI.Sprite.Quad.Style
	self.texture_path = path
	local size = util.getTextSize(path)
	self.uv = vec(0,0,size.x,size.y)
	return self
end


---@overload fun(self: GNUI.Sprite.Quad.Style, xy1: Vector2, xy2: Vector2): self
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@generic self
---@param self self
---@return self
function QuadStyle:setUV(x1,y1,x2,y2)
	---@cast self GNUI.Sprite.Quad.Style
	self.uv = gncommon.vec4(x1,y1,x2,y2)
	return self
end





return QuadStyleAPI
