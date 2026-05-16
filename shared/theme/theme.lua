local BASE = (...):match(".+[./]GNUI"):gsub("/",".")
local cfg = require(BASE..".config") ---@type GNUI.config
local utils =  require(BASE..".utils") ---@type GNUI.utils
local gncommon = require("lib.GNcommon") ---@type GNCommon


--TODO: rewrite all styles into a full data driven one, instead of an imperial one


---@alias GNUI.StyleImporter fun(style:GNUI.StyleEntry):any


---@type table<string,GNUI.StyleImporter>
local STYLE_IMPORTERS = {}

---@class GNUI.Theme
---@field title string
---@field styles GNUI.Theme.Styles

---@class GNUI.Theme.Styles
---@field [string] GNUI.Theme.Styles.Class

---@class GNUI.Theme.Styles.Class
---@field [string] GNUI.Theme.Styles.Class.Variant|string

---@class GNUI.Theme.Styles.Class.Variant
---@field [string] GNUI.StyleEntry|any

---@class GNUI.StyleEntry

---@type table<string,GNUI.Theme>
local Themes = {}

---@class GNUI.ThemeAPI
local ThemeAPI = {}


---@param type string
---@param importer GNUI.StyleImporter
function ThemeAPI._registerImporter(type,importer)
	STYLE_IMPORTERS[type] = importer
end


---@param style GNUI.StyleEntry
---@param box GNUI.Box
---@param layer number?
function ThemeAPI.applyStyle(style,box,layer)
	assert(style,"No style given")
	assert(box,"No box given")
	assert(style.type,"No type found")
	local importer = STYLE_IMPORTERS[style.type]
	local parsedStype = importer(style)
	parsedStype:newInstance(box,layer)
end

---NOTE: the theme only applies to future instantiated elements, and wont be affecting existing ones.
---@param path string
function ThemeAPI.importTheme(path)
	local theme = require(path)
	
	local Styles
	
	if not Themes[theme.title] then
		Themes[theme.title] = {
			title = theme.title,
			styles = {}
		}
	end
	Styles = Themes[theme.title].styles
	
	for classIndex, class in pairs(theme.styles) do
		if not Styles[classIndex] then Styles[classIndex] = {} end
		
		for variantIndex, variant in pairs(class) do
			if type(variant) == "table" then
				if not Styles[classIndex][variantIndex] then Styles[classIndex][variantIndex] = {} end
				for keyIndex, key in pairs(variant) do
					if type(key) == "table" then
						if key.type then
							local importer = STYLE_IMPORTERS[key.type]
							if importer then
								Styles[classIndex][variantIndex][keyIndex] = importer(key)
							else
								print("[GNUI] : tried to import \""..key.type.."\" but no importer found")
								Styles[classIndex][variantIndex][keyIndex] = key
							end
						end
					else
						Styles[classIndex][variantIndex][keyIndex] = key
					end
				end
			else
				Styles[classIndex][variantIndex] = variant
			end
		end
	end
end

--────────────────────────-< Theme Loader >-────────────────────────--

---@param class string|GNUI.Box
---@param variant string
---@param key any
---@param themeOverride string?
---@return GNUI.Sprite.Style|any
function ThemeAPI.getStyle(class,variant,key,themeOverride)
	local Theme
	if not themeOverride then
		Theme = Themes[next(Themes)]
	else
		assert(Themes[themeOverride],"Unknown theme: " .. themeOverride)
		Theme = Themes[themeOverride]
	end
	Theme = Theme.styles
	
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

--────────────────────────-< Theme APIs >-────────────────────────--


---@overload fun(style: GNUI.StyleEntry|{type:"sprite"}): GNUI.Sprite
---@overload fun(style: GNUI.StyleEntry|{type:"quad"}): GNUI.Sprite.Quad
---@overload fun(style: GNUI.StyleEntry|{type:"nineslice"}): GNUI.Sprite.Nineslice
function ThemeAPI.newSprite(style)
---@diagnostic disable-next-line: param-type-mismatch
	return STYLE_IMPORTERS[style.type](style)
end


---@param box GNUI.Box
---@param key any
---@return GNUI.Sprite.Style|any
function ThemeAPI.getStyleFromBox(box,key)
	return ThemeAPI.getStyle(box.__style,box.variant,key)
end


---@param class any
---@return string[]
function ThemeAPI.getVariantNames(class,theme)
	local list = {}
	if theme then
		for variantIndex, variant in pairs(Themes[theme].styles[class]) do
			list[#list+1] = variantIndex
		end
	end
	return list
end


---@return string[]
function ThemeAPI.getClassNames()
	local hash = {}
	local list = {}
	for key, theme in pairs(Themes) do
		for classIndex,stuff in pairs(theme.styles) do
			hash[classIndex] = true
		end
	end
	for name in pairs(hash) do
		list[#list+1] = name
	end
	return list
end

return ThemeAPI
