

local hostconfig = world.avatarVars()[client:getViewer():getUUID()]

local config = {
   debug_visible = hostconfig and hostconfig["gnui.debug"] or true,
   debug_scale = 0.33333, -- the thickness of the lines for debug lines, in BBunits
   
   -- The gap between the parent element to its children, change this depending on the situation
   clipping_margin = 0.05, 
   
   debug_event_name = "_c",
   internal_events_name = "__a",
   
}

return config