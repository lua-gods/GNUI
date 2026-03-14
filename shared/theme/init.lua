local BASE = (...):match(".+[./]GNUI"):gsub("/",".")
local cfg = require(BASE..".config") ---@type GNUI.config
local utils =  require(BASE..".utils") ---@type GNUI.utils
local Theme = require(cfg.THEME..".theme") ---@type GNUI.ThemeAPI

-- load all importers
for index, path in ipairs(utils.listFiles(cfg.THEME..".sprites")) do
	require(path)
end


return Theme