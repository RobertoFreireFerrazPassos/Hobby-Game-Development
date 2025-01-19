local intro = {
    update = function(self, dt)
    end,
    isFinished = function(self)
    end,
    draw = function(self)
    end
}

createIntroScene = function(sceneManager)
    return {
        intro = intro,
        enter = function(self)
        end,
        update = function(self, dt)
        end,
        draw = function(self)
        end,
        keypressed = function(self, key)
        end
    }
end