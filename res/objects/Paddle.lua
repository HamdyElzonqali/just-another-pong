local object = class:extend()

local PRESS_DELAY = 0.05
local PADDLE_WIDTH = 5
local COMPUTER_BASE_ADVANTAGE = 1.05 -- Starts 5% faster
local COMPUTER_STEP_ADVANTAGE = 0.05 -- Increases 5% each time the opponent scores

local PADDLE_SPEED = 70
local PADDLE_MAX_SPEED = 106
local PADDLE_MIN_SPEED = 58
local PADDLE_POWERUP_SPEED = 12

local PADDLE_SIZE = 20
local PADDLE_MAX_SIZE = 32
local PADDLE_MIN_SIZE = 12
local PADDLE_POWERUP_SIZE = 4


function object:new(color, x, target)
    self.x = x
    self.startX = x
    self.y = VIRTUAL_HEIGHT / 2 - PADDLE_SIZE / 2
    self.color = color
    self.w = PADDLE_WIDTH
    self.h = PADDLE_SIZE
    self.target = target
    self.timer = 0
    self.dy = 0
    self.pushAmount = 0
    self.pushTimer  = 0

    self.speed = PADDLE_SPEED
    self.size = PADDLE_SIZE
    self.difficulty = COMPUTER_BASE_ADVANTAGE
end

function object:reset()
    self.y = VIRTUAL_HEIGHT / 2 - self.h / 2
    self.speed = PADDLE_SPEED
    self.size = PADDLE_SIZE
    self.h = self.size
end

function object:update(dt)
    local amount = love.math.lerp(self.h, self.size, 10 * dt) - self.h
    self.h = self.h + amount
    self.y = self.y - amount / 2

    if self.target then
        if self.timer > 0 then
            self.timer = self.timer - dt
        else
            self.dy = 0
        end

        -- if ball is moving towards the paddle, move towards it
        if math.abs(self.x - self.target.x) > math.abs(self.x - self.target.x - self.target.dx * dt) then
            if self.target.y < self.y + self.h / 2 - 4 then
                self.dy = -self.speed * self.difficulty
                self.timer = PRESS_DELAY
            end

            if self.target.y > self.y + self.h / 2 + 4 then
                self.dy = self.speed * self.difficulty
                self.timer = PRESS_DELAY
            end
        end
    end

    self.y = self.y + self.dy * dt

    if self.y < 0 then
        self.y = 0
    end

    if self.y + self.h > VIRTUAL_HEIGHT then
        self.y = VIRTUAL_HEIGHT - self.h
    end

    if self.pushTimer > 0 then
        self.pushTimer = self.pushTimer - dt
        self.x = love.math.lerp(self.x, self.startX + self.pushAmount, 10 * dt)
    else
        self.x = love.math.lerp(self.x, self.startX, 10 * dt)
    end

    if not self.target then
        self:stop()
    end
end

function object:moveUp()
    if self.target then
        return
    end

    self.dy = -self.speed
end

function object:moveDown()
    if self.target then
        return
    end

    self.dy = self.speed
end

function object:stop()
    self.dy = 0
end

function object:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

function object:drawShadow()
    love.graphics.setColor(COLORS.GREY)
    love.graphics.rectangle("fill", self.x + 1, self.y + 1, self.w, self.h)
end

function object:calculateDifficulty(opponentScore)
    self.difficulty = COMPUTER_BASE_ADVANTAGE + COMPUTER_STEP_ADVANTAGE * opponentScore
end

function object:push(amount, time)
    self.pushAmount = amount
    self.pushTimer = time
end

function object:speedup()
    self.speed = self.speed + PADDLE_POWERUP_SPEED
    if self.speed > PADDLE_MAX_SPEED then
        self.speed = PADDLE_MAX_SPEED
    end
end

function object:slowdown()
    self.speed = self.speed - PADDLE_POWERUP_SPEED
    if self.speed < PADDLE_MIN_SPEED then
        self.speed = PADDLE_MIN_SPEED
    end
end

function object:grow()
    self.size = self.size + PADDLE_POWERUP_SIZE
    if self.size > PADDLE_MAX_SIZE then
        self.size = PADDLE_MAX_SIZE
    end
end

function object:shrink()
    self.size = self.size - PADDLE_POWERUP_SIZE
    if self.size < PADDLE_MIN_SIZE then
        self.size = PADDLE_MIN_SIZE
    end
end

return object