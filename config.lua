# flags: host_only
---@class GNUI.Config
local config = {
--[────────────────────────────────────────-< Config >-────────────────────────────────────────]--

host_only = false,
-- makes the library only load for the host, excluding it from your final avatar size
-- requires Figura 0.1.6


debug_mode = false,
-- enable to view debug information about the boxes
debug_scale = 2/client:getGuiScale(),
-- the thickness of the lines for debug lines, in BBunits

clipping_margin = 16,
-- The gap between the parent element to its children.

debug_event_name = "_c",
internal_events_name = "__a",

utils = require("./utils"),
event = require("./../event"),
}

return config