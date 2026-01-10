---@diagnostic disable: duplicate-doc-field
local config = require("../../config") ---@type GNUI.config
local gncommon = require("../../../gncommon") ---@type GNCommon
local utils = require("../../utils") ---@type GNUI.utils
local Event = require("../../"..config.EVENT) ---@type Event

local Layout = require("../../" .. config.LAYOUT) ---@class GNUI.LayoutAPI
local Style = require("../../" .. config.STYLE) ---@class GNUI.StyleAPI

---@class GNUI.BoxAPI
local BoxAPI = {}


---@alias GNUI.Box.SizingMode string
---| "FIXED"
---| "FIT"
---| "FILL"


---@alias GNUI.Box.LayoutMode string?
---| "VERTICAL"
---| "HORIZONTAL"
---| nil


---@class GNUI.Box.Event.CharInput
---@field register fun(self,func:fun(char: string))

---@class GNUI.Box.Event.KeyInput
---@field register fun(self,func:fun(scancode:integer, state:integer))

---@class GNUI.Box.Event.MouseInput
---@field register fun(self,func:fun(button:integer,state:integer))


---@class GNUI.Box.Event.CursorPresenceChanged
---@field register fun(self,func:fun(inside: boolean))


---@class GNUI.Box
---
---@field pos Vector2
---@field size Vector2
---@field sizing {x:GNUI.Box.SizingMode,y:GNUI.Box.SizingMode}
---@field minSize Vector2
---@field maxSize Vector2
---
---@field padding Vector4
---@field margin Vector4
---@field childGap number
---
---@field layout GNUI.Box.LayoutMode?
---
---@field bakedPos Vector2
---@field bakedSize Vector2
---@field bakedDim Vector4
---
---@field parent GNUI.Box?
---@field childIndex integer
---@field children GNUI.Box[]
---@field namedChildren table<string,GNUI.Box>
---@field childAlign Vector2
---
---@field visible boolean
---@field id integer
---
---@field text string
---@field textAlignmnet -1|0|1
---@field wrapText boolean
---
---@field flaggedUpdate boolean
---@field canvas GNUI.Canvas
---
---@field variant string?
---@field sprite GNUI.Sprite?
---
---@field isHovered boolean
---
---@field CURSOR_PRESENCE_CHANGED GNUI.Box.Event.CursorPresenceChanged
---@field KEY_INPUT GNUI.Box.Event.KeyInput
---@field CHAR_INPUT GNUI.Box.Event.CharInput
---@field MOUSE_INPUT GNUI.Box.Event.MouseInput
---
---@field [string] GNUI.Box
local Box = {}
Box.__index = function (t,i)
	return rawget(t,i) or Box[i] or rawget(t,"children")[i] or rawget(t,"namedChildren")[i]
end
Box.__style = "box"

function BoxAPI.index(i)
	return Box[i]
end


local nextFree = 1

---Creates a new box, the fundemental primitive element of GNUI.
---@param canvas GNUI.Canvas
---@return GNUI.Box
function BoxAPI.new(canvas)
	local self = {
		pos = vec(0,0),
		
		sizing = {x="FIT",y="FIT"},
		size = vec(-1,-1),
		minSize = vec(0,0),
		maxSize = vec(math.huge,math.huge),
		
		padding = vec(0,0,0,0),
		margin = vec(0,0,0,0),
		childGap = 0,
		
		--layout = "HORIZONTAL",
		
		bakedPos = vec(0,0),
		bakedSize = vec(0,0),
		
		parent = nil,
		childIndex = 0,
		children = {},
		namedChildren = {},
		childAlign = vec(-1,-1),
		
		id = nextFree,
		visible = true,
		
		textAlignment = 0,
		wrapText = true,
		
		canvas = canvas,
		
		CURSOR_PRESENCE_CHANGED = Event.new(),
		KEY_INPUT = Event.new(),
		CHAR_INPUT = Event.new(),
		MOUSE_INPUT = Event.new(),
	}
	nextFree = nextFree + 1
	
	setmetatable(self, Box)
	return self
end


---@param name string
---@return GNUI.Box
function Box:setName(name)
	if self.parent then
		self.parent.namedChildren[name] = self
	end
	self.name = name
	return self
end


---Sets the position of the box,
---note that position only applies if the parent box dosent automatically handle it
---@overload fun(self: GNUI.Box ,pos : Vector2): GNUI.Box
---@param x number?
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setPos(x,y)
	---@cast self GNUI.Box
	self.pos = gncommon.vec2(x,y,self.pos)
	self:update()
	return self
end


---@return Vector2
function Box:getPos()
	return self.bakedPos
end


function Box:getGlobalPos()
	local pos = self.bakedPos
	local parent = self.parent
	while parent do
		pos = pos + parent.bakedPos
		parent = parent.parent
	end
	return pos
end


---@generic self
---@param self self
---@return self
---@overload fun(self: GNUI.Box ,leftTop: Vector2, rightBottom: Vector2): GNUI.Box
---@overload fun(self: GNUI.Box ,leftTopRightBottom: Vector4): GNUI.Box
---@param left number
---@param top number
---@param right number
---@param bottom number
function Box:setMargin(left,top,right,bottom)
	---@cast self GNUI.Box
	self.margin = gncommon.vec4(left,top,right,bottom)
	self:update()
	return self
end


---@return Vector4
function Box:getMargin()
	return self.margin + (self.sprite and self.sprite.style and self.sprite.style.margin or vec(0,0,0,0))
end


---@generic self
---@param self self
---@return self
---@overload fun(self: GNUI.Box ,leftTop: Vector2, rightBottom: Vector2): GNUI.Box
---@overload fun(self: GNUI.Box ,leftTopRightBottom: Vector4): GNUI.Box
---@param left number
---@param top number
---@param right number
---@param bottom number
function Box:setPadding(left,top,right,bottom)
	---@cast self GNUI.Box
	self.padding = gncommon.vec4(left,top,right,bottom)
	if self.sprite then
		self.sprite:setPadding(self:getPadding())
	end
	self:update()
	return self
end


---@return Vector4
function Box:getPadding()
	return self.padding + (self.sprite and self.sprite.style and self.sprite.style.padding or vec(0,0,0,0))
end


---@generic self
---@param self self
---@return self
---@param gap number
function Box:setChildGap(gap)
	---@cast self GNUI.Box
	self.childGap = gap
	return self
end


---@return number
function Box:getChildGap()
	return self.childGap
end


---Sets the size of the box  
---NOTE: setting an axis to -1 will make it automatically fit that given axis.
---@overload fun(self: GNUI.Box ,size : Vector2): GNUI.Box
---@param x number?
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setSize(x,y)
	---@cast self GNUI.Box
	local size = gncommon.vec2(x,y,self.size)
	self.size = size
	self:update()
	return self
end


---@overload fun(self: GNUI.Box ,size : Vector2): GNUI.Box
---@param x number?
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setMinimumSize(x,y)
	---@cast self GNUI.Box
	self.minSize = gncommon.vec2(x,y,self.minSize)
	self:update()
	return self
end


---@return Vector2
function Box:getMinimumSize()
	return self.minSize
end


---@overload fun(self: GNUI.Box ,size : Vector2): GNUI.Box
---@param x number?
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setMaximumSize(x,y)
	---@cast self GNUI.Box
	self.maxSize = gncommon.vec2(x,y,self.maxSize)
	self:update()
	return self
end


---@return Vector2
function Box:getMaximumSize()
	return self.maxSize
end


---@generic self
---@param self self
---@return self
---@param x GNUI.Box.SizingMode?
---@param y GNUI.Box.SizingMode?
function Box:setSizing(x,y)
	---@cast self GNUI.Box
	self.sizing = {x=x or self.sizing.x,y=y or self.sizing.y}
	return self
end


---@return Vector2
function Box:getSize()
	return vec(
		math.clamp(self.size.x,self.minSize.x,self.maxSize.x),
		math.clamp(self.size.y,self.minSize.y,self.maxSize.y)
	)
end


---@generic self
---@param self self
---@return self
---@param layout GNUI.Box.LayoutMode
function Box:setLayout(layout)
	---@cast self GNUI.Box
	self.layout = layout
	self:update()
	return self
end


---@overload fun(self: GNUI.Box ,hv: Vector2): GNUI.Box
---@param h number
---@param v number
---@generic self
---@param self self
---@return self
function Box:setChildAlign(h,v)
	---@cast self GNUI.Box
	self.childAlign = gncommon.vec2(h,v)
	self:update()
	return self
end


---@generic self
---@param self self
---@return self
---@param sprite GNUI.Sprite
function Box:setSprite(sprite)
	---@cast self GNUI.Box
	if self.sprite then
		self.sprite:setBox(self)
		
		for index, value in ipairs(self.children) do
			if value.sprite then
				value.sprite:setParent(self.sprite.id, index)
			end
		end
	end
	self.sprite = sprite
	self:update()
	return self
end


---Sets the style of the sprite of this box, if no sprite exists, it will create one for that given style
---
---if no style is given, it will simply reapply the style of the sprite back to itself
---@generic self
---@param self self
---@return self
---@param style GNUI.Sprite.Style?
function Box:setStyle(style)
	---@cast self GNUI.Box
	if not self.sprite and style then
		self.sprite = style:newInstance(self)
	end
	
	if self.sprite then
		if style then
			self.sprite:setStyle(style)
		end
		self.sprite:applyStyle()
	end
	return self
end

--────────────────────────-< Children Management >-────────────────────────--

---@param box GNUI.Box
local function updateChildrenIndexes(box)
	for id, child in ipairs(box.children) do
		child.childIndex = id
		if child and child.sprite and box.sprite then
			child.canvas.render:setIndex(child.sprite.id, id)
		end
		updateChildrenIndexes(child)
	end
end


---@param box GNUI.Box
---@generic self
---@param self self
---@return self
function Box:addChild(box)
	---@cast self GNUI.Box
	box.parent = self
	local id = #self.children + 1
	self.children[id] = box
	box.childIndex = id
	
	if box.name then
		self.namedChildren[box.name] = box
	end
	
	if box and box.sprite and self.sprite then
		box.sprite:setParent(self.sprite.id, id)
	end
	
	self:update()
	return box
end


---Removes a child from the box
---@param box GNUI.Box
---@generic self
---@param self self
---@return self
function Box:removeChild(box)
	---@cast self GNUI.Box
	local boxID = box.childIndex
	if self.children[boxID] == box then
		local box = self.children[boxID]
		table.remove(self.children, boxID)
		
		if box.name then
			box.namedChildren[box.name] = nil
		end
		
		updateChildrenIndexes(self)
		box.parent = nil
	end
	self:update()
	return self
end


---@param name string
---@return GNUI.Box?
function Box:getChild(name)
	if tonumber(name) then
		return self.children[name]
	else
		for index, child in ipairs(self.children) do
			if child.name == name then
				return child
			end
		end
	end
end


---Removes the parent of the box
---@generic self
---@param self self
---@return self
function Box:removeParent()
	---@cast self GNUI.Box
	if self.parent then
		self.parent:removeChild(self)
	end
	return self
end


---Sets the parent of the box
---@param parent GNUI.Box
---@return GNUI.Box
function Box:setParent(parent)
	self:removeParent()
	parent:addChild(self)
	return self
end


---Returns the parent of the box
---@return GNUI.Box?
function Box:getParent()
	return self.parent
end


---@generic self
---@param self self
---@return self
---@param text string
function Box:setText(text)
	---@cast self GNUI.Box
	self.text = text
	if self.sprite then
		self.sprite:setText(text)
	end
	return self
end


---@generic self
---@param self self
---@return self
---@param alignment -1|0|1
function Box:setTextAlignment(alignment)
	---@cast self GNUI.Box
	self.textAlignment = alignment
	return self
end


---sets if the text should wrap around or not
---@generic self
---@param self self
---@return self
---@param wrap boolean
function Box:setWrapText(wrap)
	---@cast self GNUI.Box
	self.wrapText = wrap
	return self
end

--────────────────────────-<  >-────────────────────────--

---@param pos Vector2
---@return boolean
function Box:isPosInbounds(pos)
	local globalPos = self:getGlobalPos()
	local otherEnd = globalPos + self.bakedSize
	
	if pos.x > globalPos.x and pos.x < otherEnd.x
	and pos.y > globalPos.y and pos.y < otherEnd.y then
		return true
	end
	return false
end

--────────────────────────-< UPDATERS >-────────────────────────--


---Updates itself and its relatives that will get affected
function Box:update()
	self:updateItself()
end


function Box:updateItself()
	if not self.flaggedUpdate then
		self.flaggedUpdate = true
		if self.canvas then
			self.canvas.queueUpdate[self.id] = self
		end
	end
end

function Box:updateSprites()
	if self.sprite then
		local sprite = self.sprite
		sprite:setPos(self.bakedPos)
		sprite:setSize(self.bakedSize)
	end
	for _, child in ipairs(self.children) do
		child:updateSprites()
	end
end

---Forces this element to update
---@generic self
---@param self self
---@return self
function Box:forceUpdate()
	---@cast self GNUI.Box
	self
	
	:solveForFitSizing(false)
	:sovleForFillSizing(false)
	:sovleForLayout(false)
	
	:solveForFitSizing(true)
	:sovleForFillSizing(true)
	:sovleForLayout(true)
	
	
	:updateSprites()
	return self
end


---@param other boolean? # tell if its in the X(false) or Y(true) axis
---@generic self
---@param self self
---@return self
function Box:solveForFitSizing(other)
	local x = (other and "y" or "x")
	local z = (other and "w" or "z")
	---@cast self GNUI.Box
	
	for _, child in ipairs(self.children) do
		child.bakedSize[x] = 0
		child:solveForFitSizing(other)
	end
	
	local padding = self:getPadding()
	local textSize = self.text and utils.getTextSize(self.text, x == "y" and (self.bakedSize.x - padding.x - padding.z) or 0, self.wrapText) or vec(0,0)
	if self.sizing[x] == "FIXED" then
		self.bakedSize[x] = math.max(self.minSize[x],self.size[x])
		
	elseif self.sizing[x] == "FIT" then
		
		if (self.layout == (other and "VERTICAL" or "HORIZONTAL")) then -- is parallel
			local totalSize = 0
			for _, child in ipairs(self.children) do
				local childPadding = child:getPadding()
				local childMargin = child:getMargin()
				totalSize = totalSize + child.bakedSize[x] + childPadding[x] + childPadding[z] + childMargin[x] + childMargin[z]
			end
			totalSize = totalSize + self.childGap * (#self.children - 1)
			self.bakedSize[x] = math.max(self.minSize[x],totalSize,textSize[x])
		
		else
			local minSize = self.minSize[x]
			for _, child in ipairs(self.children) do
				local childMargin = child:getMargin()
				minSize = math.max(minSize,child.bakedSize[x] + childMargin[x] + childMargin[z])
			end
			self.bakedSize[x] = math.max(minSize,textSize[x]) + padding[x] + padding[z]
		end
	end
	return self
end


---@param other boolean? # tell if its in the X(false) or Y(true) axis
---@generic self
---@param self self
---@return self
function Box:sovleForFillSizing(other)
	---@cast self GNUI.Box
	local x = (other and "y" or "x")
	local z = (other and "w" or "z")
	local padding = self:getPadding()
	local remainingSpace = self.bakedSize[x] - padding[x] - padding[z]
	
	local parallel = self.layout == (other and "VERTICAL" or "HORIZONTAL")
	local fillers = {} ---@type GNUI.Box[]
	local fitters = {} ---@type GNUI.Box[]
	
	if parallel then
		for _, child in ipairs(self.children) do
			if child.sizing[x] == "FILL"then
				fillers[#fillers+1] = child
				child.bakedSize[x] = math.max(child.minSize[x], 0)
			elseif child.sizing[x] == "FIT" then
				fitters[#fitters+1] = child
			end
			local margin = child:getMargin()
			remainingSpace = remainingSpace - child.bakedSize[x] - margin[x] - margin[z]
		end
		remainingSpace = remainingSpace - self.childGap * (#self.children - 1)
		
		if #fillers > 0 then
			for i = 1, 10, 1 do
				if remainingSpace < 0.01 then break end
				local smallest = fillers[1]
				local secondSmallest = fillers[1]
				local spaceToAdd = remainingSpace
				
				
				for _, child in pairs(fillers) do
					-- find the smallest and 2nd smallest child
					if child.bakedSize[x] < smallest.bakedSize[x] then
						secondSmallest = smallest
						smallest = child
					end
					
					-- set space to add to the difference between the smallest to the 2nd smallest
					if child.bakedSize[x] > smallest.bakedSize[x] then 
						secondSmallest.bakedSize[x] = math.max(secondSmallest.bakedSize[x], child.bakedSize[x])
						spaceToAdd = secondSmallest.bakedSize[x] - smallest.bakedSize[x]
					end
				end
				
				-- clamp the allowed space to expand to the remaining space divided to all fillers
				spaceToAdd = math.min(spaceToAdd, remainingSpace / #fillers)
				for _, child in pairs(fillers) do
					if child.bakedSize[x] == smallest.bakedSize[x] then
						child.bakedSize[x] = child.bakedSize[x] + spaceToAdd
						remainingSpace = remainingSpace - spaceToAdd
					end
				end
			end
		end
	else
		for _, child in pairs(self.children) do
			if child.sizing[x] == "FILL" then
				local margin = child:getMargin()
				child.bakedSize[x] = math.max(self.bakedSize[x] - padding[x] - padding[z] - margin[x] - margin[z],child.bakedSize[x])
			end
		end
	end
	
	for _, child in ipairs(self.children) do
		child:sovleForFillSizing(other)
	end
	return self
end


---@param other boolean? # tell if its in the X(false) or Y(true) axis
---@generic self
---@param self self
---@return self
function Box:sovleForLayout(other)
	---@cast self GNUI.Box
	local x = (other and "y" or "x")
	local z = (other and "z" or "w")
	
	if self.layout then
		if self.layout == (other and "VERTICAL" or "HORIZONTAL") then
			local pos = self:getPadding()[x]
			for _, child in ipairs(self.children) do
				local childMargin = child:getMargin()
				child.bakedPos[x] = pos + childMargin[x]
				pos = pos + child.bakedSize[x] + childMargin[x] + childMargin[z] + self.childGap
			end
		else
			local padding = self:getPadding()
			for _, child in ipairs(self.children) do
				local margin = child:getMargin()
				child.bakedPos[x] = math.lerp(
				padding[x] + margin[x],
				self.bakedSize[x] - child.bakedSize[x] - padding[x] - margin[x],
				self.childAlign[x] * 0.5 + 0.5)
			end
		end
	else
		for _, child in ipairs(self.children) do
			local margin = child:getMargin()
			child.bakedPos[x] = child.pos[x] + margin[x]
			if child.sizing[x] == "FIXED" then
				child.bakedSize[x] = child.size[x]
			end
		end
	end
	
	for _, child in ipairs(self.children) do
		child:sovleForLayout(other)
	end
	return self
end


--────────────────────────-< Layout Parser >-────────────────────────--

---@class GNUI.Layout
---@field type nil|"box"
---@field name string?
---@field size Vector2?
---@field minSize Vector2?
---@field sizing ({[1]:GNUI.Box.SizingMode,[2]:GNUI.Box.SizingMode}|GNUI.Box.SizingMode)?
---@field pos Vector2?
---@field gap number?
---@field layout GNUI.Box.LayoutMode?
---@field childAlign Vector2?
---@field text string?
---@field textAlign (-1|0|1)?
---@field wrap boolean?


---@param layout GNUI.Layout
---@param canvas GNUI.Canvas
---@generic box
---@param box box
---@return box
function BoxAPI.parse(layout,canvas,box)
	local box = box or BoxAPI.new(canvas)

	local hasSizeX, hasSizeY = false, false
	if layout.size then
		box:setSize(layout.size.x, layout.size.y)
		hasSizeX = layout.size.x ~= -1
		hasSizeY = layout.size.y ~= -1
	end
	if layout.minSize then box:setMinimumSize(layout.minSize.x, layout.minSize.y) end
	if layout.sizing then
		if type(layout.sizing) == "string" then
---@diagnostic disable-next-line: param-type-mismatch
			box:setSizing(layout.sizing, layout.sizing)
		else
			box:setSizing(layout.sizing[1], layout.sizing[2])
		end
	else
		if box.text then
			box:setSizing("FILL", "FIT")
		else
			box:setSizing(hasSizeX and "FIXED" or "FIT", hasSizeY and "FIXED" or "FIT")
		end
	end
	if layout.pos then box:setPos(layout.pos.x, layout.pos.y) end
	if layout.layout then box:setLayout(layout.layout) end
	if layout.childAlign then box:setChildAlign(layout.childAlign) end
	if layout.gap then box:setChildGap(layout.gap) end
	
	box.variant = layout.variant or "default"
	
	local style = Style.getStyle(box, box.variant, "normal")
	if style then
		box:setSprite(style:newInstance(box))
	end

	if layout.text then box:setText(layout.text) end
	if layout.textAlign then box:setTextAlignment(layout.textAlign) end
	if layout.wrap then box:setWrapText(layout.wrap) end

	if layout.name then
		box:setName(layout.name)
		box.name = layout.name
	end

	return box
end

Layout.registerType("box", BoxAPI.parse)

return BoxAPI