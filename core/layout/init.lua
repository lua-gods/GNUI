---@class GNUI.LayoutAPI
local LayoutAPI = {}



---@class GNUI.Layout
---@field [1] GNUI.Layout[]|GNUI.Layout?
---@field style string|GNUI.StyleEntry?


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
		
		local children = {}
		if layout[1] then
			if not layout[1][1] then
				layout[1] = {layout[1]}
			end
			for index, childLayout in ipairs(layout[1]) do
				children[index] = parseEntry(canvas, childLayout)
			end
		end
		local parser = elements[layout.type or "box"]
		local ok, box = pcall(parser,layout,canvas,children)
		if ok then
			return box
		else
			error("Failed to parse layout: " .. tostring(layout.type) .. "\n" .. box,2)
		end
	else
		error("Unknown element type: " .. (layout and layout.type or "nil"))
	end
end

---@param canvas GNUI.Canvas
---@param layout GNUI.Layout
---@return GNUI.Box
function LayoutAPI.parse(canvas, layout)
	return parseEntry(canvas, layout)
end

return LayoutAPI

