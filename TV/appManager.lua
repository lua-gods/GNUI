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

local appstore = {}
local apps = {}---@type table<any,ApplicationPackage>

function appstore:registerApp(factory,name,icon)
   apps[name] = {factory = factory,name = name,icon = icon}
   return self
end

appstore.apps = apps

return appstore