---@diagnostic disable: param-type-mismatch
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Nineslice Module
/ /_/ / /|  /  desc: an extension of sprite which can display a texture
\____/_/ |_/ source: link ]]

local gncommon = require("lib.gncommon") ---@type GNCommon
local Style = require("../styles/nineslice") ---@type GNUI.Sprite.Nineslice.StyleAPI
local config = require("../../config") ---@type GNUI.config

local Sprite = require("./sprite") ---@type GNUI.SpriteAPI
local Quad = require("./quad") ---@type GNUI.Sprite.QuadAPI

---@class GNUI.Sprite.NinesliceAPI
local NinesliceAPI = {}


---@class GNUI.Sprite.Nineslice : GNUI.Sprite.Quad
---@field style GNUI.Sprite.Nineslice.Style 
---
---@field idTopLeft integer
---@field idTop integer
---@field idTopRight integer
---
---@field idLeft integer
---@field idCenter integer
---@field idRight integer
---
---@field idBottomRight integer
---@field idBottom integer
---@field idBottomLeft integer
---
---@field ids integer[]
local Nineslice = {}
Nineslice.__index = function (t,i)
	return rawget(t,i) or Nineslice[i] or Quad.index(i) or Sprite.index(i)
end


function NinesliceAPI.getIndex() return Nineslice.__index end


---A representation of a quad that will get drawn
---@param box GNUI.Box
---@return GNUI.Sprite.Nineslice
function NinesliceAPI.new(box)
	assert(box,"no GNUI.Box given")
	local self = Sprite.new(box)
	---@cast self GNUI.Sprite.Nineslice
	
	self.idTopLeft = self.render:newVisualQuad()
	self.idTop = self.render:newVisualQuad()
	self.idTopRight = self.render:newVisualQuad()
	
	self.idLeft = self.render:newVisualQuad()
	self.idCenter = self.render:newVisualQuad()
	self.idRight = self.render:newVisualQuad()
	
	self.idBottomRight = self.render:newVisualQuad()
	self.idBottom = self.render:newVisualQuad()
	self.idBottomLeft = self.render:newVisualQuad()
	
	self.ids = {
		self.idTopLeft,
		self.idTop,
		self.idTopRight,
		
		self.idLeft,
		self.idCenter,
		self.idRight,
		
		self.idBottomLeft,
		self.idBottom,
		self.idBottomRight,
	}
	
	setmetatable(self, Nineslice)
	self:setBox(box)
	return self
end


Style.setInstancer(NinesliceAPI.new)
---@return GNUI.Sprite.Nineslice.Style
function NinesliceAPI.newStyle()
	return Style.new()
end


--────────────────────────-< API >-────────────────────────--


---@param path string
---@generic self
---@param self self
---@return self
function Nineslice:setTexture(path)
	---@cast self GNUI.Sprite.Nineslice
	self.texture_path = path
	self.render:setTexture(self.idTopLeft,self.texture_path)
	self.render:setTexture(self.idTop,self.texture_path)
	self.render:setTexture(self.idTopRight,self.texture_path)
	
	self.render:setTexture(self.idLeft,self.texture_path)
	self.render:setTexture(self.idCenter,self.texture_path)
	self.render:setTexture(self.idRight,self.texture_path)
	
	self.render:setTexture(self.idBottomLeft,self.texture_path)
	self.render:setTexture(self.idBottom,self.texture_path)
	self.render:setTexture(self.idBottomRight,self.texture_path)
	return self
end


function Nineslice:updateSprites()
	local border = self.style.border
	local expand = self.style.expand
	local size = self.size + expand.xy + expand.zw
	local pos = self.pos - expand.xy
	self.render:setSize(self.id,      size.x, size.y)
	
	self.render:setSize(self.idTopLeft,  border.x, border.y)
	self.render:setSize(self.idTop,      size.x-border.x-border.z, border.y)
	self.render:setSize(self.idTopRight, border.z, border.y)
	
	self.render:setSize(self.idLeft,  border.x, size.y-border.y-border.w)
	self.render:setSize(self.idCenter,      size.x-border.x-border.z, size.y-border.y-border.w)
	self.render:setSize(self.idRight, border.z, size.y-border.y-border.w)
	
	self.render:setSize(self.idBottomLeft,  border.x, border.w)
	self.render:setSize(self.idBottom,      size.x-border.x-border.z, border.w)
	self.render:setSize(self.idBottomRight, border.z, border.w)
	
	self.render:setPos(self.id,  self.pos.x,self.pos.y)
	
	self.render:setPos(self.idTopLeft,  pos.x, pos.y)
	self.render:setPos(self.idTop,      pos.x+border.x, pos.y)
	self.render:setPos(self.idTopRight, pos.x+size.x-border.z, pos.y)
	
	self.render:setPos(self.idLeft,  pos.x, pos.y+border.y)
	self.render:setPos(self.idCenter,      pos.x+border.x, pos.y+border.y)
	self.render:setPos(self.idRight, pos.x+size.x-border.z, pos.y+border.y)
	
	self.render:setPos(self.idBottomLeft,  pos.x, pos.y+size.y-border.w)
	self.render:setPos(self.idBottom,      pos.x+border.x,pos.y+size.y-border.w)
	self.render:setPos(self.idBottomRight, pos.x+size.x-border.z,pos.y+size.y-border.w)
end


---@overload fun(self: GNUI.Sprite, xy: Vector2): self
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Nineslice:setPos(x,y)
	---@cast self GNUI.Sprite.Nineslice
	self.pos = gncommon.vec2(x,y)
	self:updateSprites()
	return self
end



---@overload fun(self: GNUI.Sprite, xy: Vector2): self
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Nineslice:setSize(x,y)
	---@cast self GNUI.Sprite.Nineslice
	self.size = gncommon.vec2(x,y)
	self:updateSprites()
	return self
end


function Nineslice:applyStyle()
	if self.style then
		local style = self.style
		local border = self.style.border
		local uv = style.uv:copy():add(0,0,1,1)
		
		self:setTexture(style.texture_path)
		
		self.render:setUV(self.idTopLeft,  uv.x,             uv.y,      uv.x+border.x,       uv.y+border.y)
		self.render:setUV(self.idTop,      uv.x+border.x,    uv.y,      uv.z-border.z,       uv.y+border.y)
		self.render:setUV(self.idTopRight, uv.z-border.z,    uv.y,      uv.z,                uv.y+border.y)
		
		self.render:setUV(self.idLeft,  uv.x,                uv.y+border.y,       uv.x+border.x,   uv.w-border.w)
		self.render:setUV(self.idCenter,      uv.x+border.x, uv.y+border.y,       uv.z-border.z,   uv.w-border.w)
		self.render:setUV(self.idRight, uv.z-border.z,       uv.y+border.y,       uv.z,            uv.w-border.w)
		
		self.render:setUV(self.idBottomLeft,  uv.x,          uv.w-border.w, uv.x+border.x, uv.w)
		self.render:setUV(self.idBottom,      uv.x+border.x, uv.w-border.w, uv.z-border.z, uv.w)
		self.render:setUV(self.idBottomRight, uv.z-border.z, uv.w-border.w, uv.z, uv.w)

		for index, id in ipairs(self.ids) do
			self.render:setBoxColor(id,style.color.x,style.color.y,style.color.z)
		end
		self.render:setTextColor(self.id,style.textColor.x,style.textColor.y,style.textColor.z)
		
		if self.parentID then
			self:setParent(self.parentID, self.childIndex)
		end
		self:updateSprites()
	end
end


---@param spriteID integer
---@param index integer
function Nineslice:setParent(spriteID,index)
	assert(spriteID,"no spriteID given")
	
	self.render:setParent(self.idTopLeft,spriteID,index)
	self.render:setParent(self.idTop,spriteID,index)
	self.render:setParent(self.idTopRight,spriteID,index)
	
	self.render:setParent(self.idLeft,spriteID,index)
	self.render:setParent(self.idCenter,spriteID,index)
	self.render:setParent(self.idRight,spriteID,index)
	
	self.render:setParent(self.idBottomLeft,spriteID,index)
	self.render:setParent(self.idBottom,spriteID,index)
	self.render:setParent(self.idBottomRight,spriteID,index)
	
	self.render:setParent(self.id,spriteID,index)
end


return NinesliceAPI