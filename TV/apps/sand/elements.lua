local elements = {}

for _, file in pairs(listFiles(.....".elements")) do
    if file:gsub("/",".") ~= (....."."..({...})[2]):gsub("/",".") then
        local element = require(file)
        elements[element.id] = element
    end
end

return elements