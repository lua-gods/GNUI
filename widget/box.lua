# flags: host_only
local Box = require("./../prims/box") ---@type GNUI.Box
local cfg = require("./../config") ---@type GNUI.Config
local Event = cfg.event ---@type Event
local utils = cfg.utils ---@type GNUI.UtilsAPI
local Theme = require("./../theme") ---@type GNUI.ThemeAPI


---@class GNUI.BoxAPI : GNUI.Box
local BoxAPI = {}

function BoxAPI.new(parent, variant)
	local box = Box.new(parent)
	if variant then
		local sprite = Theme.getStyle(box, "backdrop", variant)
		if sprite then
			box:setSprite(sprite)
		end
	end
	return box
end

BoxAPI.__index = Box.__index

return BoxAPI