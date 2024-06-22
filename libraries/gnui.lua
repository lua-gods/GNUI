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
local label = require("libraries.gnui.primitives.label")
local sprite = require("libraries.gnui.spriteLib")
local canvas = require("libraries.gnui.primitives.canvas")
local container = require("libraries.gnui.primitives.container")
local point_anchor = require("libraries.gnui.primitives.anchor")
---                             Blast off! ~ ~ ~~~$%$#%%$#%#!@!#%|>=========>
api.newPointAnchor = point_anchor.new
api.newContainer = container.new
api.newCanvas = canvas.new
api.newSprite = sprite.new
api.newLabel = label.new
api.utils = utils


local screenCanvas
---Gets a canvas for the screen. Quick startup for putting UI elements onto the screen.
---@return GNUI.canvas
function api.getScreenCanvas()
  if not screenCanvas then
    screenCanvas = api.newCanvas()
    models:addChild(screenCanvas.ModelPart)
    screenCanvas.ModelPart:setParentType("HUD")
  
    local lastWindowSize = vectors.vec2()
    events.WORLD_RENDER:register(function (delta)
      local windowSize = client:getScaledWindowSize()
      
      if windowSize.x ~= lastWindowSize.x
      or windowSize.y ~= lastWindowSize.y then
        lastWindowSize = windowSize
        screenCanvas:setDimensions(0,0,windowSize.x,windowSize.y)
      end
    end)
    screenCanvas:setDimensions(0,0,client:getScaledWindowSize().x,client:getScaledWindowSize().y)
  end
  return screenCanvas
end

return api