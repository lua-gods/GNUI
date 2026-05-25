--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: Display API
/ /_/ / /|  /  desc: handles all the updating for all visuals,
\____/_/ |_/ source: link ]]

local Tween = require("lib.GNtween")


---@class GNUI.Render.Visual.Task
---@field [any] any


---A render representation of a box, which contains multiple tasks and child visuals.
---@class GNUI.Render.Visual
---@field id integer
---
---@field index integer
---@field children GNUI.Render.Visual[]
---@field parent GNUI.Render.Visual?
---
---@field pos Vector2
---@field size Vector2
---
---@field model ModelPart
---@field tasks GNUI.Render.Visual.Task[]


---A collection of visuals
---@class GNUI.Render.Display
---@field visuals GNUI.Render.Visual[]
local Display = {}
Display.__index = Display


---Creates a new Display.
---@return GNUI.Render.Display
function Display.newDisplay()
	local self = {}
	setmetatable(self,Display)
	---@cast self GNUI.Render.Display
	
	self.visuals = {}
	self:newVisual()
	
	return self
end


---Creates a new Visual from that given display, 
---returns an ID that can be used to identify it in other functions.
---@return integer
function Display:newVisual()
	local id = #self.visuals+1
	local visual = {
		id = id,
		
		index = 1,
		children = {},
		
		pos = vec(0,0),
		size = vec(0,0),
		
		tasks = {},
		model = models:newPart("GNUI.visual" .. id),
	}
	
	self.visuals[id] = visual
	return id
end


---@param visualID integer
function Display:flash(visualID)
	if false and self.visuals[visualID] then
		local visual = self.visuals[visualID]
		Tween.new({
			from = 0,
			to = 1,
			duration = 0.25,
			tick = function (v, t)
	---@diagnostic disable-next-line: param-type-mismatch
				for index, value in pairs(visual.tasks) do
					value:setColor(1,v,v)
				end
			end,
			id=visual.id.."ee"
		})
	end
end


---NOTE: INTERNAL USE ONLY
---@param visualID integer
---@param spriteID integer
---@return GNUI.Render.Visual.Task?
function Display:getTask(visualID,spriteID)
	local visual = self.visuals[visualID]
	--assert(visual,"Visual Quad "..tostring(visualID).." not found")
	if not visual then return end
	local task = visual.tasks[spriteID]
	--assert(task,"Visual Quad "..tostring(visualID).." task "..tostring(spriteID).." not found")
	return task
end


---Recalculates all the children indexes.
---@param vis GNUI.Render.Visual
local function updateChildrenIndexes(vis)
	for i, child in ipairs(vis.children) do
		vis.index = i
		updateChildrenIndexes(child)
	end
end


---Updates the dimensions of the visual
---@param visual GNUI.Render.Visual
local function updateDimensions(visual)
	visual.model:pos(-visual.pos.x,-visual.pos.y,-visual.index)
	visual.model:scale(1,1,1)
end


---Adds the given child Visual to the given parent Visual
---@param visualID integer
---@param childVisualID integer
---@return GNUI.Render.Visual
function Display:addChild(visualID,childVisualID)
	local vis = self.visuals[visualID]
	local child = self.visuals[childVisualID]
	if not vis then return nil end
	assert(child,"Visual Quad "..tostring(childVisualID).." not found")
	
	
	child.parent = vis
	local id = #vis.children + 1
	vis.children[id] = vis
	child.index = id
	vis.model:addChild(child.model:remove())
	updateDimensions(child)
	updateDimensions(vis)
	return vis
end


---Removes a child from the box
---@param visualID integer
---@param childVisualID integer
function Display:removeChild(visualID,childVisualID)
	local vis = self.visuals[visualID]
	local child = self.visuals[childVisualID]
	if not vis then return end
	assert(child,"Visual Quad "..visualID.." not found")
	
	if vis.children[child.id] == child then
		table.remove(vis.children, childVisualID)
		
		updateChildrenIndexes(vis)
		child.parent = nil
		updateDimensions(child)
		updateDimensions(vis)
	end
	return self
end


---Removes the parent of the box
---@param visualID integer
function Display:removeParent(visualID)
	local vis = self.visuals[visualID]
	if not vis then return end
	
	if vis.parent then
		self:removeChild(vis.parent.id,vis.id)
	end
	return self
end


function Display:removeVisual(visualID)
	local vis = self.visuals[visualID]
	if not vis then return end
	vis.model:remove()
	self.visuals[visualID] = nil
end


---Sets the parent of the box
---@param visualID integer
---@param parentID integer
function Display:setParent(visualID,parentID)
	local vis = self.visuals[visualID]
	local parent = self.visuals[parentID]
	if not vis then return end
	if not parent then return end
	
	self:removeParent(visualID)
	self:addChild(parentID,visualID)
end


---Sets the position of this visual
---@param visualID integer
---@param x number
---@param y number
function Display:setPos(visualID,x,y)
	local vis = self.visuals[visualID]
	if vis then
		vis.pos = vec(x,y)
		updateDimensions(vis)
		self:flash(visualID)
	end
end


---Applies the size to all the tasks of the given visual.
---@param visualID integer
---@param x number
---@param y number
function Display:setSize(visualID,x,y)
	local vis = self.visuals[visualID]
	if vis then
		vis.size = vec(x,y)
		for key, task in pairs(vis.tasks) do
			task:setSize(x,y)
		end
		
		updateDimensions(vis)
		self:flash(visualID)
	end
end


---Sets the visibility of the visual
---@param visualID integer
---@param visible boolean
function Display:setVisible(visualID,visible)
	local vis = self.visuals[visualID]
	if not vis then return end
	self:flash(visualID)
	vis.model:setVisible(visible)
end


---Sets the tint color for all the tasks in this visual
---@param visualID integer
---@param r number
---@param g number
---@param b number
function Display:setColor(visualID,r,g,b)
	local vis = self.visuals[visualID]
	if not vis then return end
	
	for key, task in pairs(vis.tasks) do
		task:setColor(r,g,b)
	end
	
	self:flash(visualID)
end


---Sets the parent type.
---
---NOTE: This is Figura exclusive.
---@param type ModelPart.parentType
function Display:setParentType(type)
	self.visuals[1].model:setParentType(type)
end

---Returns the model of the visual
---
---NOTE: This is Figura exclusive.
---@param visualID integer
---@return ModelPart
function Display:getModelPart(visualID)
	local vis = self.visuals[visualID]
	return vis.model
end


--- Voids the display entirely.
function Display:free()
	for index, visual in ipairs(self.visuals) do
		visual.model:remove()
	end
	self.visuals = {}
	for index, value in ipairs(self) do
		self[index] = nil
	end
end


return Display