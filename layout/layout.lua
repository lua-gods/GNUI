---@diagnostic disable: param-type-mismatch
local config = require("../config")

local Style = require("../style/style") ---@type GNUI.StyleAPI

---@class GNUI.LayoutAPI
local LayoutAPI = {}



---@class GNUI.Layout
---@field type nil|"box"
---@field name string?
---@field size Vector2?
---@field minSize Vector2?
---@field sizing ({[1]:GNUI.Box.SizingMode,[2]:GNUI.Box.SizingMode}|GNUI.Box.SizingMode)?
---@field pos Vector2?
---@field gap number?
---@field layout GNUI.Box.LayoutMode?
---@field text string?
---@field textAlign (-1|0|1)?
---@field wrap boolean?
---@field variant string?
---
---@field [1] GNUI.Layout[]?


local elements = {}


---@param type string
---@param callback fun(layout:GNUI.Layout,canvas:GNUI.Canvas):GNUI.Box
function LayoutAPI.registerType(type, callback)
	elements[type] = callback
end


---@param canvas GNUI.Canvas
---@param layout GNUI.Layout
local function parseEntry(canvas, layout)
	assert(layout, "No layout given")
	assert(canvas, "No canvas given")
	if elements[layout.type or "box"] then
		local parser = elements[layout.type or "box"]
		local ok, box = pcall(parser,layout,canvas)
		if ok then
			if layout[1] then
				assert(layout[1][1], "Common mistake, children entry should be an array, not an box entry")
				for index, childLayout in ipairs(layout[1]) do
					box:addChild(parseEntry(canvas, childLayout))
				end
			end
			return box
		else
			error("Failed to parse layout: " .. tostring(layout.type) .. "\n" .. box,2)
		end
	else
		error("Unknown layout type: " .. (layout and layout.type or "nil"))
	end
	
end

---@param canvas GNUI.Canvas
---@param layout GNUI.Layout
---@return GNUI.Box
function LayoutAPI.parse(canvas, layout)
	return parseEntry(canvas, layout)
end

return LayoutAPI

