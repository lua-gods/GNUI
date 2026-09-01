local BASE = ((...):gsub("/", ".")):match(".+%.GNUI")
local cfg = require(BASE .. ".config") ---@type GNUI.config

local Box = require(cfg.WIDGETS .. ".box") ---@type GNUI.BoxAPI
local Event = require(cfg.EVENT)
local Button = require(cfg.WIDGETS .. ".button") ---@type GNUI.Widget.ButtonAPI

local Style = require(cfg.THEME .. ".init") ---@type GNUI.ThemeAPI
local Layout = require(cfg.LAYOUT .. ".init") ---@type GNUI.LayoutAPI

local utils = require(cfg.UTILS) ---@type GNUI.utils


---@class GNUI.Widget.DropdownAPI
local DropdownAPI = {}


---@class GNUI.Widget.Dropdown : GNUI.Widget.Button
---@field popup GNUI.Box
local Dropdown = {}
Dropdown.__index = function (t,i)
	return rawget(t, i)
		 or Dropdown[i]
		 or Button.index(t, i)
		 or Box.index(t, i)
end
Dropdown.__style = "dropdown"
Dropdown.__type = "Dropdown"

---@param canvas GNUI.Canvas
---@param children GNUI.Box[]?
---@return GNUI.Widget.Button
function DropdownAPI.new(box,canvas,children)
	local self = Button.new(box,canvas,children)
	
	setmetatable(self, Dropdown)
	self:setLayout("FIXED")
	self:setSizing(self.sizing.x,"FIXED")
	local popup = canvas:parse{
		style="opaque",
		layout="VERTICAL",
		sizing={ "FILL", "FIT" },
	}
	
	popup:setVisible(true)
	
	self.popup = popup
	
	self:addChild(popup)
	
	
	self.SIZE_CHANGED:register(function ()
		popup:setPos(0, self.finalSize.y)
		popup:setMinimumSize(self.finalSize.x)
	end)
	
	
	if children then
		for index, child in ipairs(children) do
			local entryButton = canvas:parse{
				type="button",
				style="secondary",
				sizing={"FILL","FIT"},
				layout="HORIZONTAL",
			}
			
			
			entryButton:addChild(child)
			popup:addChild(entryButton)
		end
	end
	return self
end


--────────────────────────-< Layout Parser >-────────────────────────--

---@diagnostic disable: duplicate-doc-field
---@class GNUI.Layout
---@field type "dropdown"?

---@param layout any
---@param canvas GNUI.Canvas
---@param button GNUI.Widget.Button?
---@return GNUI.Widget.Button
function DropdownAPI.parse(layout,canvas,children,button)
	local self = button or Box.parse(layout,canvas,children,DropdownAPI.new)

	self:setStyleVariant(layout.style)
	
	return self
end

Layout.registerType("dropdown", DropdownAPI.parse)


return DropdownAPI