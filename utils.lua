--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Utility Module
/ /_/ / /|  /  desc: meant to be refactored to the existing framework/library
\____/_/ |_/ source: link ]]

---@class GNUI.utils
local util = {}


---@return Vector2
function util.getScreenSize()
	local x,y,w,h = love.window.getSafeArea()
	return vec2(w,h)
end


---@param path string
---@return string[]
function util.listFiles(path)
	return listFiles(path)
end


---@return string
function util.getClipboard()
	return host:getClipboard()
end


---@param content string
---@param maxWidth any
---@param wrap any
---@return Vector2
function util.getTextSize(content, maxWidth, wrap)
	return client.getTextDimensions(content, maxWidth, wrap)
end

---@param text string
---@return integer
function util.getTextWidth(text)
	return client.getTextWidth(text)
end

-- Thankyou 4P5!
local clampCache = setmetatable({}, { mode = "v" })
---@param text string
---@param length number
---@return number
function util.LengthToCharCount(text, length)
	if not clampCache[length] then clampCache[length] = {} end
	if clampCache[length][text] then return clampCache[length][text][1] end

	local width = client.getTextWidth(text)

	local i = 0
	if width > length then
		local low, high = 0, #text
		while low < high do
			i = i + 1
			local mid = math.floor((low + high) / 2)
			local test_text = text:sub(1, mid)
			local test_width = client.getTextWidth(test_text)

			if test_width > length then
				high = mid
			else
				low = mid + 1
			end
		end

		local left = text:sub(1, low - 1)
		text = left
	end

	return #text
end


return util
