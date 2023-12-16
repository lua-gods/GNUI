---@type Elements, Utils, EventLibLib, Config, Debug
local elements, utils, eventLib, config, debug = ...

---@class Elements
---@field label GNUI.Label

--#region-->========================================[ Rich Text Label ]=========================================<--


---@class GNUI.Label : GNUI.container
---@field Text string
---@field Words table<any,{word:string,len:number}>
---@field RenderTasks table<any,TextTask>
---@field TEXT_CHANGED EventLib
---@field Align Vector2
---@field AutoWarp boolean
local label = {}
label.__index = function (t,i)
   return label[i] or elements.container[i]
end

---@return GNUI.Label
function label.new(preset)
   ---@type GNUI.Label
   local new = elements.container.new() or preset
   new.Text = ""
   new.TEXT_CHANGED = eventLib.new()
   new.Align = vectors.vec2()
   new.Words = {}
   new.RenderTasks = {}

   new.TEXT_CHANGED:register(function ()
      new
      :_bakeWords()
      :_deleteRenderTasks()
      :_buildRenderTasks()
      :_updateRenderTasks()
   end,config.internal_events_name.."_txt")

   new.DIMENSIONS_CHANGED:register(function ()
      new
      :_updateRenderTasks()
   end,config.internal_events_name.."_txt")
   setmetatable(new,label)
   return new
end

---@param text string
---@return GNUI.Label
function label:setText(text)
   self.Text = text
   self.TEXT_CHANGED:invoke(self.Text)
   return self
end

---Sets how the text is anchored to the container.  
---left 0 <-> 1 right  
---up 0 <-> 1 down  
--- horizontal or vertical by default is 0
---@param horizontal number?
---@param vertical number?
---@return GNUI.Label
function label:setAlign(horizontal,vertical)
   self.Align = vectors.vec2(horizontal or 0,vertical or 0)
   self:_updateRenderTasks()
   return self
end

local function split(inputString)
   local result = {}
   local pattern = "([^ \t\v\f\r\n]+)([ \t\v\f\r]+)([\n]*)"
   for nonWhitespace, whitespace, newline in inputString:gmatch(pattern) do
      if nonWhitespace ~= "" then
         table.insert(result, nonWhitespace)
      end
      if whitespace ~= "" then
         table.insert(result, #whitespace)
      end
      if newline ~= "" then
         table.insert(result, true)
      end
   end
   return result
end

--print(split("Apple  Bananas\nOranges Your mothEr"))

function label:_bakeWords()
   self.Words = {}
   local i = 0
   
   for word in string.gmatch(self.Text,"%S+") do
      i = i + 1
      self.Words[i] = {word = word,len=client.getTextWidth(word)}
   end
   return self
end

function label:_buildRenderTasks()
   for i, data in pairs(self.Words) do
      self.RenderTasks[i] = self.Part:newText("word" .. i):setText(data.word)
   end
   return self
end

function label:_updateRenderTasks()
   if #self.Words == 0 then return end
   local cursor = vectors.vec2(math.huge,8)
   local current_line = 1
   local line_len = 0
   local lines = {}
   -- generate lines
   for i, data in pairs(self.Words) do
      if cursor.x + data.len > self.ContainmentRect.z then -- if over the width of the bounding box
         cursor.x = self.ContainmentRect.x
         cursor.y = cursor.y - 8
         
         if current_line ~= 1 then
            lines[current_line].overall =  line_len - 4
            line_len = 0
         end
         current_line = current_line + 1
         lines[current_line] = {overall=0,len={}}
      end
      lines[current_line].len[i] = vectors.vec2(-cursor.x,cursor.y)
      cursor.x = cursor.x + data.len + 4
      line_len = line_len + data.len + 4
   end
   lines[current_line].overall =  line_len - 4
   -- place the text
   for key, line in pairs(lines) do
      for id, wlen in pairs(line.len) do
         self.RenderTasks[id]:setPos(
            wlen.x + (line.overall - (self.ContainmentRect.z - self.ContainmentRect.x)) * self.Align.x,
            wlen.y + (current_line * 8 - (self.ContainmentRect.w - self.ContainmentRect.y)) * self.Align.y -- - (self.ContainmentRect.w - self.ContainmentRect.y)) * self.Align.y
         ):setVisible(true)
      end
   end
   return self
end

function label:_deleteRenderTasks()
   for key, task in pairs(self.RenderTasks) do
      self.Part:removeTask(task:getName())
   end
   return self
end

--#endregion

return label