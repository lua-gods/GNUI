--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / Theme File
/ /_/ / /|  / Contains how to theme specific classes
\____/_/ |_/ Source: link]]

--[[ Layout --------
├Class
│├Default
│└AnotherVariant
└Class
 ├Default
 ├Variant
 └MoreVariant
-------------------]]
---GNUI.Button        ->    Button
---GNUI.Button.Slider ->    Slider

local GNUI = require "GNUI.main"
local atlas = textures["GNUI.theme.gnuiTheme"]

---@type GNUI.Theme
return {
  Box = {
    Default = function (box)end,
    Background = function (box)
      local spritePressed = GNUI.newNineslice(atlas,1,7,3,9 ,2,2,2,2)
      box:setNineslice(spritePressed)
    end
  },
  Button = {
    ---@param box GNUI.Button
    Default = function (box)
      local spriteNormal = GNUI.newNineslice(atlas,7,1,11,7 ,2,2,2,4, 2)
      local spritePressed = GNUI.newNineslice(atlas,13,3,17,7 ,2,2,2,2)
      local spriteHover = GNUI.newNineslice(atlas,19,1,25,7 ,3,3,3,3, 2,2,2,2)
      
      box:setDefaultTextColor("black"):setTextAlign(0.5,0.5)
      box.HoverBox:setNineslice(spriteHover):setAnchor(0,0,1,1):setBlockMouse(false):setZMul(200)
      local wasPressed = true
      local function update(pressed,hovering)
        box.HoverBox:setVisible(hovering)
        if pressed ~= wasPressed then
          wasPressed = pressed
          if pressed then
            box:setNineslice(spritePressed)
            :setTextOffset(0,2)
            :setChildrenOffset(0,0)
            GNUI.playSound("minecraft:ui.button.click",1)
          else
            box:setNineslice(spriteNormal)
            :setTextOffset(0,0)
            :setChildrenOffset(0,-2)
          end
        end
      end
      
      box.BUTTON_CHANGED:register(update)
      update(false,false)
    end
  },
}