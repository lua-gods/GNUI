--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: Display API
/ /_/ / /|  /  desc: handles all the updating for all visuals
\____/_/ |_/ source: link ]]

---@class GNUI.Render.Visual.Task
---@field [any] any


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
---@field tasks GNUI.Render.Visual[]


---@class GNUI.Render.Display
---@field visuals GNUI.Render.Visual[]
local Display = {}
Display.__index = Display


function Display.newDisplay()
	local self = {}
	setmetatable(self,Display)
	---@cast self GNUI.Render.Display
	
	self.visuals = {}
	self:newVisual()
	
	return self
end


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


---NOTE: INTERNAL USE ONLY
---@param visualID integer
---@param spriteID integer
---@return GNUI.Render.Visual
function Display:getTask(visualID,spriteID)
	local visual = self.visuals[visualID]
	assert(visual,"Visual Quad "..tostring(visualID).." not found")
	local task = visual.tasks[spriteID]
	assert(task,"Visual Quad "..tostring(visualID).." task "..tostring(spriteID).." not found")
	return task
end


---@param vis GNUI.Render.Visual
local function updateChildrenIndexes(vis)
	for i, child in ipairs(vis.children) do
		vis.index = i
		updateChildrenIndexes(child)
	end
end


---@param vis GNUI.Render.Visual
local function updateDimensions(vis)
	vis.model:pos(-vis.pos.x,-vis.pos.y,-vis.index)
	vis.model:scale(1,1,1)
end


---@param id integer
---@param childID integer
---@return GNUI.Render.Visual
function Display:addChild(id,childID)
	local vis = self.visuals[id]
	local child = self.visuals[childID]
	assert(vis,"Visual Quad "..tostring(id).." not found")
	assert(child,"Visual Quad "..tostring(childID).." not found")
	
	
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
---@param id integer
---@param childID integer
function Display:removeChild(id,childID)
	local vis = self.visuals[id]
	local child = self.visuals[childID]
	assert(vis,"Visual Quad "..id.." not found")
	assert(child,"Visual Quad "..id.." not found")
	
	if vis.children[child.id] == child then
		table.remove(vis.children, childID)
		
		updateChildrenIndexes(vis)
		child.parent = nil
		updateDimensions(child)
		updateDimensions(vis)
	end
	return self
end


---Removes the parent of the box
---@param id integer
function Display:removeParent(id)
	local vis = self.visuals[id]
	assert(vis,"Visual Quad "..id.." not found")
	
	if vis.parent then
		self:removeChild(vis.parent.id,vis.id)
	end
	return self
end


---Sets the parent of the box
---@param id integer
---@param parentID integer
function Display:setParent(id,parentID)
	local vis = self.visuals[id]
	local parent = self.visuals[parentID]
	assert(vis,"Visual Quad "..id.." not found")
	assert(parent,"Visual Quad "..parentID.." not found")
	
	self:removeParent(id)
	self:addChild(parentID,id)
end


function Display:free(id)
	local vis = self.visuals[id]
	assert(vis,"Visual Quad "..id.." not found")
	
	vis.model:remove()
	self.visuals[id] = nil
end


function Display:setPos(id,x,y)
	local vis = self.visuals[id]
	assert(vis,"Visual Quad "..id.." not found")
	vis.pos = vec(x,y)
	updateDimensions(vis)
end


function Display:setSize(id,x,y)
	local vis = self.visuals[id]
	assert(vis,"Visual Quad "..id.." not found")
	
	vis.size = vec(x,y)
	for key, task in pairs(vis.tasks) do
		task:setSize(x,y)
	end
	
	updateDimensions(vis)
end


function Display:setVisible(id,visible)
	local vis = self.visuals[id]
	assert(vis,"Visual Quad "..id.." not found")
	
	for key, task in pairs(vis.tasks) do
		task:setVisible(visible)
	end
	
	vis.model:setVisible(visible)
end


function Display:setColor(id,r,g,b)
	local vis = self.visuals[id]
	assert(vis,"Visual Quad "..id.." not found")
	
	for key, task in pairs(vis.tasks) do
		task:setColor(r,g,b)
	end
end


---@param type ModelPart.parentType
function Display:setParentType(type)
	self.visuals[1].model:setParentType(type)
end




return Display
