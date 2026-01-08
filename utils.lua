--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Utility Module
/ /_/ / /|  /  desc: meant to be refactored to the existing framework/library
\____/_/ |_/ source: link ]]

---@class GNUI.utils
local util = {}


---@return Vector2
function util.getScreenSize()
	return client:getWindowSize()/client:getGuiScale()
end


---@param path string
---@return string[]
function util.listFiles(path)
	return listFiles(path)
end


---@param content string
---@param maxWidth any
---@param wrap any
---@return Vector2
function util.getTextSize(content, maxWidth, wrap)
	return client.getTextDimensions(content, maxWidth, wrap)
end


return util