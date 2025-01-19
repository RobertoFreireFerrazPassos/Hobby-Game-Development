function gameStart()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(640, 480, { resizable = false })
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    pixelFont = love.graphics.newFont("fonts/slkscreb.ttf", 16)
    love.graphics.setFont(pixelFont)

    libraries = {
        anim8 = require 'libraries/anim8',
        timer = require 'libraries/timer',
        vector2d = require 'libraries/vector2d',
        sti = require 'libraries/sti',
        wf = require 'libraries/windfield'
    }

    spriteSheets = {
        player = love.graphics.newImage('sprites/player.png'),
        slime = love.graphics.newImage('sprites/slime.png'),
    }

    require 'src/objects/entity'
    require 'src/objects/player'
    require 'src/objects/slime'

    require "src/utils/controls"    
    require "src/utils/statemachine"
    require "src/scenes/gamestates/playingstate"
    require "src/scenes/gamestates/gameoverstate"

    sceneManager = StateMachine:new()

    require "src/scenes/introscene"
    require "src/scenes/menuscene"
    require "src/scenes/gamescene"
    
    sceneManager:registerState("intro", createIntroScene(sceneManager))
    sceneManager:registerState("menu", createMenuScene(sceneManager))
    sceneManager:registerState("game", createGameScene(sceneManager))
    sceneManager:switchState("game")
end
