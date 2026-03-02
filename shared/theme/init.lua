local BASE = (...):match(".+[./]GNUI"):gsub("/",".")
local util =  require(BASE..".utils") ---@type GNUI.utils


---@class GNUI.Theme
---@field [string] GNUI.Theme.Class

---@class GNUI.Theme.Class
---@field [string] GNUI.Theme.Class.Variant|string

---@class GNUI.Theme.Class.Variant
---@field [string] GNUI.Sprite.Style|any

---@type GNUI.Theme
local Theme = {}

---@class GNUI.ThemeAPI
local ThemeAPI = {}


---NOTE: the theme only applies to future instantiated elements, and wont be affecting existing ones.
---@param path string
function ThemeAPI.applyTheme(path)
	local package = require(path)
	for keyClass, class in pairs(package) do
		if not Theme[keyClass] then
			Theme[keyClass] = {}
		end
		
		for keyVariant, variant in pairs(class) do
			if type(variant) == "table" then
				if not Theme[keyClass][keyVariant] then
					Theme[keyClass][keyVariant] = {}
				end
				if type(variant) == "table" then
					for keyKey, key in pairs(variant) do
						Theme[keyClass][keyVariant][keyKey] = key
					end
				else
					Theme[keyClass][keyVariant] = variant
				end
			else
				Theme[keyClass][keyVariant] = variant
			end
		end
	end
end


--────────────────────────-< Theme Loader >-────────────────────────--

---@param class string|GNUI.Box
---@param variant string
---@param key any
---@return GNUI.Sprite.Style
function ThemeAPI.getStyle(class,variant,key)
	if type(class) ~= "string" then
		class = class.__style
		assert(class,"No class found")
	end
	
	if Theme[class] then
		local classVal = Theme[class]
		
		if classVal[variant] then
			local variantVal = classVal[variant]

			-- solve for refStyle in variants
			while type(variantVal) == "string" do
				variantVal = Theme[class][variantVal]
				Theme[class][variant] = variantVal
			end

			assert(variantVal,"Unknown variant: " .. class .. "." .. variant)
			
			if variantVal[key] then
				local key = variantVal[key]
				return key
			end
		end
	end
	error("Unknown style: " .. class .. "." .. variant .. "." .. key)
end


---@param box GNUI.Box
---@param key any
---@return GNUI.Sprite.Style
function ThemeAPI.getStyleFromBox(box,key)
	return ThemeAPI.getStyle(box.__style,box.variant,key)
end


return ThemeAPI
