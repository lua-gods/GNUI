if not host:isHost() then return end

local gnuiFolder = "GNUI"
local gnuiInit = "GNUI.lua"

local gnui = gnuiFolder .. "/" .. gnuiInit
if not file:exists(gnui) then
    error("Unable to load GNUI from data folder")
end

return load(file:readString(gnui), "data:"..gnui)(gnuiFolder)