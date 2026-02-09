--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GN's User Interface Library
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]
local BASE = (...):match(".+%.GNUI")
local config = require(BASE .. ".config") ---@type GNUI.config
local utils = require(BASE .. ".utils") ---@type GNUI.utils

local Core = require(BASE .. "." .. config.CORE .. ".core") ---@type GNUI.CoreAPI
local Layout = require(BASE .. "." .. config.LAYOUT .. ".layout") ---@type GNUI.LayoutAPI
local Render = require(BASE .. "." .. config.RENDER .. ".render") ---@type GNUI.RenderAPI
local Style = require(BASE .. "." .. config.STYLE .. ".style") ---@type GNUI.StyleAPI
---@class GNUIAPI
local GNUIAPI = {}

print("LOADING WIDGETS")
for index, path in ipairs(utils.listFiles(BASE..".widgets")) do
	print(path)
	require(path)
end
print("---")

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
		print(utils.getScreenSize())
		screen:setSize(utils.getScreenSize())
		return screen
	end
end




return GNUIAPI
