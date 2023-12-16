local main = {}

---@class Config
local config = {
   debug_visible = true,
   debug_event_name = "_c",
   internal_events_name = "__a",
}

--#region EventLib
---@class EventLibLib
local eventLib = {}

---@class EventLib
local eventMetatable = {__type = "Event", __index = {}}
local eventsMetatable = {__index = {}}
eventMetatable.__index = eventMetatable

---@return EventLib
function eventLib.new()
   return setmetatable({subscribers = {}}, eventMetatable)
end
---@return EventLib
function eventLib.newEvent()
   return setmetatable({subscribers = {}}, eventMetatable)
end

function eventLib.table(tbl)
   return setmetatable({_table = tbl or {}}, eventsMetatable)
end

---Registers an event
---@param func function
---@param name string?
function eventMetatable:register(func, name)
   if name then
      self.subscribers[name] = {func = func}
   else
      table.insert(self.subscribers, {func = func})
   end
end

---Clears all event
function eventMetatable:clear()
   self.subscribers = {}
end

---Removes an event with the given name.
---@param match string
function eventMetatable:remove(match)
   self.subscribers[match] = nil
end

---Returns how much listerners there are.
---@return integer
function eventMetatable:getRegisteredCount()
   return #self.subscribers
end

function eventMetatable:__call(...)
   local returnValue = {}
   for _, data in pairs(self.subscribers) do
      table.insert(returnValue, {data.func(...)})
   end
   return returnValue
end

function eventMetatable:invoke(...)
   local returnValue = {}
   for _, data in pairs(self.subscribers) do
      table.insert(returnValue, {data.func(...)})
   end
   return returnValue
end

function eventMetatable:__len()
   return #self.subscribers
end

-- events table
function eventsMetatable.__index(t, i)
   return t._table[i] or (type(i) == "string" and getmetatable(t._table[i:upper()]) == eventMetatable) and t._table[i:upper()] or nil
end

function eventsMetatable.__newindex(t, i, v)
   if type(i) == "string" and type(v) == "function" and t._table[i:upper()] and getmetatable(t._table[i:upper()]) == eventMetatable then
      t._table[i:upper()]:register(v)
   else
      t._table[i] = v
   end
end

function eventsMetatable.__ipairs(t)
   return ipairs(t._table)
end
function eventsMetatable.__pairs(t)
   return pairs(t._table)
end

--#endregion

--#region-->========================================[ Utilities ]=========================================<--

---@class Utils
local utils = {}

---Returns the same vector but the `X` `Y` are the **min** and `Z` `W` are the **max**.  
---vec4(1,2,0,-1) --> vec4(0,-1,1,2)
---@param vec4 Vector4
---@return Vector4
function utils.vec4FixNegativeBounds(vec4)
   return vectors.vec4(
      math.min(vec4.x,vec4.z),
      math.min(vec4.y,vec4.w),
      math.max(vec4.x,vec4.z),
      math.max(vec4.y,vec4.w)
   )
end

---Sets the position`(x,y)` while translating the other position`(x,z)`
---@param vec4 Vector4
---@param x number
---@param y number
---@return Vector4
function utils.vec4SetPos(vec4,x,y)
   local lpos = vec4.xy
   vec4.x,vec4.y = x,y
   vec4.z,vec4.w = x-lpos.x,y-lpos.y
   return vec4
end

---Sets the other position`(x,z)` while translating the position`(x,y)`
---@param vec4 Vector4
---@param z number
---@param w number
---@return Vector4
function utils.vec4SetOtherPos(vec4,z,w)
   local lpos = vec4.zw
   vec4.z,vec4.w = z,w
   vec4.x,vec4.y = z-lpos.x,w-lpos.y
   return vec4
end

---Gets the size of a vec4
---@param vec4 Vector4
---@return Vector2
function utils.vec4GetSize(vec4)
   return (vec4.zw - vec4.xy) ---@type Vector2
end

function utils.figureOutVec2(posx,y)
   local typa, typb = type(posx), type(y)
   
   if typa == "Vector2" and typb == "nil" then
      return posx:copy()
   elseif typa == "number" and typb == "number" then
      return vectors.vec2(posx,y)
   else
      error("Invalid Vector2 parameter, expected Vector2 or (number, number), instead got ("..typa..", "..typb..")")
   end
end

function utils.figureOutVec3(posx,y,z)
   local typa, typb, typc = type(posx), type(y), type(z)
   
   if typa == "Vector2" and typb == "nil" and typc == "nil" then
      return posx:copy()
   elseif typa == "number" and typb == "number" and typc == "number" then
      return vectors.vec3(posx,y,z)
   else
      error("Invalid Vector3 parameter, expected Vector3 or (number, number, number), instead got ("..typa..", "..typb..", "..typc..")")
   end
end

--#endregion

--#region-->========================================[ Debug ]=========================================<--

---@class Debug
local debug = {}
debug.texture = textures:newTexture("1x1white",1,1):setPixel(0,0,vectors.vec3(1,1,1))

--#endregion

--#region-->========================================[ Init ]=========================================<--

---@class Elements
---@field [string] GNUI.element | false
local elements = {}

local dir = ... .. "/elements"
local function loadElement(element)
    if rawget(elements, element) then return elements[element] end
    local path = dir.."/"..element..".lua"
    if not file:exists(path) then
        elements[element] = false
        return false
    end
    local ret = load(file:readString(path), "data:"..path)(elements, utils, eventLib, config, debug)
    elements[element] = ret
    return ret
end

setmetatable(elements, {
    __index = function (t, i)
        return loadElement(i)
    end
})

for _, file in ipairs(file:list(dir)) do
   local e = loadElement(file:match("^(.+)%.lua$"))
   -- loadElement will return false when a file is not found, so scripts that return explicitly nil returned nothing
   if e == nil then
      error("File "..file.." does not return anything")
   end
end

--#endregion

setmetatable(main, {
   __index=function (t, k)
      local element = k:match("^new(.+)$")
      if element then
         local e = elements[element:lower()]
         if e then return e.new end
         error("Element \""..element.."\" does not exist",2)
      end
      return rawget(t, k)
   end
})

main.elements = elements
main.utils = utils
return main