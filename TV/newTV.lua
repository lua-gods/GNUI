local FigUI = require("libraries.FiGUI")
local skullHandler = require("libraries.skullHandler")
local lorem = require("lorem")
local tvs = {} -- collection of all loaded tvs
local tween = require("libraries.GNTweenLib")

local model = models.core
models:removeChild(models.core)

---@class TV
---@field Window GNUI.container
---@field Dimensions Vector4
---@field current_app Application
---@field apps table<any,Application>
local TV = {}
TV.__index = TV

local wallpaper = FigUI.newSprite()
:setTexture(textures.ui)
:setUV(0,16,0,16)
:setRenderType("EMISSIVE_SOLID")

---@param modelPart ModelPart
---@return TV
function TV:new(modelPart)
   local new = {}
   local window = FigUI.newContainer()
   new.Window = window
   new.apps = {}
   modelPart:addChild(window.Part)
   setmetatable(new,TV)
   return new
end

function TV:free()
   self.Window:free()
   self = nil
end

local function getEveryTV()
   local list = {}
   for key, tv in pairs(tvs) do
      list[key] = {
         id = tv.id,
         rect = tv.rect,
         rot = tv.skull.rot,
         origin = (tv.skull.pos - tv.skull.dir*((16+4)/16)):add(.5,.5,.5),
         dir = tv.skull.dir,
      }
   end
   return list
end
avatar:store("getEveryTV",getEveryTV)

local MAX_SIZE = 500

local function check(pos)
   return world.getBlockState(pos).id
end
---@param skull WorldSkull
skullHandler.INIT:register(function(skull)
   local rect = vectors.vec4(-MAX_SIZE,MAX_SIZE,-MAX_SIZE,MAX_SIZE)
   local transform = matrices.mat4()
   transform:translate(0,0,1)
   transform:rotateY(skull.rot)
   transform:translate(skull.pos)

   local s = vectors.vec2(0,0)
   local screen_block = world.getBlockState(skull.pos-skull.dir).id
   for i = 1, MAX_SIZE, 1 do
      local ws = transform:apply(s.x+i,s.y,0)
      if check(ws) ~= screen_block then
         rect.x = i-1
         break
      end
   end
   for i = 1, MAX_SIZE, 1 do
      local ws = transform:apply(s.x-i,s.y,0)
      if check(ws) ~= screen_block then
         rect.z = -i+1
         break
      end
   end
   for i = 1, MAX_SIZE, 1 do
      local ws = transform:apply(s.x,s.y+i,0)
      if check(ws) ~= screen_block then
         rect.y = i-1
         break
      end
   end
   for i = 1, MAX_SIZE, 1 do
      local ws = transform:apply(s.x,s.y-i,0)
      if check(ws) ~= screen_block then
         rect.w = -i+1
         break
      end
   end
   rect.x,
   rect.y,
   rect.z,
   rect.w 
   = 
   rect.x,
   rect.y,
   rect.x-rect.z+1,
   rect.y-rect.w+1 -- evaluate dimensions
   
   local corners = {
      transform:apply(rect.x,rect.y,0),
   }
   local id = corners[1].x .. "y" .. corners[1].y .. "z" .. corners[1].z .. "w" .. rect.z .. "h" .. rect.w

   if not tvs[id] then
      local part = model:copy("aa")
      local TVanchor = part:newPart("TVanchor")
      skull.model:addChild(part)
      part:setPos(8, 0, 8):setRot(0,180 + skull.rot)
      local tv = TV:new(TVanchor)
   
      skull.tv = tv
      skull.tvid = id
      tv.Window:setSize(16 * rect.z,16 * rect.w)
      tv.Window:setSprite(wallpaper:duplicate())
      TVanchor:setPos(8-(rect.x-rect.z+1)*16,(rect.y+1)*16,-16-4-0.02)
      tvs[id] = {
         tv=tv,
         id=id,
         rect=rect,
         skull=skull,
      }
   else
      print("TV already exists")
   end
end)

local appManager = require("TV.appManager")

function TV:setApp(id)
   if self.current_app then
      if self.current_app.CLOSE then
         self.current_app.CLOSE(self.current_app.window,self)
      end
      self.Window:removeChild(self.current_app.window)
   end
   if not appManager.apps[id] then
      error("Application \""..id.."\" does not exist",2)
   end
   local win
   if not self.apps[id] then
      local new = appManager.apps[id].factory()
      self.current_app = new
      self.apps[id]    = new
      win = FigUI.newContainer()
      win:setAnchor(0,0,1,1)
      win:setSprite(wallpaper)
      self.Window:addChild(win)
      if self.current_app.INIT then
         self.current_app.INIT(win,self)
      end
   else
      self.current_app = self.apps[id]
      win = self.current_app.window
      self.Window:addChild(self.apps[id].window)
      win:setAnchor(0,0,1,1)
      if self.current_app.OPEN then
         self.current_app.OPEN(win,self)
      end
   end
   self.current_app.window = win
end

skullHandler.TICK:register(function (skull)
   if skull.tv and skull.tv.current_app and skull.tv.current_app.TICK then
      skull.tv.current_app.TICK(skull.tv.current_app.window,skull.tv)
   end
end)

skullHandler.FRAME:register(function (skull,dt,df)
   if skull.tv and skull.tv.current_app and skull.tv.current_app.FRAME then
      skull.tv.current_app.FRAME(skull.tv.current_app.window,skull.tv,dt,df)
   end
end)

skullHandler.EXIT:register(function (skull)
   if skull.tvid then
      skull.tv:free()
      tvs[skull.tvid] = nil
   end
end)

skullHandler.INIT:register(function (skull)
   if skull.tv then
      skull.tv:setApp("Home")
   end
end)

-- CONTROL SERVER

local remoteAuthAPI = {}
local users = {}
local remoteAPI = {}

---@param client ClientAPI
function remoteAuthAPI.handshake(client)
   local player = client:getViewer()
   local id = player:getUUID()
   if not users[id] then
      local api = {
         setSelectedTV = function (tv_id)
            return remoteAPI.setSelectedTV(id,tv_id)
         end,
         setCursorPos = function (uvpos)
            return remoteAPI.setCursorPos(id,uvpos)
         end,
         click = function (right)
            remoteAPI.click(id,right)
         end
      }
      users[id] = {api=api}
      return api
   else
      return users[id]
   end
end

function remoteAPI.setSelectedTV(id,tv_id)
   users[id].selected_tv = tvs[tv_id] and tvs[tv_id].tv or nil
end

function remoteAPI.setCursorPos(id,uvpos)
   if users[id].selected_tv then

      ---@type GNUI.container
      local window = users[id].selected_tv.Window
      window:setCursor(
         uvpos.x*(window.ContainmentRect.z+window.Padding.z+window.Padding.x),
         uvpos.y*(window.ContainmentRect.w+window.Padding.w+window.Padding.y))
   end
   --print(id,uvpos)
end

function remoteAPI.click(id,right)
   if users[id].selected_tv then
      ---@type GNUI.container
      local window = users[id].selected_tv.Window
      window:setCursor(window.Cursor,nil,true)
   end
end

avatar:store("auth",remoteAuthAPI)
return TV