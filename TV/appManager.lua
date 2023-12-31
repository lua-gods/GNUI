---@class Application
---@field INIT fun(window : GNUI.container,tv:TV)?
---@field OPEN fun(window : GNUI.container,tv:TV)?
---@field TICK fun(window : GNUI.container,tv:TV)?
---@field FRAME fun(window : GNUI.container,tv:TV,delta_frame : number,delta_tick : number)?
---@field CLOSE fun(window : GNUI.container,tv:TV)?
---@field KEY_PRESS fun(window : GNUI.container,tv:TV,player : Player,char : string?,key_id : Minecraft.keyid ,key_status : Event.Press.state,key_modifier : Event.Press.modifiers)?
---@field close function?
---@field window GNUI.container?

---@class ApplicationPackage
---@field factory fun(): Application
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