local game = {
}

function game:load()
    self.stateManager = StateMachine:new()
    self.stateManager:registerState("playing", PlayingState:new(self))
    self.stateManager:registerState("gameover", GameOverState:new(self))

    self.stateManager:switchState("playing")
end

function game:update(dt)
    self.stateManager:update(dt)
end

function game:draw()
    self.stateManager:draw()
end

function game:keypressed(key)
    self.stateManager:keypressed(key)
end

createGameScene = function(sceneManager)
    return {
        game = game,
        enter = function(self)
            game:load()
        end,
        update = function(self, dt)
            game:update(dt)
        end,
        draw = function(self)
            game:draw()
        end,
        keypressed = function(self, key)
            game:keypressed(key)
        end
    }
end