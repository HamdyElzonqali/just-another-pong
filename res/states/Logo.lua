local gameState = {}

function gameState:enter(...)
    
end

function gameState:exit()
    
end

function gameState:update(dt)
    
end

function gameState:draw()
    love.graphics.printf("Hello, Pong!", 0, VIRTUAL_HEIGHT / 2 - 3, VIRTUAL_WIDTH, "center", 0, 1, 1)
end

return gameState