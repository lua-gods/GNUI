---@diagnostic disable: assign-type-mismatch
--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / a gradient edit box
/ /_/ / /|  / made to edit gradients from the https://github.com/lua-gods/GNs-Avatar-3/blob/main/lib/gradient.lua
\____/_/ |_/ Source: ...]]

local GRADIENT_SAMPLE_SIZE = 20

local linear = textures["64x1alpha"] or textures:newTexture("64x1alpha",64,1):applyFunc(0,0,64,1,function (col, x, y)return vec(1,1,1,x/64)end)
local white = textures["1x1white"] or textures:newTexture("1x1white",1,1):setPixel(0,0,vec(1,1,1))


local Box = require(....."/../primitives/box") ---@type GNUI.Box
local cfg = require(....."/../config") ---@type GNUI.Config
local Nineslice = require(....."/../nineslice") ---@type Nineslice
local eventLib = cfg.event ---@type EventLibAPI ---@type EventLibAPI
local Theme = require(....."/../theme") ---@type GNUI.ThemeAPI
local Button = require(....."/button") ---@type GNUI.Button

---@class GNUI.GradientEdit : GNUI.Box
---@field gradient Gradient
---@field gradientBox table<integer,{slider:GNUI.Button,boxA:GNUI.Box,boxB:GNUI.Box}>
---@field GRADIENT_CHANGED EventLib
local GradientEdit = {}

GradientEdit.__index = function (t,i) return rawget(t,i) or GradientEdit[i] or Box[i] end
GradientEdit.__type = "GNUI.GradientEdit"

---Creates a new GradientEdit.
---@param parent GNUI.Box?
---@return GNUI.GradientEdit
function GradientEdit.new(parent)
   ---@type GNUI.GradientEdit
   local box = Box.new(parent)
   box._parent_class = GradientEdit
   box.GRADIENT_CHANGED = eventLib.newEvent()
   box.gradientBox = {}
   setmetatable(box,GradientEdit)
   return box
end

---Sets the gradient to be edited
---@param gradient Gradient
---@generic self
---@param self self
---@return self
function GradientEdit:setGradient(gradient)
   ---@cast self GNUI.GradientEdit
   self.gradient = gradient
   self:rebuildGradientDisplay()
   return self
end

---@generic self
---@param self self
---@return self
function GradientEdit:rebuildGradientDisplay()
   local gradientBox = {}
   ---@cast self GNUI.GradientEdit
   self:purgeAllChildren()
   local previewBox = Box.new(self)
   :setAnchor(0,0,1,1)
   local editBox = Box.new(self)
   :setAnchor(0,0,1,1)
   ---@param event GNUI.InputEvent
   editBox.INPUT:register(function (event)
      if event.key == "key.mouse.left" and event.state == 1 then
         if self.gradient then
            self.gradient:addPoint(editBox:toLocal(editBox.Canvas.MousePosition).x / editBox.Size.x * self.gradient.range)
            self:rebuildGradientDisplay()
         end
      end
   end)
   
   local range = self.gradient.range
   local count = #self.gradient.colors
   for i = 1, #self.gradient.colors, 1 do
      local colorA = self.gradient.colors[i]
      local posA = self.gradient.positions[i] / range
      
      if count ~= i then
         local colorB = self.gradient.colors[i+1]
         local posB = self.gradient.positions[i+1] / range
         local boxA = Box.new(previewBox)
         :setAnchor(posA,0,posB,1)
         :setNineslice(Nineslice.new():setTexture(white):setColor(colorA))
         
         local boxB = Box.new(previewBox)
         :setAnchor(posA,0,posB,1)
         :setNineslice(Nineslice.new():setTexture(linear):setColor(colorB):setRenderType("TRANSLUCENT"))
         gradientBox[i] = {boxA=boxA,boxB=boxB}
      else
         gradientBox[i] = {}
      end
      
      local slider = Button.new(editBox)
      :setAnchor(posA,0,posA,1)
      :setDimensions(-4,0,4,0)
      :setColor(colorA)
      gradientBox[i].slider = slider
      local o = i
      
      ---@param event GNUI.InputEventMouseMotion
      slider.MOUSE_MOVED:register(function (event)
         if slider.isPressed then
            self.gradient:movePoint(o,math.max(self.gradient.positions[o] + event.relative.x / self.Size.x * range,0))
            self:updateGradientDisplay()
         end
      end)
      ---@param event GNUI.InputEvent
      slider.INPUT:register(function (event)
         if event.key == "key.mouse.middle" and event.state == 1 then
            if #self.gradient.positions > 2 then
               self.gradient:removePoint(o)
               self:rebuildGradientDisplay()
            end
         end
      end)
   end
   self.gradientBox = gradientBox
   return self
end

---@generic self
---@param self self
---@return self
function GradientEdit:updateGradientDisplay()
   ---@cast self GNUI.GradientEdit
   local gradientBox = self.gradientBox
   local count = #self.gradient.colors
   local range = self.gradient.range
   for i = 1, count, 1 do
      local gd = gradientBox[i]
      local colorA = self.gradient.colors[i]
      local posA = self.gradient.positions[i] / range
      if count ~= i then
         local posB = self.gradient.positions[i+1] / range
         gd.boxA:setAnchor(posA,0,posB,1)
         gd.boxB:setAnchor(posA,0,posB,1)
      end
      gd.slider:setAnchor(posA,0,posA,1)
   end
   return self
end

return GradientEdit