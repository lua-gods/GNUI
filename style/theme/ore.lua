local Sprite = require("../sprites/sprite") ---@type GNUI.Sprite
local Quad = require("../sprites/quad") ---@type GNUI.Sprite.Quad
local Nineslice = require("../sprites/nineslice") ---@type GNUI.Sprite.Nineslice


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
			:setPadding(1,1,1,1)
			--:setMargin(5,5,5,5)
			,
		},
		glass={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(40,5,42,7)
			:setBorder(1,1,1,1)
			:setPadding(1,1,1,1)
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
		},
		highlight={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(26,9,28,11)
			:setBorder(1,1,1,1)
			:setExpand(1,1,1,1)
			,
		}
	},
	
	
	button={
		default="secondary",
		green="primary",
		
		primary={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(10,0,14,6)
			
			:setBorder(2,2,2,4)
			:setPadding(6,6,6,4)
			:setExpand(0,0,0,2)
			:setMargin(0,-2,0,2)
			
			:setTextAlignment(0,0)
			:setTextColor("#ffffff")
			,
			pressed = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(10,7,14,11)
			
			:setBorder(2,2,2,2)
			:setPadding(6,6,6,4)
			:setMargin(0,0,0,0)
			
			:setTextAlignment(0,0)
			:setTextColor("#ffffff")
			,
		},
		white="secondary",
		secondary={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(5,0,9,6)
			
			:setBorder(2,2,2,4)
			:setPadding(6,6,6,4)
			:setExpand(0,0,0,2)
			:setMargin(0,-2,0,2)
			
			:setTextAlignment(0,0)
			:setTextColor("#1b1b1b")
			,
			pressed = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(5,7,9,11)
			
			:setBorder(2,2,2,2)
			:setPadding(6,6,6,4)
			
			:setTextAlignment(0,0)
			:setTextColor("#1b1b1b")
			,
		},
		bevel={
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(36,1,38,3)
			
			:setBorder(1,1,1,1)
			:setPadding(3,3,3,3)
			
			:setTextAlignment(0,0)
			:setTextColor("#ffffff")
			,
			pressed = Quad.newStyle()
			:setTexture(atlas)
			:setUV(36,11,38,13)
			:setPadding(3,3,3,3)
			
			:setTextAlignment(0,0)
			:setTextColor("#ffffff")
			,
		},
		flat={
			normal = Quad.newStyle()
			:setTexture(atlas)
			:setUV(7,32,7,32)
			:setTextColor("#ffffff")
			,
			pressedHovered = Quad.newStyle()
			:setTexture(atlas)
			:setUV(7,34,7,34)
			:setTextColor("#ffffff")
			,
			hovered = Quad.newStyle()
			:setTexture(atlas)
			:setUV(7,32,7,32)
			:setTextColor("#1b1b1b")
			,
			pressed = Quad.newStyle()
			:setTexture(atlas)
			:setUV(7,32,7,32)
			:setTextColor("#1b1b1b")
			,
		},
	},
	textField={
		default={
			colorHighlight="#00ff00",
			normal = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(1,32,5,36)
			
			:setBorder(1,3,1,1)
			:setPadding(2,2,2,2)
			
			:setTextAlignment(-1,0)
			:setTextColor("#ffffff")
			,
			hovered = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(0,38,6,44)
			
			:setBorder(2,4,2,2)
			:setPadding(2,2,2,2)
			:setExpand(1,1,1,1)
			
			:setTextAlignment(-1,0)
			:setTextColor("#ffffff")
			,
			active = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(0,38,6,44)
			
			:setBorder(2,4,2,2)
			:setPadding(2,2,2,2)
			:setExpand(1,1,1,1)
			
			:setTextAlignment(-1,0)
			:setTextColor("#ffffff")
			,
			invalid = Nineslice.newStyle()
			:setTexture(atlas)
			:setUV(0,45,6,51)
			
			:setBorder(2,4,2,2)
			:setPadding(2,2,2,2)
			:setExpand(1,1,1,1)
			
			:setTextAlignment(-1,0)
			:setTextColor("#ffffff")
			,
		}
	}
}