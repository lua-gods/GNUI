---@diagnostic disable: assign-type-mismatch, undefined-field, return-type-mismatch, inject-field
local cfg = require("./../config") ---@type GNUI.Config
local eventLib = cfg.event ---@type EventLibAPI ---@type EventLibAPI
local utils = cfg.utils ---@type GNUI.UtilsAPI
local Container = require(.....".box") ---@type GNUI.Box

---@class GNUI.InputEvent
---@field char string
---@field key GNUI.keyCode
---@field state Event.Press.state
---@field ctrl boolean
---@field shift boolean
---@field alt boolean
---@field isHandled boolean
---@field strength number # for scrollwheel

---@class GNUI.InputEventMouseMotion
---@field pos Vector2 # local position 
---@field relative Vector2 # the change of position since last set


---A valid key code for use in keybinds.
---
---Also accepts other formats such as
---* `key.keyboard.###`
---* `key.mouse.###`
---* `scancode.###`
---@alias GNUI.keyCode string
---| "key.keyboard.unknown"    # 🚫 *Unset*
---| "key.keyboard.escape"     # `⎋ Esc`
---| "key.keyboard.f1"       # `F1`
---| "key.keyboard.f2"       # `F2`
---| "key.keyboard.f3"       # `F3`
---| "key.keyboard.f4"       # `F4`
---| "key.keyboard.f5"       # `F5`
---| "key.keyboard.f6"       # `F6`
---| "key.keyboard.f7"       # `F7`
---| "key.keyboard.f8"       # `F8`
---| "key.keyboard.f9"       # `F9`
---| "key.keyboard.f10"      # `F10`
---| "key.keyboard.f11"      # `F11`
---| "key.keyboard.f12"      # `F12`
---| "key.keyboard.print.screen"  # `PrtSc|SysRq`
---| "key.keyboard.scroll.lock"   # `Scroll Lock`
---| "key.keyboard.pause"      # `Pause|Break`
---| "key.keyboard.f13"      # `F13`
---| "key.keyboard.f14"      # `F14`
---| "key.keyboard.f15"      # `F15`
---| "key.keyboard.f16"      # `F16`
---| "key.keyboard.f17"      # `F17`
---| "key.keyboard.f18"      # `F18`
---| "key.keyboard.f19"      # `F19`
---| "key.keyboard.f20"      # `F20`
---| "key.keyboard.f21"      # `F21`
---| "key.keyboard.f22"      # `F22`
---| "key.keyboard.f23"      # `F23`
---| "key.keyboard.f24"      # `F24`
---| "key.keyboard.f25"      # `F25`
---| "key.keyboard.0"       # `0`
---| "key.keyboard.1"       # `1`
---| "key.keyboard.2"       # `2`
---| "key.keyboard.3"       # `3`
---| "key.keyboard.4"       # `4`
---| "key.keyboard.5"       # `5`
---| "key.keyboard.6"       # `6`
---| "key.keyboard.7"       # `7`
---| "key.keyboard.8"       # `8`
---| "key.keyboard.9"       # `9`
---| "key.keyboard.a"       # `A`
---| "key.keyboard.b"       # `B`
---| "key.keyboard.c"       # `C`
---| "key.keyboard.d"       # `D`
---| "key.keyboard.e"       # `E`
---| "key.keyboard.f"       # `F`
---| "key.keyboard.g"       # `G`
---| "key.keyboard.h"       # `H`
---| "key.keyboard.i"       # `I`
---| "key.keyboard.j"       # `J`
---| "key.keyboard.k"       # `K`
---| "key.keyboard.l"       # `L`
---| "key.keyboard.m"       # `M`
---| "key.keyboard.n"       # `N`
---| "key.keyboard.o"       # `O`
---| "key.keyboard.p"       # `P`
---| "key.keyboard.q"       # `Q`
---| "key.keyboard.r"       # `R`
---| "key.keyboard.s"       # `S`
---| "key.keyboard.t"       # `T`
---| "key.keyboard.u"       # `U`
---| "key.keyboard.v"       # `V`
---| "key.keyboard.w"       # `W`
---| "key.keyboard.x"       # `X`
---| "key.keyboard.y"       # `Y`
---| "key.keyboard.z"       # `Z`
---| "key.keyboard.grave.accent"  # ``‌`‌``
---| "key.keyboard.comma"      # `,`
---| "key.keyboard.period"     # `.`
---| "key.keyboard.semicolon"    # `;`
---| "key.keyboard.apostrophe"   # `'`
---| "key.keyboard.minus"      # `-`
---| "key.keyboard.equal"      # `=`
---| "key.keyboard.slash"      # `/`
---| "key.keyboard.backslash"    # `\`
---| "key.keyboard.left.bracket"  # `[`
---| "key.keyboard.right.bracket"  # `]`
---| "key.keyboard.space"      # `␣`
---| "key.keyboard.tab"      # `↹ Tab` **/** `⇥`
---| "key.keyboard.backspace"    # `⟵ Backspace` **/** `⌫`
---| "key.keyboard.caps.lock"    # `🅰 Caps Lock` **/** `⇪`
---| "key.keyboard.enter"      # `↵ Enter` **/** `↵ Return`
---| "key.keyboard.left.control"  # `✲ Ctrl` **/** `⎈` **/** `⌃`
---| "key.keyboard.right.control"  # `✲ RCtrl` **/** `⎈` **/** `⌃`
---| "key.keyboard.left.shift"   # `⇧ Shift`
---| "key.keyboard.right.shift"   # `⇧ RShift`
---| "key.keyboard.left.win"    # `⊞ Win` **/** `⌘ Command` **/** `❖ Super`
---| "key.keyboard.right.win"    # `⊞ RWin` **/** `⌘ RCommand` **/** `❖ RSuper`
---| "key.keyboard.left.alt"    # `⎇ Alt` **/** `⌥ Option`
---| "key.keyboard.right.alt"    # `⎇ RAlt` **/** `Alt Gr` **/** `⌥ ROption`
---| "key.keyboard.menu"      # `☰ Menu`
---| "key.keyboard.insert"     # `Ins`
---| "key.keyboard.delete"     # `⌦ Del`
---| "key.keyboard.home"      # `⤒ Home`
---| "key.keyboard.end"      # `⤓ End`
---| "key.keyboard.page.up"    # `⇞ PgUp`
---| "key.keyboard.page.down"    # `⇟ PgDn`
---| "key.keyboard.up"       # `↑ Up`
---| "key.keyboard.down"      # `↓ Down`
---| "key.keyboard.left"      # `← Left`
---| "key.keyboard.right"      # `→ Right`
---| "key.keyboard.num.lock"    # `Num Lock` **/** `⌧ Clear`
---| "key.keyboard.keypad.equal"  # `KP =`
---| "key.keyboard.keypad.divide"  # `KP /`
---| "key.keyboard.keypad.multiply" # `KP *`
---| "key.keyboard.keypad.subtract" # `KP -`
---| "key.keyboard.keypad.add"   # `KP +`
---| "key.keyboard.keypad.0"    # `KP 0`
---| "key.keyboard.keypad.1"    # `KP 1`
---| "key.keyboard.keypad.2"    # `KP 2`
---| "key.keyboard.keypad.3"    # `KP 3`
---| "key.keyboard.keypad.4"    # `KP 4`
---| "key.keyboard.keypad.5"    # `KP 5`
---| "key.keyboard.keypad.6"    # `KP 6`
---| "key.keyboard.keypad.7"    # `KP 7`
---| "key.keyboard.keypad.8"    # `KP 8`
---| "key.keyboard.keypad.9"    # `KP 9`
---| "key.keyboard.keypad.decimal"  # `KP .`
---| "key.keyboard.keypad.enter"  # `↵ KP Enter` **/** `⌤`
---| "key.keyboard.world.1"    # `🌐¹`
---| "key.keyboard.world.2"    # `🌐²`
---| "key.mouse.left"       # `Mouse Left`
---| "key.mouse.right"       # `Mouse Right`
---| "key.mouse.middle"      # `Mouse Middle`
---| "key.mouse.4"        # `Mouse Back`
---| "key.mouse.5"        # `Mouse Forward`
---| "key.mouse.6"        # `Mouse 6`
---| "key.mouse.7"        # `Mouse 7`
---| "key.mouse.8"        # `Mouse 8`
---| "key.mouse.scroll"        # `Mouse 8`


local keymap = {[32]="space",[39]="apostrophe",[44]="comma",[46]="period",[47]="slash",[48]="0",[49]="1",[50]="2",[51]="3",[52]="4",[53]="5",[54]="6",
[55]="7",[56]="8",[57]="9",[59]="semicolon",[61]="equal",[65]="a",[66]="b",[67]="c",[68]="d",[69]="e",[70]="f",[71]="g",[72]="h",[73]="i",[74]="j",
[75]="k",[76]="l",[77]="m",[78]="n",[79]="o",[80]="p",[81]="q",[82]="r",[83]="s",[84]="t",[85]="u",[86]="v",[87]="w",[88]="x",[89]="y",[90]="z",
[91]="left.bracket",[92]="left.backslash",[93]="right.bracket",[96]="grave.accent",[161]="world.1",[162]="world.2",[256]="escape",[257]="enter",
[258]="tab",[259]="backspace",[260]="insert",[261]="delete",[262]="right",[263]="left",[264]="down",[265]="up",[266]="page.up",[267]="page.down",
[268]="home",[269]="end",[280]="caps.lock",[281]="scroll.lock",[282]="number.lock",[283]="print.screen",[284]="pause",[290]="f1",[291]="f2",[292]="f3",
[293]="f4",[294]="f5",[295]="f6",[296]="f7",[297]="f8",[298]="f9",[299]="f10",[300]="f11",[301]="f12",[302]="f13",[303]="f14",[304]="f15",[305]="f16",
[306]="f17",[307]="f18",[308]="f19",[309]="f20",[310]="f21",[311]="f22",[312]="f23",[313]="f24",[314]="f25",[320]="keypad.0",[321]="keypad.1",[322]="keypad.2",
[323]="keypad.3",[324]="keypad.4",[325]="keypad.5",[326]="keypad.6",[327]="keypad.7",[328]="keypad.8",[329]="keypad.9",[330]="keypad.decimal",[331]="keypad.divide",
[332]="keypad.multiply",[333]="keypad.subtract",[334]="keypad.add",[335]="keypad.enter",[336]="keypad.equal",[340]="left.shift",[341]="left.control",
[342]="left.alt",[344]="right.shift",[345]="right.control",[346]="right.alt",[348]="menu"
}

local chars = {
  normal={
[32]=" ",[39]="'",[44]=",",[45]="-",[46]=".",[47]="/",
[48]="0",[49]="1",[50]="2",[51]="3",[52]="4",[53]="5",
[54]="6",[55]="7",[56]="8",[57]="9",[59]=";",[61]="=",
[65]="a",[66]="b",[67]="c",[68]="d",[69]="e",[70]="f",
[71]="g",[72]="h",[73]="i",[74]="j",[75]="k",[76]="l",
[77]="m",[78]="n",[79]="o",[80]="p",[81]="q",[82]="r",
[83]="s",[84]="t",[85]="u",[86]="v",[87]="w",[88]="x",
[89]="y",[90]="z",[91]="[",[92]="\\",[93]="]",
[320]="0",[321]="1",[322]="2",[323]="3",[324]="4",
[325]="5",[326]="6",[327]="7",[328]="8",[329]="9",
[330]=".",[331]="/",[332]="*",[333]="-",[334]="+",
[336]="=",
  },

  shift = {
[39]=":",[44]="<",[45]="_",[46]=">",[47]="?",
[48]=")",[49]="!",[50]="@",[51]="#",[52]="$",[53]="%",
[54]="^",[55]="&",[56]="*",[57]="(",[59]=":",[61]="+",
[65]="A",[66]="B",[67]="C",[68]="D",[69]="E",[70]="F",
[71]="G",[72]="H",[73]="I",[74]="J",[75]="K",[76]="L",
[77]="M",[78]="N",[79]="O",[80]="P",[81]="Q",[82]="R",
[83]="S",[84]="T",[85]="U",[86]="V",[87]="W",[88]="X",
[89]="Y",[90]="Z",[91]="{",[92]="|",[93]="}",[320]=")",
[321]="!",[322]="@",[323]="#",[324]="$",[325]="%",
[326]="^",[327]="&",[328]="*",[329]="(",[330]=":",[331]="+",
[332]="_",[333]="-",[334]="+",[336]="+",
  }
}

for key, value in pairs(keymap) do keymap[key] = "key.keyboard." .. value end

local mousemap = {
  [0]="left",[1]="right",
  [2]="middle",[3]="4",
  [4]="5",[5]="6",[6]="7",
  [7]="8",
  -- anyhting after this is made up for GNUI
  [8] = "scroll",
}

for key, value in pairs(mousemap) do mousemap[key] = "key.mouse." .. value end

---@class GNUI.Canvas : GNUI.Box # A special type of container that handles all the inputs
---@field MousePosition Vector2 # the position of the mouse
---@field HoveredElement GNUI.any? # the element the mouse is currently hovering over
---@field PassiveHoveredElement GNUI.Box? # the last hovering element.
---@field HOVERING_ELEMENT_CHANGED EventLib # triggered when the hovering element changes
---@field PASSIVE_HOVERING_ELEMENT_CHANGED EventLib # Just like the HOVERING_BOX_CHANGED, but will never be nil if there is nothing being hovered.
---
---@field PressedElements GNUI.any[]? # the last pressed element, used to unpress buttons that have been unhovered.
---@field MOUSE_MOVED_GLOBAL EventLib # called when the mouse position changes
---@field reciveInputs boolean # EventLibs whether the canvas could capture input events
---@field captureCursorMovement boolean # true when the canvas should capture mouse movement, stopping the vanilla mouse movement, not the cursor itself
---@field captureInputs boolean # true when the canvas should capture the inputs
---@field hasCustomCursorSetter boolean # true when the setCursor is called, while false, the canvas will use the screen cursor.
---@field INPUT EventLib # serves as the handler for all inputs within the boundaries of the canvas. called with the first argument being an input event
---@field UNHANDLED_INPUT EventLib # triggers when an input is not handled by the children of the canvas.
local Canvas = {}
Canvas.__index = function (t,i)
  return rawget(t,i) or Canvas[i] or Container[i]
end
Canvas.__type = "GNUI.Element.Container.Canvas"

---@type GNUI.Canvas[]
local autoCanvases = {}

-->====================[ Figura Input Handling Conections ]====================<--

local function screenCheck()
  return host:isCursorUnlocked() and not host:getScreen() or host:isChatOpen()
end

local _shift,_ctrl,_alt = false,false,false
events.KEY_PRESS:register(function (key, state, modifiers)
	 _shift = modifiers % 2 == 1
	 _ctrl = math.floor(modifiers / 2) % 2 == 1
	 _alt = math.floor(modifiers / 4) % 2 == 1
  local minecraft_keybind = keymap[key]
  local char = chars[_shift and "shift" or "normal"][key] or chars.normal[key]
  if minecraft_keybind then
	for _, value in pairs(autoCanvases) do
	 if value.reciveInputs and value.Visible and value.canCaptureCursor and screenCheck() then
		value:parseInputEvent(minecraft_keybind, state,_shift,_ctrl,_alt,char)
		--if value.captureInputs then return true end
	 end
	end
  end
end)

events.MOUSE_MOVE:register(function (x, y)
  local s = host:getScreen()
  if not s or s == "net.minecraft.class_408" then
	local cursor_pos = client:getMousePos() / client:getGuiScale()
	for _, c in pairs(autoCanvases) do
	 if c.reciveInputs and c.Visible and not c.hasCustomCursorSetter and screenCheck() then
		c:setMousePos(cursor_pos.x, cursor_pos.y)
		if c.captureCursorMovement or c.captureInputs then return true end
	 end
	 end
  end
end)

events.MOUSE_PRESS:register(function (button, state)
  if mousemap[button] then
	for _, c in pairs(autoCanvases) do
	 if c.reciveInputs and c.Visible and screenCheck() then
		c:parseInputEvent(mousemap[button],state,_shift,_ctrl,_alt)
		if c.captureInputs then return true end
	 end
	end
  end
end)

events.MOUSE_SCROLL:register(function (dir) 
  for _, c in pairs(autoCanvases) do
	if c.reciveInputs and c.Visible and screenCheck() then
	 c:parseInputEvent(mousemap[8],1,_shift,_ctrl,_alt,nil,dir)
	end
  end
end)

--- Work around to having too many world render events
local WORLD_RENDER = eventLib.new()
events.WORLD_RENDER:register(function (delta)
  WORLD_RENDER:invoke()
end,"GNUI")

-->====================[ Canvas Class ]====================<--

---Creates a new canvas.
---if autoScreenInputs is true, the canvas will capture input events
---@param autoScreenInputs boolean? # if true, the canvas will capture input events
---@return GNUI.Canvas
function Canvas.new(autoScreenInputs)
  local new = Container.new()---@type GNUI.Canvas
  new.MousePosition = vec(0,0)
  new.reciveInputs = true
  new.MOUSE_MOVED_GLOBAL = eventLib.new()
  new.INPUT = eventLib.new()
  new.UNHANDLED_INPUT = eventLib.new()
  new.HOVERING_ELEMENT_CHANGED = eventLib.new()
  new.hasCustomCursorSetter = not autoScreenInputs
  new.PASSIVE_HOVERING_ELEMENT_CHANGED = eventLib.new()
  new.PressedElements = {}
  
  WORLD_RENDER:register(function ()
	new:_propagateUpdateToChildren()
  end,"GNUI_root_box."..new.id)
  
  new.ModelPart:setLight(15,15)
  if autoScreenInputs then
	autoCanvases[#autoCanvases+1] = new
  end
  setmetatable(new, Canvas)
  new.VISIBILITY_CHANGED:register(function () -- clear stuff
	 new.PressedElements = {}
	 new.HoveredElement = nil
	 new.PassiveHoveredElement = nil
  end)
  return new
end


---Sets the Mouse position relative to the canvas. meaning in canvas local space.
---@param x number|Vector2
---@param y number?
---@generic self
---@param self self
---@return self
function Canvas:setMousePos(x,y)
  ---@cast self GNUI.Canvas
  local mpos = utils.vec2(x,y)
  local relative = mpos - self.MousePosition
  if relative.x ~= 0 or relative.y ~= 0 then  
	self.MousePosition = mpos
	
	---@type GNUI.InputEventMouseMotion
	local event = {relative = relative,pos = self.MousePosition}
	self.MOUSE_MOVED_GLOBAL:invoke(event)
	if self.HoveredElement then
	 self.HoveredElement.MOUSE_MOVED:invoke(event)
	end
	
	for _, e in pairs(self.PressedElements) do
	  if e ~= self.HoveredElement then
		  e.MOUSE_MOVED:invoke(event)
	  end
	end
	self:pos2HoveringChild(self.MousePosition)
  end
  return self
end

local parseInputEventToChildren

--- The function that handles the INPUT event in all boxes.
---@param element GNUI.any
---@param event GNUI.InputEvent
local function parseInputEventOnElement(element,event,position,force)
	if event.isHandled then return end
  	if element.Visible and element.canCaptureCursor then
	
		local statuses = element.INPUT_CHILDREN:invoke(event)
		for j = 1, #statuses, 1 do
		 	if statuses[j] and statuses[j][1] then 
				event.isHandled = true
				return true
			end
		end
	
		if element:isPosInside(position) or force then
			if not parseInputEventToChildren(element,event,position) then
				statuses = element.INPUT:invoke(event)
				for j = 1, #statuses, 1 do
					if statuses[j] and statuses[j][1] then 
						event.isHandled = true
						return true
					end
				end
				if element.isCursorHovering and event.state and event.key:find"$key.mouse" then
					element.Canvas.PressedElements = {element}
				end
				return true
			end
		end
	end
	return false
end


---propagates the INPUT event to children, if the cursor is on top of them.  
---if you want a box to always recive input, register a function from the canvas itself, instead of the box.
---@param element GNUI.any
---@param event GNUI.InputEvent
function parseInputEventToChildren(element,event,position)
  if element.Parent then
	 position = position - element.ContainmentRect.xy
  end
  for i = #element.Children, 1, -1 do
	 if parseInputEventOnElement(element.Children[i],event,position) then
		return true
	 end
  end
  return false
end



---Simulates a boolean key event into the canvas.
---@param key GNUI.keyCode
---@param state Event.Press.state
---@param ctrl boolean?
---@param alt boolean?
---@param shift boolean?
---@param strength number?
---@param char string?
function Canvas:parseInputEvent(key,state,shift,ctrl,alt,char,strength)
  ---@type GNUI.InputEvent
  local event = {
	char = char,
	key = key,
	state = state,
	ctrl = ctrl or false,
	alt = alt or false,
	shift = shift or false,
	isHandled = false,
	strength = strength or 1
  }
  local captured = false -- if somehow the canvas itself captured the inputs
  local statuses = self.INPUT:invoke(event)
  for i = 1, #statuses, 1 do
	if statuses[i] and statuses[i][1] then
	 captured = true
	 break
	end
  end
  if not captured then
	 parseInputEventToChildren(self,event,self.MousePosition)
	 for _, e in pairs(self.PressedElements) do
		if e ~= self.HoveredElement and e.Canvas == self then
		  parseInputEventOnElement(e,event,self.MousePosition,true)
		end
	 end
  end
  if key ~= "key.mouse.scroll" then
	 if state ~= 0 then -- QOL feature that allows boxes to recive a button being unpressed even when not hovered anymore.
		self.PressedElements[key] = self.HoveredElement
	 else
		if self.PressedElements[key] then
		  self.PressedElements[key].MOUSE_MOVED:invoke({relative = vec(0,0),pos = self.MousePosition})
		end
		self.PressedElements[key] = nil
	 end
  end
  
  if not event.isHandled then
	self.UNHANDLED_INPUT:invoke(event)
  end
  return self
end

-->====================[ Child Hovering ]====================<--

---Returns the child that the point at the given position is on top of.
---@param pos Vector2
function Canvas:getChildFromPos(pos)
  if self.Parent then
	 pos = pos - self.ContainmentRect.xy
  end
  if self.Visible and self.canCaptureCursor then
	for i = #self.Children, 1, -1 do
	 local child = self.Children[i]
	 if child.Visible and child.canCaptureCursor and child:isPosInside(pos) then
		return Canvas.getChildFromPos(child,pos)
	 end
	end
  end
  return self
end


---Sets the child that the point at the given position is on top of.
---@param pos Vector2
function Canvas:pos2HoveringChild(pos)
  self:setHoveringChild(self:getChildFromPos(pos))
  return self
end


---Sets the child being hovered.
---@param box GNUI.Box
---@return GNUI.Canvas
function Canvas:setHoveringChild(box)
  if box ~= self.HoveredElement then  
	 if self.HoveredElement then
		self.HoveredElement:setIsCursorHovering(false)
		local l = self.PassiveHoveredElement
		self.PassiveHoveredElement = box
		self.PASSIVE_HOVERING_ELEMENT_CHANGED:invoke(box,l)
	 end
	 if box then
		box:setIsCursorHovering(true)
	 end
	 self.HoveredElement = box
	 self.HOVERING_ELEMENT_CHANGED:invoke(box,self.PassiveHoveredElement)
  end
  return self
end


---Returns which element the mouse cursor is on top of.
---@return GNUI.any
function Canvas:getHoveredElement()
  return self.HoveredElement
end

-->====================[ Flags ]====================<--

---Sets whether the canvas should capture the mouse movement, making it not possible to move the mouse outside of the canvas.
---@param toggle boolean
---@generic self
---@param self self
---@return self
function Canvas:setCaptureMouseMovement(toggle)
---@cast self GNUI.Canvas
  self.captureCursorMovement = toggle
  return self
end

---Sets whether the canvas should capture input from the user.
---@param toggle boolean
---@generic self
---@param self self
---@return self
function Canvas:setCaptureInputs(toggle)
---@cast self GNUI.Canvas
  self.captureInputs = toggle
  return self
end

return Canvas