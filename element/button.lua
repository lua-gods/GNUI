--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / The Button Class.
/ /_/ / /|  / The base class for all clickable buttons.
\____/_/ |_/ Source: link]]
---@diagnostic disable: assign-type-mismatch
local Box = require"GNUI.primitives.box"
local eventLib = require"libraries.eventLib"
local Theme = require"GNUI.theme"

local tree = {}

---@class GNUI.Button : GNUI.Box
---@field isPressed boolean
---@field isToggle boolean
---@field keybind GNUI.keyCode
---
---@field HoverBox GNUI.Box
---
---@field BUTTON_CHANGED EventLib
---@field PRESSED EventLib
---@field BUTTON_DOWN EventLib
---@field BUTTON_UP EventLib
local Button = {}
Button.__index = function (t,i) return rawget(t,i) or Button[i] or Box[i] end
Button.__type = "GNUI.Button"


---@param parent GNUI.Box?
---@param variant string?
---@return GNUI.Button
function Button.new(parent,variant)
  
  ---@type GNUI.Button
  local new = setmetatable(Box.new(parent),Button)
  new.PRESSED = eventLib.new()
  new.BUTTON_DOWN = eventLib.new()
  new.BUTTON_UP = eventLib.new()
  new.keybind = "key.mouse.left"
  new.BUTTON_CHANGED = eventLib.new()
  new.isToggle = false
  new.isPressed = false
  
  local hoverBox = Box.new(new)
  new.HoverBox = hoverBox
  
  new.MOUSE_PRESSENCE_CHANGED:register(function (isHovering)
    new.BUTTON_CHANGED:invoke(new.isPressed,new.isCursorHovering)
  end)
  
  ---@param event GNUI.InputEvent
  new.INPUT:register(function (event)
    if event.key == new.keybind then
      if event.isPressed then
        new:press()
      else
        new:release()
      end
    end
  end)
  
  Theme.style(new,variant)
  return new
end


---Sets whether the button is toggleable
---@param toggle boolean
---@generic self
---@param self self
---@return self
function Button:setToggle(toggle)
  ---@cast self GNUI.Button
  self.isToggle = toggle or false
  return self
end

---Presses the button
---@generic self
---@param self self
---@return self
function Button:press()
  ---@cast self GNUI.Button
  if self.isToggle then
    self.isPressed = not self.isPressed
  else
    self.isPressed = true
  end
  
  if self.isPressed then self.BUTTON_DOWN:invoke()
  else self.PRESSED:invoke()
    self.BUTTON_UP:invoke()
  end
  
  self.BUTTON_CHANGED:invoke(self.isPressed,self.isCursorHovering)
  return self
end

function Button:release()
  if not self.isToggle then
    self.isPressed = false
    self.BUTTON_UP:invoke()
    self.BUTTON_CHANGED:invoke(self.isPressed,self.isCursorHovering)
  end
end

return Button