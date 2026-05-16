---@diagnostic disable: duplicate-doc-field
local BASE = (...):match(".+[./]GNUI"):gsub("/",".")
local cfg = require(BASE..".config") ---@type GNUI.config

local SpriteStyle = require(BASE..".shared.theme.styles.sprite") ---@type GNUI.Sprite.StyleAPI
local QuadStyle = require(BASE..".shared.theme.styles.quad") ---@type GNUI.Sprite.Quad.StyleAPI
local gncommon = require(cfg.GN_COMMON) ---@type GNCommon
local util = require(BASE..".utils") ---@type GNUI.utils
local cfg = require(BASE..".config") ---@type GNUI.config
local Theme = require(cfg.THEME..".theme") ---@type GNUI.ThemeAPI

---@class GNUI.Sprite.Nineslice.StyleAPI
local NinesliceStyleAPI = {}


---@class GNUI.StyleEntry
---@field type "nineslice"
---@field padding Vector4?
---@field expand Vector4?
---@field textColor Vector3|string?
---@field textAlignment Vector2?
---@field margin Vector4?
---@field texturePath string?
---@field color Vector3|string?
---@field uv Vector4?
---@field border Vector4?
---@field childGap number?


Theme._registerImporter("nineslice",function (style)
	local nine = NinesliceStyleAPI.new()
	nine.padding = style.padding or nine.padding
	nine.expand = style.expand or nine.expand
	nine.textAlignment = style.textAlignment or nine.textAlignment
	nine.margin = style.margin or nine.margin
	nine.texturePath = style.texturePath or nine.texturePath
	nine.color = style.color and gncommon.color(style.color).xyz or nine.color
	nine.textColor = style.textColor and gncommon.color(style.textColor).xyz or nine.textColor
	nine.uv = style.uv or nine.uv
	nine.minSize = style.minSize or nine.minSize
	
	-- default layout
	nine.childGap = style.childGap or nine.childGap
	
	nine.border = style.border
	
	return nine
end)


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
	self.minSize = vec(0,0)
	setmetatable(self,NinesliceStyle)
	return self
end


local newInstance

function NinesliceStyleAPI.setInstancer(new)
	newInstance = new
end


---@param box GNUI.Box
---@param layer (integer)?
---@return GNUI.Sprite
function NinesliceStyle:newInstance(box,layer)
	local instance = newInstance(box,layer):setStyle(self)
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
