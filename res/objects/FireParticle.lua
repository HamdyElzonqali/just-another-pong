local object = class:extend()

local PARTICLE_MAX_SPEED = 10
local PARTICLE_MIN_SPEED = 5
local PARTICLE_MAX_LIFETIME = 0.7
local PARTICLE_MIN_LIFETIME = 0.4
local PARTICLE_MAX_SIZE = 2
local PARTICLE_MIN_SIZE = 1

local function lerpColor(c1, c2, amount)
    local r = c1[1] + (c2[1] - c1[1]) * amount
    local g = c1[2] + (c2[2] - c1[2]) * amount
    local b = c1[3] + (c2[3] - c1[3]) * amount
    local a = c1[4] + (c2[4] - c1[4]) * amount
    return {r, g, b, a}
end

function object:new(x, y)
    self.x = x
    self.y = y
    self.startColor = COLORS.YELLOW
    self.endColor = COLORS.RED
    self.speed = PARTICLE_MIN_SPEED + love.math.random() * (PARTICLE_MAX_SPEED - PARTICLE_MIN_SPEED)
    self.lifetime = PARTICLE_MIN_LIFETIME + love.math.random() * (PARTICLE_MAX_LIFETIME - PARTICLE_MIN_LIFETIME)
    self.startSize = PARTICLE_MIN_SIZE + love.math.random() * (PARTICLE_MAX_SIZE - PARTICLE_MIN_SIZE)
    self.size = self.startSize
    self.direction = love.math.random() * (math.pi * 2)
    self.dx = math.cos(self.direction) * self.speed
    self.dy = math.sin(self.direction) * self.speed
    self.timer = self.lifetime
    self.color = self.startColor
end

function object:update(dt)
    self.timer = self.timer - dt
    if self.timer <= 0 then
        self.remove = true
    end

    local amount = 1 - self.timer / self.lifetime
    self.color = lerpColor(self.startColor, self.endColor, amount)
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