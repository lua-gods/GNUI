---@diagnostic disable: param-type-mismatch

---@class GNUI.Render.Display
local Display = require("./display") ---@type GNUI.Render.Display


---@class GNUI.Text
---@field text string
---@field color string


---@class GNUI.Render.VisualTask.Label : GNUI.Render.Visual
---@field padding Vector4
---@field text string|GNUI.Text[]
---@field jsonText string
---@field textColor string
---@field textAlignment Vector2
---@field wrapText boolean
---
---@field label TextTask
local Label = {}
Label.__index = Label


local function parseText(text,defaultColor)
	local tableText
	if type(text) == "string" then
		tableText = {{text=text,color="#"..defaultColor}}
	else
		if type(text) == "table" then
			for index, value in ipairs(text) do
				if not value.color then
					value.color = defaultColor
				end
			end
			tableText = text
		end
	end
	return toJson(tableText)
end


---@param visualID integer
---@return integer
function Display:newLabel(visualID)
	local vis = self.visuals[visualID]
	assert(vis,"Visual Quad "..visualID.." not found")
	
	local taskID = #vis.tasks+1
	local self = {
		
		size = vec(0,0),
		padding = vec(0,0,0,0),
		
		textAlignment = vec(-1,1),
		textColor = "ffffff",
		wrapText = true,
		label = vis.model:newText("task"..taskID),
	}
	
	setmetatable(self,Label)
	
	vis.tasks[taskID] = self
	return taskID
end


---@param task GNUI.Render.VisualTask.Label
local function updateLabelText(task)
	if task.text then
		task.jsonText = parseText(task.text,task.textColor)
		task.label:setText(task.jsonText)
	end
end

---@param task GNUI.Render.VisualTask.Label
local function updateLabelPos(task)
	if task.label and task.text then
		task.label:alignment(task.textAlignment.x == -1 and "LEFT" or task.textAlignment.x == 0 and "CENTER" or "RIGHT")
		local fineWidth = task.size.x-task.padding.x-task.padding.z
		task.label:setWidth(fineWidth)
		local textDim = client.getTextDimensions(task.jsonText, fineWidth, task.wrapText)
		local align = task.textAlignment*0.5+0.5
		task.label:setPos(
			math.floor(math.lerp(-task.padding.x,task.padding.z,align.x) - task.size.x * (align.x)+0.5),
			math.floor(math.lerp(
				-task.padding.y,
				-task.size.y+task.padding.w+textDim.y,
				align.y
			)+0.5)
		)
	end
end



---@param x number
---@param y number
function Label:setSize(x,y)
	self.size = vec(x,y)
	updateLabelPos(self)
end



function Label:setVisible(visible)
	self.label:setVisible(visible)
end


---Sets the label color
---TODO: investigate label set color method
function Label:setColor(r,g,b)
	self.textColor = vectors.rgbToHex(r,g,b)
end


--────────────────────────-< Injected APIs >-────────────────────────--


---Sets the padding of the given label
---@param visualID integer
---@param taskID integer
---@param left number
---@param top number
---@param right number
---@param bottom number
function Display:setLabelPadding(visualID,taskID,left,top,right,bottom)
	local task = self:getTask(visualID,taskID)
	task.padding = vec(left,top,right,bottom)
	updateLabelPos(task)
end


---Sets the visibility of the given label
function Display:setLabelVisible(visualID,taskID,visible)
	local task = self:getTask(visualID,taskID)
	task.label:setVisible(visible)
end


---Sets the color of the given label
---@param visualID integer
---@param taskID integer
---@param r number
---@param g number
---@param b number
function Display:setLabelColor(visualID,taskID,r,g,b)
	local task = self:getTask(visualID,taskID)
	task.textColor = vectors.rgbToHex(r,g,b)
	task.jsonText = parseText(task.text,task.textColor)
	updateLabelText(task)
	updateLabelPos(task)
end


---Sets the text of the given label
---@param visualID integer
---@param taskID integer
---@param text string|GNUI.Text[]
function Display:setLabelText(visualID,taskID,text)
	local task = self:getTask(visualID,taskID)
	task.text = text
	
	updateLabelText(task)
	updateLabelPos(task)
end


---Sets the alignment of the given label
---@param visualID integer
---@param taskID integer
---@param h -1|0|1
---@param v -1|0|1
function Display:setLabelAlignment(visualID,taskID,h,v)
	local task = self:getTask(visualID,taskID)
	task.textAlignment = vec(h,v)
	updateLabelPos(task)
end


---Removes the given label
---@param visualID integer
---@param taskID integer
function Display:removeLabel(visualID,taskID)
	local task = self:getTask(visualID,taskID)
	task.label:remove()
	self.visuals[visualID].tasks[taskID] = nil
end