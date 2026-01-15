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
		default="glass",
		opaque={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(40,1,42,3)
			:setBorder(1,1,1,1)
			:setPadding(2,2,2,2)
			--:setMargin(5,5,5,5)
			,
		},
		glass={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(40,5,42,7)
			:setBorder(1,1,1,1)
			:setPadding(2,2,2,2)
			--:setMargin(5,5,5,5)
			,
		},
		header={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(52,11,54,13)
			:setBorder(1,1,1,1)
			:setPadding(2,2,2,2)
			--:setMargin(5,5,5,5)
			,
		},
		ribbon={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(52,5,54,9)
			:setBorder(0,0,0,2)
			:setPadding(1,1,3,1)
			--:setMargin(5,5,5,5)
			,
		}
	},
	button={
		default="secondary",
		green="primary",
		
		primary={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(15,0,19,6)
			:setBorder(2,2,2,4)
			:setPadding(2,2,2,4)
			:setTextColor("#ffffff")
			,
			pressed = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(14,17,20,23)
			:setBorder(3,3,3,3)
			:setPadding(2,2,2,2)
			:setMargin(0,2,0,0)
			:setExpand(1,1,1,1)
			:setTextColor(1,1,1)
			,
			hovered = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(14,8,20,16)
			:setBorder(3,3,3,5)
			:setPadding(2,2,2,4)
			:setExpand(1,1,1,1)
			:setTextColor("#ffffff")
			,
		},
		white="secondary",
		secondary={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(8,0,12,6)
			:setBorder(2,2,2,4)
			:setPadding(2,2,2,4)
			:setTextColor("#1b1b1b")
			,
			pressed = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(7,17,13,23)
			:setBorder(3,3,3,3)
			:setPadding(2,2,2,2)
			:setMargin(0,2,0,0)
			:setExpand(1,1,1,1)
			:setTextColor(0,0,0)
			,
			hovered = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(7,8,13,16)
			:setBorder(3,3,3,5)
			:setPadding(2,2,2,4)
			:setExpand(1,1,1,1)
			:setTextColor("#1b1b1b")
			,
		},
		dark="tertiary",
		tertiary={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(1,0,5,6)
			:setBorder(2,2,2,4)
			:setPadding(2,2,2,4)
			:setTextColor("#ffffff")
			,
			pressed = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(0,17,6,23)
			:setBorder(3,3,3,3)
			:setPadding(2,2,2,2)
			:setMargin(0,2,0,0)
			:setExpand(1,1,1,1)
			:setTextColor(0,0,0)
			:setTextColor("#ffffff")
			,
			hovered = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(0,8,6,16)
			:setBorder(3,3,3,5)
			:setPadding(2,2,2,4)
			:setExpand(1,1,1,1)
			:setTextColor("#ffffff")
			,
		},
		red="destructive",
		destructive={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(22,0,26,6)
			:setBorder(2,2,2,4)
			:setPadding(2,2,2,4)
			:setTextColor("#1b1b1b")
			:setTextColor("#ffffff")
			,
			pressed = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(21,17,27,23)
			:setBorder(3,3,3,3)
			:setPadding(2,2,2,2)
			:setMargin(0,2,0,0)
			:setExpand(1,1,1,1)
			:setTextColor(0,0,0)
			:setTextColor("#ffffff")
			,
			hovered = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(21,8,27,16)
			:setBorder(3,3,3,5)
			:setPadding(2,2,2,4)
			:setExpand(1,1,1,1)
			:setTextColor("#ffffff")
			,
		},
		blue={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(29,0,33,6)
			:setBorder(2,2,2,4)
			:setPadding(2,2,2,4)
			:setTextColor("#1b1b1b")
			:setTextColor("#ffffff")
			,
			pressed = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(28,17,34,23)
			:setBorder(3,3,3,3)
			:setPadding(2,2,2,2)
			:setExpand(1,1,1,1)
			:setMargin(0,2,0,0)
			:setTextColor(0,0,0)
			:setTextColor("#ffffff")
			,
			hovered = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(28,8,34,16)
			:setBorder(3,3,3,5)
			:setPadding(2,2,2,4)
			:setExpand(1,1,1,1)
			:setTextColor("#ffffff")
			,
		},
		bevel={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(36,1,38,3)
			:setBorder(1,1,1,1)
			:setPadding(1,1,1,1)
			:setTextColor("#ffffff")
			,
			pressed = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(36,9,38,11)
			:setBorder(1,1,1,1)
			:setPadding(1,1,1,1)
			:setTextColor("#ffffff")
			,
			hovered = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(36,5,38,7)
			:setBorder(1,1,1,1)
			:setPadding(1,1,1,1)
			:setTextColor("#ffffff")
			,
		},
	}
}