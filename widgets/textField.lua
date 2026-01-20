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
		return tonumber(field) and true or false
	end,
	integer = function (field)
		local result = tonumber(field)
		return result and result % 1 == 0 or false
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
---@field cursor integer
---@field field string
---@field editingField string
---@field placeholder string
---@field validField boolean
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
---@return GNUI.TextField
function TextFieldAPI.new(canvas)
	local self = Button.new(canvas)
	---@cast self GNUI.TextField
	setmetatable(self,TextField)
	self:setMinimumSize(0,13)
	
	self.cursor = 0
	self.field = ""
	self.editingField = ""
	self.placeholder = ""
	self.toggle = true
	self.validField = true
	
	self.BUTTON_DOWN:register(function ()
		self.editingField = self.field
		self.canvas.CHAR_INPUT:register(function (char)
			self.editingField = self.editingField:sub(1,self.cursor) .. char .. self.editingField:sub(self.cursor+1,-1)
			self.cursor = self.cursor + 1
			self:updateTextField()
			return true
		end,self.id)
		
		local ctrl = false
		self.canvas.KEY_INPUT:register(function (scancode, state)
			if scancode == 341 then
				ctrl = state ~= 0
			end
			if state == 1 or state == 2 then
				if scancode == 263 then -- left
					if ctrl then
						local from = self.editingField:sub(1,self.cursor):find("%S*%s*$")
						self.cursor = from - 1
					else
						self.cursor = math.max(self.cursor - 1,0)
					end
				elseif scancode == 262 then -- right
				if ctrl then
					local from,to = self.editingField:sub(self.cursor+1,-1):find("^%s*%S*")
					self.cursor = self.cursor + to
				else
					self.cursor = math.min(self.cursor + 1,#self.editingField)
				end
				elseif scancode == 265 then -- up
				
				elseif scancode == 264 then -- down
				
				elseif scancode == 257 then -- enter
					self:release()
					if self.verifier and self.verifier(self.editingField) or not self.verifier then
						self.field = self.editingField
					end
				elseif scancode == 256 then -- esc
					self:release()
				elseif scancode == 259 then -- backspace
					if ctrl and self.cursor > 2 then
						local from = self.editingField:sub(1,self.cursor):find("%s*%S*$")
						self.editingField = self.editingField:sub(1,from-1)..self.editingField:sub(self.cursor+1,-1)
						self.cursor = from-1
					else
						self.editingField = self.editingField:sub(1,self.cursor-1)..self.editingField:sub(self.cursor+1,-1)
						self.cursor = math.max(self.cursor - 1,0)
					end
					
				elseif scancode == 261 then -- delete
					if ctrl then
						local _,to = self.editingField:sub(self.cursor+1,-1):find("^%s*%S*")
						self.editingField = self.editingField:sub(1,self.cursor)..self.editingField:sub(self.cursor+to+1,-1)
					else
						self.editingField = self.editingField:sub(1,self.cursor)..self.editingField:sub(self.cursor+2,-1)
					end
				end
				self:updateTextField()
			end
			return true
		end,self.id)
		
		self.canvas.MOUSE_INPUT:register(function (button, state)
			if not self:isPosInbounds(self.canvas.cursorPos) then
				self.field = self.editingField
				self:release()
			end
			return true
		end,self.id)
		self:updateTextField()
	end,"__core")
	
	self.BUTTON_UP:register(function ()
		self.canvas.CHAR_INPUT:remove(self.id)
		self.canvas.MOUSE_INPUT:remove(self.id)
		self.canvas.KEY_INPUT:remove(self.id)
		self:updateTextField()
	end,"__core")
	
	return self
end


---@generic self
---@param self self
---@return self
function TextField:updateTextField()
	---@cast self GNUI.TextField
	if self.down then
		self:setText(self.editingField:sub(1,self.cursor) .. "|" .. self.editingField:sub(self.cursor+1,-1))
	else
		self:setText(self.field)
	end
	
	local isValid = true
	if self.verifier then
		isValid = self.verifier(self.editingField)
	end
	
	if isValid ~= self.validField then
		self.validField = isValid
		self:applyApropriateStyle()
	end
	
	return self
end


---@generic self
---@param self self
---@return self
function TextField:applyApropriateStyle()
	---@cast self GNUI.TextField
	if self.down then
		if self.validField then
			self.sprite:setStyle(Style.getKey(self,"active"))
		else
			self.sprite:setStyle(Style.getKey(self,"invalid"))
		end
	else
		self.sprite:setStyle(Style.getKey(self,"normal"))
	end
	return self
end


---@diagnostic disable: duplicate-doc-field
---@class GNUI.Layout
---@field type "button"?

---@param layout any
---@param canvas GNUI.Canvas
---@param button GNUI.TextField?
---@return GNUI.TextField
function TextFieldAPI.parse(layout,canvas,button)
	local box = button or Box.parse(layout,canvas,TextFieldAPI.new(canvas))
	
	return box
end

Layout.registerType("textField", TextFieldAPI.parse)



return TextFieldAPI