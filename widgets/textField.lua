local BASE = ((...):gsub("/",".")):match(".+%.GNUI")
local cfg = require(BASE..".config") ---@type GNUI.config

local Box = require(cfg.WIDGETS..".box") ---@type GNUI.BoxAPI
local Event = require(cfg.EVENT)
local Button = require(cfg.WIDGETS..".button") ---@type GNUI.Widget.ButtonAPI

local Style = require(cfg.THEME..".init") ---@type GNUI.ThemeAPI
local Layout = require(cfg.LAYOUT..".init") ---@type GNUI.LayoutAPI

local utils = require(cfg.UTILS) ---@type GNUI.utils


---@class GNUI.Widget.TextFieldAPI.Event.Confirmed : Event
---@field register fun(self,func:fun(field: string))

---@class GNUI.Widget.TextFieldAPI.Event.Discard : Event
---@field register fun(self,func:fun(discarded: string))

---@class GNUI.Widget.TextFieldAPI.Event.FieldChanged : Event
---@field register fun(self,func:fun(field: string))


---@class GNUI.TextFieldAPI
local TextFieldAPI = {}


---@alias GNUI.TextField.Verifier string|(fun(field: string):boolean)
---| "decimal"
---| "integer"
---| "hex"
---| "email"
---| "username"
---| "url")))

TextFieldAPI.validators = {
	decimal = function (field) 
		return tonumber(field) and true or false
	end,
	integer = function (field)
		local result = tonumber(field) return result and result % 1 == 0 or false
	end,
	hex = function (field) return field:match("#?%x%x%x%x%x%x") and true or false end,
	email = function (field) return field:match("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$") and true or false end,
	username = function (field) return field:match("^[a-zA-Z0-9_]+$") and true or false end,
	url = function (field) return field:match("https?://[%w-_%.%?%.:/%+=&%()%#]+") and true or false end
}


---@class GNUI.TextField : GNUI.Widget.Button
---@field toggle true
---@field cursor integer
---@field field string
---@field editingField string
---@field placeholder string
---@field validField boolean
---@field multiline boolean
---@field validator fun(field: string):boolean
---@field CONFIRMED GNUI.Widget.TextFieldAPI.Event.Confirmed
---@field DISCARDED GNUI.Widget.TextFieldAPI.Event.Discard
---@field FIELD_CHANGED GNUI.Widget.TextFieldAPI.Event.FieldChanged
local TextField = {}
TextField.__index = function (t,i)
	return rawget(t,i)
	or TextField[i]
	or Button.index(t,i)
	or Box.index(t,i)
end
TextField.__style = "textField"
TextField.__type = "TextField"


function TextField.index(t,i)
	return TextField.__index(t,i)
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
	self.multiline = false
	
	self.CONFIRMED = Event.new()
	self.DISCARDED = Event.new()
	self.FIELD_CHANGED = Event.new()
	
	self.BUTTON_DOWN:register(function ()
		self.editingField = self.field
		local ctrl = false
		
		self.canvas.CHAR_INPUT:register(function (char)
			self.editingField = self.editingField:sub(1,self.cursor) .. char .. self.editingField:sub(self.cursor+1,-1)
			self.cursor = self.cursor + 1
			
			self:updateTextField()
			return true
		end,self.id)
		
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
					local cursor = self.cursor
					local lineStart,lineEnd,otherLineStart = cursor,cursor,cursor
					for i = cursor, 1, -1 do
						lineStart = i if self.editingField:sub(i,i) == "\n" then break end
					end
					for i = cursor, #self.editingField, 1 do lineEnd = i
						if self.editingField:sub(i,i) == "\n" then break end
					end
					for i = lineStart-1, 1, -1 do
						if self.editingField:sub(i,i) == "\n" then break end
						otherLineStart = i
					end
					if otherLineStart == lineStart then
						self.cursor = 0
					else
						local o = utils.getTextWidth(self.editingField:sub(lineStart,cursor))
						if o >= utils.getTextWidth(self.editingField:sub(otherLineStart,lineStart)) then
							self.cursor = lineStart-1
						else
							local newCursorPosInNextLine = utils.LengthToCharCount(self.editingField:sub(otherLineStart,lineEnd),o)
							self.cursor = otherLineStart + newCursorPosInNextLine - 1
						end
					end
				elseif scancode == 264 then -- down
					local cursor = self.cursor
					local lineStart,lineEnd,otherLineEnd = cursor,cursor,cursor
					for i = cursor, 1, -1 do
						lineStart = i if self.editingField:sub(i,i) == "\n" then break end
					end
					for i = cursor+1, #self.editingField, 1 do lineEnd = i
						if self.editingField:sub(i,i) == "\n" then break end
					end
					for i = lineEnd+1, #self.editingField, 1 do
						if self.editingField:sub(i,i) == "\n" then break end
						otherLineEnd = i
					end
					
					if otherLineEnd == lineEnd then
						self.cursor = #self.editingField
					else
						local o = utils.getTextWidth(self.editingField:sub(lineStart,cursor))
						if o == 0 then
							self.cursor = lineEnd
						else
							local newCursorPosInNextLine = utils.LengthToCharCount(self.editingField:sub(lineEnd,otherLineEnd),o)
							self.cursor = lineEnd + newCursorPosInNextLine - 1
						end
					end
					
				elseif scancode == 86 then -- v
					if ctrl then
						local clipboard = utils.getClipboard()
						self.editingField = self.editingField:sub(1,self.cursor) .. clipboard .. self.editingField:sub(self.cursor+1,-1)
						self.cursor = self.cursor + #clipboard
					end
				elseif scancode == 257 then -- enter
					if self.multiline then
						self.editingField = self.editingField .. "\n"
						self.cursor = self.cursor + 1
					else
						self:confirm()
					end
				elseif scancode == 256 then -- esc
					self:confirm()
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
			if not self:isPosInbounds(self.canvas.cursorPos) and state == 1 then
				self:confirm()
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


function TextField:discard()
	if self.down then
		self.DISCARDED:invoke(self.editingField)
		self:release()
	end
end


function TextField:confirm()
	if self.down then
		if self.validator and self.validator(self.editingField) or not self.validator then
			self.field = self.editingField
			self.CONFIRMED:invoke(self.field)
		end
		self:release()
	end
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
	if self.validator then
		isValid = self.validator(self.editingField)
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
			self.sprites[1]:setStyle(Style.getStyleFromBox(self,"active"))
		else
			self.sprites[1]:setStyle(Style.getStyleFromBox(self,"invalid"))
		end
	else
		self.sprites[1]:setStyle(Style.getStyleFromBox(self,"normal"))
	end
	return self
end


---@diagnostic disable: duplicate-doc-field
---@class GNUI.Layout
---@field type "textField"?
---@field field string?
---@field placeholder string?
---@field multiline boolean?
---@field validator GNUI.TextField.Verifier?

---@param layout any
---@param canvas GNUI.Canvas
---@param textField GNUI.TextField?
---@return GNUI.TextField
function TextFieldAPI.parse(layout,canvas,textField)
	local box = textField or Box.parse(layout,canvas,TextFieldAPI.new(canvas))
	
	if layout.field then box.field = layout.field end
	if layout.placeholder then box.placeholder = layout.placeholder end
	if layout.multiline then box.multiline = layout.multiline end
	if layout.validator then 
		if type(layout.validator) == "function" then
			box.validator = layout.validator
		else
			box.validator = TextFieldAPI.validators[layout.validator]
		end
	end
	
	return box
end

Layout.registerType("textField", TextFieldAPI.parse)

return TextFieldAPI