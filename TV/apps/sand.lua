local FiGUI = require("libraries.FiGUI")
local appManager = require("TV.appManager")
local Sandboard = require(.....".sand.Sandboard")
local Cell = require(.....".sand.Cell")
local elements = require(.....".sand.elements")

local DPI = 1.5

local factory = function (window,tv)
    ---@type Application
    local app = {}
    app.capture_keyboard = false

    local function uuid()
        ---@diagnostic disable-next-line: undefined-field
        return client.intUUIDToString(client.generateUUID())
    end

    local rect = window.ContainmentRect
    local size = ((rect.zw - rect.xy).xy / DPI):floor() --[[@as Vector2]]
    local texture = textures:newTexture("sand" .. uuid(), size.x, size.y)

    local image = FiGUI.newSprite()
    :setTexture(texture)
    :setRenderType("EMISSIVE_SOLID")
    :setSize(size.x, size.y)

    window:setSprite(image)

    local board = Sandboard.new(size.x, size.y, Cell)
    app.data = {
        texture = texture,
        board = board,
        brush_element = elements.sand,
        brightness = 1,
        brush_size = 3,
    }
    board:draw(texture)

    local brush_size_display
    brush_size_display = FiGUI.newLabel()
    brush_size_display:setText("Brush Size: 3"):setFontScale(0.3)
    brush_size_display:setAnchor(0,0,1,1)
    brush_size_display:setPos(0,0)
    brush_size_display:setSize(3,3)
    brush_size_display.CaptureCursor = false
    window:addChild(brush_size_display)

    local selection_display = FiGUI.newLabel() -- top left
    selection_display:setText("Brush: sand"):setFontScale(0.3)
    selection_display:setAnchor(0,0,1,1)
    selection_display:setPos(0,3)
    selection_display:setSize(3,3)
    selection_display.CaptureCursor = false
    window:addChild(selection_display)

    local i = 5
    for id, element in pairs(elements) do
        i = i + 1
        local n = i - 1
        local x = (n % 4)
        local y = math.floor(n/4) + 1
        local text = toJson{
            text = "█",
            color = "#"..vectors.rgbToHex(element.colour.xyz)
        }
        local button = FiGUI.newLabel()
        button:setText(text):setFontScale(0.3)
        button:setAnchor(0,0,0,0)
        button:setPos(x*3,y*3)
        button:setSize(3,3)
        button.PRESSED:register(function()
            app.data.brush_element = element
            selection_display:setText(id)
        end)
        window:addChild(button)
    end

    window.PRESSED:register(function()
        local cursor = window.Cursor
        local x = math.floor(cursor.x / DPI)
        local y = math.floor(cursor.y / DPI)
        for dx = -app.data.brush_size, app.data.brush_size do
            for dy = -app.data.brush_size, app.data.brush_size do
                if (dx*dx + dy*dy) <= app.data.brush_size^2 then
                    local cell = board.cells[x+dx] and board.cells[x+dx][y+dy]
                    if cell then
                        cell.element = app.data.brush_element
                    end
                end
            end
        end
    end)

    local close = FiGUI.newLabel()
    close:setText("X"):setFontScale(0.3)
    close:setSize(3,3)
    close:setAlign(0.5,0.5)
    close:setAnchor(1,0,1,0)
    close:setPos(-3,0)
    close.PRESSED:register(function ()
        tv:setApp(tv.default_app)
    end)
    window:addChild(close)

    function app.TICK()
        --local board = app.data.board
        board:update()
        board:draw(app.data.texture)
        app.data.texture:update()
    end

    return app
end

local icon = FiGUI.newSprite()
icon:setTexture(textures:fromVanilla("sand", "minecraft:textures/block/sand.png"))

appManager:registerApp(factory,"Sand",icon)