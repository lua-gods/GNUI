--[[______   __
  / ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / Theme Class Handler
/ /_/ / /|  / the script that manages how every class looks.
\____/_/ |_/ Source: link]]

---@alias GNUI.Theme table<string,table<string|"default",table<string,GNUI.Sprite|any>>>

---@type GNUI.Theme
local styles = {}

---@class GNUI.ThemeAPI
local Theme = {}
local classCache = {}


---@alias GNUI.Theme.Variants string : string
---| "default"
---| "none"


---Loads a theme
---@param theme GNUI.Theme
function Theme.loadTheme(theme)
	for className, classData in pairs(theme) do
		styles[className] = theme[className] or {}
		for styleName, styleFun in pairs(classData) do
			styles[className][styleName] = styleFun
		end
	end
end

local requirePath = "./styles"

-- load theme from theme folder
for _, path in pairs(listFiles(requirePath, true)) do
	if #requirePath ~= #path then
		local style = require(path)
		Theme.loadTheme(style)
	end
end

-- load theme from data/theme folder
if host:isHost() and file:isDirectory("GNUI/theme") then
	local styleFuns = {}
	for key, fileName in pairs(file:list("GNUI/theme")) do
		local path = "GNUI/theme/" .. fileName
		local type = fileName:match("[^%.]+$")
		local name = fileName:sub(1, - #type - 2)
		if type == "lua" then
			styleFuns[#styleFuns + 1] = loadstring(file:readString(path))
		elseif type == "png" then
			local read = file:openReadStream(path)
			local buff = data:createBuffer(read:available())
			buff:readFromStream(read)
			buff:setPosition(0)
			local data = buff:readBase64(buff:available())
			textures:read("GNUI.theme." .. name, data)
			buff:close()
			read:close()
		end
	end
	for name, style in pairs(styleFuns) do
		local varag = { ... }
		varag[1] = varag[1] .. "/theme"
		varag[2] = name
		Theme.loadTheme(style(table.unpack(varag)))
	end
end


---Styles a given class using the theme script, the single lua file in the theme folder.
---@param box GNUI.Box|string
---@param field string
---@param variant string|"none"|"default"?
---@return GNUI.Sprite|any
function Theme.getStyle(box, field, variant)
	
	local class
	local rawClass = type(box) == "string" and box or box.__type
	if classCache[rawClass] then
		class = classCache[rawClass]
	else
		class = rawClass:match("[^%.]+$") -- GNUI.Button -> Button
		classCache[rawClass] = class
	end
	variant = variant or "default"
	
	if not styles[class] then
		return
	end
	if styles[class] and styles[class][variant] and styles[class][variant][field] then
		if styles[class][variant][field] then
			local ok, result = pcall(function ()
				return styles[class][variant][field].copy
			end)
			if ok then
				return result(styles[class][variant][field])
			else
				return styles[class][variant][field]
			end
		end
	end
end

return Theme
