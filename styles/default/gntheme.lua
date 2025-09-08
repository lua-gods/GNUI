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
	background = GNUI.newSprite(atlas,23,8,27,12 ,2,2,2,2),
	solid = GNUI.newSprite(atlas,2,12,2,12)
}
--[────────────────────────────────────────-< Button >-────────────────────────────────────────]--
theme.Button = {
	----@param box GNUI.Button
	--All = function (box)
	--	local spriteHover = GNUI.newSprite(atlas,19,1,25,7 ,3,3,3,3, 2,2,2,2)
	--	box.HoverBox:setNineslice(spriteHover):setAnchor(0,0,1,1):setCanCaptureCursor(false):setZMul(1.1)
	--	box.BUTTON_CHANGED:register(function (pressed,hovering)
	--		box.HoverBox:setVisible(hovering):setZMul(10)
	--	end,"GNUI.Hover")
	--	box.HoverBox:setVisible(false)
	--end,
	
	default = {
		normal = GNUI.newSprite(atlas, 23,1,27,7 ,2,2,2,4, 2)
		:setTextAlign(0.5,0.5)
		:setDefaultTextColor("#000000"),
		pressed= GNUI.newSprite(atlas,17,9,21,13 ,2,2,2,2)
		:setTextAlign(0.5,0.5)
		:setDefaultTextColor("#000000")
		:setTextOffset(0,2),
		hovered=GNUI.newSprite(atlas, 17,1,21,7 ,2,2,2,4, 2)
		:setTextAlign(0.5,0.5)
		:setDefaultTextColor("#000000"),
	},
--	secondary = function (box)
--		box.TextOffset = vec(0,2)
--		box.HoverBox:setDimensions(0,-2,0,-2)
--		local spriteNormal = GNUI.newSprite(atlas,13,15,17,21 ,2,2,2,4, 2)
--		local spritePressed = GNUI.newSprite(atlas,19,17,23,21 ,2,2,2,2)
--		
--		box:setDefaultTextColor("white"):setTextAlign(0.5,0.5)
--		:setTextEffect("SHADOW")
--		local wasPressed = true
--		local function update(pressed,hovering,forced)
--			if pressed ~= wasPressed or forced then
--				wasPressed = pressed
--				if pressed then
--					box:setNineslice(spritePressed)
--					:setChildrenOffset(0,0)
--					:setTextOffset(box.TextOffset + vec(0,2))
--					:setChildrenOffset(0,2)
--					if not forced then
--						GNUI.playSound("minecraft:ui.button.click",1) -- click
--					end
--				else
--					box:setNineslice(spriteNormal)
--					:setTextOffset(box.TextOffset - vec(0,2))
--					:setChildrenOffset(0,0)
--				end
--			end
--		end
--		box.BUTTON_CHANGED:register(update)
--		update(false,false,true)
--	end,
--	tertiary = function (box)
--		box.TextOffset = vec(0,2)
--		box.HoverBox:setDimensions(0,-2,0,-2)
--		local spriteNormal = GNUI.newSprite(atlas,29,11,31,13 ,1,1,1,1)
--		local spritePressed = GNUI.newSprite(atlas,29,15,31,17 ,1,1,1,1)
--		
--		box:setDefaultTextColor("white"):setTextAlign(0.5,0.5)
--		:setTextEffect("SHADOW")
--		local wasPressed = true
--		local function update(pressed,hovering,forced)
--			if pressed ~= wasPressed or forced then
--				wasPressed = pressed
--				if pressed then
--					box:setNineslice(spritePressed)
--					if not forced then
--						GNUI.playSound("minecraft:ui.button.click",1) -- click
--					end
--				else
--					box:setNineslice(spriteNormal)
--				end
--			end
--		end
--		box.BUTTON_CHANGED:register(update)
--		update(false,false,true)
--	end,
--	---@param box GNUI.Button
--	flat = function (box)
--		local spriteNormal = GNUI.newSprite(atlas,9,13,11,15 ,1,1,1,1)
--		local spritePressed = GNUI.newSprite(atlas,5,13,7,15 ,1,1,1,1)
--		
--		box:setDefaultTextColor("black"):setTextAlign(0.5,0.5)
--		local wasPressed = true
--		local function update(pressed,hovering)
--			if pressed ~= wasPressed then
--				wasPressed = pressed
--				if pressed then
--					box:setNineslice(spritePressed)
--					GNUI.playSound("minecraft:ui.button.click",1) -- click
--				else
--					box:setNineslice(spriteNormal)
--				end
--			end
--		end
--		box.BUTTON_CHANGED:register(update)
--		update(false,false)
--	end
}
--[────────────────────────────────────────-< Spider >-────────────────────────────────────────]--
theme.Slider = {
	default = {
		shaft = GNUI.newSprite(atlas,33,24,35,26, 1,1,1,1),
		thumb = GNUI.newSprite(atlas,39,17,43,22 ,2,2,2,3, 2),
		thumbHover = GNUI.newSprite(atlas,33,17,37,22 ,2,2,2,3, 2),
		thumbPressed = GNUI.newSprite(atlas,39,24,43,28 ,2,2,2,2),
		number = GNUI.newSprite(atlas,0,0,0,0):setTextAlign(0.5,0.5):setTextEffect("OUTLINE"),
	},
}
--[────────────────────────────────────────-< Text Field >-────────────────────────────────────────]--
theme.TextField = {
	default = {
		normal = GNUI.newSprite(atlas,17,17,19,20, 1,2,1,1):setTextMargin(3,3,3,3),
		pressed = GNUI.newSprite(atlas,17,17,19,20, 1,2,1,1):setTextMargin(3,3,3,3),
	}
}
--[────────────────────────────────────────-< Pane Stack >-────────────────────────────────────────]--

theme.Stack = {
	default = {
		background = GNUI.newSprite(atlas,48,16,54,22, 3,3,3,3, -3, -3, -3, -3):setPadding(7,7,7,7),
		spacing = 7
	}
}

return theme