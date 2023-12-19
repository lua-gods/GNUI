local FiGUI = require("libraries.FiGUI")

local wallpaper = FiGUI.newSprite()
:setTexture(textures.wallpaper)
:setRenderType("EMISSIVE_SOLID")

local clock_label = FiGUI:newLabel()
clock_label:setAnchor(0,0,1,1)
clock_label:setAlign(0.5,0.5)

local date_label = FiGUI:newLabel()
date_label:setAnchor(0,0,1,1)
date_label:setAlign(0.5,0.5)
date_label:setPos(0,5)
date_label:setFontScale(0.3)

local info_label = FiGUI:newLabel()
info_label:setAnchor(0,0,1,1)
info_label:setAlign(0.5,0.5)
info_label:setPos(0,7)
info_label:setFontScale(0.2)
---@type Application
local app = {}

function app.START(window)
   window:addChild(clock_label)
   window:addChild(date_label)
   window:addChild(info_label)
   window:setSprite(wallpaper)
end

function app.TICK(window)
   
end

local week = {
   "Sunday",
   "Monday",
   "Tuesday",
   "Wednesday",
   "Thursday",
   "Friday",
   "Saturday",
}

local last_minute = 0
function app.FRAME(window,delta,dt)
   local date = client:getDate()
   if last_minute ~= date.minute then
      last_minute = date.minute
      local time = world.getTimeOfDay() % 24000
      local hour = math.floor(time / 1000 + 6) % 24
      local minute = math.floor((time / 1000) % 1 * 60)
      
      clock_label:setText((date.hour%12)..":"..(#tostring(date.minute) == 1 and "0" .. date.minute or date.minute) .. (date.hour > 12 and "pm" or "am"))
      date_label:setText(week[date.week_day]..", "..date.month_name.." "..date.day .. " ".. date.year)
      info_label:setText(date.timezone_name)
   end
   --time = time * 0.01
   --local dim = textures.wallpaper:getDimensions()
   --wallpaper:setUV(math.sin(time) * 5,0,math.sin(time) * 5 + dim.x - 6,dim.y-1)
end

function app.CLOSE(window)
   window:removeChild(clock_label)
   window:removeChild(date_label)
   window:removeChild(info_label)
   
end

return app, "home", "Home"