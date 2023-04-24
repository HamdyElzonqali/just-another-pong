local camera = {
    x = 0,
    y = 0,
    scale = 1,
    rotation = 0,
    virtualWidth = 0,
    virtualHeight = 0,
    pixelPerfectRotation = true,
    edgeOffset = {
        x = 0,
        y = 0,
    },
    _shake = {
        intensity = 0,
        duration = 0,
        timer = 0,
        x = 0,
        y = 0,
    },
    pivot = {
        x = 0.5,
        y = 0.5,
    }
}

function camera:setRotation(rotation)
    self.rotation = rotation
end

function camera:setPosition(x, y)
    self.x = x
    self.y = y
end

function camera:setScale(scale)
    self.scale = scale
end

function camera:setPivot(x, y)
    self.pivot.x = x
    self.pivot.y = y
end

function camera:reset()
    self.x = 0
    self.y = 0
    self.scale = 1
    self.rotation = 0
    
    -- Reset shake
    self._shake.intensity = 0
    self._shake.duration = 0
    self._shake.timer = 0
    self._shake.x = 0
    self._shake.y = 0
end

function camera:shake(intensity, duration)
    self._shake.intensity = intensity or 1.5
    self._shake.duration = duration or 0.25

    self._shake.timer = self._shake.duration
end

function camera:update(dt)
    -- Update shake
    if self._shake.timer > 0 then
        local multiplier = 1
        
        -- divide by 0 will cause errors
        if self._shake.duration > 0 then
            multiplier = self._shake.timer / self._shake.duration
        end

        self._shake.timer = self._shake.timer - dt
        
        self._shake.x = love.math.random(-self._shake.intensity, self._shake.intensity) * multiplier
        self._shake.y = love.math.random(-self._shake.intensity, self._shake.intensity) * multiplier
    else
        self._shake.x = 0
        self._shake.y = 0
    end
end

function camera:setVirtualDimensions(width, height)
    self.virtualWidth = width
    self.virtualHeight = height

    self:resize()
end

function camera:resize()
    local windowWidth, windowHeight = love.graphics.getDimensions()

    local width, height = self.virtualWidth, self.virtualHeight
    local scaleX, scaleY
    if width ~= 0 then
        scaleX = math.floor(windowWidth / width)
    end

    if height ~= 0 then
        scaleY = math.floor(windowHeight / height)
    end

    local scale
    if not scaleX then
        scale = scaleY
    elseif not scaleY then
        scale = scaleX
    else
        scale = math.min(scaleX, scaleY)
    end

    if scaleX then 
        self.edgeOffset.x = math.floor((windowWidth - (width * scale)) / (2 * scale))
    end
    
    if scaleY then
        self.edgeOffset.y = math.floor((windowHeight - (height * scale)) / (2 * scale))
    end

    self:setScale(scale)
end

function camera:screenToWorld(x, y)
    x = x / self.scale - self.edgeOffset.x
    y = y / self.scale - self.edgeOffset.y

    return x, y
end

function camera:worldToScreen(x, y)
    x = (x + self.edgeOffset.x) * self.scale
    y = (y + self.edgeOffset.y) * self.scale

    return x, y
end

function camera:mousePosition()
    local x, y = love.mouse.getPosition()
    x, y = self:screenToWorld(x, y)

    return x, y
end

function camera:set()
    love.graphics.push()
    love.graphics.translate(-self.x - self._shake.x + self.edgeOffset.x * self.scale, -self.y - self._shake.y + self.edgeOffset.y * self.scale)
    love.graphics.translate(love.graphics.getWidth() * self.pivot.x, love.graphics.getHeight() * self.pivot.y)
    love.graphics.rotate(-self.rotation)
    love.graphics.translate(-love.graphics.getWidth() * self.pivot.x, -love.graphics.getHeight() * self.pivot.y)
    love.graphics.scale(self.scale, self.scale)
end

function camera:unset()
    love.graphics.pop()
end

return camera