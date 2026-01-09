
local SpriteStyle = require("./styles/sprite") ---@type GNUI.Sprite.StyleAPI

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
	if type(class) ~= "string" then
		class = class.__style
		assert(class,"No class found")
	end
	
	if Theme[class] and Theme[class][variant] and Theme[class][variant][key] then
		return Theme[class][variant][key]
	else
		error("Unknown style: " .. tostring(class) .. "." .. toJson(variant) .. "." .. tostring(key))
	end
end


return StyleAPI