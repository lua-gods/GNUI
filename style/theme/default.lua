local Sprite = require("../sprites/sprite") ---@type GNUI.SpriteAPI
local Quad = require("../sprites/quad") ---@type GNUI.Sprite.QuadAPI
local Nineslice = require("../sprites/nineslice") ---@type GNUI.Sprite.NinesliceAPI


local atlas = nil ---@type string
if figuraMetatables then -- is Figura lmao
	atlas = (...):gsub("/",".") ..".ore"
end


---@type GNUI.Theme
return {
	box={
		default={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(59,0,61,2)
			:setBorder(1,1,1,1)
			:setPadding(2,2,2,2)
			--:setMargin(5,5,5,5)
			,
		}
	},
	button={
		default={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(7,0,11,6)
			:setBorder(2,2,2,4)
			:setPadding(2,2,2,4)
			:setTextColor("#1b1b1b")
			,
			pressed = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(7,26,11,30)
			:setBorder(2,2,2,2)
			:setPadding(2,2,2,2)
			:setMargin(0,2,0,0)
			:setTextColor(0,0,0)
			,
		}
	}
}