--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
--[[ An example script for interacting with the LGTV ]]
---@class auth : string

---@class TV
---@field auth fun(player : Player): auth
---@field keyPress fun(auth:auth,key:integer,status:integer,modifier:integer)
---@field raycastPress fun(auth:auth,pos:Vector3,dir:Vector3)
local TV
local auth

--- find the API
events.ENTITY_INIT:register(function ()
   ---@type {auth:fun(player : Player): auth, remote:{keyPress:fun(auth:string,key:integer), keyRelease:fun(auth:string,key:integer)}}?
   TV = world.avatarVars()[host:isHost() and avatar:getUUID() or "dc912a38-2f0f-40f8-9d6d-57c400185362"]
   if not TV then return end
   auth = TV.auth(player)
end)


local active = false
local toggle = keybinds:newKeybind("Toggle Remote","key.keyboard.right.alt")
toggle.press = function (modifiers, self)
   active = not active
   host:setActionbar("keyboard "..(active and "§aEnabled" or "§cDisabled"))
end

local primary = keybinds:fromVanilla("key.attack")

function pings.LGTVpress(auth,pos,dir)
   TV.raycastPress(auth,pos,dir)
end
primary.press = function ()
   pings.LGTVpress(auth,client:getCameraPos(),client:getCameraDir())
end

function pings.LGTVkey(user,key,status,modifier)
   TV.keyPress(user,key,status,modifier)
end

events.KEY_PRESS:register(function (key,status,modifier)
   if active and key ~= toggle:getID() then
      pings.LGTVkey(auth,key,status,modifier)
      return true
   end
end)