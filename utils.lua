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
	return vec(w,h)
end


---@param path string
---@return string[]
function util.listFiles(path)
	return listFiles(path,false)
end


---@return string
function util.getClipboard()
	return love.system.getClipboardText()
end



---@param path string
---@return Vector2
function util.getTextureSize(path)
	local img = love.graphics.newImage(path,{dpiscale=1}) -- force dpi scale
	return vec(img:getWidth(),img:getHeight())
end


---@param content string
---@param maxWidth any
---@param wrap any
---@return Vector2
function util.getTextSize(content, maxWidth, wrap)
	local text = love.graphics.newText(love.graphics.getFont())
	text:setf(content, maxWidth, "left")
	return vec(text:getDimensions())
end

---@param text string
---@return integer
function util.getTextWidth(text)
	local text = love.graphics.newText(love.graphics.getFont())
	text:set(text)
	return text:getWidth()
end

-- Thankyou 4P5!
local clampCache = setmetatable({}, { mode = "v" })
---@param text string
---@param length number
---@return number
function util.LengthToCharCount(text, length)
	if not clampCache[length] then clampCache[length] = {} end
	if clampCache[length][text] then return clampCache[length][text][1] end

	local width = util.getTextWidth(text)

	local i = 0
	if width > length then
		local low, high = 0, #text
		while low < high do
			i = i + 1
			local mid = math.floor((low + high) / 2)
			local test_text = text:sub(1, mid)
			local test_width = util.getTextWidth(test_text)

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
