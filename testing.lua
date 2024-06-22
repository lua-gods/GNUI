local GNUI = require("libraries.gnui")

local screen = GNUI.getScreenCanvas()

for i = 1, 3, 1 do
   local btn = GNUI.newContainer()
   btn:setAnchor(0.25,0.5):setDimensions(0,i*30,300,24+i*30)

   local pressed = false
   ---@param event GNUI.InputEvent
   btn.INPUT:register(function (event)
      if event.key == "key.mouse.left" then
         pressed = event.isPressed
         return true
      end
   end)

   ---@param event GNUI.InputEventMouseMotion
   screen.MOUSE_POSITION_CHANGED:register(function (event)
      if pressed then
         btn:offsetDimensions(event.relative)
      end
   end)

   screen:addChild(btn)
end