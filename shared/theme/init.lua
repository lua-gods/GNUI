local BASE = (...):match(".+[./]GNUI"):gsub("/",".")
local paths = require(BASE..".paths") ---@type GNUI.config
local utils =  require(BASE..".utils") ---@type GNUI.utils
local Theme = require(paths.THEME..".theme") ---@type GNUI.ThemeAPI

-- load all importers
for index, path in ipairs(utils.listFiles(paths.THEME..".sprites")) do
	require(path)
end


return Theme