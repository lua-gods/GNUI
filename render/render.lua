local BASE = (...):match(".+%.GNUI")

local utils = require(BASE..".utils") ---@type GNUI.utils
local config = require(BASE..".config") ---@type GNUI.config
local Display = require(BASE.."."..config.RENDER..".visuals.display") ---@type GNUI.Render.Display

---@class GNUI.RenderAPI
local RenderAPI = {}


for index, value in ipairs(utils.listFiles("./visuals")) do
	require(value)
end


---@return GNUI.Render.Display
function RenderAPI.newDisplay()
	return Display.newDisplay()
end


return RenderAPI
