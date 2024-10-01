--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / Theme Class Handler
/ /_/ / /|  / the script that manages how every class looks.
\____/_/ |_/ Source: link]]

---@alias GNUI.Theme table<string,table<string|"default",fun(box:GNUI.Box)>>

local themePath
for _, path in pairs(listFiles("GNUI.theme")) do
  if path ~= "GNUI.theme" then themePath = path break end
end
local theme = themePath and require(themePath) or {}

local API = {}

---Styles a given class using the theme script, the single lua file in the theme folder.
---@param object GNUI.Box
---@param variant string?
function API.style(object,variant)
  local class = object.__type:match("[^%.]+$") -- GNUI.Button -> Button
  variant = variant or "Default"
  if theme[class] and theme[class][variant] then
    theme[class][variant](object)
  end
  return object
end

return API