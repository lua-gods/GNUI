---@diagnostic disable: param-type-mismatch

local BASE = (...):match(".+[./]GNUI"):gsub("/",".")

---@class GNUI.Render.Display
local Display = require(BASE..".render.visuals.display") ---@type GNUI.Render.Display

---@class GNUI.Render.Visual.Task.Sprite : GNUI.Render.Visual.Task
---@field color Vector3
---@field quad love.Quad?
---@field texturePath string
---@field textureSize Vector2
---@field image love.Image
---@field uv Vector4
local Sprite = {}
Sprite.__index = Sprite


---@param visualID integer
---@return integer
function Display:newSprite(visualID)
	local vis = self.visuals[visualID]
	assert(vis,"Visual Quad "..visualID.." not found")
	
	local taskID = #vis.tasks+1
	local self = {
		textureSize = vec(1,1),
		--quad = love.graphics.newQuad(0,0,0,0)
		visible = true
	}
	
	setmetatable(self,Sprite)
	
	vis.tasks[taskID] = self
	return taskID
end


---INTERNAL CALLBACK for Display
---@param x number
---@param y number
function Sprite:setSize(x,y)
end


function Sprite:setVisible(visible)
	self.visible = visible
end


function Sprite:setColor(r,g,b)
	self.color = vec(r,g,b)
end


--────────────────────────-< Injected APIs >-────────────────────────--


---@param x number
---@param y number
function Display:setSpriteSize(visualID,taskID,x,y)
	local task = self:getVisual(visualID,taskID)
	---@cast task GNUI.Render.Visual.Task.Sprite
	local size = task.textureSize
	task.size = vec(x,y)
end


function Display:setSpriteVisible(visualID,taskID,visible)
	local task = self:getVisual(visualID,taskID)
	---@cast task GNUI.Render.Visual.Task.Sprite
	task.visible = visible
end


function Display:setSpriteColor(visualID,taskID,r,g,b)
	local task = self:getVisual(visualID,taskID)
	---@cast task GNUI.Render.Visual.Task.Sprite
	task.color = vec(r,g,b)
end


---@param x number
---@param y number
function Display:setSpritePos(visualID,taskID,x,y)
	local task = self:getVisual(visualID,taskID)
	---@cast task GNUI.Render.Visual.Task.Sprite
	
	task.pos = vec(x,y)
end


---@param visualID integer
---@param taskID integer
---@param path string
function Display:setSpriteTexture(visualID,taskID,path)
	local task = self:getVisual(visualID,taskID)
	---@cast task GNUI.Render.Visual.Task.Sprite
	
	local image = love.graphics.newImage(path)
	local textureSize = vec(image:getWidth(),image:getHeight())
	local uv = vec(0,0,1,1)
	task.texturePath = path
	task.textureSize = textureSize
	task.uv = uv
	task.image = image
	task.quad = love.graphics.newQuad(0,0,textureSize.x,textureSize.y,image)
end

---Sets the UV of the visual
---@param visualID integer
---@param u1 number
---@param v1 number
---@param u2 number
---@param v2 number
function Display:setSpriteUV(visualID,taskID,u1,v1,u2,v2)
	local task = self:getVisual(visualID,taskID)
	---@cast task GNUI.Render.Visual.Task.Sprite
	
	
	local uv = vec(u1,v1,u2,v2)
	task.uv = uv
	
	if task.quad then
		task.quad:release()
	end
	if task.image then
		task.quad = love.graphics.newQuad(
			uv.x,uv.y,
			uv.z,uv.w,
			task.image
		)
	end
end


function Display:removeSprite(visualID,taskID)
	local task = self:getVisual(visualID,taskID)
	---@cast task GNUI.Render.Visual.Task.Sprite
	task.quad:release()
	self.visuals[visualID].tasks[taskID] = nil
end

function Sprite:draw()
	
end
