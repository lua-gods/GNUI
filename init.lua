--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GN's User Interface Library
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]
local BASE = (...):match(".+[./]GNUI"):gsub("/",".")

local paths = require(BASE..".paths") ---@type GNUI.config

local utils = require(BASE..".utils") ---@type GNUI.utils



-- local Core = require("./"..paths.CORE..".core") ---@type GNUI.CoreAPI
-- local Layout = require("./"..paths.LAYOUT..".layout") ---@type GNUI.LayoutAPI
-- local Render = require("./"..paths.RENDER..".render") ---@type GNUI.RenderAPI
-- local Style = require("./"..paths.STYLE..".style") ---@type GNUI.ThemeAPI




---@class GNUIAPI
local GNUIAPI = {}

local PRESETS = {}
for _, path in ipairs(utils.listFiles(BASE..".presets")) do
	local name = path:match("[^.]+$")
	PRESETS[name] = path
end

--TODO: add setup loading
--TODO: add custom parameters to setup to allow loading of custom themes


---overrideName is meant for custom presets and modules.
---
---its not recommended to be changed unless you know what you're doing.
---@param customPresetName string?
function GNUIAPI.setup(customPresetName)
	if not customPresetName then
		customPresetName = next(PRESETS)
	end
	
	assert(PRESETS[customPresetName],"GNUI setup preset '"..customPresetName.."' does not exist")
	---@type GNUI.config
	local preset = require(PRESETS[customPresetName])
	
	paths.CORE = preset.CORE:format(BASE)
	paths.LAYOUT = preset.LAYOUT:format(BASE)
	paths.RENDER = preset.RENDER:format(BASE)
	paths.THEME = preset.THEME:format(BASE)
	paths.WIDGETS = preset.WIDGETS:format(BASE)
	paths.GN_COMMON = preset.GN_COMMON:format(BASE)
	paths.UTILS = preset.UTILS:format(BASE)
	paths.EVENT = preset.EVENT:format(BASE)
	
	-- load selected modules
	local Core = require(paths.CORE..".init") ---@type GNUI.CoreAPI
	local Layout = require(paths.LAYOUT..".init") ---@type GNUI.LayoutAPI
	local Render = require(paths.RENDER..".init") ---@type GNUI.RenderAPI
	local Theme = require(paths.THEME..".init") ---@type GNUI.ThemeAPI
	
	
	for index, path in ipairs(utils.listFiles(paths.WIDGETS)) do
		require(path)
	end
	
	-- import default theme
	Theme.importTheme(BASE..".shared.theme.defaults.ore")

	
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
end





return GNUIAPI