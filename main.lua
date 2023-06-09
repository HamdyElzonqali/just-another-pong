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

IS_MOBILE = love.system.getOS() == "Android" or love.system.getOS() == "iOS"

SHOW_BRANDING = true

gSound = true
gMusic = true

local _sounds = {}
function playSound(sound, volume, pitch)
    if gSound then
        if not _sounds[sound] then
            _sounds[sound] = love.audio.newSource(sound, "static")
        end

        if pitch then
            _sounds[sound]:setPitch(pitch)
        end

        if volume then
            _sounds[sound]:setVolume(volume)
        end

        _sounds[sound]:play()
    end
end

local _music = {}
function playMusic(music, volume)
    if gMusic then
        if not _music[music] then
            _music[music] = love.audio.newSource(music, "stream")
            _music[music]:setLooping(true)
        end

        if volume then
            _music[music]:setVolume(volume)
        end

        _music[music]:setLooping(true)

        _music[music]:play()
    end
end

function stopMusic(music)
    if _music[music] then
        _music[music]:stop()
    end
end


COLORS = {
    RESET       = {1, 1, 1, 1},
    WHITE       = {0.980, 0.980, 0.980, 1}, -- #fafafa
    BLACK       = {0.294, 0.294, 0.294, 1}, -- #4b4b4b
    BLUE        = {0.345, 0.682, 0.933, 1}, -- #58aeee
    RED         = {0.906, 0.349, 0.322, 1}, -- #e75952
    GREY        = {0.831, 0.831, 0.831, 1}, -- #d4d4d4
    YELLOW      = {0.976, 0.827, 0.506, 1}, -- #f9d381
    GREEN       = {0.553, 0.929, 0.655, 1}, -- #8deda7
    ORANGE      = {0.918, 0.686, 0.302, 1}, -- #eaaf4d
    LIGHT_BLUE  = {0.604, 0.820, 0.976, 1}, -- #9ad1f9
    LIGHT_RED   = {0.976, 0.579, 0.541, 1}, -- #f9938a
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
    :bindKeyPressed("p")
    :bindGamepadPressed("start")

input.action("back")
    :bindKeyPressed("escape", "backspace")
    :bindGamepadPressed("back")

input.action("ui_confirm")
    :bindKeyPressed("return", "space")
    :bindGamepadPressed("a", "b")

input.action("ui_left")
    :bindKeyPressed("a", "left")
    :bindGamepadPressed("left")

input.action("ui_right")
    :bindKeyPressed("d", "right")
    :bindGamepadPressed("right")

input.action("ui_up")
    :bindKeyPressed("w", "up")
    :bindGamepadPressed("up")

input.action("ui_down")
    :bindKeyPressed("s", "down")
    :bindGamepadPressed("down")


-- lerp
love.math.lerp = function (a, b, t)
    return a + (b - a) * t
end

function love.load()
    -- Start with the either the logo or the menu state.
    if SHOW_BRANDING then
        state:switch("logo")
    else
        state:switch("menu")
    end

    -- Setting the resolution
    camera:setVirtualDimensions(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

end


local CAP = 1 / 20
function love.update(dt)
    if dt > CAP then
         return
    end
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