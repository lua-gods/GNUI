local FiGUI = require("libraries.FiGUI")
local lorem = require("lorem")

---@class TVold
local api = {}

--[[ NOTE
This is a Skull specifically hard coded in the Figura SMP at the lua goofs base
Right behind the TV at 889,57,889 is the skull facing north.
]]

---@param dir Vector3
---@param plane_normal Vector3
---@param plane_origin Vector3
---@return Vector3?
local function ray2plane(ray_origin, dir, plane_normal, plane_origin)
   dir = dir:normalize()
   plane_normal = plane_normal:normalize()

   local dot = dir:dot(plane_normal)
   if math.abs(dot) < 1e-6 then return nil end

   local t = (plane_origin - ray_origin):dot(plane_normal) / dot
   if t < 0 then return nil end

   local intersection = ray_origin + dir * t
   return intersection
end

--- create theme
local wallpaper = FiGUI.newSprite()
:setTexture(textures.ui)
:setUV(0,16,0,16)
:setRenderType("EMISSIVE_SOLID")

local size = vectors.vec2(7,3)
local origin = vectors.vec3(889,57,889)
local TV = models:newPart("TV","SKULL")
:pos(size.x*8,size.y*16,16+4)
:rot(0,180,0)

---create window
local window = FiGUI.newContainer()
:setSprite(wallpaper)
:setSize(size * 16)
:setPos(size.x * -16,0)
TV:addChild(window.Part)

events.SKULL_RENDER:register(function (delta, block, item,_,ctx)
   TV:setVisible(ctx == "BLOCK" and block:getPos() == origin)
end)
--local label = GNUI.newLabel()
--:setAlign(0,0)
--:setFontScale(0.1)
--:setText(lorem)
--:setMargin(5,5,5,5)
--:setPadding(2,2,2,2)

--window:addChild(label)

events.WORLD_RENDER:register(function (dt)
   local time = client:getSystemTime() / 1000
   --label:setAnchor(
      --   math.cos(time*0.25)*0.1 + 0.1,math.sin(time*0.23)*0.1 + 0.1,
   --   math.cos(time*0.23)*0.1 + 0.9,math.sin(time*0.21)*0.1 + 0.9
   --)
   --label:setFontScale(math.abs((time * 0.1) % 2 - 1)*0.1 + 0.2)
   --:setAlign(math.abs((time * 0.05) % 2 - 1),math.abs((time * 0.0513513) % 2 - 1))
end)

-->====================[ App Management ]====================<--
local tween = require("libraries.GNTweenLib")
local apps = {}---@type table<any,{app:Application,id:string,name:string}>
local current_app = nil ---@type Application?



---@param application Application
function api.registerApp(application,name,icon)
   apps[name] = {app = application,name = name,icon = icon}
end

-- load apps
for _, path in pairs(listFiles("TV.apps")) do
   local app,id,name = require(path)
   app.close = function ()
      api.setApp("home")
   end
   api.registerApp(app,id,name)
end

local transitioning = false

function api.setApp(id)
   if not transitioning then
      if current_app then
         transitioning = true
         if current_app.CLOSE then
            current_app.CLOSE(current_app.window,api)
         end
         local last_window = current_app.window
         last_window:setZ(10)
         tween.tweenFunction(0.5,"outQuint",function (t)
            local anchor = math.lerp(vectors.vec4(0,0,1,1),vectors.vec4(0.1,0.1,0.9,0.9),t)
            last_window:setAnchor(anchor)
         end,function ()
            tween.tweenFunction(0.5,"inSine",function (t)
               local anchor = math.lerp(vectors.vec4(0.1,0.1,0.9,0.9),vectors.vec4(0.1,1.1,0.9,1.9),t)
               last_window:setAnchor(anchor)
            end,function ()
               transitioning = false
               last_window:setZ(0)
               window:removeChild(last_window)
            end)
         end)
      end
   
      current_app = apps[id].app
      if current_app then
         local win = current_app.window or FiGUI.newContainer()
         win:setAnchor(0,0,1,1)
         window:addChild(win)
         if not current_app.window then
            win:setSprite(wallpaper)
         end
         current_app.window = win
         if not current_app.ready then
            if current_app.INIT then
               current_app.INIT(win,api)
               current_app.ready = true
            end
         end
         if current_app.OPEN then
            current_app.OPEN(win,api)
         end
      end
   end
end

events.WORLD_TICK:register(function ()
   if current_app and current_app.TICK then
      current_app.TICK(current_app.window,api)
   end
end)

local last_system_time = client:getSystemTime()
events.WORLD_RENDER:register(function (dt)
   local system_time = client:getSystemTime()
   local delta = (system_time - last_system_time) / 1000
   if current_app and current_app.FRAME then
      current_app.FRAME(current_app.window,api,delta,dt)
   end
end)

api.setApp("home")

-->========================================[ Remote ]=========================================<--

local auth = {} 
local users = {}
local keyPress = {}

function auth(player)
   if type(player) == "PlayerAPI" then
      local name = player:getName()
      users[name] = {player = player,name = name}
      log(name .." connected")
      return name
   end
end

local timer = 0
events.WORLD_TICK:register(function ()
   timer = timer + 1
   if timer > 20  then
      for key, user in pairs(users) do
         if not user.player:isLoaded() then
            users[key] = nil
            log(user.name.." disconnected")
         end
      end
   end
end)


local key2string = require("libraries.key2string")
function keyPress(user,key,status,modifier)
   if current_app and current_app.KEY_PRESS then
      current_app.KEY_PRESS(current_app.window,api,users[user].player,key2string(key,modifier),key,status,modifier)
   end
   --log(users[user].name .. " " .. (key2string(key,modifier) or " "))
end

local function raycastPress(user,pos,dir)
   local world_cursor = ray2plane(pos,dir,vectors.vec3(0,0,1),origin:copy():add(0,0,1.8))
   if world_cursor then
      local local_cursor = vectors.vec2(
         world_cursor.x-origin.x+size.x * 0.5 - 0.5,
         origin.y - world_cursor.y+size.y
      ) * 16 - window.Padding.xy

      if current_app.window then
         current_app.window:setCursor(local_cursor.x,local_cursor.y,true)
         window:setCursor(local_cursor.x,local_cursor.y,true,true)
      else
         window:setCursor(local_cursor.x,local_cursor.y,true)
      end
   end
end

avatar:store("auth",auth)
avatar:store("keyPress",keyPress)
avatar:store("raycastPress",raycastPress)
return api