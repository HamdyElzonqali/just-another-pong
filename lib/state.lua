-- a state is just a table with enter, exit, update, and draw functions
local emptyState = {
    enter   = function(self, ...)   end,
    exit    = function(self)        end,
    update  = function(self, dt)    end,
    draw    = function(self)        end
}

state = {
    current = emptyState,
    states = {
        ['empty'] = emptyState,
    },
}

function state:add(name, state)
    self.states[name] = state
end

function state:switch(newState, ...)
    if self.states[newState] then
        if self.current.exit then
            self.current:exit()
        end

        self.current = self.states[newState]
        
        if self.current.enter then 
            self.current:enter(...)
        end
    else
        error("State '" .. newState .. "' does not exist.")
    end
end

function state:update(dt)
    if self.current.update then
        self.current:update(dt)
    end
end

function state:draw()
    if self.current.draw then
        self.current:draw()
    end
end

return state