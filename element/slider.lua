--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / The Button Class.
/ /_/ / /|  / The base class for all clickable buttons.
\____/_/ |_/ Source: link]]
---@diagnostic disable: assign-type-mismatch
local Box = require"GNUI.primitives.box"
local eventLib = require"libraries.eventLib"
local Theme = require"GNUI.theme"

local Button = require"GNUI.element.button"


---@class GNUI.Slider : GNUI.Button
---@field isVertical boolean
---@field min number
---@field max number
---@field step number
---@field value number
---@field sliderBox GNUI.Box
---@field numberBox GNUI.Box
---@field showNumber boolean
---@field VALUE_CHANGED EventLib
local Slider = {}
Slider.__index = function (t,i) return rawget(t,i) or Slider[i] or Button[i] or Box[i] end
Slider.__type = "GNUI.Slider"


---@param isVertical boolean
---@param min number
---@param max number
---@param step number
---@param value number
---@param parent GNUI.Box?
---@param showNumber boolean?
---@param variant string|"none"|"default"?
---@return GNUI.Slider
function Slider.new(isVertical,min,max,step,value,parent,showNumber,variant)
  ---@type GNUI.Slider
  local new = setmetatable(Button.new(parent,"none"),Slider)
  
  new.min = min
  new.max = max
  new.step = step
  new.value = value
  new.keybind = "key.mouse.left"
  new.sliderBox = Box.new(new):setCanCaptureCursor(false)
  new.numberBox = Box.new(new):setAnchor(0,0,1,1):setCanCaptureCursor(false)
  new.isVertical = isVertical or false
  new.showNumber = showNumber or true
  if not (showNumber or true) then new.numberBox:setVisible(false) end
  
  new.VALUE_CHANGED = eventLib.new()
  
  new.VALUE_CHANGED:register(function () new:updateSliderBox() end)
  new:updateSliderBox()
  
  local lastEvent -- workaround to getting the current mouse pos outside the mouse moved event
  local function updateEvent()
    local lastValue = new.value
      local diff = math.abs(new.min-new.max)
      local pos = new:toLocal(lastEvent.pos) / new.Size * (1+1/diff)
      pos.x = math.clamp(pos.x,0,1)
      pos.y = math.clamp(pos.y,0,1)
      new:setValue(math.floor(math.lerp(new.min,new.max,pos.x) / new.step + 1/diff) * new.step)
  end
  
  ---@param event GNUI.InputEvent
  new.INPUT:register(function (event)
    if event.key == new.keybind then
      if event.state == 1 then
        new:press()
        updateEvent()
      else
        new:release()
      end
    elseif event.key == "key.mouse.scroll" then
      local dir = event.strength > 0 and 1 or -1
      new:setValue(new.value + new.step * dir)
    end
  end,"GNUI.Input")
  
  ---@param event GNUI.InputEventMouseMotion
  new.MOUSE_MOVED:register(function (event)
    lastEvent = event
    if new.isPressed then
      updateEvent()
    end
  end,"GNUI.Input")
  Theme.style(new,variant)
  return new
end

---Sets the value of the slider.
---@param value number
---@generic self
---@param self self
---@return self
function Slider:setValue(value)
  ---@cast self GNUI.Slider
  local lvalue = self.value
  self.value = math.clamp(value,self.min,self.max)
  if self.value ~= lvalue then
    self.VALUE_CHANGED:invoke(self.value)
    self:updateSliderBox()
  end
  return self
end

---Sets the minimum value of the slider.
---@param min number
---@generic self
---@param self self
---@return self
function Slider:setMin(min)
  ---@cast self GNUI.Slider
  self.min = min
  return self
end

---Sets the maximum value of the slider.
---@param max number
---@generic self
---@param self self
---@return self
function Slider:setMax(max)
  ---@cast self GNUI.Slider
  self.max = max
  return self
end

---Sets the step size of the slider.
---@param step number
---@generic self
---@param self self
---@return self
function Slider:setStep(step)
  ---@cast self GNUI.Slider
  self.step = step
  return self
end

---Updates the displayed slider box.
---@generic self
---@param self self
---@return self
function Slider:updateSliderBox()
  ---@cast self GNUI.Slider
  local diff = math.min(math.abs(self.max - self.min),10) + 1
  local mul = (diff-1) / (self.max - self.min)
  local a1,a2 = (self.value * mul)/diff,(self.value * mul+1)/diff
  if self.isVertical then self.sliderBox:setAnchor(0,a1,1,a2)
  else self.sliderBox:setAnchor(a1,0,a2,1)
  end
  self.numberBox:setText(self.value)
  return self
end

return Slider