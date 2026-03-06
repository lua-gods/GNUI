---@diagnostic disable: duplicate-doc-field
local BASE = (...):match(".+[./]GNUI"):gsub("/",".")
local utils = require("lib.gncommon") ---@type GNCommon
local gncommon = require("lib.gncommon") ---@type GNCommon
local paths = require(BASE..".paths") ---@type GNUI.config
local Theme = require(paths.THEME..".theme") ---@type GNUI.ThemeAPI


---@class GNUI.Sprite.StyleAPI
local SpriteSTyleAPI = {}


---@class GNUI.StyleEntry
---@field type "sprite"
---@field padding Vector4?
---@field expand Vector4?
---@field textColor Vector3|string?
---@field textAlignment Vector2?
---@field margin Vector4?

Theme._registerImporter("sprite",function (style)
	local sprite = SpriteSTyleAPI.new()
	
	sprite.padding = style.padding or sprite.padding
	sprite.expand = style.expand or sprite.expand
	sprite.textColor = style.textColor and gncommon.color(style.textColor).xyz or sprite.textColor
	sprite.textAlignment = style.textAlignment or sprite.textAlignment
	sprite.margin = style.margin or sprite.margin
	
	return sprite
end)

---@class GNUI.Sprite.Style
---@field padding Vector4
---@field expand Vector4
---@field textColor Vector3
---@field textAlignment Vector2
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
---@param slot (integer|string)?
---@return GNUI.Sprite
function SpriteStyle:newInstance(box,slot)
	return newInstance(box,slot):setStyle(self)
end


---@return GNUI.Sprite.Style
function SpriteSTyleAPI.new()
	local self = {
		padding = utils.vec4(0,0,0,0),
		expand = vec(0,0,0,0),
		margin = utils.vec4(0,0,0,0),
		textAlignment = vec(-1,-1),
	}
	setmetatable(self,SpriteStyle)
	return self
end


---@overload fun(self: self, leftTopRightBottom: Vector4): self
---@overload fun(self: self, leftTop: Vector2, rightBottom: Vector2): self
---@param left number
---@param top number
---@param right number
---@param bottom number
---@generic self
---@param self self
---@return self
function SpriteStyle:setExpand(left,top,right,bottom)
	---@cast self GNUI.Sprite.Quad.Style
	self.expand = gncommon.vec4(left,top,right,bottom)
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
	self.padding = utils.vec4(left,top,right,bottom)
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
	self.margin = utils.vec4(left,top,right,bottom)
	return self
end


---@param r number
---@param g number
---@param b number
---@generic self
---@param self self
---@return self
---@overload fun(self: self, hex: string): self
---@overload fun(self: self, rgb: Vector3): self
function SpriteStyle:setTextColor(r,g,b)
	---@cast self GNUI.Sprite.Style
	local t = type(r)
	if t == "string" then
		self.textColor = vectors.hexToRGB(r)
	else
		self.textColor = gncommon.vec3(r,g,b)
	end
	return self
end


---@param h (-1|0|1)?
---@param v (-1|0|1)?
---@generic self
---@param self self
---@return self
function SpriteStyle:setTextAlignment(h,v)
	---@cast self GNUI.Sprite.Style
	if h then self.textAlignment.x = h end
	if v then self.textAlignment.y = v end
	return self
end


return SpriteSTyleAPI