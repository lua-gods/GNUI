local components = {}

for _, file in pairs(listFiles(.....".components")) do
    if file:gsub("/",".") ~= (....."."..({...})[2]):gsub("/",".") then
        local component = require(file)
        components[component.id] = component
    end
end

return components