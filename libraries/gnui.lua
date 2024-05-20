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

local utils = require("libraries.gnui.utils")
local label = require("libraries.gnui.elements.label")
local sprite = require("libraries.gnui.spriteLib")
local container = require("libraries.gnui.elements.container")
local point_anchor = require("libraries.gnui.elements.anchor")
---                             Blast off! ~ ~ ~~~$%$#%%$#%#!@!#%|>=========>
api.newPointAnchor = point_anchor.new
api.newContainer = container.new
api.newSprite = sprite.new
api.newLabel = label.new
api.utils = utils
return api