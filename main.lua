-- LIBRARIES

-- classic by rxi (https://github.com/rxi/classic)
class = require "lib.third-party.classic"

state  = require "lib.state"
camera = require "lib.camera"
input  = require "lib.input"

--love._openConsole()

-- CONSTANTS
WINDOW_WIDTH = 960
WINDOW_HEIGHT = 540

VIRTUAL_WIDTH = 160
VIRTUAL_HEIGHT = 90

COLORS = {
    RESET       = {1, 1, 1, 1},
    WHITE       = {0.980, 0.980, 0.980, 1}, -- #fafafa
    BLACK       = {0.294, 0.294, 0.294, 1}, -- #4b4b4b
    BLUE        = {0.345, 0.682, 0.933, 1}, -- #58aeee
    RED         = {0.906, 0.349, 0.322, 1}, -- #e75952
    GREY        = {0.831, 0.831, 0.831, 1}, -- #d4d4d4
    YELLOW      = {0.976, 0.827, 0.506, 1}, -- #f9d381
    LIGHT_BLUE  = {0.604, 0.820, 0.976, 1}, -- #9ad1f9
    LIGHT_RED   = {0.976, 0.579, 0.541, 1} -- #f9938a
}


love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")
love.graphics.setLineWidth(1)


FONTS = {
    -- To scale the font use xScale and yScale parameters when drawing the font.
    MAIN = love.graphics.newImageFont('res/misc/main-font.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890\':"()[] !,-|_+/*\\?.%@')
}

-- GRAPHICS
love.graphics.setBackgroundColor(COLORS.WHITE)
love.graphics.setColor(COLORS.BLACK)
love.graphics.setFont(FONTS.MAIN)

-- STATES
state:add("logo", require "res.states.Logo")
state:add("menu", require "res.states.Menu")
state:add("play", require "res.states.Play")
state:add("playCPU", require "res.states.PlayCPU")

-- INPUT
input.setup()

input.action ("player1")
    :bindGamepadAxis("lefty", 1)
    :bindGamepadAxis("righty", 1)
    :negative()
        :bindKey("w")
        :bindGamepad("dpup", 1)
    :positive()
        :bindKey("s")
        :bindGamepad("dpdown", 1)

input.action ("player2")
    :bindGamepadAxis("lefty", 2)
    :bindGamepadAxis("righty", 2)
    :negative()
        :bindKey("up")
        :bindGamepad("dpup", 2)
    :positive()
        :bindKey("down")
        :bindGamepad("dpdown", 2)

input.action("pause")
    :bindKeyPressed("escape", "p")
    :bindGamepadPressed("start")

-- lerp
love.math.lerp = function (a, b, t)
    return a + (b - a) * t
end

function love.load()
    -- Start with the logo state.
    state:switch("play")

    -- Setting the resolution
    camera:setVirtualDimensions(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

end

function love.update(dt)
    -- Update the current state.
    state:update(dt)

    -- Update the camera.
    camera:update(dt)

    -- Update the input.
    input.update(dt)
end

function love.draw()
    -- Set the camera.
    camera:set()

    -- Draw the current state.
    state:draw()
    
    -- Unset the camera.
    camera:unset()
end

function love.resize()
    camera:resize()
end