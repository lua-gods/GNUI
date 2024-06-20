local GNUI = require("libraries.gnui")

local screen = GNUI.createScreenCanvas()

for i = 1, 3, 1 do
   local btn = GNUI.newContainer()
   btn:setAnchor(0.25,0.5):setDimensions(0,i*30,300,24+i*30)

   ---@param event GNUI.InputEvent
   btn.INPUT:register(function (event)
      if event.key == "key.mouse.left" and not event.isPressed then
         btn:offsetDimensions(10,0)
      end
      return true
   end)

   screen:addChild(btn)
end