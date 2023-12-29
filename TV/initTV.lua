require("TV.appManager")
for key, path in pairs(listFiles("TV.apps")) do -- load apps
    require(path)
end
require("TV.newTV")