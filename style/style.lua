local Quad = require("./sprites/quad") ---@type GNUI.Sprite.QuadAPI
local Sprite = require("./sprites/sprite") ---@type GNUI.Sprite
local util =  require("../utils") ---@type GNUI.utils

---@alias GNUI.Theme table<string,table<string,table<string,GNUI.Sprite.Style>>>

---@type GNUI.Theme
local Theme = {}

---@class GNUI.StyleAPI
local StyleAPI = {}


--────────────────────────-< Theme Loader >-────────────────────────--
for index, path in ipairs(util.listFiles("./theme")) do
	local package = require(path)
	for keyClass, class in pairs(package) do
		if not Theme[keyClass] then
			Theme[keyClass] = {}
		end
		
		for keyVariant, variant in pairs(class) do
			if not Theme[keyClass][keyVariant] then
				Theme[keyClass][keyVariant] = {}
			end
			
			for keyKey, key in pairs(variant) do
				Theme[keyClass][keyVariant][keyKey] = key
			end
		end
	end
end


---Get a style
---@param class string|GNUI.Box
---@param variant string
---@param key any
---@return GNUI.Sprite.Style?
function StyleAPI.getStyle(class,variant,key)
	if type(class) == "table" then
		class = class.__style
		assert(class,"No class found")
	end
	
	if Theme[class] and Theme[class][variant] and Theme[class][variant][key] then
		return Theme[class][variant][key]
	end
end


return StyleAPI