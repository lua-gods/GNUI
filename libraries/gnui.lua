--[[______   __
  / ____/ | / / By: GNamimates
 / / __/  |/ / GNUI v2.0.0
/ /_/ / /|  / A high level UI library for figura.
\____/_/ |_/ https://github.com/lua-gods/GNUI]]

--[[ NOTES
Everything is in one file to make sure it is possible to load this script from a config file, 
allowing me to put as much as I want without worrying about storage space.
]]

---@class GNUI
local api = {}

---@alias GNUI.any GNUI.element|GNUI.container|GNUI.Label|GNUI.anchorPoint|GNUI.canvas

local utils = require("libraries.gnui.utils")
local label = require("libraries.gnui.elements.label")
local sprite = require("libraries.gnui.spriteLib")
local canvas = require("libraries.gnui.elements.canvas")
local container = require("libraries.gnui.elements.container")
local point_anchor = require("libraries.gnui.elements.anchor")
---                             Blast off! ~ ~ ~~~$%$#%%$#%#!@!#%|>=========>
api.newPointAnchor = point_anchor.new
api.newContainer = container.new
api.newCanvas = canvas.new
api.newSprite = sprite.new
api.newLabel = label.new
api.utils = utils




---Creates a Canvas onto your screen that automatically resizes to your window, and canceling all the inputs outside the screen. to disable canceling all the inputs outside the screen, use `Canvas:setCaptureInputs(false)` or `Canvas:setVisible(false)` to disable the functionality.
---This serves as a quick setup for your screen.
---@return GNUI.canvas
function api.createScreenCanvas()
  local c = api.newCanvas()
  models:addChild(c.ModelPart)
  c.ModelPart:setParentType("HUD")

  local last_window_size = vectors.vec2()
  events.WORLD_RENDER:register(function (delta)
    local window_size = client:getScaledWindowSize()
    
    if window_size.x ~= last_window_size.x
    or window_size.y ~= last_window_size.y then
      last_window_size = window_size
      c:setDimensions(0,0,window_size.x,window_size.y)
    end
  end)
  c:setDimensions(0,0,client:getScaledWindowSize().x,client:getScaledWindowSize().y)
  return c
end

return api