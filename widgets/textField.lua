local config = require("../config") ---@type GNUI.config
local Box = require("./box") ---@type GNUI.BoxAPI
local Event = require("../" .. config.EVENT)
local Button = require("./button") ---@type GNUI.ButtonAPI

local Style = require("../" .. config.STYLE) ---@type GNUI.StyleAPI
local Layout = require("../" .. config.LAYOUT) ---@class GNUI.LayoutAPI


---@class GNUI.TextFieldAPI
local TextFieldAPI = {}


---@alias GNUI.TextField.Verifier fun(field: string):boolean



TextFieldAPI.verifiers = {
	decimal = function (field)
		local ok, result = pcall(tonumber, field)
		return ok
	end,
	integer = function (field)
		local ok, result = pcall(tonumber, field)
		return ok and result % 1 == 0
	end,
	hex = function (field)
		return field:match("#?%x%x%x%x%x%x")
	end,
	email = function (field)
		return field:match("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$")
	end,
	username = function (field)
		return field:match("^[a-zA-Z0-9_]+$")
	end,
	url = function (field)
		return field:match("https?://[%w-_%.%?%.:/%+=&%()%#]+")
	end
}


---@class GNUI.TextField : GNUI.Button
---@field toggle true
---
---@field field string
---@field editingField string
---@field placeholder string
---
---@field verifier fun(field: string):boolean
local TextField = {}
TextField.__index = function (t,i)
	return rawget(t,i) or TextField[i] or Button.index(i) or Box.index(i)
end
TextField.__style = "textField"
TextField.__type = "TextField"


function TextField.index(i)
	return TextField[i]
end



---@param canvas GNUI.Canvas
---@return GNUI.Button
function TextFieldAPI.new(canvas)
	local self = Button.new(canvas)
	self.toggle = true
	
	return self
end




return TextFieldAPI