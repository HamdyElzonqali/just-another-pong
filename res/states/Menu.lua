local gameState = {}

local SOCIAL_COUNT = 5
local SELECT_MULTIPLAYER = true

local SOCIAL_LINKS = {
    "https://www.patreon.com/HamdyElzanqali",
    "https://twitter.com/HamdyElzanqali",
    "https://discord.gg/eJjtQ3XyfY",
    "https://www.facebook.com/profile.php?id=100064020667974",
    "https://www.youtube.com/channel/UC0V92BG4mHnQ7zg-BiBiRvA",
}

function gameState:enter(...)
    self.ui_map = {
        {}, {}, {},
    }
    self.buttons = {}
    if SHOW_BRANDING then
        for i = 1, SOCIAL_COUNT do
            self:addButton("res/sprites/social" .. i .. ".png", "res/sprites/social-shadow.png", (VIRTUAL_WIDTH / 2) + (i - math.ceil(SOCIAL_COUNT / 2)) * 16, 70, 8, 8, function() love.system.openURL(SOCIAL_LINKS[i]) end, 3, i)
        end
    end

    self:addButton(gSound and 'res/sprites/sound1.png' or 'res/sprites/sound2.png', gSound and 'res/sprites/sound-shadow1.png' or 'res/sprites/sound-shadow2.png', VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT - 21, 10, 7, function(self)
        gSound = not gSound
        if gSound then
            self.image = love.graphics.newImage('res/sprites/sound1.png')
            self.shadow = love.graphics.newImage('res/sprites/sound-shadow1.png')
        else
            self.image = love.graphics.newImage('res/sprites/sound2.png')
            self.shadow = love.graphics.newImage('res/sprites/sound-shadow2.png')
        end
    end, 3, SOCIAL_COUNT + 1)

    self:addButton(gMusic and 'res/sprites/music1.png' or 'res/sprites/music2.png', gMusic and 'res/sprites/music-shadow1.png' or 'res/sprites/music-shadow2.png', VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT - 37, 8, 8, function(self)
        gMusic = not gMusic
        if gMusic then
            self.image = love.graphics.newImage('res/sprites/music1.png')
            self.shadow = love.graphics.newImage('res/sprites/music-shadow1.png')
            playMusic("res/audio/music.ogg", 0.3)
        else
            self.image = love.graphics.newImage('res/sprites/music2.png')
            self.shadow = love.graphics.newImage('res/sprites/music-shadow2.png')
            stopMusic("res/audio/music.ogg")
        end
    end, 2, SOCIAL_COUNT + 1)

    local multiplayer = self:addButton ('res/sprites/2p.png', 'res/sprites/2p-shadow.png', VIRTUAL_WIDTH / 2 - 20, VIRTUAL_HEIGHT / 2 + (SHOW_BRANDING and -5 or 8), 20, 20, 
        function() 
            state:switch("play", false)
            camera:shake(1.25, 0.25)
            SELECT_MULTIPLAYER = true
        end, 1, 1)
    
    table.insert(self.ui_map[1], multiplayer)

    local single = self:addButton ('res/sprites/1p.png', 'res/sprites/1p-shadow.png', VIRTUAL_WIDTH / 2 + 20, VIRTUAL_HEIGHT / 2 + (SHOW_BRANDING and -5 or 8), 20, 20, 
        function() 
            state:switch("play", true)
            camera:shake(1.25, 0.25)
            SELECT_MULTIPLAYER = false
        end, 1, 2)

    self.descriptionRotation = 0
    self.descriptionRotationDirection = 1

    
    self.selected = nil

    if SELECT_MULTIPLAYER then
        self.selected = multiplayer
    else
        self.selected = single
    end

    self.targetX = self.selected.x
    self.targetY = self.selected.y

    self.selectorImage = love.graphics.newImage('res/sprites/selector.png')
    self.selectorShadow = love.graphics.newImage('res/sprites/selector-shadow.png')
    self.selector = {
        x = self.selected.x,
        y = self.selected.y,
        w = self.selected.w,
        h = self.selected.h,
    }

    self.fade = 0.7

    playSound("res/audio/menu_select.wav", 0.8)
    playMusic("res/audio/music.ogg", 0.3)
end

function gameState:addButton(image, shadow, x, y, w, h, callback, ui_map_level, ui_map_index)
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
    button.size = 1

    button.callback = callback
    button.draw = function(self)
        love.graphics.setColor(COLORS.RESET)
        love.graphics.draw(self.shadow, self.x + 1 + self.offset[1], self.y + 1 + self.offset[2], self.rotation, self.size, self.size, self.w / 2, self.h / 2)
        love.graphics.draw(self.image, self.x + self.offset[1], self.y + self.offset[2], self.rotation, self.size, self.size, self.w / 2, self.h / 2)
    end

    button.update = function (self, dt, state)
        self.size = love.math.lerp(self.size, 1, dt * 4)
        local mx, my = camera:mousePosition()
        local hovered = mx > self.x - self.w and mx < self.x + self.w and my > self.y - self.h and my < self.y + self.h

        if state.selected == self then 
            self.offset[2] = love.math.lerp(self.offset[2], -self.h / 4, 0.1)
            self.rotation = love.math.lerp(self.rotation, -0.1, dt)
        end

        if hovered then
            state.targetX = self.x
            state.targetY = self.y

            if input.mouseMoved() then
                if state.selected ~= self and not IS_MOBILE then
                    playSound("res/audio/menu_select.wav", 0.7)
                end

                state.selected = self
            end

            if input.mousePressed(1) then
                playSound("res/audio/menu_click.wav", 0.7)
                self.callback(self)
                self.size = 1.18
            end
        end

        if state.selected ~= self then
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

        for _, touch in ipairs(love.touch.getTouches()) do
            local tx, ty = love.touch.getPosition(touch)
            if tx > self.x - self.w and tx < self.x + self.w and ty > self.y - self.h and ty < self.y + self.h then
                playSound("res/audio/menu_click.wav")
                self.callback(self)
                self.size = 1.18
            end
        end
    end

    self.buttons[button] = button
    if ui_map_level and ui_map_index then
        self.ui_map[ui_map_level][ui_map_index] = button
        button.ui_map_level = ui_map_level
        button.ui_map_index = ui_map_index
    end
    return button
end

function gameState:exit()
    
end

function gameState:update(dt)
    self.fade = math.max(love.math.lerp(self.fade, 0.1, dt * 8), 0)

    for _, button in pairs(self.buttons) do
        button:update(dt, self)
    end


    if input.mouseMoved() then
        local mx, my = camera:mousePosition()
        self.targetX = mx
        self.targetY = my
    end

    camera.x = love.math.lerp(camera.x, (self.targetX -  VIRTUAL_WIDTH / 2) / 8, 0.1)
    camera.y = love.math.lerp(camera.y, (self.targetY - VIRTUAL_HEIGHT / 2) / 8, 0.1)
    camera.rotation = love.math.lerp(camera.rotation, 0.03 * (self.targetX / 100), 0.1)

    self.selector.x = love.math.lerp(self.selector.x, self.selected.x + self.selected.offset[1], dt * 5)
    self.selector.y = love.math.lerp(self.selector.y, self.selected.y + self.selected.offset[2], dt * 5)
    self.selector.w = love.math.lerp(self.selector.w, self.selected.w + 4, dt * 5)
    self.selector.h = love.math.lerp(self.selector.h, self.selected.h + 4, dt * 5)

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

    if input.get "ui_confirm" then
        playSound("res/audio/menu_click.wav")
        if self.selected then
            self.selected:callback(self.selected)
            self.selected.size = 1.18
        end
    end

    if input.get "ui_right" then
        if not IS_MOBILE then 
            playSound("res/audio/menu_select.wav")
        end

        local ui_map_index = self.selected.ui_map_index + 1
        if SHOW_BRANDING then
            if self.selected.ui_map_level == 1 then
                if ui_map_index > 2 then
                    self.selected = self.ui_map[2][6]
                else
                    self.selected = self.ui_map[1][ui_map_index]
                end
            elseif self.selected.ui_map_level == 3 then
                if ui_map_index > 6 then
                    ui_map_index = 6
                end

                self.selected = self.ui_map[3][ui_map_index]
            end

        else
            if self.selected.ui_map_level == 1 then
                if ui_map_index > 2 then
                    self.selected = self.ui_map[2][6]
                else
                    self.selected = self.ui_map[1][ui_map_index]
                end
            end
        end
        self.targetX = self.selected.x
        self.targetY = self.selected.y
    end

    if input.get "ui_left" then
        if not IS_MOBILE then 
            playSound("res/audio/menu_select.wav")
        end

        local ui_map_index = self.selected.ui_map_index - 1
        if SHOW_BRANDING then
            if self.selected.ui_map_level == 1 then
                if ui_map_index < 1 then
                    ui_map_index = 1
                end
                self.selected = self.ui_map[1][ui_map_index]
            elseif self.selected.ui_map_level == 2 then
                self.selected = self.ui_map[1][2]
            elseif self.selected.ui_map_level == 3 then
                if ui_map_index < 1 then
                    ui_map_index = 1
                end
    
                self.selected = self.ui_map[3][ui_map_index]
            end
        else
            if ui_map_index < 1 then
                ui_map_index = 1
            end
            if self.selected.ui_map_level == 1 then
                self.selected = self.ui_map[1][ui_map_index]
            else
                self.selected = self.ui_map[1][2]
            end
        end
        self.targetX = self.selected.x
        self.targetY = self.selected.y
    end

    if input.get "ui_down" then
        if not IS_MOBILE then 
            playSound("res/audio/menu_select.wav")
        end

        local ui_map_level = self.selected.ui_map_level + 1
        if SHOW_BRANDING then
            if ui_map_level > 3 or ui_map_level == 2 then
                ui_map_level = 3
            end
    
            if self.selected.ui_map_index == 6 then
                self.selected = self.ui_map[ui_map_level][6]
            elseif self.selected.ui_map_index == 1 then
                self.selected = self.ui_map[ui_map_level][1]
            elseif self.selected.ui_map_index == 2 then
                self.selected = self.ui_map[ui_map_level][4]
            end
        else
            if self.selected.ui_map_level == 2 then
                self.selected = self.ui_map[ui_map_level][6]
            end
        end

        self.targetX = self.selected.x
        self.targetY = self.selected.y
    end

    if input.get "ui_up" then
        if not IS_MOBILE then 
            playSound("res/audio/menu_select.wav")
        end

        local ui_map_level = self.selected.ui_map_level - 1
        if ui_map_level < 1 then
            ui_map_level = 1
        end

        if self.selected.ui_map_index == 6 then 
           if ui_map_level == 1 then
                self.selected = self.ui_map[ui_map_level][2]
           else
                self.selected = self.ui_map[ui_map_level][6]
           end
        elseif self.selected.ui_map_index > 3 then
            self.selected = self.ui_map[1][2]
        elseif self.selected.ui_map_level == 3 then
            self.selected = self.ui_map[1][1]
        end

        self.targetX = self.selected.x
        self.targetY = self.selected.y
    end
end

function gameState:draw()
    if not IS_MOBILE then
        love.graphics.setColor(COLORS.RESET)
        love.graphics.draw(self.selectorShadow, self.selector.x + 1, self.selector.y + 1, 0, 1, 1, self.selector.w / 2, self.selector.h / 2)
        love.graphics.draw(self.selectorShadow, self.selector.x + 1, self.selector.y + 1, 0, -1, 1, self.selector.w / 2, self.selector.h / 2)
        love.graphics.draw(self.selectorShadow, self.selector.x + 1, self.selector.y + 1, 0, -1, -1, self.selector.w / 2, self.selector.h / 2)
        love.graphics.draw(self.selectorShadow, self.selector.x + 1, self.selector.y + 1, 0, 1, -1, self.selector.w / 2, self.selector.h / 2)
    end
    

    for _, button in pairs(self.buttons) do
        button:draw()
    end
    
    if not IS_MOBILE then
        love.graphics.setColor(COLORS.RESET)
        love.graphics.draw(self.selectorImage, self.selector.x, self.selector.y, 0, 1, 1, self.selector.w / 2, self.selector.h / 2)
        love.graphics.draw(self.selectorImage, self.selector.x, self.selector.y, 0, -1, 1, self.selector.w / 2, self.selector.h / 2)
        love.graphics.draw(self.selectorImage, self.selector.x, self.selector.y, 0, -1, -1, self.selector.w / 2, self.selector.h / 2)
        love.graphics.draw(self.selectorImage, self.selector.x, self.selector.y, 0, 1, -1, self.selector.w / 2, self.selector.h / 2)
    end


    love.graphics.setColor(COLORS.GREY)
    love.graphics.printf("FIRST TO   WINS", VIRTUAL_WIDTH / 2 + 1, SHOW_BRANDING and 17 or 31, VIRTUAL_WIDTH, "center", self.descriptionRotation, 1, 1, VIRTUAL_WIDTH / 2, 3)
    love.graphics.printf("    5", VIRTUAL_WIDTH / 2 + 1, SHOW_BRANDING and 17 or 31, VIRTUAL_WIDTH, "center", self.descriptionRotation, 1, 1,  VIRTUAL_WIDTH / 2, 3)

    love.graphics.setColor(COLORS.BLACK)
    love.graphics.printf("FIRST TO   WINS", VIRTUAL_WIDTH / 2, SHOW_BRANDING and 16 or 30, VIRTUAL_WIDTH, "center", self.descriptionRotation, 1, 1, VIRTUAL_WIDTH / 2, 3)
    love.graphics.setColor(COLORS.YELLOW)
    love.graphics.printf("    5", VIRTUAL_WIDTH / 2, SHOW_BRANDING and 16 or 30, VIRTUAL_WIDTH, "center", self.descriptionRotation, 1, 1,  VIRTUAL_WIDTH / 2, 3)

    local color = {unpack(COLORS.WHITE)}
    color[4] = self.fade
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

return gameState