Slime = {}
Slime.__index = Slime
setmetatable(Slime,Entity)

function Slime.new(x, y, speed)
    local instance = setmetatable({},Slime)
    instance.direction = "down"
    instance:configureProperties(x, y, speed)
    instance:configureCollisionBox({ x = 10, y = 16, w = 12, h = 8}, true)
    instance:configureAnimations(
        32, 
        32,
        2,
        spriteSheets.slime, 
        { 
            {
                name = "idle_down",
                columnRange = '1-4',
                rowRange = 1,
                duration = 0.2
            },
            {
                name = "idle_right",
                columnRange = '1-4',
                rowRange = 2,
                duration = 0.2
            },
            {
                name = "idle_up",
                columnRange = '1-4',
                rowRange = 3,
                duration = 0.2
            },
            {
                name = "mov_down",
                columnRange = '1-6',
                rowRange = 4,
                duration = 0.2
            },
            {
                name = "mov_right",
                columnRange = '1-6',
                rowRange = 5,
                duration = 0.2
            },
            {
                name = "mov_up",
                columnRange = '1-6',
                rowRange = 6,
                duration = 0.2
            },
        },
        "idle_down")
    return instance
end

function Slime:draw()
    -- TO DO 
    -- Remove { PlayerRef } in self:rayCast2D(rayStart, rayEnd, { PlayerRef }, 5)
    -- It should test if there are walls between rayStart and rayEnd

    self.animations[self.currentAnimation]:draw(self.spriteSheet, self.x, self.y, 0, self.scale, self.scale)

    local x, y = self:GetCenterBox()
    local px, py = PlayerRef:GetCenterBox()
    local rayStart = {x = x, y = y}
    local rayEnd = {x = px, y = py}
    local hit = self:rayCast2D(rayStart, rayEnd, { PlayerRef }, 5)

    love.graphics.setColor(1, 1, 1)
    love.graphics.line(rayStart.x, rayStart.y, rayEnd.x, rayEnd.y)

    -- Draw hit point
    if hit then
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", hit.x, hit.y, 10)
    end

    love.graphics.setColor(1, 1, 1) -- Reset color
end

function Slime:update(dt)
    self:move(0, 0, dt)
end