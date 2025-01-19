GameOverState = {}
GameOverState.__index = GameOverState

function GameOverState:new(game)
    local state = { game = game }
    setmetatable(state, self)
    return state
end

function GameOverState:draw()
end

function GameOverState:keypressed(key)
end