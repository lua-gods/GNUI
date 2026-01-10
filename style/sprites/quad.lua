--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Quad Module
/ /_/ / /|  /  desc: an extension of sprite which can display a texture
\____/_/ |_/ source: link ]]

local Sprite = require("./sprite") ---@type GNUI.SpriteAPI
local gncommon = require("lib.gncommon") ---@type GNCommon
local Style = require("../styles/quad") ---@type GNUI.Sprite.Quad.StyleAPI
local config = require("../../config") ---@type GNUI.config

---@class GNUI.Sprite.QuadAPI
local QuadAPI = {}


---@class GNUI.Sprite.Quad : GNUI.Sprite
---@field style GNUI.Sprite.Quad.Style
local Quad = {}
Quad.__index = function (t,i)
	return rawget(t,i) or Quad[i] or Sprite.index(i)
end


function QuadAPI.index(i) return Quad[i] end


---A representation of a quad that will get drawn
---@param box GNUI.Box
---@return GNUI.Sprite.Quad
function QuadAPI.new(box)
	assert(box,"no GNUI.Box given")
	local self = Sprite.new(box)
	---@cast self GNUI.Sprite.Quad
	
	self.id = self.render:newVisualQuad()
	
	setmetatable(self, Quad)
	return self
end


Style.setInstancer(QuadAPI.new)
---@return GNUI.Sprite.Quad.Style
function QuadAPI.newStyle()
	return Style.new()
end


--────────────────────────-< API >-────────────────────────--


---@param path string
---@generic self
---@param self self
---@return self
function Quad:setTexture(path)
	---@cast self GNUI.Sprite.Quad
	self.texture_path = path
	self.render:setTexture(self.id,self.texture_path)
	return self
end


function Quad:applyStyle()
	if self.style then
		local style = self.style
		self.render:setTexture(self.id,style.texture_path)
		self.render:setUV(self.id,style.uv.x,style.uv.y,style.uv.z,style.uv.w)
		
		self.render:setBoxColor(self.id,style.color.x,style.color.y,style.color.z)
		self.render:setTextColor(self.id,style.textColor.x,style.textColor.y,style.textColor.z)
	end
end




return QuadAPI