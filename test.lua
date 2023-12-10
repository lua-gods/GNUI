local GNUI = require("libraries.GNUI")

--- creates the window
local window = GNUI.newContainer()
window.Part:setParentType("HUD")

-- testing features
local m = 20
local p  = 40
window:setMargin(m,m,m,m)
window:setPadding(p,p,p,p)

--- resizes it everytime the window resolution changes
local lwindow_size = vectors.vec2()
events.WORLD_TICK:register(function ()
   local window_size = client:getScaledWindowSize()
   if window_size ~= lwindow_size then
      window:setSize(window_size)
      lwindow_size = window_size
   end
   local t = client:getSystemTime() / 300
   window:setTopLeft(math.sin(t) * 60 + 60,0)
end)


