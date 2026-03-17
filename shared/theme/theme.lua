local BASE = (...):match(".+[./]GNUI"):gsub("/",".")
local cfg = require(BASE..".config") ---@type GNUI.config
local utils =  require(BASE..".utils") ---@type GNUI.utils
local gncommon = require("lib.gncommon") ---@type GNCommon


--TODO: rewrite all styles into a full data driven one, instead of an imperial one


---@alias GNUI.StyleImporter fun(style:GNUI.StyleEntry):any


---@type table<string,GNUI.StyleImporter>
local STYLE_IMPORTERS = {}


---@class GNUI.Theme
---@field [string] GNUI.Theme.Class

---@class GNUI.Theme.Class
---@field [string] GNUI.Theme.Class.Variant|string

---@class GNUI.Theme.Class.Variant
---@field [string] GNUI.StyleEntry

---@class GNUI.StyleEntry

---@type GNUI.Theme
local Theme = {}

---@class GNUI.ThemeAPI
local ThemeAPI = {}


---@param type string
---@param importer GNUI.StyleImporter
function ThemeAPI._registerImporter(type,importer)
	STYLE_IMPORTERS[type] = importer
end


---NOTE: the theme only applies to future instantiated elements, and wont be affecting existing ones.
---@param path string
function ThemeAPI.importTheme(path)
	local theme = require(path)
	
	for classIndex, class in pairs(theme) do
		if not Theme[classIndex] then Theme[classIndex] = {} end
		
		for variantIndex, variant in pairs(class) do
			if type(variant) == "table" then
				if not Theme[classIndex][variantIndex] then Theme[classIndex][variantIndex] = {} end
				for keyIndex, key in pairs(variant) do
					
					if key.type then
						local importer = STYLE_IMPORTERS[key.type]
						if importer then
							Theme[classIndex][variantIndex][keyIndex] = importer(key)
						else
							print("[GNUI] : tried to import \""..key.type.."\" but no importer found")
							Theme[classIndex][variantIndex][keyIndex] = key
						end
					end
				end
			else
				Theme[classIndex][variantIndex] = variant
			end
		end
	end
end


--────────────────────────-< Theme Loader >-────────────────────────--

---@param class string|GNUI.Box
---@param variant string
---@param key any
---@return GNUI.Sprite.Style|any
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
	error("Unknown style: " .. tostring(class) .. "." .. tostring(variant) .. "." .. tostring(key))
end


---@param box GNUI.Box
---@param key any
---@return GNUI.Sprite.Style|any
function ThemeAPI.getStyleFromBox(box,key)
	return ThemeAPI.getStyle(box.__style,box.variant,key)
end


---@param class any
---@return string[]
function ThemeAPI.getVariantNames(class)
	local list = {}
	for variantIndex, variant in pairs(Theme[class]) do
		list[#list+1] = variantIndex
	end
	return list
end


---@return string[]
function ThemeAPI.getClassNames()
	local list = {}
	for classIndex, class in pairs(Theme) do
		list[#list+1] = classIndex
	end
	return list
end


return ThemeAPI
