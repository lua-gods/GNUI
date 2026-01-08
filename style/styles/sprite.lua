local util = require("lib.gncommon") ---@type GNCommon

---@class GNUI.Sprite.StyleAPI
local SpriteSTyleAPI = {}

---@class GNUI.Sprite.Style
---@field padding Vector4
---@field margin Vector4
local SpriteStyle = {}
SpriteStyle.__index = SpriteStyle

local newInstance

function SpriteSTyleAPI.index(i)
	return SpriteStyle[i]
end


function SpriteSTyleAPI.setInstancer(new)
	newInstance = new
end


---@param box GNUI.Box
---@return GNUI.Sprite
function SpriteStyle:newInstance(box)
	return newInstance(box):setStyle(self)
end


---@return GNUI.Sprite.Style
function SpriteSTyleAPI.new()
	local self = {
		padding = util.vec4(0,0,0,0),
		margin = util.vec4(0,0,0,0)
	}
	setmetatable(self,SpriteStyle)
	return self
end


---@overload fun(self: GNUI.Sprite, ltrb: Vector4): self
---@overload fun(self: GNUI.Sprite, lt: Vector2, rb: Vector2): self
---@param left number
---@param top number
---@param right number
---@param bottom number
---@generic self
---@param self self
---@return self
function SpriteStyle:setPadding(left,top,right,bottom)
	---@cast self GNUI.Sprite
	self.padding = util.vec4(left,top,right,bottom)
	return self
end


---@overload fun(self: GNUI.Sprite, ltrb: Vector4): self
---@overload fun(self: GNUI.Sprite, lt: Vector2, rn: Vector2): self
---@param left number
---@param top number
---@param right number
---@param bottom number
---@generic self
---@param self self
---@return self
function SpriteStyle:setMargin(left,top,right,bottom)
	---@cast self GNUI.Sprite
	self.margin = util.vec4(left,top,right,bottom)
	return self
end


return SpriteSTyleAPI