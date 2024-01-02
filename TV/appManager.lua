---@class Application
---@field TICK fun()?
---@field FRAME fun(delta_frame : number,delta_tick : number)?
---@field CLOSE fun()?
---@field KEY_PRESS fun(char : string?,key_id : Minecraft.keyid ,key_status : Event.Press.state,key_modifier : Event.Press.modifiers)?
---@field window GNUI.container?
---@field capture_keyboard boolean?

---@class ApplicationPackage
---@field factory fun(window: GNUI.container, TV: TV): Application
---@field name string
---@field icon Sprite?
---@field instance Application?

local eventLib = require("libraries.figui.eventHandler")
local update_timer = 1


local appstore = {APP_LIST_CHANGED = eventLib.new()}
local apps = {}---@type table<any,ApplicationPackage>
local app_debug_data = {}

function appstore:registerApp(factory,name,icon)
   apps[name] = {factory = factory,name = name,icon = icon}
   return self
end

appstore.apps = apps

events.WORLD_TICK:register(function ()
   update_timer = update_timer - 1
   if update_timer < 0 then
      update_timer = 20
      local something_changed = false
      for uuid, vars in pairs(world.avatarVars()) do
         for key, package_data in pairs(vars) do
            if key:find("^app.") then
               if app_debug_data[key] then
                  if app_debug_data[key] ~= package_data.uuid then -- the app updated
                     something_changed = true
                     app_debug_data[key] = package_data.uuid
                     appstore:registerApp(package_data.factory,package_data.name,package_data.icon or nil)
                  end
               else
                  something_changed = true
                  app_debug_data[key] = package_data.uuid
                  appstore:registerApp(package_data.factory,package_data.name,package_data.icon or nil)
               end
            end
         end
      end
      if something_changed then
         appstore.APP_LIST_CHANGED:invoke()
      end
   end
end)

return appstore