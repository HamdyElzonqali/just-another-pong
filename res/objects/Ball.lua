local object = class:extend()

local FireParticle = require "res.objects.FireParticle"
local SmokeParticle = require "res.objects.SmokeParticle"

local STARTING_SPEED = 80
local MAX_SPEED = 160
local PARTICLE_MIN_RATE = 0.08
local PARTICLE_MAX_RATE = 0.01

local BALL_SIZE = 1
local BALL_MIN_SIZE = 0.5
local BALL_MAX_SIZE = 2
local BALL_POWERUP_SIZE = 0.5

function object:new()
    self.image = love.graphics.newImage("res/sprites/ball.png")
    self.shadow = love.graphics.newImage("res/sprites/ball-shadow.png")
    self.w = self.image:getWidth()
    self.h = self.image:getHeight()
    self.dx = 0
    self.dy = 0

    self.rotation = 0
    self.size = BALL_SIZE
    self.scale = self.size

    self:reset()

    self.particles = {}
    self.particlesTimer = 0

    self.player = nil
end

function object:reset()
    self.x = VIRTUAL_WIDTH / 2 - self.w / 2
    self.y = VIRTUAL_HEIGHT / 2 - self.h / 2
    self.speed = STARTING_SPEED
    self.size = BALL_SIZE
    self.particles = {}
end

function object:start()
    self.speed = STARTING_SPEED
    self.size = BALL_SIZE
    self.scale = self.size
    
    local angle = (-math.pi / 6) + love.math.random() * (math.pi / 3) -- a random angle between -30 and 30 degrees
    self.dx = math.cos(angle) * self.speed * (love.math.random(2) == 1 and 1 or -1)
    self.dy = math.sin(angle) * self.speed

    self:reset()
end

function object:update(dt)
    self.scale = love.math.lerp(self.scale, self.size, 10 * dt)

    local angle = math.atan2(self.dy, self.dx)

    self.x = self.x + self.speed * math.cos(angle) * dt
    self.y = self.y + self.speed * math.sin(angle) * dt

    -- make sure the ball can't go in a perfect vertical angle
    local absAngle = math.atan2(math.abs(self.dy), math.abs(self.dx))
    if absAngle > math.pi * 0.32 then
        self.dy = self.dy * 0.95
        self.dx = self.dx + (self.dx > 0 and 1 or -1) * 0.05
    end

    self.rotation = self.rotation + self.speed * dt * 0.1

    if self.y < 0 then
        self:reflectV()
        self.y = 0
        self.dy = self.dy * 1.005
        camera:shake(0.6, 0.15)
    end

    if self.y > VIRTUAL_HEIGHT - self.h then
        self:reflectV()
        self.y = VIRTUAL_HEIGHT - self.h
        self.dy = self.dy * 1.001
        camera:shake(0.6, 0.15)
    end

    camera.x = love.math.lerp(camera.x, (-VIRTUAL_WIDTH  / 2 + self.x) / 4, 10 * dt)
    camera.y = love.math.lerp(camera.y, (-VIRTUAL_HEIGHT / 2 + self.y) / 4, 10 * dt)

    camera.rotation = love.math.lerp(camera.rotation, (-VIRTUAL_WIDTH  / 2 + self.x) / VIRTUAL_WIDTH * math.pi / 60, 4 * dt)

    if self.speed > MAX_SPEED then
        self.speed = MAX_SPEED
    end

    if self.particlesTimer > 0 then
        self.particlesTimer = self.particlesTimer - dt
    elseif self.speed > 100 then
        self.particlesTimer = PARTICLE_MIN_RATE + (PARTICLE_MAX_RATE - PARTICLE_MIN_RATE) * (self.speed  / MAX_SPEED)
        for i = 1, math.random(1, 3) do
            local particle =  FireParticle(self.x + self.w / 2, self.y + self.h / 2)
            self.particles[particle] = particle
        end
    end

    for particle, _ in pairs(self.particles) do
        particle:update(dt)
        if particle.remove then
            self.particles[particle] = nil
        end
    end
end

function object:draw()
    love.graphics.setColor(COLORS.RESET)
    love.graphics.draw(self.image, self.x + 2, self.y + 2, self.rotation, self.scale, self.scale, self.w / 2, self.h / 2)
    for particle, _ in pairs(self.particles) do
        particle:draw()
    end
end

function object:drawShadow()
    love.graphics.setColor(COLORS.RESET)
    love.graphics.draw(self.shadow, self.x + 1 + 2, self.y + 1 + 2, self.rotation, self.scale, self.scale, self.w / 2, self.h / 2)
    for particle, _ in pairs(self.particles) do
        particle:drawShadow()
    end
end

function object:collides(object)
    -- AABB collision detection
    return self.x + self.w * self.scale > object.x and self.x < object.x + object.w and self.y + self.h * self.scale > object.y and self.y < object.y + object.h
end

function object:reflectH()
    self.dx = -self.dx
    for i = 1, love.math.random(3, 8) do
        local particle =  SmokeParticle(self.x + self.w / 2 + love.math.random(-2, 2), self.y + self.h / 2 + love.math.random(-2, 2))
        self.particles[particle] = particle
    end
end

function object:reflectV()
    self.dy = -self.dy
    for i = 1, love.math.random(3, 5) do
        local particle =  SmokeParticle(self.x + self.w / 2 + love.math.random(-2, 2), self.y + self.h / 2 + love.math.random(-2, 2))
        self.particles[particle] = particle
    end
end

function object:grow()
    self.size = self.size + BALL_POWERUP_SIZE
    if self.size > BALL_MAX_SIZE then
        self.size = BALL_MAX_SIZE
    end
end

function object:shrink()
    self.size = self.size - BALL_POWERUP_SIZE
    if self.size < BALL_MIN_SIZE then
        self.size = BALL_MIN_SIZE
    end
end

function object:slowdown()
    self.speed = STARTING_SPEED + 10
end

return object