---@diagnostic disable: undefined-global, assign-type-mismatch
--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / a color picker
/ /_/ / /|  / 
\____/_/ |_/ Source: link]]


local Box = require(....."/../primitives/box") ---@type GNUI.Box
local cfg = require(....."/../config") ---@type GNUI.Config
local Nineslice = require(....."/../nineslice") ---@type Nineslice
local eventLib = cfg.event ---@type EventLibAPI ---@type EventLibAPI
local Theme = require(....."/../theme") ---@type GNUI.ThemeAPI
local Button = require(....."/button") ---@type GNUI.Button


---@class GNUI.ColorPicker : GNUI.Box
---@field color Vector3
---@field COLOR_CHANGED EventLib
local ColorPicker = {}
ColorPicker.__index = function (t,i) return rawget(t,i) or ColorPicker[i] or Box[i] end
ColorPicker.__type = "GNUI.ColorPicker"

local colorTexture = textures:newTexture("GNUI_colorPicker",128,128)


do
   local res = 2
   local invRes = 64
   local x = 0
   local y = 0
   events.WORLD_RENDER:register(function (delta)
      for i = 1, 10, 1 do
         colorTexture:fill(x*invRes,y*invRes,invRes,invRes,vectors.hsvToRGB(vec(0,x/res,1-(y/res))))
         colorTexture:update()
         x = x + 1
         if x >= res then
            x = 0
            y = y + 1
            if y >= res then
               y = 0
               res = res * 2
               invRes = invRes / 2
               if res >128 then
                  events.WORLD_RENDER:remove("GNUI_colorPicker")
               end
            end
         end
      end
   end,"GNUI_colorPicker")
end

---@param parent GNUI.Box
function ColorPicker.new(parent)
   ---@type GNUI.ColorPicker
   local box = Box.new(parent)
   Theme.style(box,"Background")
   box._parent_class = ColorPicker
   box:setSize(128,192)
   :setPos(0,-64)
   
   local colorBox = Box.new(box)
   :setAnchor(0,0,1,1)
   :setDimensions(4,4,-4,-4)
   :setNineslice(Nineslice.new():setTexture(colorTexture))
   
   box.COLOR_CHANGED = eventLib.newEvent()
   
   setmetatable(box,ColorPicker)
   return box
end

return ColorPicker