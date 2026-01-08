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
			normal = Quad.newStyle()
			:setTexture("avatar")
			--:setUV(1,0,6,7)
			,
		},
		test={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(1,0,6,7)
			:setBorder(2,2,2,4)
			:setPadding(5,5,5,7)
			--:setMargin(5,5,5,5)
			,
		}
	}
}