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



local eventLib = require("libraries.figui.eventHandler")
local utils = require("libraries.figui.utils")
local sprite = require("libraries.figui.spriteLib")

local element = require("libraries.figui.elements.element")
local container = require("libraries.figui.elements.container")
local label = require("libraries.figui.elements.label")


api.newContainer = container.new
api.newLabel = label.new
api.utils = utils
api.newSprite = sprite.new
return api