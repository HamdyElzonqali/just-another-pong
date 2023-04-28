local gameState = {}

local PAUSE_TIME = 1.3

local SmokeParticle = require("res.objects.SmokeParticle")

function gameState:enter(...)
    self.finishing = false
    self.timer = 0
    self.alpha = 0

    self.particles = {}

    for i = 1, 50 do
        local particle = SmokeParticle(VIRTUAL_WIDTH / 2 - 50 + i * 2, VIRTUAL_HEIGHT / 2 + love.math.random(-4, 4))
        self.particles[particle] = particle
    end

    camera:shake(1.1, 0.2)

    playSound("res/audio/logo.wav", 0.8)
end

function gameState:exit()
    
end

function gameState:update(dt)
    self.alpha = math.min(love.math.lerp(self.alpha, 1.05, 5 * dt), 1)

    if self.alpha == 1 then
        self.timer = self.timer + dt
        if self.timer >= PAUSE_TIME then
            self.finishing = true
        end
    end

    if self.finishing or input.anyPressed() or (#love.touch.getTouches()) > 0 then
        state:switch("menu")
        camera:shake(1.25, 0.25)
    end

    for i, particle in pairs(self.particles) do
        particle:update(dt)

        if particle.remove then
            self.particles[particle] = nil
        end
    end
end

function gameState:draw()
    for i, particle in pairs(self.particles) do
        particle:drawShadow()
    end

    local color = {unpack(COLORS.YELLOW)}
    color[4] = self.alpha
    love.graphics.setColor(color)
    love.graphics.printf("Made by Hamdy ELzanqali", 0, VIRTUAL_HEIGHT / 2 - 3 + (self.alpha < 0.2 and -1 or 0), VIRTUAL_WIDTH , "center", 0, 1, 1)
    
    for i, particle in pairs(self.particles) do
        particle:draw()
    end
end

return gameState