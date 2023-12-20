local eventLib = require("libraries.figui.eventHandler")
local utils = require("libraries.figui.utils")

local container = require("libraries.figui.elements.container")
local core = require("libraries.figui.core")

---@class GNUI.Label : GNUI.container
---@field Text string
---@field Words table<any,{word:string,len:number}>
---@field RenderTasks table<any,TextTask>
---@field TEXT_CHANGED EventLib
---@field Align Vector2
---@field AutoWarp boolean
---@field FontScale number
local label = {}
label.__index = function (t,i)
   return label[i] or container[i]
end

---@return GNUI.Label
function label.new(preset)
   ---@type GNUI.Label
   local new = container.new() or preset
   new.Text = ""
   new.TEXT_CHANGED = eventLib.new()
   new.Align = vectors.vec2()
   new.Words = {}
   new.RenderTasks = {}
   new.FontScale = 1

   new.TEXT_CHANGED:register(function ()
      new
      :_bakeWords()
      :_deleteRenderTasks()
      :_buildRenderTasks()
      :_updateRenderTasks()
   end,core.internal_events_name.."_txt")

   new.DIMENSIONS_CHANGED:register(function ()
      new
      :_updateRenderTasks()
   end,core.internal_events_name.."_txt")
   setmetatable(new,label)
   return new
end

---@param text string
---@return GNUI.Label
function label:setText(text)
   self.Text = text or ""
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

---Sets the font scale for all text thats by this container.
---@param scale number
function label:setFontScale(scale)
   self.FontScale = scale or 1
   self:_updateRenderTasks()
   return self
end

function label:_bakeWords()
   self.Words = utils.string2instructions(self.Text)
   return self
end

function label:_buildRenderTasks()
   for i, data in pairs(self.Words) do
      if type(data) == "table" then
         self.RenderTasks[i] = self.Part:newText("word" .. i):setText(data.word)   
      end
   end
   return self
end

function label:_updateRenderTasks()
   if #self.Words == 0 then return end
   local cursor = vectors.vec2(self.ContainmentRect.x,0)
   local current_line = 1
   local line_len = 0
   local lines = {}
   
   lines[current_line] = {width=0,len={}}
   -- generate lines
   for i, data in pairs(self.Words) do
      --- calculate where the next word should be placed
      local data_type = type(data)
      local current_word_width
      if data_type == "table" then -- word
         current_word_width = data.len * self.FontScale
         cursor.x = cursor.x + current_word_width
         line_len = line_len + current_word_width
      elseif data_type == "number" then
         current_word_width = data * self.FontScale
         cursor.x = cursor.x + current_word_width
         line_len = line_len + current_word_width
      elseif data_type == "boolean" then
         cursor.x = math.huge
      end

      -- inside bounds verification
      if cursor.x > self.ContainmentRect.z then
         -- reset cursor
         cursor.x = self.ContainmentRect.x + (current_word_width or 0)
         cursor.y = cursor.y - 8 * self.FontScale
         
         -- finalize data on next line
         lines[current_line].width = line_len * self.FontScale
         line_len = 0
         current_line = current_line + 1
         lines[current_line] = {width=0,len={}}
      end
      if data_type == "table" then
         lines[current_line].len[i] = vectors.vec2(-cursor.x + current_word_width,cursor.y) -- tells where the text should be positioned
      end
   end

   --- finalize last line
   lines[current_line].width =  line_len

   -- place render tasks
   for key, line in pairs(lines) do
      for id, word_length in pairs(line.len) do
         self.RenderTasks[id]
         :setPos(
            word_length.x + (line.width - self.ContainmentRect.z + self.ContainmentRect.x) * self.Align.x,
            word_length.y + ((current_line) * 8 * self.FontScale - (self.ContainmentRect.w - self.ContainmentRect.y)) * self.Align.y - self.ContainmentRect.y,
         -0.1)
         :setScale(self.FontScale,self.FontScale,1)
         :setVisible(true)
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

return label