StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine:new()
    local instance = {
        states = {},
        currentState = nil
    }
    setmetatable(instance, StateMachine)
    return instance
end

function StateMachine:registerState(name, state)
    self.states[name] = state
end

function StateMachine:switchState(name, ...)
    if self.currentState and self.currentState.exit then
        self.currentState:exit()
    end
    self.currentState = self.states[name]
    if self.currentState and self.currentState.enter then
        self.currentState:enter(...)
    end
end

function StateMachine:update(dt)
    if self.currentState and self.currentState.update then
        self.currentState:update(dt)
    end
end

function StateMachine:draw()
    if self.currentState and self.currentState.draw then
        self.currentState:draw()
    end
end

function StateMachine:keypressed(key)
    if self.currentState and self.currentState.keypressed then
        self.currentState:keypressed(key)
    end
end

function StateMachine:keyreleased(key)
    if self.currentState and self.currentState.keyreleased then
        self.currentState:keyreleased(key)
    end
end