---@diagnostic disable: undefined-doc-name, undefined-field
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: 
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]

--[[ Layout --------
├─Class
│ ├─Default
│ └─AnotherVariant
└─Class
  ├─Default
  ├─Variant
  └─MoreVariant
-------------------]]
---GNUI.Button        ->    Button
---GNUI.Button.Slider ->    Slider

local GNUI = require "../../main" ---@type GNUIAPI
local atlas = textures[(...):gsub("/",".") ..".gnuitheme"] ---@type Texture

---@type GNUI.Theme
local theme = {}

--[────────────────────────────────────────-< Box >-────────────────────────────────────────]--
theme.Box = {
	default = nil,
	background = {backdrop = GNUI.newSprite(atlas,1,17,3,19 ,1,1,1,1)},
	solid = {backdrop = GNUI.newSprite(atlas,1,21,3,23)},
	group = {
		backdrop = GNUI.newSprite(atlas,48,16,54,22, 3,3,3,3, -3, -3, -3, -3)
		:setPadding(7,12,7,7)
		:setTextOffset(8,1)
		:setTextEffect("OUTLINE"),
	}
}
--[────────────────────────────────────────-< Button >-────────────────────────────────────────]--
theme.Button = {
	default = {
		normal = GNUI.newSprite(atlas, 23,2,27,7 ,2,2,2,3, 2)
		:setTextAlign(0.5,0.5)
		:setDefaultTextColor("#000000")
		:setChildrenOffset(0,-2),
		pressed= GNUI.newSprite(atlas,17,9,21,13 ,2,2,2,2)
		:setTextAlign(0.5,0.5)
		:setDefaultTextColor("#000000")
		:setTextOffset(0,2),
		hovered=GNUI.newSprite(atlas, 17,1,21,7 ,2,2,2,4, 2)
		:setTextAlign(0.5,0.5)
		:setDefaultTextColor("#000000")
		:setChildrenOffset(0,-2),
	},
}
--[────────────────────────────────────────-< Spider >-────────────────────────────────────────]--
theme.Slider = {
	default = {
		shaft = GNUI.newSprite(atlas,33,24,35,26, 1,1,1,1),
		thumb = GNUI.newSprite(atlas,39,17,43,22 ,2,2,2,3, 2),
		thumbHover = GNUI.newSprite(atlas,33,17,37,22 ,2,2,2,3, 2),
		thumbPressed = GNUI.newSprite(atlas,39,24,43,28 ,2,2,2,2),
		number = GNUI.newSprite(atlas,0,0,0,0)
		:setTextAlign(0.5,0.5)
		:setTextEffect("OUTLINE"),
	},
}
--[────────────────────────────────────────-< Text Field >-────────────────────────────────────────]--
theme.TextField = {
	default = {
		normal = GNUI.newSprite(atlas,17,17,19,20, 1,2,1,1)
		:setTextMargin(2,2,2,2),
		pressed = GNUI.newSprite(atlas,17,17,19,20, 1,2,1,1)
		:setTextMargin(2,2,2,2),
	}
}
--[────────────────────────────────────────-< Pane Stack >-────────────────────────────────────────]--
theme.Stack = {
	default = {},
	group = {
		backdrop = GNUI.newSprite(atlas,48,16,54,22, 3,3,3,3, -3, -3, -3, -3)
		:setPadding(7,12,7,7),
		spacing = 2
	}
}

return theme