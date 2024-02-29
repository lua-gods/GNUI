---@diagnostic disable: assign-type-mismatch, undefined-field
local eventLib = require("libraries.eventHandler")
local utils = require("libraries.gnui.utils")

local container = require("libraries.gnui.elements.container")
local core = require("libraries.gnui.core")

---Calculates text length along with its spaces as well.  
---accepts raw json component as well, if the given text is a table.
---@param text string|table
---@return integer
local function getlen(text)
   local t = type(text)
   if t == "string" then
      return client.getTextWidth(text:gsub(" ","|"))
   else
      local og = text.text
      text.text = text.text:gsub(" ","||")
      local l = client.getTextWidth(toJson(text))
      text.text = og
      return l
   end
end

---@alias TextEffect string
---| "NONE"
---| "OUTLINE"
---| "SHADOW"

---@class GNUI.Label : GNUI.container
---@field Text string
---@field TextData table
---@field TextEffect TextEffect
---@field LineHeight number
---@field WrapText boolean
---@field RenderTasks table<any,TextTask>
---@field TEXT_CHANGED EventLib
---@field Align Vector2
---@field AutoWarp boolean
---@field Offset Vector2
---@field FontScale number
---@field _TextChanged boolean -- for optimization purposes
local label = {}
label.__index = function (t,i)
   return label[i] or container[i]
end
label.__type = "GNUI.element.container.label"

---@return GNUI.Label
function label.new(preset)
   ---@type GNUI.Label
   local new = container.new() or preset
   new.Text = ""
   new.TEXT_CHANGED = eventLib.new()
   new.TextEffect = "NONE"
   new.LineHeight = 8
   new.WrapText = false
   new.TextData = {}
   new.Align = vectors.vec2()
   new.RenderTasks = {}
   new.FontScale = 1
   new._TextChanged = false

   new.TEXT_CHANGED:register(function ()
      new
      :_bakeWords()
      :_deleteRenderTasks()
      :_buildRenderTasks()
      :_updateRenderTasks()
   end,core.internal_events_name.."_txt")

   new.SIZE_CHANGED:register(function ()
      new:_updateRenderTasks()
   end,core.internal_events_name.."_txt")

   new.PARENT_CHANGED:register(function ()
      if not new.Parent then
         new:_deleteRenderTasks()
      end
      new.TEXT_CHANGED:invoke(new.Text)
   end,core.internal_events_name.."_txt")
   setmetatable(new,label)
   return new
end

---@param text string|table
---@return GNUI.Label
function label:setText(text)
   local t = type(text)
   if t == "table" then
      if not text[1] then -- convert to array
         text = {text}
      end
      self.Text = text
   else
      self.Text = text or ""
   end
   self.TEXT_CHANGED:invoke(self.Text)
   return self
end

function label:wrapText(wrap)
   self.WrapText = wrap
   self:_deleteRenderTasks()
   self:_buildRenderTasks()
   self:_updateRenderTasks()
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

---@param effect TextEffect
function label:setTextEffect(effect)
   self.TextEffect = effect
   label:_buildRenderTasks()
   self:_updateRenderTasks()
   return self
end

local function flattenComponents(json)
   local lines = {}
   local content = {}
   local content_length = 0
   local l = 0
   if json.extra then
      json = {json}
   end
   for _, comp in pairs(json) do
      if comp.text and (comp.text ~= "") then
         local end_line = select(2,string.gsub(comp.text,"\n",""))
         local i = 0
         for line in string.gmatch(comp.text,"[^\n]*") do -- separate each line
            content = {}
            content_length = 0
            for word in string.gmatch(line,"[%s]*[%S]+[%s]*") do -- split words
               i = i + 1
               local prop = {}
               -- only append used data in labels
               prop.font = comp.font
               prop.bold = comp.bold
               prop.italic = comp.italic
               prop.color = comp.color
               l = 0
               prop.text = word
               if prop.font then
                  l = client.getTextWidth(toJson(prop))
               else
                  l = getlen(prop)
               end
               prop.text = word
               prop.length = l
               content_length = content_length + l
               content[#content+1] = prop
            end
            if i ~= end_line then -- last line
               lines[#lines+1] = {content = content,length = content_length}
            end
         end
      end
      if comp.extra then
         for _, line in pairs(flattenComponents(comp.extra)) do
            for _, data in pairs(line.content) do
               content[#content+1] = data
               content_length = content_length + line.length
            end
         end
      end
   end
   return lines
end

---@param from string|table
local function parseText(from)
   local lines = {}
   local t = type(from)
   if t == "table" then
      lines = flattenComponents(from)
   elseif t == "string" then
      for line in string.gmatch(from,"[^\n]*") do -- separate each line
         local compose = {}
         for word in string.gmatch(line,"[%S]+[%s]*") do -- split words
            local l = getlen(word)
            compose[#compose+1] = {text=word,length=l}
         end
         local l = getlen(line)
         lines[#lines+1] = {length=l,content=compose}
      end
   end
   return lines
end



function label:_bakeWords()
   self.TextData = parseText(self.Text)
   self._TextChanged = true
   return self
end

function label:_buildRenderTasks()
   local i = 0
   if self.TextData then
      for _, lines in pairs(self.TextData) do
         for _, component in pairs(lines.content) do
            if component.text then
               i = i + 1
               local task = self.Part:newText("word" .. i):setText(toJson(component))
               if self.TextEffect == "OUTLINE" then
                  task:setOutline(true)
               elseif  self.TextEffect == "SHADOW" then
                  task:setShadow(true)
               end
               self.RenderTasks[i] = task
            end
         end
      end
   end
   return self
end

function label:_updateRenderTasks()
   local i = 0
   local size = self.ContainmentRect.xy - self.ContainmentRect.zw -- inverted for optimization
   local pos = vectors.vec2(0,self.LineHeight)
   if #self.TextData == 0 then return end
   local offset = vectors.vec2(0,(size.y / self.FontScale)  * self.Align.y + #self.TextData * self.LineHeight * self.Align.y)
   for _, line in pairs(self.TextData) do
      pos.x = 0
      pos.y = pos.y - self.LineHeight
      offset.x = (size.x / self.FontScale) * self.Align.x + line.length * self.Align.x
      for c, component in pairs(line.content) do
         i = i + 1
         local task = self.RenderTasks[i]
         if (pos.x - component.length > size.x / self.FontScale) or c == 1 then
            if self._TextChanged then
               task
               :setPos(pos.xy_:add(offset.x,offset.y) * self.FontScale)
               :setScale(self.FontScale,self.FontScale,self.FontScale)
            end
         else
            task:setVisible(false)
         end
         pos.x = pos.x - component.length
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