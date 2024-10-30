--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / The Slider Class.
/ /_/ / /|  / a number range box.
\____/_/ |_/ Source: link]]
---@diagnostic disable: assign-type-mismatch
local Box = require"GNUI.primitives.box"
local cfg = require"GNUI.config"
local eventLib = cfg.event
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
    if lastEvent then
      local diff = math.abs(new.min-new.max)
      local pos = new:toLocal(lastEvent.pos) / new.Size * (1+1/diff)
      if new.isVertical then
        pos.y = math.clamp(pos.y,0,1)
        new:setValue(math.floor(math.lerp(new.min,new.max,pos.y) / new.step + 1/diff) * new.step)
      else
        pos.x = math.clamp(pos.x,0,1)
        new:setValue(math.floor(math.lerp(new.min,new.max,pos.x) / new.step + 1/diff) * new.step)
      end
    end
  end
  
  ---@param event GNUI.InputEvent
  new.INPUT:register(function (event)
    if event.key == new.keybind then
      if event.state == 1 then
        new:press()
        updateEvent()
        return true
      else
        new:release()
      end
    elseif event.key == "key.mouse.scroll" then
      local dir = event.strength > 0 and 1 or -1
      new:setValue(new.value + new.step * dir)
      return true
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
  local diff = math.min(math.abs(self.max - self.min),5) + 1
  local mul = (diff-1) / (self.max - self.min)
  local l = self.value - self.min
  local a1,a2 = (l * mul)/diff,(l * mul+1)/diff
  if self.isVertical then self.sliderBox:setAnchor(0,a1,1,a2)
  else self.sliderBox:setAnchor(a1,0,a2,1)
  end
  self.numberBox:setText(self.value)
  return self
end

return Slider