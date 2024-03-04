---@diagnostic disable: assign-type-mismatch, undefined-field
local eventLib = require("libraries.eventHandler")

local container = require("libraries.gnui.elements.container")
local core = require("libraries.gnui.core")

---Calculates text length along with its spaces as well.  
---accepts raw json component as well, if the given text is a table.
---This is a workaround for keeping the whitespace while getting the length because Minecraft trims them off.
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
---@field Text string|table               # The text that will be displayed on the label, for raw json, pass a table instead of a string json.
---@field TextData table                  # Baked data of the text.
---@field TextEffect TextEffect           # Determins the effects applied to the label.
---@field LineHeight number               # the distance between each line, defaults to 10.
---@field WrapText boolean                # Does nothing at the moment. but should send the text to the next line once the word is over the container's boundaries
---@field RenderTasks table<any,TextTask> # every render task used for rendering text
---@field Align Vector2                   # Determins where to fall on to when displaying the text (`0`-`1`, left-right, up-down)
---@field AutoWarp boolean                # Does nothing at the moment, but should toggle the word warping option.
---@field FontScale number                # Scales the text in the container.
---@field private _TextChanged boolean    
---@field TEXT_CHANGED EventLib           # Triggered when the text is changed.
local label = {}
label.__index = function (t,i)
   return label[i] or container[i]
end
label.__type = "GNUI.element.container.label"

---Creates a new label, which is just a container but can render text, separated into its own class for optimization.
---@return GNUI.Label
function label.new()
   ---@type GNUI.Label
   local new = container.new()
   new.Text = ""
   new.TextEffect = "NONE"
   new.LineHeight = 8
   new.WrapText = false
   new.TextData = {}
   new.Align = vectors.vec2()
   new.RenderTasks = {}
   new.FontScale = 1
   new._TextChanged = false
   new.TEXT_CHANGED = eventLib.new()
   
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

---Sets the text for the label to display.
---@param text string|table # For raw json text, use a table instead.
---@return self
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

---NOTE: Does not work yet.  
---determins whenever to allow word warping or not.
---@param wrap boolean
---@return self
function label:wrapText(wrap)
   self.WrapText = wrap
   self.DIMENSIONS_CHANGED:invoke()
   return self
end

---Sets how the text is anchored to the container.  
--- horizontal or vertical by default is 0, making them clump up at the top left
---@param horizontal number? # left 0 <-> 1 right
---@param vertical number?   #up 0 <-> 1 down  
---@return self
function label:setAlign(horizontal,vertical)
   self.Align = vectors.vec2(horizontal or 0,vertical or 0)
   self:_updateRenderTasks()
   return self
end

---Sets the font scale for all text thats by this container.
---@param scale number # defaults to `1`
---@return self
function label:setFontScale(scale)
   self.FontScale = scale or 1
   self:_updateRenderTasks()
   return self
end

---Determins the effect used for the label.  
---NONE, OUTLINE or SHADOW.
---@param effect TextEffect
---@return self
function label:setTextEffect(effect)
   self.TextEffect = effect
   label:_buildRenderTasks()
   self:_updateRenderTasks()
   return self
end

---Flattens the json components into one long array of components. by merging the `extra` tag in components into the base array.
---@param json table
---@return table
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
---@return table # TextData
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


---@return self
function label:_bakeWords()
   self.TextData = parseText(self.Text)
   self._TextChanged = true
   return self
end

---@return self
function label:_buildRenderTasks()
   local i = 0
   if self.TextData then
      for _, lines in pairs(self.TextData) do
         for _, component in pairs(lines.content) do
            if component.text then
               i = i + 1
               local task = self.ModelPart:newText("word" .. i):setText(toJson(component))
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
         if (pos.x - component.length > size.x / self.FontScale) or true then
            if self._TextChanged or true then
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
      self.ModelPart:removeTask(task:getName())
   end
   return self
end

return label