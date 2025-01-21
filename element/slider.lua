--[[______   __
  / ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / The Slider Class.
/ /_/ / /|  / a number range box.
\____/_/ |_/ Source: link]]
---@diagnostic disable: assign-type-mismatch
local Box = require("./../primitives/box") ---@type GNUI.Box
local cfg = require("./../config") ---@type GNUI.Config
local eventLib = cfg.event ---@type EventLibAPI
local Theme = require("./../theme")

local Button = require("./button") ---@type GNUI.Button
local TextField = require("./textField") ---@type GNUI.TextField

local DOUBLE_CLICK_TIME = 300

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
  
  ---@param event GNUI.InputEventMouseMotion
  local function updateEvent(event)
    local size = math.abs(new.min-new.max)
    local dir = event.relative / new.Size * (1+1/size)
    if new.isVertical then
      new:setValue(math.floor((new.value + dir.y * size) / new.step + 0.5) * new.step)
    else
      new:setValue(math.floor((new.value + dir.x * size) / new.step + 0.5) * new.step)
    end
  end
  
  local lastClickTime = 0
  ---@param event GNUI.InputEvent
  new.INPUT:register(function (event)
    if event.key == new.keybind then
      if event.state == 1 then
        local clickTime = client:getSystemTime()
        if clickTime - lastClickTime < DOUBLE_CLICK_TIME then
          new.numberBox:setVisible(false)
          local numberField = TextField.new(new):setAnchor(0,0,1,1)
          numberField.FIELD_CONFIRMED:register(function (out)
            numberField:free()
            if tonumber(out) then
              new:setValue(tonumber(out))
            end
            new.numberBox:setVisible(true)
          end)
          numberField:press()
          new:release()
          return true
        end
        lastClickTime = clickTime
        new:press()
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
    if new.isPressed then
      updateEvent(event)
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
  self.value = math.clamp(math.floor(value / self.step + 0.5) * self.step,self.min,self.max)
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
  local diff = math.min(math.abs(self.max - self.min),20) + 1
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