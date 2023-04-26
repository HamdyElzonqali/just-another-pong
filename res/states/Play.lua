local gameState = {}

local Ball      = require "res.objects.Ball"
local Paddle    = require "res.objects.Paddle"
local Powerup   = require "res.objects.Powerup"

local COOLDOWN = 1.8
local MAX_SCORE = 5
local POWERUP_START = 5
local POWERUP_MIN_INTERVAL = 3

function gameState:enter(cpuControlled)
    self.score = {0, 0}
    
    self.ball = Ball()
    self.player1 = Paddle(COLORS.RED, 15)
    self.cpuControlled  = cpuControlled
    if cpuControlled then
        self.player2 = Paddle(COLORS.BLUE, VIRTUAL_WIDTH - 20, self.ball)
        input.action("player1")
    else
        self.player2 = Paddle(COLORS.BLUE, VIRTUAL_WIDTH - 20)
    end
    
    self.cooldown = COOLDOWN
    self.ball:start()
    
    self.scored = 0
    self.scoreScreenAlpha = 0
    self.scoredRotation = 0
    self.scoredRotationDirection = 1
    self.scoredOffsetX = FONTS.MAIN:getWidth("Player 1 scored!") / 2
    self.scoredOffsetY = FONTS.MAIN:getHeight() / 2
    self.won = false
    self.paused = false

    self.powerups = {}
    self.powerupTimer = POWERUP_START

    self.fade = 0.3
end

function gameState:exit()
    
end

function gameState:update(dt)
    self.fade = math.max(love.math.lerp(self.fade, -0.05, 8 * dt), 0)

    if self.scored == 0 then
        if self.cooldown > 0 then
            self.cooldown = self.cooldown - dt
            return
        end
        
        
        if self.paused then
            camera.x = love.math.lerp(camera.x, 0, dt * 5)
            camera.y = love.math.lerp(camera.y, 0, dt * 5)
            camera.rotation = love.math.lerp(camera.rotation, 0, dt * 5)
            
            if input.get 'back' then
                state:switch("menu")
            elseif input.anyPressed() or #(love.touch.getTouches()) > 0 then
                self.paused = false
            end
            
            return
        elseif input.get 'pause' or input.get 'back' then
            self.paused = true
        end
        
        if self.powerupTimer > 0 then
            self.powerupTimer = self.powerupTimer - dt
        else
            self.powerupTimer = POWERUP_MIN_INTERVAL + math.random(5)
            local powerup = Powerup(love.math.random(7), love.math.random(30, VIRTUAL_WIDTH - 60), love.math.random(30, VIRTUAL_HEIGHT - 60))
            self.powerups[powerup] = powerup
        end
        
        -- Touch Controls
        local touches = love.touch.getTouches()
        for i, id in ipairs(touches) do
            local x, y = love.touch.getPosition(id)
            x, y = camera:screenToWorld(x, y)
            if x < VIRTUAL_WIDTH / 2 then
                if y < VIRTUAL_HEIGHT / 2 then
                    self.player1:moveUp()
                else
                    self.player1:moveDown()
                end
            else
                if y < VIRTUAL_HEIGHT / 2 then
                    self.player2:moveUp()
                else
                    self.player2:moveDown()
                end
            end
        end
        
        -- Mouse controls (for testing)
        local x, y = camera:mousePosition()
        if love.mouse.isDown(1) then
            if x < VIRTUAL_WIDTH / 2 then
                if y < VIRTUAL_HEIGHT / 2 then
                    self.player1:moveUp()
                else
                    self.player1:moveDown()
                end
            else
                if y < VIRTUAL_HEIGHT / 2 then
                    self.player2:moveUp()
                else
                    self.player2:moveDown()
                end
            end
        end
        
        -- Keyboard and Gamepad controls
        local player2 = input.getAxisRaw("player2")
        
        if player2 > 0 then
            self.player2:moveDown()
        elseif player2 < 0 then
            self.player2:moveUp()
        end

        local player1 = input.getAxis("player1", 1) + (self.cpuControlled and player2 or 0)
        
        if player1 > 0 then
            self.player1:moveDown()
        elseif player1 < 0 then
            self.player1:moveUp()
        end
        
        
        
        if self.ball.x < 0 then
            self.score[2] = self.score[2] + 1
            self.player1:calculateDifficulty(self.score[2])
            self.scored = 2
            self.scoreScreenAlpha = 0
            if self.score[2] >= MAX_SCORE then
                self.cooldown = 1
                self.won = true
            else
                self.cooldown = 0.3
            end
        end
        
        if self.ball.x > VIRTUAL_WIDTH - self.ball.w * self.ball.scale then
            self.score[1] = self.score[1] + 1
            self.player2:calculateDifficulty(self.score[1])
            self.scored = 1
            self.scoreScreenAlpha = 0
            if self.score[1] >= MAX_SCORE then
                self.cooldown = 1
                self.won = true
            else
                self.cooldown = 0.3
            end
        end
        
        self.player1:update(dt)
        self.player2:update(dt)
        self.ball:update(dt)
        
        for _, powerup in pairs(self.powerups) do
            powerup:update(dt)
            if powerup:collides(self.ball) then
                powerup:pick(self.ball.player, self.ball)
            end

            if powerup.remove then
                self.powerups[powerup] = nil
            end
        end
        
        if self.ball:collides(self.player1) then
            camera:shake(1, 0.2)
            if (self.ball.x - self.ball.dx * dt + 1 > self.player1.x + self.player1.w)
             then
                self.ball:reflectH()
                self.player1:push(-2, 0.1)
                self.ball.player = self.player1
                self.ball.x = self.player1.x + self.player1.w
                self.ball.speed = self.ball.speed * 1.03
                self.ball.dy = self.ball.dy + (-(self.player1.y + self.player1.h/2) + self.ball.y) * 5
                self.ball.dy = self.ball.dy + love.math.random(-10, 10)
            else
                self.ball.x = self.ball.x - 0.05
                if self.ball.y < self.player1.y then
                    self.ball.y = self.player1.y - self.ball.h * self.ball.scale
                    self.ball.dy = -math.abs(self.ball.dy) * 1.1
                elseif self.ball.y + self.ball.h * self.ball.scale / 2 > self.player1.y + self.player1.h then
                    self.ball.y = self.player1.y + self.player1.h
                    self.ball.dy = math.abs(self.ball.dy) * 1.1
                end
            end
        end
        
        if self.ball:collides(self.player2) then
            camera:shake(1, 0.2)
            if (self.ball.x + self.ball.w * self.ball.scale / 2 - self.ball.dx * dt - 1 < self.player2.x) then
                self.ball:reflectH()
                self.player2:push(2, 0.1)
                self.ball.player = self.player2
                self.ball.x = self.player2.x - self.ball.w * self.ball.scale
                self.ball.speed = self.ball.speed * 1.03
                self.ball.dy = self.ball.dy + (-(self.player2.y + self.player2.h/2) + self.ball.y) * 5
                self.ball.dy = self.ball.dy + love.math.random(-10, 10)
            else
                self.ball.x = self.ball.x + 0.05
                if self.ball.y < self.player2.y then
                    self.ball.y = self.player2.y - self.ball.h * self.ball.scale
                    self.ball.dy = -math.abs(self.ball.dy) * 1.4
                elseif self.ball.y + self.ball.h * self.ball.scale / 2 > self.player1.y + self.player1.h then
                    self.ball.y = self.player2.y + self.player2.h
                    self.ball.dy = math.abs(self.ball.dy) * 1.4
                end
            end
        end
    else
        self.powerups = {}
        self.powerupTimer = POWERUP_START
        self.scoreScreenAlpha = math.min(self.scoreScreenAlpha + dt * 2, 0.9)
        self.scoredRotation = self.scoredRotation + dt * 0.05 * self.scoredRotationDirection
        if self.scoredRotation > math.pi * 0.005 then
            self.scoredRotation = math.pi * 0.005
            self.scoredRotationDirection = -1
        elseif self.scoredRotation < -math.pi * 0.005 then
            self.scoredRotation = -math.pi * 0.005
            self.scoredRotationDirection = 1
        end

        camera.x = love.math.lerp(camera.x, 0, dt * 5)
        camera.y = love.math.lerp(camera.y, 0, dt * 5)
        camera.rotation = love.math.lerp(camera.rotation, 0, dt * 5)


        if self.cooldown > 0 then
            self.cooldown = self.cooldown - dt
            return
        end

        if input.anyPressed() or #(love.touch.getTouches()) > 0 then
            if not self.won then
                self.scored = 0
                self.fade = 0.3
                self.ball:start()
                self.player1:reset()
                self.player2:reset()
                self.cooldown = 1.8
            else
                -- go back to menu
                state:switch("menu")
            end
        end
    end
end

function gameState:draw()

    love.graphics.setColor(COLORS.GREY)
    love.graphics.line(-50, -1, VIRTUAL_WIDTH + 100, -1)
    love.graphics.line(-50, VIRTUAL_HEIGHT + 1, VIRTUAL_WIDTH + 100, VIRTUAL_HEIGHT + 1)

    self.player1:drawShadow()
    self.player2:drawShadow()
    self.ball:drawShadow()
    
    for _, powerup in pairs(self.powerups) do
        powerup:drawShadow()
    end
    
    love.graphics.setColor(COLORS.GREY)
    for i = -2, 2, 1 do
        love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 1, VIRTUAL_HEIGHT / 2 + i * 10 - 3, 2, 6)
    end
    
    love.graphics.setColor(COLORS.LIGHT_RED)
    love.graphics.printf(tostring(self.score[1]), 20, 35, 18, "right", 0, 3, 3)
    
    love.graphics.setColor(COLORS.LIGHT_BLUE)
    love.graphics.printf(tostring(self.score[2]), VIRTUAL_WIDTH / 2 + 9, 35, 18, "left", 0, 3, 3)
    

    self.player1:draw()
    self.player2:draw()

    for _, powerup in pairs(self.powerups) do
        powerup:draw()
    end

    self.ball:draw()

    if self.paused then
        local color = {unpack(COLORS.BLACK)}
        color[4] = 0.80
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", -100, -100, VIRTUAL_WIDTH + 200, VIRTUAL_HEIGHT + 200)
        love.graphics.setColor(COLORS.WHITE)
        love.graphics.printf("Paused", 0, VIRTUAL_HEIGHT / 2 - 15, VIRTUAL_WIDTH / 2, "center", 0, 2, 2)

        love.graphics.printf("Press any key or tap to continue", 0, VIRTUAL_HEIGHT / 2 + 5, VIRTUAL_WIDTH, "center", 0, 1, 1)
    elseif self.scored ~= 0 then
        if self.scored == 1 then
            local color = {unpack(COLORS.RED)}
            color[4] = self.scoreScreenAlpha
            love.graphics.setColor(color)
        elseif self.scored == 2 then
            local color = {unpack(COLORS.BLUE)}
            color[4] = self.scoreScreenAlpha
            love.graphics.setColor(color)
        end

        love.graphics.rectangle("fill", -100, -100, VIRTUAL_WIDTH + 200, VIRTUAL_HEIGHT + 200)
        love.graphics.setColor(COLORS.WHITE)

        if not self.won then
            love.graphics.printf("Player " .. tostring(self.scored) .. " scored!", self.scoredOffsetX * 2, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH / 2, "center", self.scoredRotation, 2, 2, self.scoredOffsetX, self.scoredOffsetY)
            love.graphics.printf("Press any key or tap to continue", 0, VIRTUAL_HEIGHT / 2 + 15, VIRTUAL_WIDTH, "center", 0, 1, 1)    
        else
            love.graphics.printf("Player " .. tostring(self.scored) .. " wins!", self.scoredOffsetX * 2, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH / 2, "center", self.scoredRotation, 2, 2, self.scoredOffsetX, self.scoredOffsetY)
        end
    elseif self.cooldown > 0 then
        love.graphics.setColor(COLORS.GREEN)
        love.graphics.printf(string.rep(".", math.ceil(self.cooldown / 0.6)), 1, 0, VIRTUAL_WIDTH / 2, "center", 0, 2, 2)
    end

    local color = {unpack(COLORS.WHITE)}
    color[4] = self.fade
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", -10, -10, VIRTUAL_WIDTH + 20, VIRTUAL_HEIGHT + 20)

    love.graphics.setColor(COLORS.RESET)
end
return gameState