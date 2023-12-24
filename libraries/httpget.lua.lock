--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
--[[ Makes it easier to request certain things with just a few lines ]]
local lib = {}

---@class HTTPRequestQueue
---@field peprocessor function?
local wait = {}
wait.__index = wait
local next_free = 0

local debug = false

---@param url string
---@param body_buffer Buffer
---@param preprocessor fun(result : any): (result: any)?
---@return HTTPRequestQueue
function lib.request(url,body_buffer,preprocessor)
   local id = "http"..tostring(next_free)
   ---@type HTTPRequestQueue
   local new = {
      response = net.http:request(url),
      url = url,
   }
   if debug then
      print('"'..url..'" requesting')
   end
   if body_buffer then
      new.response:body(body_buffer)
   end
   new.response = new.response:send()
   
   events.WORLD_TICK:register(function ()
      if new.response:isDone() then
         local result = new.response:getValue()
         local code = 404
         if result and result.getResponseCode then
            code = result:getResponseCode()
         end
         if debug then
            print('"'..new.url..'" sent back')
            if code == 200 then
               print('Error code '..code.. " OK")
            else
               print('Error code '..code)
            end
         end
         if code == 200 then
            if new.finish then
               local buffer = data:createBuffer()
               buffer:readFromStream(result:getData())
               buffer:setPosition(0)
               if preprocessor then
                  result = preprocessor(buffer)
               end
               buffer:close()
               new.finish(result)
            end
         else
            if new.fail then
               new.fail(code)
            end
         end
         events.WORLD_TICK:remove(id)
      end
   end,id)

   next_free = next_free + 1
   setmetatable(new,wait)
   return new
end

function lib.requestTexture(url,body,name)
   return lib.request(url,body,function (buffer)
      local output = buffer:readBase64()
      local success, result = pcall(function () return textures:read(name,output) end)
      if success then
         return result
      end
   end)
end

function lib.requestString(url,body)
   return lib.request(url,body,function (buffer)
      local output = buffer:readString()
      return output
   end)
end

---@param func fun(result : any)
---@return HTTPRequestQueue
function wait:onFinish(func)
   self.finish = func
   return self
end

---@param func fun(code : integer)
---@return HTTPRequestQueue
function wait:onFail(func)
   self.fail = func
   return self
end

return lib