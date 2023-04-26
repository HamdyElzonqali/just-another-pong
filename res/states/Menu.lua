local gameState = {}

local SOCIAL_COUNT = 5

local SOCIAL_LINKS = {
    "https://www.patreon.com/HamdyElzanqali",
    "https://twitter.com/HamdyElzanqali",
    "https://discord.gg/eJjtQ3XyfY",
    "https://www.facebook.com/profile.php?id=100064020667974",
    "https://www.youtube.com/channel/UC0V92BG4mHnQ7zg-BiBiRvA",
}

function gameState:enter(...)
    self.buttons = {}
    if SHOW_BRANDING then
        for i = 1, SOCIAL_COUNT do
            self:addButton("res/sprites/social" .. i .. ".png", "res/sprites/social-shadow.png", (VIRTUAL_WIDTH / 2) + (i - math.ceil(SOCIAL_COUNT / 2)) * 16, 70, 8, 8, function() love.system.openURL(SOCIAL_LINKS[i]) end)
        end
    end

    self:addButton(gSound and 'res/sprites/sound1.png' or 'res/sprites/sound2.png', gSound and 'res/sprites/sound-shadow1.png' or 'res/sprites/sound-shadow2.png', VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT - 21, 8, 8, function(self)
        gSound = not gSound
        if gSound then
            self.image = love.graphics.newImage('res/sprites/sound1.png')
            self.shadow = love.graphics.newImage('res/sprites/sound-shadow1.png')
        else
            self.image = love.graphics.newImage('res/sprites/sound2.png')
            self.shadow = love.graphics.newImage('res/sprites/sound-shadow2.png')
        end
    end)

    self:addButton(gMusic and 'res/sprites/music1.png' or 'res/sprites/music2.png', gMusic and 'res/sprites/music-shadow1.png' or 'res/sprites/music-shadow2.png', VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT - 37, 8, 8, function(self)
        gMusic = not gMusic
        if gMusic then
            self.image = love.graphics.newImage('res/sprites/music1.png')
            self.shadow = love.graphics.newImage('res/sprites/music-shadow1.png')
        else
            self.image = love.graphics.newImage('res/sprites/music2.png')
            self.shadow = love.graphics.newImage('res/sprites/music-shadow2.png')
        end
    end)

    self:addButton ('res/sprites/2p.png', 'res/sprites/2p-shadow.png', VIRTUAL_WIDTH / 2 - 15, VIRTUAL_HEIGHT / 2 + (SHOW_BRANDING and -5 or 5), 16, 16, 
        function() 
            state:switch("play", false)
            camera:shake(1.25, 0.25)
        end)

    self:addButton ('res/sprites/1p.png', 'res/sprites/1p-shadow.png', VIRTUAL_WIDTH / 2 + 15, VIRTUAL_HEIGHT / 2 + (SHOW_BRANDING and -5 or 5), 16, 16, 
        function() 
            state:switch("play", true)
            camera:shake(1.25, 0.25)
        end)

    self.descriptionRotation = 0
    self.descriptionRotationDirection = 1

    self.targetX = 0
    self.targetY = 0
end

function gameState:addButton(image, shadow, x, y, w, h, callback)
    local button = {}
    button.image = love.graphics.newImage(image)
    button.shadow = love.graphics.newImage(shadow)
    button.x = x
    button.y = y
    button.w = w
    button.h = h
    button.rotation = -0.03 + love.math.random() * 0.06
    button.rotationDirection = 1
    button.offset = {0, 0}

    button.callback = callback
    button.draw = function(self)
        love.graphics.setColor(COLORS.RESET)
        love.graphics.draw(self.shadow, self.x + 1 + self.offset[1], self.y + 1 + self.offset[2], self.rotation, 1, 1, self.w / 2, self.h / 2)
        love.graphics.draw(self.image, self.x + self.offset[1], self.y + self.offset[2], self.rotation, 1, 1, self.w / 2, self.h / 2)
    end

    button.update = function (self, dt)
        local mx, my = camera:mousePosition()
        if mx > self.x - self.w and mx < self.x + self.w and my > self.y - self.h and my < self.y + self.h then
            self.offset[2] = love.math.lerp(self.offset[2], -self.h / 4, 0.1)
            self.rotation = love.math.lerp(self.rotation, -0.1, dt)
            -- SELECT BUTTON
            if input.mousePressed(1) then
                self.callback(self)
            end
        else
            self.offset[2] = love.math.lerp(self.offset[2], 0, dt * 4)
            
            if self.rotationDirection == 1 then
                self.rotation = love.math.lerp(self.rotation, 0.07, 3 * dt)
                if self.rotation > 0.05 then
                    self.rotation = 0.05
                    self.rotationDirection = -1
                end
            else
                self.rotation = love.math.lerp(self.rotation, -0.07, 3 * dt)
                if self.rotation < -0.05 then
                    self.rotation = -0.05
                    self.rotationDirection = 1
                end
            end
        end
    end

    self.buttons[button] = button
end

function gameState:exit()
    
end

function gameState:update(dt)
    for _, button in pairs(self.buttons) do
        button:update(dt)
    end


    if input.mouseMoved() then
        local mx, my = camera:mousePosition()
        self.targetX = mx - VIRTUAL_WIDTH / 2
        self.targetY = my - VIRTUAL_HEIGHT / 2
    end

    camera.x = love.math.lerp(camera.x, self.targetX / 8, 0.1)
    camera.y = love.math.lerp(camera.y, self.targetY / 8, 0.1)
    camera.rotation = love.math.lerp(camera.rotation, 0.03 * (self.targetX / 100), 0.1)

    if self.descriptionRotationDirection == 1 then
        self.descriptionRotation = love.math.lerp(self.descriptionRotation, 0.04, 3 * dt)
        if self.descriptionRotation > 0.03 then
            self.descriptionRotation = 0.03
            self.descriptionRotationDirection = -1
        end
    else
        self.descriptionRotation = love.math.lerp(self.descriptionRotation, -0.04, 3 * dt)
        if self.descriptionRotation < -0.03 then
            self.descriptionRotation = -0.03
            self.descriptionRotationDirection = 1
        end
    end
end

function gameState:draw()
    for _, button in pairs(self.buttons) do
        button:draw()
    end




    love.graphics.setColor(COLORS.GREY)
    love.graphics.printf("FIRST TO   WINS", VIRTUAL_WIDTH / 2 + 1, SHOW_BRANDING and 17 or 31, VIRTUAL_WIDTH, "center", self.descriptionRotation, 1, 1, VIRTUAL_WIDTH / 2, 3)
    love.graphics.printf("    5", VIRTUAL_WIDTH / 2 + 1, SHOW_BRANDING and 17 or 31, VIRTUAL_WIDTH, "center", self.descriptionRotation, 1, 1,  VIRTUAL_WIDTH / 2, 3)

    love.graphics.setColor(COLORS.BLACK)
    love.graphics.printf("FIRST TO   WINS", VIRTUAL_WIDTH / 2, SHOW_BRANDING and 16 or 30, VIRTUAL_WIDTH, "center", self.descriptionRotation, 1, 1, VIRTUAL_WIDTH / 2, 3)
    love.graphics.setColor(COLORS.YELLOW)
    love.graphics.printf("    5", VIRTUAL_WIDTH / 2, SHOW_BRANDING and 16 or 30, VIRTUAL_WIDTH, "center", self.descriptionRotation, 1, 1,  VIRTUAL_WIDTH / 2, 3)
end

return gameState