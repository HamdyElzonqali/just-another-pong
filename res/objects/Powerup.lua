local object = class:extend()

local LIFE_TIME = 10

local SmokeParticle = require "res.objects.SmokeParticle"

local images = {
    love.graphics.newImage("res/sprites/speedup.png"),
    love.graphics.newImage("res/sprites/slowdown.png"),
    love.graphics.newImage("res/sprites/grow.png"),
    love.graphics.newImage("res/sprites/shrink.png"),
    --love.graphics.newImage("res/sprites/wind.png"),
    love.graphics.newImage("res/sprites/big.png"),
    love.graphics.newImage("res/sprites/small.png"),
    love.graphics.newImage("res/sprites/slow.png")
}

local shadows = {
    love.graphics.newImage("res/sprites/speedup-shadow.png"),
    love.graphics.newImage("res/sprites/slowdown-shadow.png"),
    love.graphics.newImage("res/sprites/grow-shadow.png"),
    love.graphics.newImage("res/sprites/shrink-shadow.png"),
    --love.graphics.newImage("res/sprites/wind-shadow.png"),
    love.graphics.newImage("res/sprites/big-shadow.png"),
    love.graphics.newImage("res/sprites/small-shadow.png"),
    love.graphics.newImage("res/sprites/slow-shadow.png")
}

local pickFunc = {
    function (player, ball)
        if player then
            player:speedup()
        end
    end,
    function (player, ball)
        if player then
            player:slowdown()
        end
    end,
    function (player, ball)
        player:grow()
    end,
    function (player, ball)
        player:shrink()
    end,
    -- function (player, ball)
        
    -- end,
    function (player, ball)
        ball:grow()
    end,
    function (player, ball)
        ball:shrink()
    end,
    function (player, ball)
        ball:slowdown()
    end
}

function object:new(type, x, y)
    self.size = 0
    self.x = x
    self.y = y
    self.picked = false
    self.w = 8
    self.h = 8
    self.type = type
    self.image = images[type]
    self.rotation = math.pi * -0.15 + love.math.random() * math.pi * 0.3
    self.rotationDirection = love.math.random(2) == 1 and 1 or -1

    self.timer = LIFE_TIME
end

function object:pick(player, ball)
    if self.picked then 
        return 
    end

    self.size = 1.2
    self.picked = true

    if pickFunc[self.type] then
        pickFunc[self.type](player, ball)
    end

    for i = 1, love.math.random(6, 10) do
        local particle = SmokeParticle(self.x + love.math.random(-4, 4), self.y + love.math.random(-4, 4))
        ball.particles[particle] = particle
    end
end

function object:update(dt)
    self.timer = self.timer - dt
    if self.timer <= 0 then
        self.picked = true
    end

    if not self.picked then
        self.size = love.math.lerp(self.size, 1, 10 * dt)
    else
        self.size = love.math.lerp(self.size, -0.1, 10 * dt)
        if self.size <= 0 then
            self.remove = true
        end
    end

    self.rotation = self.rotation + self.rotationDirection * 0.7 * dt

    if self.rotation > math.pi * 0.15 then
        self.rotationDirection = -1
    elseif self.rotation < -math.pi * 0.15 then
        self.rotationDirection = 1
    end
end

function object:collides(ball)
    -- AABB collision detection
    if ball.x + ball.w * ball.scale / 2 > self.x - self.w / 2 and ball.x - ball.w * ball.scale / 2 < self.x + self.w / 2 and ball.y + ball.h * ball.scale / 2 > self.y - self.h / 2 and ball.y - ball.h * ball.scale / 2 < self.y + self.h / 2 then
        return true
    end
end

function object:draw()
    love.graphics.setColor(COLORS.RESET)
    love.graphics.draw(self.image, self.x, self.y, self.rotation, self.size, self.size, 8, 8)

    -- love.graphics.setColor(COLORS.RED)
    -- love.graphics.rectangle("fill", self.x - self.w / 2, self.y - self.h / 2, self.w, self.h)
end

function object:drawShadow()
    love.graphics.setColor(COLORS.RESET)
    love.graphics.draw(shadows[self.type], self.x + 1, self.y + 1, self.rotation, self.size, self.size, 8, 8)
end

return object