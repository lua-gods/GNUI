-- FROM: auriafoxgirl (note: old library)
---@class EventLibAPI
local lib = {}

---@class EventLib
local eventMetatable = {__type = "Event", __index = {}}
local eventsMetatable = {__index = {}}
eventMetatable.__index = eventMetatable

---@return EventLib
function lib.new()
  return setmetatable({subscribers = {}}, eventMetatable)
end
---@return EventLib
function lib.newEvent()
  return setmetatable({subscribers = {}}, eventMetatable)
end

function lib.table(tbl)
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
function eventMetatable:clear() self.subscribers = {} end

---Removes an event with the given name.
---@param match string
function eventMetatable:remove(match) self.subscribers[match] = nil end

---Returns how much listerners there are.
---@return integer
function eventMetatable:getRegisteredCount() return #self.subscribers end

function eventMetatable:__call(...) local returnValue = {} for _, data in pairs(self.subscribers) do table.insert(returnValue, {data.func(...)}) end return returnValue end

function eventMetatable:invoke(...) local returnValue = {} for _, data in pairs(self.subscribers) do table.insert(returnValue, {data.func(...)}) end return returnValue end

function eventMetatable:__len() return #self.subscribers end

-- events table
function eventsMetatable.__index(t, i) return t._table[i] or (type(i) == "string" and getmetatable(t._table[i:upper()]) == eventMetatable) and t._table[i:upper()] or nil end

function eventsMetatable.__newindex(t, i, v)
  if type(i) == "string" and type(v) == "function" and t._table[i:upper()] and getmetatable(t._table[i:upper()]) == eventMetatable then t._table[i:upper()]:register(v)
  else t._table[i] = v end
end

function eventsMetatable.__ipairs(t) return ipairs(t._table) end
function eventsMetatable.__pairs(t) return pairs(t._table) end

-- return library
return lib