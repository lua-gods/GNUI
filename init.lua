--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GN's User Interface Library
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]
local BASE = (...):match(".+[./]GNUI"):gsub("/",".")

local cfg = require(BASE..".config") ---@type GNUI.config

local utils = require(BASE..".utils") ---@type GNUI.utils



-- local Core = require("./"..paths.CORE..".core") ---@type GNUI.CoreAPI
-- local Layout = require("./"..paths.LAYOUT..".layout") ---@type GNUI.LayoutAPI
-- local Render = require("./"..paths.RENDER..".render") ---@type GNUI.RenderAPI
-- local Style = require("./"..paths.STYLE..".style") ---@type GNUI.ThemeAPI




---@class GNUIAPI
---@field Core GNUI.CoreAPI
---@field Layout GNUI.LayoutAPI
---@field Render GNUI.RenderAPI
---@field Theme GNUI.ThemeAPI
local GNUIAPI = {}

local PRESETS = {}
for _, path in ipairs(utils.listFiles(BASE..".presets")) do
	local name = path:match("[^.]+$")
	PRESETS[name] = path
end

--TODO: add custom parameters to setup to allow loading of custom themes


---overrideName is meant for custom presets and modules.
---
---its not recommended to be changed unless you know what you're doing.
---@param customPresetName string?
---@return GNUIAPI
function GNUIAPI.setup(customPresetName)
	if not customPresetName then
		customPresetName = next(PRESETS)
	end
	
	assert(PRESETS[customPresetName],"GNUI setup preset '"..customPresetName.."' does not exist")
	---@type GNUI.config
	local preset = require(PRESETS[customPresetName])
	
	cfg.CORE = preset.CORE:format(BASE)
	cfg.LAYOUT = preset.LAYOUT:format(BASE)
	cfg.RENDER = preset.RENDER:format(BASE)
	cfg.THEME = preset.THEME:format(BASE)
	cfg.WIDGETS = preset.WIDGETS:format(BASE)
	cfg.GN_COMMON = preset.GN_COMMON:format(BASE)
	cfg.UTILS = preset.UTILS:format(BASE)
	cfg.EVENT = preset.EVENT:format(BASE)
	
	-- load selected modules
	local Core = require(cfg.CORE..".init") ---@type GNUI.CoreAPI
	local Layout = require(cfg.LAYOUT..".init") ---@type GNUI.LayoutAPI
	local Render = require(cfg.RENDER..".init") ---@type GNUI.RenderAPI
	local Theme = require(cfg.THEME..".init") ---@type GNUI.ThemeAPI
	
	GNUIAPI.Core = Core
	GNUIAPI.Layout = Layout
	GNUIAPI.Render = Render
	GNUIAPI.Theme = Theme
	cfg.PRESET_TYPE = customPresetName
	
	
	for index, path in ipairs(utils.listFiles(cfg.WIDGETS)) do
		require(path)
	end
	
	-- import default theme
	Theme.importTheme(BASE..".shared.theme.defaults.gnui")
	
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
end





return GNUIAPI