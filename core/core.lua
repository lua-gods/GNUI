local box = require("./prims/box") ---@type GNUI.Primitive.BoxAPI
local canvas = require("./prims/canvas") ---@type GNUI.CanvasAPI

---Holds all instantiations for elements in GNUI
---and utility functions with them
---@class GNUI.CoreAPI
local CoreAPI = {}

---@param canvas GNUI.Canvas
---@return GNUI.Box
function CoreAPI.newBox(canvas) return box.new(canvas) end
function CoreAPI.newCanvas() return canvas.new() end

return CoreAPI