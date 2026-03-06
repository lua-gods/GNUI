---@diagnostic disable: param-type-mismatch

---@class GNUI.Render.Display
local Display = require("./display") ---@type GNUI.Render.Display

---@class GNUI.Render.VisualTask.Sprite : GNUI.Render.Visual
---@field texturePath string
---@field textureSize Vector2
---@field uv Vector4
---
---@field quad SpriteTask
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
		quad = vis.model:newSprite("task"..taskID):setRenderType("CUTOUT_EMISSIVE_SOLID")
	}
	
	setmetatable(self,Sprite)
	
	vis.tasks[taskID] = self
	return taskID
end


---INTERNAL CALLBACK for Display
---@param x number
---@param y number
function Sprite:setSize(x,y)
	local size = self.textureSize
	--self.quad:scale(x/size.x,y/size.y,1)
end


function Sprite:setVisible(visible)
	self.quad:setVisible(visible)
end


function Sprite:setColor(r,g,b)
	self.quad:color(r,g,b)
end


--────────────────────────-< Injected APIs >-────────────────────────--


---@param x number
---@param y number
function Display:setSpriteSize(visualID,taskID,x,y)
	local task = self:getTask(visualID,taskID)
	local size = task.textureSize
	task.quad:scale(x/size.x,y/size.y,1)
end


function Display:setSpriteVisible(visualID,taskID,visible)
	local task = self:getTask(visualID,taskID)
	task.quad:setVisible(visible)
end


function Display:setSpriteColor(visualID,taskID,r,g,b)
	local task = self:getTask(visualID,taskID)
	task.quad:color(r,g,b)
end


---@param x number
---@param y number
function Display:setSpritePos(visualID,taskID,x,y)
	local task = self:getTask(visualID,taskID)
	task.quad:pos(-x,-y)
end


---@param visualID integer
---@param taskID integer
---@param path string
function Display:setSpriteTexture(visualID,taskID,path)
	local task = self:getTask(visualID,taskID)
	local texture = textures[path]
	local textureSize = texture:getDimensions()
	local uv = vec(0,0,1,1)
	task.texturePath = path
	task.textureSize = textureSize
	task.uv = uv
	task.quad
	:texture(textures[path],textureSize.x,textureSize.y)
	:setUV(uv.xy / task.textureSize)
	:setRegion(uv.zw * task.textureSize)
end



---Sets the UV of the visual
---@param visualID integer
---@param u1 number
---@param v1 number
---@param u2 number
---@param v2 number
function Display:setSpriteUV(visualID,taskID,u1,v1,u2,v2)
	local task = self:getTask(visualID,taskID)
	local uv = vec(u1,v1,u2,v2)
	task.uv = uv
	task.quad
	:setUV(uv.xy/task.textureSize)
	:setRegion((uv.zw-uv.xy))
end


function Display:removeSprite(visualID,taskID)
	local task = self:getTask(visualID,taskID)
	task.quad:remove()
	self.visuals[visualID].tasks[taskID] = nil
end