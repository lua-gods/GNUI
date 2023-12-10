local GNUI = require("libraries.secret")

local lwindow_size = vectors.vec2()

local window = GNUI.newContainer()
window.Part:setParentType("HUD")

local m = 0
local p  = 0

window:setMargin(m,m,m,m)
window:setPadding(p,p,p,p)

host:setActionbar('{"text":"Start","color":"#'..vectors.rgbToHex(vectors.vec3(math.random(),math.random(),math.random()):normalize())..'"}')

events.WORLD_TICK:register(function ()
   local window_size = client:getScaledWindowSize()
   if window_size ~= lwindow_size then
      window:setSize(window_size)
      lwindow_size = window_size
   end
   local t = client:getSystemTime() / 300
   window:setTopLeft(math.sin(t) * 60 + 60,0)
end)


