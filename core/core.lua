local BASE = (...):match(".+%.GNUI")

local box = require(BASE ..".core.prims.box") ---@type GNUI.Primitive.BoxAPI
local canvas = require(BASE ..".core.prims.canvas") ---@type GNUI.CanvasAPI

---Holds all instantiations for elements in GNUI
---and utility functions with them
---@class GNUI.CoreAPI
local CoreAPI = {}

---@param canvas GNUI.Canvas
---@return GNUI.Box
function CoreAPI.newBox(canvas) return box.new(canvas) end
function CoreAPI.newCanvas() return canvas.new() end

return CoreAPI
