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

local GNUI = require "../main"
local atlas = textures[(...):gsub("/",".") ..".gnuiTheme"]

---@type GNUI.Theme
local theme = {}

theme.Box = {
  Default = function (box)end,
  Background = function (box)
    local spritePressed = GNUI.newNineslice(atlas,1,7,3,9 ,2,2,2,2)
    box:setNineslice(spritePressed)
  end
}

theme.Button = {
  ---@param box GNUI.Button
  All = function (box)
    local spriteHover = GNUI.newNineslice(atlas,19,1,25,7 ,3,3,3,3, 2,2,2,2)
    box.HoverBox:setNineslice(spriteHover):setAnchor(0,0,1,1):setCanCaptureCursor(false):setZMul(1.1)
    box.BUTTON_CHANGED:register(function (pressed,hovering)
      box.HoverBox:setVisible(hovering):setZMul(10)
    end,"GNUI.Hover")
    box.HoverBox:setVisible(false)
  end,
  ---@param box GNUI.Button
  Default = function (box)
    local spriteNormal = GNUI.newNineslice(atlas,7,1,11,7 ,2,2,2,4, 2)
    local spritePressed = GNUI.newNineslice(atlas,13,3,17,7 ,2,2,2,2)
    
    box:setDefaultTextColor("black"):setTextAlign(0.5,0.5)
    local wasPressed = true
    local function update(pressed,hovering)
      if pressed ~= wasPressed then
        wasPressed = pressed
        if pressed then
          box:setNineslice(spritePressed)
          :setTextOffset(0,2)
          :setChildrenOffset(0,0)
          GNUI.playSound("minecraft:ui.button.click",1) -- click
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
}

theme.Slider = {
  ---@param box GNUI.Slider
  Default = function (box)
    local spriteButton = GNUI.newNineslice(atlas,7,1,11,7 ,2,2,2,4, 2)
    local spriteBG = GNUI.newNineslice(atlas,29,7,31,9, 1,1,1,1)
    
    box.sliderBox:setNineslice(spriteButton)
    box.numberBox:setTextAlign(0.5,0.7)
    
   
    local wasPressed = true
    local function update(pressed)
      
      if pressed ~= wasPressed then
        wasPressed = pressed
        if pressed then
          GNUI.playSound("minecraft:ui.button.click",1) -- click
        else
        end
      end
    end
    if box.showNumber then
      box.VALUE_CHANGED:register(function ()
        GNUI.playSound("minecraft:block.note_block.hat",2,0.1) -- click
      end)
    end
    
    box.VALUE_CHANGED:register(function ()
      local diff = math.min(math.abs(box.max - box.min),10) + 1
    local mul = (diff-1) / (box.max - box.min)
    local a1,a2 = (box.value * mul)/diff,(box.value * mul+1)/diff
      if a1<0.5 and a2>0.5 then
        box.numberBox:setDefaultTextColor("black")
      else
        box.numberBox:setDefaultTextColor("white")
      end
    end)
    box.numberBox:setDefaultTextColor("white")
    
    box:setNineslice(spriteBG)
    box.BUTTON_CHANGED:register(update)
    update(false)
  end
}

theme.TextField = {
  ---@param box GNUI.TextField
  Default = function (box)
    local spriteBG = GNUI.newNineslice(atlas,13,9,17,13, 2,2,2,2)
    box:setNineslice(spriteBG)
    :setTextAlign(0,0.5)
    :setTextOffset(3,1)
  end
}

theme.Separator = {
  ---@param box GNUI.TextField
  Default = function (box)
    local spriteBG = GNUI.newNineslice(atlas,1,15,1,15)
    box:setNineslice(spriteBG)
  end
}

theme.Dialog = {
  ---@param dialog GNUI.Dialog
  Default = function (dialog)
    local titlebar = GNUI.newNineslice(atlas,1,1,5,5 ,2,2,2,2)
    dialog.titlebar:setNineslice(titlebar):setTextOffset(4,4):setDefaultTextColor("#000000"):setText("Hello")
    local spritePressed = GNUI.newNineslice(atlas,1,7,3,9 ,2,2,2,2 ,4,0,0,0)
    dialog.clientArea:setNineslice(spritePressed)
    :setAnchor(0,0,1,1):setDimensions(0,17,0,0)
    dialog.titlebar:setAnchor(0,0,1,0):setDimensions(0,0,0,14)
  end
  
}

return theme