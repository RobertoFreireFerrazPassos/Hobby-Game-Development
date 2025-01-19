PlayingState = {}
PlayingState.__index = PlayingState

entities = {}
PlayerRef = {}
gameMap = {}
world = {}

function PlayingState:new(game)
    local state = { game = game }
    setmetatable(state, self)
    return state
end

function PlayingState:enter()
    gameMap = libraries.sti("maps/world.lua")
    world = libraries.wf.newWorld(0,0)

    PlayerRef = Player.new(100, 50, 120)
    table.insert(entities, PlayerRef)
    table.insert(entities, Slime.new(220,200,120))
end

function PlayingState:update(dt)
    libraries.timer.update(dt)
    world:update(dt)
    for _, entity in pairs(entities) do
        entity:update(dt)
    end
end

function PlayingState:draw()
    gameMap:draw()
    world:draw()
    table.sort(entities, function(a, b)
        return a.y + a.frameHeight*a.scale < b.y + b.frameHeight*b.scale
    end)

    for _, entity in pairs(entities) do
        entity:draw()
    end
end

function PlayingState:keypressed(key)
end
