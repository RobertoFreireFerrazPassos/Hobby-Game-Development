Player = {}
Player.__index = Player
setmetatable(Player,Entity)

function Player.new(x, y, speed)
    local instance = setmetatable({},Player)
    instance.direction = "down"
    instance.isAttacking = false
    instance.collider = world:newBSGRectangleCollider(400,250,40,80,14)
    instance:configureProperties(x, y, speed)
    instance:configureCollisionBox({ x = 16, y = 28, w = 16, h = 16}, true)
    instance:configureAnimations(
        48, 
        48,
        2,
        spriteSheets.player, 
        { 
            {
                name = "idle_down",
                columnRange = '1-6',
                rowRange = 1,
                duration = 0.2
            },
            {
                name = "idle_right",
                columnRange = '1-6',
                rowRange = 2,
                duration = 0.2
            },
            {
                name = "idle_up",
                columnRange = '1-6',
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
            {
                name = "attack_down",
                columnRange = '1-4',
                rowRange = 7,
                duration = 0.2,
                onLoop = 'pauseAtStart'
            },
            {
                name = "attack_right",
                columnRange = '1-4',
                rowRange = 8,
                duration = 0.2,
                onLoop = 'pauseAtStart'
            },
            {
                name = "attack_up",
                columnRange = '1-4',
                rowRange = 9,
                duration = 0.2,
                onLoop = 'pauseAtStart'
            },
        },
        "idle_down")
    return instance
end

function Player:update(dt)
    local dx, dy = self:handleMove()
    self:handleAttack()
    self:updateAnimation(dx, dy, dt)       
    dx,dy = self:getXY(dx, dy, dt)
    dx,dy = self:detectCollision(dx, dy)
    self:move(dx, dy, dt)
end

function Player:detectCollision(dx, dy)
    if dx ~= 0 then
        local collidesX = false
        for _, entity in pairs(entities) do
            if self ~= entity and entity.isCollidable and self:collidesWith(entity, dx, 0) then
                collidesX = true
                break
            end
        end

        if collidesX then
            dx = 0
        end
    end

    if dy ~= 0 then
        local collidesY = false
        for _, entity in pairs(entities) do
            if self ~= entity and entity.isCollidable and self:collidesWith(entity, 0, dy) then
                collidesY = true
                break
            end
        end

        if collidesY then
            dy = 0
        end
    end

    return dx, dy
end

function Player:updateAnimation(dx, dy)
    self.animations[self.currentAnimation].flippedH = false
    local currentAnimation = "mov_"

    if dx == 0 and dy == 0 then
        currentAnimation = "idle_"
    end

    if self.isAttacking then
        currentAnimation = "attack_"
    end

    if self.direction == "left" then
        currentAnimation = currentAnimation .. "right"       
        self.animations[self.currentAnimation].flippedH = true
    else
        currentAnimation = currentAnimation .. self.direction
    end

    self.currentAnimation = currentAnimation
end

function Player:handleMove()
    local dx, dy = 0, 0

    if self.isAttacking then
        return dx, dy
    end

    if love.keyboard.isDown(controls.up) or love.keyboard.isDown(controls.left_analog_up) then 
        self.direction = "up"
        dy = -1 
    end
    if love.keyboard.isDown(controls.down) or love.keyboard.isDown(controls.left_analog_down)  then
        self.direction = "down"
        dy = 1 
    end
    if love.keyboard.isDown(controls.left) or love.keyboard.isDown(controls.left_analog_left)  then
        self.direction = "left"
        dx = -1
    end
    if love.keyboard.isDown(controls.right) or love.keyboard.isDown(controls.left_analog_right)  then
        self.direction = "right"
        dx = 1 
    end

    return dx, dy
end

function Player:handleAttack()
    if self.isAttacking and self.animations[self.currentAnimation].status == 'paused' then
        self.isAttacking = false
    end

    if not self.isAttacking and love.keyboard.isDown(controls.a) then
        self.isAttacking = true
        self.animations[self.currentAnimation]:resume()
    end
end