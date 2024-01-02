local appManager = require("TV.appManager")
local FiGUI = require("libraries.FiGUI")


local factory = function (window,tv) -- creates an instance of the app
   ---@type Application
   local app = {}
   app.capture_keyboard = true
   local update = false

   local logs = ""
   local input = ""
   local carrot = 0

   function log(...)
      local gog = {...}
      local final = ""
      for key, value in pairs(gog) do
         final = final .. tostring(value) .. (#gog == key and "" or ", ") 
      end
      logs = logs .. "\n" .. final
      update = true
   end

   local function reset()
      logs = "Lua Goofs [Version 0.3.1.0]\n(c) Lua-Gods. All rights reserved.\n \n"
      update = true
   end

   -->====================[ Environment ]====================<--

   local ENV = {}

   ENV.help = function ()
      local final = ""
      for key, _ in pairs(ENV) do
         final = final .. key .. "\n"
      end
      ENV.log(final)
   end

   ENV.clear = reset
   ENV.log = log
   ENV.print = log
   ENV.roll = function (count)
      log(math.random(1,count) .. "(1 - ".. count .. ")")
   end

   ENV.coinflip = function (sides)
      log(math.random() > 0.5 and "Heads." or "Tails.")
   end

   -->====================[ Generic ]====================<--

   local text = FiGUI.newLabel()
   ENV.exit = function ()
      tv:setApp(tv.default_app)
   end
   text:setText("Hello World"):setFontScale(0.3)
   text:setAnchor(0,0,1,1)
   text:canCaptureCursor(false)
   window:setMargin(1,1,1,1)
   window:addChild(text)
   
   local close = FiGUI.newLabel()
   close:setText("X"):setFontScale(0.3)
   close:setSize(3,3)
   close:setAlign(0.5,0.5)
   close:setAnchor(1,0,1,0)
   close:setPos(-3,0)
   close.PRESSED:register(function ()
      tv:setApp(tv.default_app)
   end)
   window:addChild(close)
   reset()

   local function getLastLines(inputString)
      local lines = {}
      for line in inputString:gmatch("[^\r\n]+") do
          table.insert(lines, line)
      end
      local last_lines = {}
      local total = #lines+2
      local start_line = math.max(total - (math.floor((3*16) / 8 / text.FontScale)-1), 1)
      for i = start_line, total do
          table.insert(last_lines, lines[i])
      end
      return table.concat(last_lines, "\n")
   end

   function app.TICK()
      if update then
         update = false
         logs = getLastLines(logs)
         local final = logs .. "\n".."\n> " .. input:sub(0,carrot) .. "|" .. input:sub(carrot+1,-1)
         text:setText(final)
      end
   end

   function app.KEY_PRESS(char, key_id, key_status, key_modifier)
      if key_status == 1 or key_status == 2 then
         if key_id == 259 then -- backspace
            input = input:sub(0,math.max(carrot-1,0)) .. input:sub(carrot+1,-1)
            carrot = math.max(carrot - 1,0)
         elseif key_id == 263 then -- arrow left
            carrot = math.clamp(carrot - 1,0,#input)
         elseif key_id == 262 then -- arrow right
            carrot = math.clamp(carrot + 1,0,#input)
         elseif key_id == 257 then -- enter
            local ok, result = pcall(load("return "..input,"terminal",ENV))
            if not ok then
               ok, result = pcall(load(input,"terminal",ENV))
               if not ok then
                  log(result)
               else
                  if result then
                     log(result)
                  end
               end
            else
               if result then
                  log(result)
               end
            end
            input = ""
         else
            if char then
               input = input:sub(0,carrot) .. char .. input:sub(carrot+1,-1)
               carrot = carrot + 1
            end
         end
         carrot = math.clamp(carrot,0,#input)
         update = true
      end
   end

   return app
end

appManager:registerApp(factory,"Terminal",textures["TV.apps.terminal.terminal_icon"])