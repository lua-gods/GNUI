local config = {
   debug_visible = hostconfig and hostconfig["gnui.debug"] or false,
   debug_scale = 1,
   
   clipping_margin = 0.05,
   --clipping_margin = 2,
   
   debug_event_name = "_c",
   internal_events_name = "__a",
}

return config