--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]

--[[ NOTES
Everything is in one file to make sure it is possible to load this script from a config file, 
allowing me to put as much as I want without worrying about storage space.
]]

local api = {}



local utils = require("libraries.gnui.utils")
local sprite = require("libraries.gnui.spriteLib")

local element = require("libraries.gnui.elements.element")
local container = require("libraries.gnui.elements.container")
local label = require("libraries.gnui.elements.label")


api.newContainer = container.new
api.newLabel = label.new
api.utils = utils
api.newSprite = sprite.new
return api