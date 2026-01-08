--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GN's User Interface Library
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]

local config = require("./config") ---@type GNUI.config
local utils = require("./utils") ---@type GNUI.utils

local Core = require("./"..config.CORE) ---@type GNUI.CoreAPI
local Layout = require("./"..config.LAYOUT) ---@type GNUI.LayoutAPI
local Render = require("./"..config.RENDER) ---@type GNUI.RenderAPI
local Style = require("./"..config.STYLE) ---@type GNUI.StyleAPI
---@class GNUIAPI
local GNUIAPI = {}

for index, path in ipairs(utils.listFiles("./widgets")) do
	require(path)
end

---@param canvas GNUI.Canvas
---@param data GNUI.Layout
---@return GNUI.Box
function GNUIAPI.parse(canvas,data)
	return Layout.parse(canvas,data)
end

local screen

function GNUIAPI.getScreen()
	if screen then
		return screen
	else
		screen = Core.newCanvas()
		screen:setSize(utils.getScreenSize())
		return screen
	end
end


return GNUIAPI