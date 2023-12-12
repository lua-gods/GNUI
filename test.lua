local function superSine(value,seed,depth)
   math.randomseed(seed)
   local result = 0
   for i = 1, depth, 1 do
      result = result + math.sin(value * (math.random() * math.pi * depth) + math.random() * math.pi * depth)
   end
   return result / depth
end

local lorem = [[
   Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
   Convallis convallis tellus id interdum velit laoreet id donec. Vitae suscipit tellus mauris a diam maecenas sed. 
   Mi tempus imperdiet nulla malesuada pellentesque elit eget. Enim sit amet venenatis urna cursus eget. 
   A cras semper auctor neque vitae tempus quam pellentesque nec. Venenatis cras sed felis eget velit aliquet. 
   Cursus vitae congue mauris rhoncus. Bibendum neque egestas congue quisque egestas diam in. 
   Sit amet risus nullam eget felis. Aliquam vestibulum morbi blandit cursus risus at ultrices mi. 
   Vulputate enim nulla aliquet porttitor lacus luctus accumsan. Purus sit amet luctus venenatis. 
   Morbi quis commodo odio aenean sed. Nunc id cursus metus aliquam eleifend mi in nulla. 
   Et tortor at risus viverra adipiscing at in tellus integer. Elementum sagittis vitae et leo duis ut diam.]]

local GNUI = require("libraries.GNUI")

--- creates the window
local window = GNUI.newContainer()
window.Part:setParentType("HUD")

-- testing features
local m = 10
local p  = 5
window:setMargin(m,m,m,m)
window:setPadding(p,p,p,p)

--- resizes it everytime the window resolution changes
local lwindow_size = vectors.vec2()
events.WORLD_RENDER:register(function ()
   local window_size = client:getScaledWindowSize()
   if window_size ~= lwindow_size then
      window:setSize(window_size)
      lwindow_size = window_size
   end
   local i = 40
   local t = client:getSystemTime() / 10000
   window:setTopLeft(
      superSine(t,1,8) * i + i,
      superSine(t,4,8) * i + i)
   window:setBottomRight(
      window_size.x - superSine(t,3,8) * i - i,
      window_size.y - superSine(t,4,8) * i - i)
end)

local container = GNUI.newContainer()
window:addChild(container)
container
:setPos(0,0)
:setMargin(5,5,5,5)
:setPadding(10,10,10,10)
:setAnchor(0,0,0.5,1)


--local label = GNUI.newLabel()
--window:addChild(label)
--label
--:setPos(0,0)
--:setMargin(5,5,5,5)
--:setPadding(10,10,10,10)
--:setAnchor(0.5,0,1,1)
