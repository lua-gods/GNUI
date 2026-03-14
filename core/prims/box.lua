--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: Internal Primitive BoxAPI
/ /_/ / /|  /  desc: meant to be used by widgets, use the Widget Box API for anything else
\____/_/ |_/ source: link ]]
---@diagnostic disable: duplicate-doc-field
local BASE = ((...):gsub("/",".")):match(".+%.GNUI")

local cfg = require(BASE..".config") ---@type GNUI.config
local gncommon = require(cfg.GN_COMMON) ---@type GNCommon
local utils = require(cfg.UTILS) ---@type GNUI.utils
local Event = require(cfg.EVENT) ---@type Event


local abs = math.abs


---@class GNUI.Primitive.BoxAPI
local BoxAPI = {}


---@alias GNUI.Box.SizingMode string
---| "FIXED"
---| "FIT"
---| "FILL"


---@alias GNUI.Box.LayoutMode string?
---| "VERTICAL"
---| "HORIZONTAL"
---| nil


---@class GNUI.Box.Event.CharInput : Event
---@field register fun(self,func:fun(char: string))

---@class GNUI.Box.Event.KeyInput : Event
---@field register fun(self,func:fun(scancode:integer, state:integer))

---@class GNUI.Box.Event.MouseInput : Event
---@field register fun(self,func:fun(button:integer,state:integer))


---@class GNUI.Box.Event.CursorPresenceChanged : Event
---@field register fun(self,func:fun(inside: boolean))


---@class GNUI.Box.Flags
---@field dim boolean?
---@field extents boolean? margin, padding and minSize
---@field color boolean?
---@field text boolean?
---@field visibility boolean?


---@class GNUI.Box
---
---@field pos Vector2
---@field size Vector2
---@field minSize Vector2
---@field maxSize Vector2
---@field padding Vector4
---@field margin Vector4
---
---@field finalPos Vector2
---@field finalSize Vector2
---@field finalMinSize Vector2
---@field finalMaxSize Vector2
---@field finalPadding Vector4
---@field finalMargin Vector4
---
---@field sizing {x:GNUI.Box.SizingMode,y:GNUI.Box.SizingMode}
---
---@field childGap number
---
---@field layout GNUI.Box.LayoutMode?
---
---@field parent GNUI.Box?
---@field childIndex integer
---@field children GNUI.Box[]
---@field namedChildren table<string,GNUI.Box>
---@field childAlign Vector2
---
---@field visible boolean
---@field color Vector3
---@field id integer
---
---@field text string
---@field textAlignment Vector2
---@field wrapText boolean
---
---@field flaggedUpdate boolean
---@field canvas GNUI.Canvas
---
---@field variant string?
---@field visualID integer
---@field sprites table<any,GNUI.Sprite> # middle man style handling
---
---@field isHovered boolean
---
---@field z number
---@field zScale number
---
---@field flags GNUI.Box.Flags
---
---@field CURSOR_PRESENCE_CHANGED GNUI.Box.Event.CursorPresenceChanged
---@field KEY_INPUT GNUI.Box.Event.KeyInput
---@field CHAR_INPUT GNUI.Box.Event.CharInput
---@field MOUSE_INPUT GNUI.Box.Event.MouseInput
local Box = {}
Box.__index = function (t,i)
	return rawget(t,i)
	or Box[i]
	or rawget(t,"children")[i]
	or rawget(t,"namedChildren")[i]
end
Box.__style = "box"


function BoxAPI.index(t,i)
	return Box.__index(t,i)
end


local nextFree = 1

---Creates a new box, the fundemental primitive element of GNUI.
---@param canvas GNUI.Canvas
---@return GNUI.Box
function BoxAPI.new(canvas)
	local self = {
		
		pos = vec(0,0),
		size = vec(-1,-1),
		minSize = vec(0,0),
		maxSize = vec(math.huge,math.huge),
		padding = vec(0,0,0,0),
		margin = vec(0,0,0,0),
		
		finalPos = vec(0,0),
		finalSize = vec(0,0),
		finalMinSize = vec(0,0),
		finalMaxSize = vec(0,0),
		finalPadding = vec(0,0,0,0),
		finalMargin = vec(0,0,0,0),
		
		sizing = {x="FIT",y="FIT"},
		
		childGap = 0,
		
		--layout = "HORIZONTAL",
		
		parent = nil,
		childIndex = 0,
		children = {},
		namedChildren = {},
		childAlign = vec(-1,-1),
		
		visible = true,
		color = vec(1,1,1),
		id = nextFree,
		
		wrapText = true,
		
		canvas = canvas,
		visualID = canvas and canvas.display:newVisual(),
		
		sprites = {},
		tasks = {},
		
		flags = {},
		
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
	return self.finalPos
end


---@return Vector2
function Box:getGlobalPos()
	local pos = self.finalPos
	local parent = self.parent
	while parent do
		pos = pos + parent.finalPos
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
	self:recalculateMargin()
	self:recalculateMinimumSize()
	self:update()
	return self
end


function Box:recalculateMargin()
	local margin = vec(0,0,0,0)
	for key, sprite in pairs(self.sprites) do
		if sprite.style then
			local m = sprite.style.margin
			margin.x = (abs(margin.x) <= abs(m.x)) and m.x or margin.x
			margin.y = (abs(margin.y) <= abs(m.y)) and m.y or margin.y
			margin.z = (abs(margin.z) <= abs(m.z)) and m.z or margin.z
			margin.w = (abs(margin.w) <= abs(m.w)) and m.w or margin.w
		end
	end
	self.finalMargin = margin
end


---@return Vector4
function Box:getMargin()
	return self.finalMargin
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
	self:recalculatePadding()
	self:recalculateMinimumSize()
	self:update()
	for key, value in pairs(self.sprites) do
		if value.labelID then
			self.canvas.display:setLabelPadding(self.visualID,value.labelID,self.padding:unpack())
		end
	end
	return self
end


---@return Vector4
function Box:getPadding()
	return self.finalPadding
end


function Box:recalculatePadding()
	local padding = vec(0,0,0,0)
	for key, sprite in pairs(self.sprites) do
		if sprite.style then
			local p = sprite.style.padding
			padding.x = math.max(padding.x, p.x)
			padding.y = math.max(padding.y, p.y)
			padding.z = math.max(padding.z, p.z)
			padding.w = math.max(padding.w, p.w)
		end
	end
	self.finalPadding = padding
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
	self:recalculateMinimumSize()
	self:update()
	return self
end


---@return Vector2
function Box:getMinimumSize()
	return self.finalMinSize
end


function Box:recalculateMinimumSize()
	local minSize = self.minSize:copy()
	for key, sprite in pairs(self.sprites) do
		if sprite.style then
			local style = sprite.style
			minSize.x = math.max(minSize.x,style.padding.x + style.padding.z)
			minSize.y = math.max(minSize.y,style.padding.y + style.padding.w)
		end
	end
	self.finalMinSize = minSize
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
	self.finalMaxSize = self.maxSize -- lmao
	self:update()
	return self
end


---@return Vector2
function Box:getMaximumSize()
	return self.finalMaxSize
end


---@generic self
---@param self self
---@return self
---@param x GNUI.Box.SizingMode?
---@param y GNUI.Box.SizingMode?
function Box:setSizing(x,y)
	---@cast self GNUI.Box
	self.sizing = {x=x or self.sizing.x,y=y or self.sizing.y}
	self:update()
	return self
end


---@return Vector2
function Box:getSize()
	local minSize = self:getMinimumSize()
	return math.clamp(self.size,minSize,self.maxSize)
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
---@param slot (integer|string)?
function Box:setSprite(sprite,slot)
	---@cast self GNUI.Box
	
	sprite:setBox(self,slot)
	self:recalculateMargin()
	self:recalculatePadding()
	self:recalculateMinimumSize()
	self:update()
	return self
end


-----Sets the style of the sprite of this box, if no sprite exists, it will create one for that given style
-----
-----if no style is given, it will simply reapply the style of the sprite back to itself
-----@generic self
-----@param self self
-----@return self
-----@param style GNUI.Sprite.Style?
--function Box:setStyle(style)
--	---@cast self GNUI.Box
--	if not self.sprites and style then
--		self.sprites = style:newInstance(self)
--	end
--	
--	if self.sprites then
--		if style then
--			self.sprites:setStyle(style)
--		end
--	end
--	
--	self:recalculateMargin()
--	self:recalculatePadding()
--	self:recalculateMinimumSize()
--	self:update()
--	return self
--end


--────────────────────────-< Children Management >-────────────────────────--

---@param box GNUI.Box
local function updateChildrenIndexes(box)
	for id, child in ipairs(box.children) do
		child.childIndex = id
		updateChildrenIndexes(child)
	end
end


---@param child GNUI.Box
---@generic self
---@param self self
---@return self
function Box:addChild(child)
	---@cast self GNUI.Box
	child.parent = self
	local id = #self.children + 1
	self.children[id] = child
	child.childIndex = id
	
	if child.name then
		self.namedChildren[child.name] = child
	end
	self.canvas.display:addChild(self.visualID,child.visualID)
	
	
	self:recalculateMinimumSize()
	self:update()
	return child
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
		
		self.canvas.display:removeChild(self.visualID,box.visualID)
		
		updateChildrenIndexes(self)
		box.parent = nil
	end
	self:recalculateMinimumSize()
	self:update()
	return self
end


---@param box GNUI.Box
---@param name string
local function searchChild(box,name)
	if box == nil then return nil end
	if box.name == name then
		return box
	end
	for index, value in ipairs(box.children) do
		local result = searchChild(value,name)
		if result then
			return result
		end
	end
end


---Returns the first box with that given name, through its entirey hierarchy.
---@param name string
---@return GNUI.Box?
function Box:getChild(name)
	return searchChild(self,name)
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
	self:update()
	return self
end


---Sets the parent of the box
---@param parent GNUI.Box
---@return GNUI.Box
function Box:setParent(parent)
	self:removeParent()
	parent:addChild(self)
	self:update()
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
---@param slot (integer|string)?
function Box:setText(text,slot)
	---@cast self GNUI.Box
	self.text = text
	slot = slot or 1
	if self.sprites[slot] then
		self.sprites[slot]:setText(text)
	end
	self:update("text","dim")
	return self
end


---@generic self
---@param self self
---@return self
---@param h -1|0|1
---@param v -1|0|1
function Box:setTextAlignment(h,v)
	---@cast self GNUI.Box
	self.textAlignment = vec(h,v)
	self:update("text")
	for key, value in pairs(self.sprites) do
		value:setTextAlignment(h,v)
	end
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
	self:update("text")
	return self
end


function Box:setColor(r,g,b)
	local clr = gncommon.vec3(r,g,b)
	self.color = clr
	self:update("color")
	return self
end


---@generic self
---@param self self
---@return self
---@param visible boolean
function Box:setVisible(visible)
	---@cast self GNUI.Box
	self.visible = visible
	self:update("visibility")
	return self
end

--────────────────────────-<  >-────────────────────────--

---@param pos Vector2
---@return boolean
function Box:isPosInbounds(pos)
	local globalPos = self:getGlobalPos()
	local otherEnd = globalPos + self.finalSize
	
	if pos.x > globalPos.x and pos.x < otherEnd.x
	and pos.y > globalPos.y and pos.y < otherEnd.y then
		return true
	end
	return false
end

--────────────────────────-< UPDATERS >-────────────────────────--

---@param box GNUI.Box
local function updatePropagate(box,flags)
	if box.canvas and not box.flags.dim then
		-- TODO: propagate flag updating to all children
		box.flags.dim = true --TODO: unhardcode this by applying it only when its needed
		box.canvas.queueUpdate[#box.canvas.queueUpdate+1] = box
	end
	for index, child in ipairs(box.children) do
		updatePropagate(child)
	end
end

---Updates itself and its relatives that will get affected
function Box:update(...)
	self.flags = {}
	for index, flag in ipairs{...} do
		self.flags[flag] = true
	end
	
	if not self.flags.dim then
		if self.parent then
			local lastParent = self
			local parent = self.parent
			while parent do
				if not parent.layout then
					break
				else
					lastParent = parent
					parent = parent.parent
				end
			end
			updatePropagate(lastParent,self.flags)
		else
			updatePropagate(self,self.flags)
		end
	end
end


function Box:updateSprites()
	--TODO: separate each applying method into its own update flag
	local flags = self.flags
	if flags.color then
		self.canvas.display:setColor(self.visualID, self.color.x, self.color.y, self.color.z)
	end
	if flags.visibility then
		self.canvas.display:setVisible(self.visualID, self.visible)
	end
	if flags.dim then
		self.canvas.display:setPos(self.visualID, self.finalPos.x, self.finalPos.y)
		self.canvas.display:setSize(self.visualID, self.finalSize.x, self.finalSize.y)
	end
	--if flags.text then
	--	self.canvas.display:setTextAlignment(self.visualID,1, self.textAlignment.x, self.textAlignment.y)
	--end
	for key, sprite in pairs(self.sprites) do
		sprite:setSize(self.finalSize.x,self.finalSize.y)
	end
	
	for _, child in ipairs(self.children) do
		child:updateSprites()
	end
end

local function unflag(box)
	box.flags.dim = false -- AAAAAAAAAAAAA 
	for _, child in ipairs(box.children) do
		unflag(child)
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
	unflag(self)
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
		child.finalSize[x] = 0
		child:solveForFitSizing(other)
	end
	
	local padding = self:getPadding()
	local textSize = self.text and utils.getTextSize(self.text, x == "y" and (self.finalSize.x - padding.x - padding.z) or math.huge, self.wrapText) or vec(0,0)
	if self.sizing[x] == "FIXED" then
		self.finalSize[x] = math.max(self.finalMinSize[x],self.size[x])
		
	elseif self.sizing[x] == "FIT" then
		if self.layout == (other and "VERTICAL" or "HORIZONTAL") then -- is parallel
			local totalSize = 0
			for _, child in ipairs(self.children) do
				local childMargin = child:getMargin()
				totalSize = totalSize + child.finalSize[x] + childMargin[x] + childMargin[z]
				
			end
			totalSize = totalSize + self.childGap * (#self.children - 1)
			self.finalSize[x] = math.max(self.finalMinSize[x],totalSize,textSize[x]) + padding[x] + padding[z]
		
		else
			local minSize = self.finalMinSize[x]
			for _, child in ipairs(self.children) do
				local childMargin = child:getMargin()
				minSize = math.max(minSize,child.finalSize[x] + childMargin[x] + childMargin[z])
			end
			self.finalSize[x] = math.max(minSize,textSize[x]) + padding[x] + padding[z]
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
	local remainingSpace = self.finalSize[x] - padding[x] - padding[z]
	
	local parallel = self.layout == (other and "VERTICAL" or "HORIZONTAL")
	local fillers = {} ---@type GNUI.Box[]
	local fitters = {} ---@type GNUI.Box[]
	
	if parallel then
		for _, child in ipairs(self.children) do
			if child.sizing[x] == "FILL"then
				fillers[#fillers+1] = child
				child.finalSize[x] = math.max(child.minSize[x], 0)
			elseif child.sizing[x] == "FIT" then
				fitters[#fitters+1] = child
			end
			local margin = child:getMargin()
			local padding = child:getPadding()
			remainingSpace = remainingSpace - child.finalSize[x] - margin[x] - margin[z]
		end
		remainingSpace = remainingSpace - self.childGap * (#self.children - 1)
		
		if #fillers > 0 then
			for i = 1, 1000, 1 do
				if remainingSpace < 0.001 then break end
				local smallest = fillers[1]
				local secondSmallest = fillers[1]
				local spaceToAdd = remainingSpace
				
				
				for _, child in pairs(fillers) do
					-- find the smallest and 2nd smallest child
					if child.finalSize[x] < smallest.finalSize[x] then
						secondSmallest = smallest
						smallest = child
					end
					
					-- set space to add to the difference between the smallest to the 2nd smallest
					if child.finalSize[x] > smallest.finalSize[x] then 
						spaceToAdd = secondSmallest.finalSize[x] - smallest.finalSize[x]
					end
				end
				
				-- clamp the allowed space to expand to the remaining space divided to all fillers
				spaceToAdd = math.min(spaceToAdd, remainingSpace / #fillers)
				for _, child in pairs(fillers) do
					if child.finalSize[x] == smallest.finalSize[x] then
						child.finalSize[x] = child.finalSize[x] + spaceToAdd
						remainingSpace = remainingSpace - spaceToAdd
					end
				end
			end
		end
	else
		for _, child in pairs(self.children) do
			if child.sizing[x] == "FILL" then
				local margin = child:getMargin()
				child.finalSize[x] = math.max(self.finalSize[x] - padding[x] - padding[z] - margin[x] - margin[z],child.finalSize[x])
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
	local z = (other and "w" or "z")
	
	if self.layout then
		if self.layout == (other and "VERTICAL" or "HORIZONTAL") then
			local pos = self:getPadding()[x]
			for _, child in ipairs(self.children) do
				local childMargin = child:getMargin()
				child.finalPos[x] = pos + childMargin[x]
				pos = pos + child.finalSize[x] + childMargin[x] + childMargin[z] + self.childGap
			end
		else
			local padding = self:getPadding()
			for _, child in ipairs(self.children) do
				local margin = child:getMargin()
				child.finalPos[x] = math.lerp(
				padding[x] + margin[x],
				self.finalSize[x] - child.finalSize[x] - padding[z] - margin[z],
				self.childAlign[x] * 0.5 + 0.5)
			end
		end
	end
	if self.parent and not self.parent.layout then
		self.finalPos[x] = self.pos[x] + self:getMargin()[x]
		if self.sizing[x] == "FIXED" then
			self.finalSize[x] = self.size[x]
		end
	end
	
	for _, child in ipairs(self.children) do
		child:sovleForLayout(other)
	end
	return self
end


return BoxAPI
