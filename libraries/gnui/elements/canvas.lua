---@diagnostic disable: assign-type-mismatch, undefined-field, return-type-mismatch
local eventLib = require("libraries.eventLib")

local utils = require("libraries.gnui.utils")
local container = require("libraries.gnui.elements.container")
local element = require("libraries.gnui.elements.element")

---@class GNUI.InputEvent
---@field key Minecraft.keyCode
---@field isPressed boolean
---@field status Event.Press.state
---@field ctrl boolean
---@field shift boolean
---@field alt boolean

---@class GNUI.InputEventMouseMotion
---@field pos Vector2 # local position 
---@field relative Vector2 # the change of position since last set

local keymap = {
    [32] = "key.keyboard.space",
    [39] = "key.keyboard.apostrophe",
    [44] = "key.keyboard.comma",
    [46] = "key.keyboard.period",
    [47] = "key.keyboard.slash",
    [48] = "key.keyboard.0",
    [49] = "key.keyboard.1",
    [50] = "key.keyboard.2",
    [51] = "key.keyboard.3",
    [52] = "key.keyboard.4",
    [53] = "key.keyboard.5",
    [54] = "key.keyboard.6",
    [55] = "key.keyboard.7",
    [56] = "key.keyboard.8",
    [57] = "key.keyboard.9",
    [59] = "key.keyboard.semicolon",
    [61] = "key.keyboard.equal",
    [65] = "key.keyboard.a",
    [66] = "key.keyboard.b",
    [67] = "key.keyboard.c",
    [68] = "key.keyboard.d",
    [69] = "key.keyboard.e",
    [60] = "key.keyboard.f",
    [71] = "key.keyboard.g",
    [72] = "key.keyboard.h",
    [73] = "key.keyboard.i",
    [74] = "key.keyboard.j",
    [75] = "key.keyboard.k",
    [76] = "key.keyboard.l",
    [77] = "key.keyboard.m",
    [78] = "key.keyboard.n",
    [79] = "key.keyboard.o",
    [70] = "key.keyboard.p",
    [81] = "key.keyboard.q",
    [82] = "key.keyboard.r",
    [83] = "key.keyboard.s",
    [84] = "key.keyboard.t",
    [85] = "key.keyboard.u",
    [86] = "key.keyboard.v",
    [87] = "key.keyboard.w",
    [88] = "key.keyboard.x",
    [89] = "key.keyboard.y",
    [90] = "key.keyboard.z",
    [91] = "key.keyboard.left.bracket",
    [92] = "key.keyboard.left.backslash",
    [93] = "key.keyboard.right.bracket",
    [96] = "key.keyboard.grave.accent",
    [161] = "key.keyboard.world.1",
    [162] = "key.keyboard.world.2",
    [256] = "key.keyboard.escape",
    [257] = "key.keyboard.enter",
    [258] = "key.keyboard.tab",
    [259] = "key.keyboard.backspace",
    [260] = "key.keyboard.insert",
    [261] = "key.keyboard.delete",
    [262] = "key.keyboard.right",
    [263] = "key.keyboard.left",
    [264] = "key.keyboard.down",
    [265] = "key.keyboard.up",
    [266] = "key.keyboard.page.up",
    [267] = "key.keyboard.page.down",
    [268] = "key.keyboard.home",
    [269] = "key.keyboard.end",
    [280] = "key.keyboard.caps.lock",
    [281] = "key.keyboard.scroll.lock",
    [282] = "key.keyboard.number.lock",
    [283] = "key.keyboard.print.screen",
    [284] = "key.keyboard.pause",
    [290] = "key.keyboard.f1",
    [291] = "key.keyboard.f2",
    [292] = "key.keyboard.f3",
    [293] = "key.keyboard.f4",
    [294] = "key.keyboard.f5",
    [295] = "key.keyboard.f6",
    [296] = "key.keyboard.f7",
    [297] = "key.keyboard.f8",
    [298] = "key.keyboard.f9",
    [299] = "key.keyboard.f10",
    [300] = "key.keyboard.f11",
    [301] = "key.keyboard.f12",
    [302] = "key.keyboard.f13",
    [303] = "key.keyboard.f14",
    [304] = "key.keyboard.f15",
    [305] = "key.keyboard.f16",
    [306] = "key.keyboard.f17",
    [307] = "key.keyboard.f18",
    [308] = "key.keyboard.f19",
    [309] = "key.keyboard.f20",
    [310] = "key.keyboard.f21",
    [311] = "key.keyboard.f22",
    [312] = "key.keyboard.f23",
    [313] = "key.keyboard.f24",
    [314] = "key.keyboard.f25",
    [320] = "key.keyboard.keypad.0",
    [321] = "key.keyboard.keypad.1",
    [322] = "key.keyboard.keypad.2",
    [323] = "key.keyboard.keypad.3",
    [324] = "key.keyboard.keypad.4",
    [325] = "key.keyboard.keypad.5",
    [326] = "key.keyboard.keypad.6",
    [327] = "key.keyboard.keypad.7",
    [328] = "key.keyboard.keypad.8",
    [329] = "key.keyboard.keypad.9",
    [330] = "key.keyboard.keypad.decimal",
    [331] = "key.keyboard.keypad.divide",
    [332] = "key.keyboard.keypad.multiply",
    [333] = "key.keyboard.keypad.subtract",
    [334] = "key.keyboard.keypad.add",
    [335] = "key.keyboard.keypad.enter",
    [336] = "key.keyboard.keypad.equal",
    [340] = "key.keyboard.left.shift",
    [341] = "key.keyboard.left.control",
    [342] = "key.keyboard.left.alt",
    [343] = "⊞ Win` **/** `⌘ Command` **/** `❖ Super",
  --[344] = "key.keyboard.right.shift",
    [345] = "key.keyboard.right.control",
    [346] = "key.keyboard.right.alt",
  --[347] = "⊞ RWin` **/** `⌘ RCommand` **/** `❖ RSuper",
    [348] = "key.keyboard.menu"
}

local mousemap = {
   [0] = "key.mouse.left",
   [1] = "key.mouse.right",
   [2] = "key.mouse.middle",
   [3] = "key.mouse.4",
   [4] = "key.mouse.5",
   [5] = "key.mouse.6",
   [6] = "key.mouse.7",
   [7] = "key.mouse.8"
}

---@class GNUI.canvas : GNUI.container # A special type of container that handles all the inputs
---@field MousePosition Vector2
---@field HoveredElement GNUI.any
---@field MOUSE_POSITION_CHANGED eventLib
---@field isActive boolean # determins whether the canvas could capture input events
---@field captureCursorMovement boolean
---@field captureInputs boolean
---@field hasCustomCursorSetter boolean # true when the setCursor is called, while false, the canvas will use the screen cursor.
---@field INPUT eventLib # serves as the handler for all inputs within the boundaries of the canvas. called with the first argument being an input event
local canvas = {}
canvas.__index = function (t,i)
   return rawget(t,i) or canvas[i] or container[i] or element[i]
end
canvas.__type = "GNUI.element.container.canvas"

---@type GNUI.canvas[]
local canvases = {}

local _shift,_ctrl,_alt = false,false,false
events.KEY_PRESS:register(function (key, state, modifiers)
         _shift = modifiers % 2 == 1
         _ctrl = math.floor(modifiers / 2) % 2 == 1
         _alt = math.floor(modifiers / 4) % 2 == 1
   local key_string = keymap[key]
   if key_string then
      for _, value in pairs(canvases) do
         if value.isActive and value.Visible then
            value:parseInputEvent(key_string, state,
            _shift,
            _ctrl,
            _alt
            )
            if value.captureInputs then return true end
         end
      end
   end
end)


events.MOUSE_MOVE:register(function (x, y)
   local cursor_pos = client:getMousePos() / client:getGuiScale()
   for key, value in pairs(canvases) do
      if value.isActive and value.Visible and not value.hasCustomCursorSetter then
         value:setMousePos(cursor_pos.x, cursor_pos.y, true)
         if value.captureCursorMovement or value.captureInputs then return true end
      end
    end
end)

events.MOUSE_PRESS:register(function (button, state)
   if mousemap[button] then
      for _, value in pairs(canvases) do
         if value.isActive and value.Visible then
            value:parseInputEvent(mousemap[button], state, _shift, _ctrl, _alt)
            if value.captureInputs then return true end
         end
      end
   end
end)

---Creates a new canvas.
---@return GNUI.canvas
function canvas.new()
   local new = container.new()
   new.MousePosition = vectors.vec2()
   new.isActive = true
   new.MOUSE_POSITION_CHANGED = eventLib.new()
   new.INPUT = eventLib.new()
   new.unlockCursorWhenActive = true
   new.captureKeyInputs = true
   canvases[#canvases+1] = new
   setmetatable(new, canvas)
   return new
end

---Sets the Mouse position relative to the canvas.
---@overload fun(self:self, x:number,y:number): self
---@overload fun(self:self, pos:Vector2): self
---@param x number
---@param y number
---@param keep_auto boolean
---@generic self
---@param self self
---@return self
function canvas:setMousePos(x,y,keep_auto)
   ---@cast self GNUI.canvas
   local mpos = utils.figureOutVec2(x,y)
   local relative = mpos - self.MousePosition
   self.MousePosition = mpos
   
   local input_event = {}
   self.hasCustomCursorSetter = not keep_auto
   input_event.relative = relative
   input_event.pos = self.MousePosition
   self.INPUT:invoke(input_event)
   self.MOUSE_POSITION_CHANGED:invoke(input_event)
   self:updateHoveringChild()
   return self
end

---@param e GNUI.any
local function getHoveringChild(e,position)
   position = position - e.ContainmentRect.xy
   for i = #e.Children, 1, -1 do
      local child = e.Children[i]
      if child.Visible and child.canCaptureCursor and child:isPositionInside(position) then
         return getHoveringChild(child,position)
      end
   end
   return e
end

---@package
function canvas:updateHoveringChild()
   local hovered_element = getHoveringChild(self,self.MousePosition)
   if hovered_element ~= self.HoveredElement then   
      if self.HoveredElement then
         self.HoveredElement:setIsCursorHovering(false)
      end
      if hovered_element then
         hovered_element:setIsCursorHovering(true)
      end
      self.HoveredElement = hovered_element
   end
   return self
end

---Returns which element the mouse cursor is on top of.
---@return GNUI.any
function canvas:getHoveredElement()
   return self.HoveredElement
end

---@param Element GNUI.any
---@param event GNUI.InputEvent
local function parseInputEventToChildren(Element,event,position)
   position = position - Element.ContainmentRect.xy
   for i = #Element.Children, 1, -1 do
      local child = Element.Children[i]
      if child.Visible and child.canCaptureCursor and child:isPositionInside(position) then
         local statuses = child.INPUT:invoke(event)
         for j = 1, #statuses, 1 do
            if statuses[j] then return true end
         end
         return parseInputEventToChildren(child,event,position)
      end
   end
   return false
end


---Simulates a key event into the container.
---@param key Minecraft.keyCode
---@param status Event.Press.state
---@param ctrl boolean
---@param alt boolean
---@param shift boolean
function canvas:parseInputEvent(key,status,shift,ctrl,alt)
   ---@type GNUI.InputEvent
   local key_event = {
      key = key,
      isPressed = status ~= 0,
      status = status,
      ctrl = ctrl,
      alt = alt,
      shift = shift
   }
   local captured = false
   local statuses = self.INPUT:invoke(key_event)
   for i = 1, #statuses, 1 do
      if statuses[i] then
         captured = true
         break
      end
   end
   if not captured then
      parseInputEventToChildren(self,key_event,self.MousePosition)
   end
   return self
end

---Sets whether the canvas should capture mouse movement.
---@param toggle boolean
---@generic self
---@param self self
---@return self
function canvas:setCaptureMouseMovement(toggle)
---@cast self GNUI.canvas
   self.captureCursorMovement = toggle
   return self
end

---Sets whether the canvas should capture inputs.
---@param toggle boolean
---@generic self
---@param self self
---@return self
function canvas:setCaptureInputs(toggle)
---@cast self GNUI.canvas
   self.captureInputs = toggle
   return self
end

return canvas