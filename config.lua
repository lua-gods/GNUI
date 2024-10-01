local config = {


-->==========[ Debug ]==========<--
debug_mode = false, -- enable to view debug information about the boxes
debug_scale = 1/client:getGuiScale(), -- the thickness of the lines for debug lines, in BBunits


-->==========[ Rendering ]==========<--
clipping_margin = 64, -- The gap between the parent element to its children.


-->==========[ Labeling ]==========<--
debug_event_name = "_c",
internal_events_name = "__a",


-->==========[ System ]==========<--
utils = require("GNUI.utils"),

-->==========[ External Libraries ]==========<--
event = require("libraries.eventLib"),
}

return config