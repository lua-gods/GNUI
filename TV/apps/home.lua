local appManager = require("TV.appManager")
local FiGUI = require("libraries.FiGUI")
local tween = require("libraries.GNTweenLib")
local http = require("libraries.http")

local links = {
   "https://media.discordapp.net/attachments/1124181688566681701/1191341307340259379/2024-01-01_19.18.55.png",
   "https://cdn.discordapp.com/attachments/1135020117915344948/1187077856061292624/compression.png",
}

local wallpaper_downloaded = false
local texture = textures:newTexture("wallpaper",1,1):setPixel(0,0,vectors.vec3())
http.get(
   links[2],
   function(output, err)
      if err then return end
      texture = textures:read('wallpaper', output)
      wallpaper_downloaded = true
   end,
   'base64'
)  

---@param window GNUI.container
---@param tv TV
---@return Application
local factory = function (window,tv)
   local _wallpaper_downloaded = false
   local wallpaper = FiGUI.newSprite()
   wallpaper:setTexture(texture)

   local app_list = FiGUI.newContainer()
   app_list:setAnchor(0,0,1,1)
   

   local clock_label = FiGUI:newLabel()
   clock_label:canCaptureCursor(false)
   clock_label:setAnchor(0,0.4,1,0.6)
   clock_label:setAlign(1,0.5)
   clock_label:setTextEffect("SHADOW")
   
   local date_label = FiGUI:newLabel()
   date_label:canCaptureCursor(false)
   date_label:setAnchor(0,0.4,1,0.6)
   date_label:setAlign(1,0.5)
   date_label:setPos(0,8)
   date_label:setFontScale(0.3)
   date_label:setTextEffect("SHADOW")
   
   local info_label = FiGUI:newLabel()
   info_label:setAnchor(0,0.4,1,0.6)
   info_label:setAlign(1,0.5)
   info_label:canCaptureCursor(false)
   info_label:setPos(0,6)
   info_label:setFontScale(0.2)
   info_label:setTextEffect("SHADOW")
   ---@type Application
   local app = {}

   local function rebuildAppCatalog()
      for key, value in pairs(app_list.Children) do
         app_list:removeChild(value)
      end
      app_list.Children = {}

      local i = 0
      for _, appp in pairs(appManager.apps) do
         if appp.icon then
         local offset = vectors.vec2(i%5*12,math.floor(i/5)*12)
            local app_icon = FiGUI.newContainer()
            app_icon:setSize(12,12)
            app_icon:setPos(offset)
            app_icon:setSprite(FiGUI.newSprite():setTexture(appp.icon))
            app_list:addChild(app_icon)
            app_icon:setMargin(2,2,2,2)
            app_icon.PRESSED:register(function ()
               tv:setApp(appp.name)
            end)
            local app_label = FiGUI.newLabel()
            app_label:setPos(app_label.Dimensions.xy:copy():add(0,10):add(offset))
            app_label:setSize(12,3)
            app_label:setFontScale(0.2):setText(appp.name):setAlign(0.5,0.5)
            app_label:canCaptureCursor(false)
            app_label:setTextEffect("SHADOW")
            app_list:addChild(app_label)
            i = i + 1
         end
      end
   end
   
   window:addChild(clock_label)
   window:addChild(date_label)
   window:addChild(info_label)
   window:setSprite(wallpaper)
   window:addChild(app_list)
   window:setPadding(2,2,2,2)

   appManager.APP_LIST_CHANGED:register(function ()
      rebuildAppCatalog()
   end)
   
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
   local frame = 0
   function app.FRAME(dt,df)
      if wallpaper_downloaded and _wallpaper_downloaded ~= wallpaper_downloaded then
         local dim = texture:getDimensions()
         local aspect_ratio = dim.x/dim.y
         local window_aspect_ratio = window.ContainmentRect.z/window.ContainmentRect.w
         wallpaper:setTexture(texture)
         wallpaper:setUV(0,0,(dim.x-1) / aspect_ratio * window_aspect_ratio,dim.y-1)
         _wallpaper_downloaded = true
      end
      local date = client:getDate()
      if last_minute ~= date.minute then
         last_minute = date.minute
         local time = world.getTimeOfDay() % 24000
         local hour = math.floor(time / 1000 + 6) % 24
         local minute = math.floor((time / 1000) % 1 * 60)
         
         clock_label:setText((date.hour%12 == 0 and 12 or date.hour%12)..":"..(#tostring(date.minute) == 1 and "0" .. date.minute or date.minute) .. (date.hour > 12 and "pm" or "am"))
         date_label:setText(week[date.week_day]..", "..date.month_name.." "..date.day .. " ".. date.year)
         info_label:setText(date.timezone_name)
      end
      frame = frame + 0.005
   end
   return app
end

appManager:registerApp(factory,"Home"--[[,icon]])