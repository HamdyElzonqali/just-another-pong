local object = class:extend()

local PARTICLE_MAX_SPEED = 3
local PARTICLE_MIN_SPEED = 1
local PARTICLE_MAX_LIFETIME = 1
local PARTICLE_MIN_LIFETIME = 0.4
local PARTICLE_MAX_SIZE = 2.5
local PARTICLE_MIN_SIZE = 0.3


function object:new(x, y)
    self.x = x
    self.y = y
    self.color = COLORS.WHITE
    self.speed = PARTICLE_MIN_SPEED + love.math.random() * (PARTICLE_MAX_SPEED - PARTICLE_MIN_SPEED)
    self.lifetime = PARTICLE_MIN_LIFETIME + love.math.random() * (PARTICLE_MAX_LIFETIME - PARTICLE_MIN_LIFETIME)
    self.startSize = PARTICLE_MIN_SIZE + love.math.random() * (PARTICLE_MAX_SIZE - PARTICLE_MIN_SIZE)
    self.size = self.startSize
    self.direction = love.math.random() * (math.pi * 2)
    self.dx = math.cos(self.direction) * self.speed
    self.dy = math.sin(self.direction) * self.speed
    self.timer = self.lifetime
end

function object:update(dt)
    self.timer = self.timer - dt
    if self.timer <= 0 then
        self.remove = true
    end

    local amount = 1 - self.timer / self.lifetime
    self.size = self.startSize * (1 - amount)

    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function object:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.size)
end

function object:drawShadow()
    love.graphics.setColor(COLORS.GREY)
    love.graphics.circle("fill", self.x + 1, self.y + 1, self.size)
end


return object