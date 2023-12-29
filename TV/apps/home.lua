local appManager = require("TV.appManager")

local factory = function ()
   local FiGUI = require("libraries.FiGUI")
   local tween = require("libraries.GNTweenLib")
   
   local texture = textures["1x1white"]
   
   local http = require("libraries.http")
   
   local clock_label = FiGUI:newLabel()
   clock_label:canCaptureCursor(false)
   clock_label:setAnchor(0,0.4,1,0.6)
   clock_label:setAlign(1,0.5)
   
   local date_label = FiGUI:newLabel()
   date_label:canCaptureCursor(false)
   date_label:setAnchor(0,0.4,1,0.6)
   date_label:setAlign(1,0.5)
   date_label:setPos(0,7)
   date_label:setFontScale(0.3)
   
   local info_label = FiGUI:newLabel()
   info_label:setAnchor(0,0.4,1,0.6)
   info_label:setAlign(1,0.5)
   info_label:canCaptureCursor(false)
   info_label:setPos(0,4)
   info_label:setFontScale(0.2)
   ---@type Application
   local app = {}
   
   local wallpaper

   function app.INIT(window,tv)
   
      wallpaper = FiGUI.newSprite()
      :setTexture(texture)
      :setRenderType("EMISSIVE_SOLID")
      wallpaper:setColor(0, 0, 0)
      if false then -- offline / online
         http.get(
            'https://cdn.discordapp.com/attachments/1135020117915344948/1187077856061292624/compression.png?ex=65959367&is=65831e67&hm=ced1c5847b49e9716135cfd8924da6feb6887ed4e001a528cc5e2eb5b1b678a5&',
            function(output, err)
               if err then return end
               texture = textures:read('wallpaper', output)
               wallpaper:setTexture(texture)
               tween.tweenFunction(1,"inOutQuad",function (y)
                  wallpaper:setColor(y,y,y)
               end)
            end,
            'base64'
         )
      else
         texture = textures.wallpaper
         wallpaper:setTexture(texture)
         tween.tweenFunction(1,"inOutQuad",function (y)
            wallpaper:setColor(y,y,y)
         end)

         local dim = texture:getDimensions()
         local aspect_ratio = dim.x/dim.y
         local window_aspect_ratio = window.Dimensions.z/window.Dimensions.w
         wallpaper:setUV(0,0,(dim.x-1) / aspect_ratio * window_aspect_ratio,dim.y-1)
      end
      
   
      window:addChild(clock_label)
      window:addChild(date_label)
      window:addChild(info_label)
      window:setSprite(wallpaper)
      window:setPadding(2,2,2,2)
   
      local i = 0
      for _, value in pairs(listFiles("TV.apps")) do
         if value ~= "TV.apps.home" then
            local offset = vectors.vec2(i%5*12,math.floor(i/5)*12)
            local _, name, icon = require(value)
            local app_icon = FiGUI.newContainer()
            app_icon:setSize(12,12)
            app_icon:setPos(offset)
            app_icon:setSprite(icon)
            window:addChild(app_icon)
            app_icon:setMargin(2,2,2,2)
            app_icon.PRESSED:register(function ()
               tv.setApp(name)
            end)
            local app_label = FiGUI.newLabel()
            app_label:setPos(app_label.Dimensions.xy:copy():add(0,10):add(offset))
            app_label:setSize(12,3)
            app_label:setFontScale(0.2):setText(name):setAlign(0.5,0.5)
            app_label:canCaptureCursor(false)
            window:addChild(app_label)
            i = i + 1
         end
      end
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
   local frame = 0
   function app.FRAME(window,tv,dt,df)
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

appManager:registerApp(factory,"home"--[[,icon]])