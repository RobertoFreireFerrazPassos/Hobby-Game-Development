Entity = {}
Entity.__index = Entity

function Entity:configureProperties(x, y, speed)
    self.x = x
    self.y = y
    self.speed = speed
end

function Entity:configureCollisionBox(box, isCollidable)
    self.box = box
    self.isCollidable = isCollidable
end

function Entity:configureAnimations(frameWidth, frameHeight, scale, spriteSheet, animations, currentAnimation)
    self.frameHeight = frameHeight
    self.scale = scale
    local grid =  libraries.anim8.newGrid(frameWidth, frameHeight, spriteSheet:getWidth(), spriteSheet:getHeight())
    self.animations = {}
    self.spriteSheet = spriteSheet
    self.currentAnimation = currentAnimation
    for _, animation in pairs(animations) do
        self.animations[animation.name] = libraries.anim8.newAnimation(grid(animation.columnRange,animation.rowRange), animation.duration, animation.onLoop)
    end
end

function Entity:getXY(dx, dy, dt)
    local magnitude = math.sqrt(dx^2 + dy^2)
    if magnitude > 0 then
        dx, dy = (dx / magnitude), (dy / magnitude)
    end

    dx = dx * self.speed * dt
    dy = dy * self.speed * dt

    return dx,dy
end

function Entity:move(dx, dy, dt)
    self.x = self.x + dx
    self.y = self.y + dy
    self.animations[self.currentAnimation]:update(dt)
end

function Entity:GetCenterBox()
    return self.x + self.box.x * self.scale + (self.box.w * self.scale)/2, self.y + self.box.y * self.scale + (self.box.h * self.scale)/2
end

function Entity:collidesWith(other, dx, dy)
    local selfLeft = self.x + dx + self.box.x * self.scale
    local selfRight = self.x + dx + self.box.x * self.scale + self.box.w * self.scale
    local selfTop = self.y + dy + self.box.y * self.scale
    local selfBottom = self.y + dy + self.box.y * self.scale + self.box.h * self.scale

    local otherLeft = other.x + other.box.x * other.scale
    local otherRight = other.x + other.box.x * other.scale + other.box.w  * other.scale
    local otherTop = other.y + other.box.y * other.scale
    local otherBottom = other.y + other.box.y * other.scale + other.box.h  * other.scale

    return selfRight > otherLeft and
           selfLeft < otherRight and
           selfBottom > otherTop and
           selfTop < otherBottom
end

function Entity:rayCast2D(from, to, objects, numSteps)
    local closestHit = nil
    local closestDistance = math.huge

    -- Calculate the direction vector and total distance
    local dx, dy = to.x - from.x, to.y - from.y
    local distance = ((dx)^2 + (dy)^2)^0.5

    -- Normalize direction vector
    local nx, ny = dx / distance, dy / distance

    -- Iterate through the line in equal steps
    for i = 0, numSteps do
        local t = i / numSteps
        local stepX = from.x + nx * t * distance
        local stepY = from.y + ny * t * distance

        -- Create a temporary entity for the current step
        local rayEntity = {
            x = stepX,
            y = stepY,
            box = {x = 0, y = 0, w = 1, h = 1}, -- Small box to represent the ray point
            scale = 1
        }

        for _, object in ipairs(objects) do
            if object.box and object.collidesWith and self ~= object and object.isCollidable then
                if object:collidesWith(rayEntity, 0, 0) then
                    local stepDistance = ((from.x - stepX)^2 + (from.y - stepY)^2)^0.5
                    if stepDistance < closestDistance then
                        closestDistance = stepDistance
                        closestHit = {x = stepX, y = stepY, object = object}
                    end
                end
            end
        end

        -- If a hit is found, stop further checks
        if closestHit then
            break
        end
    end

    return closestHit -- Returns the closest intersection point or nil if no collision
end

function Entity:draw()
    self.animations[self.currentAnimation]:draw(self.spriteSheet, self.x, self.y, 0, self.scale, self.scale)
    --love.graphics.rectangle("fill", self.x + self.box.x*self.scale, self.y + self.box.y*self.scale, self.box.w*self.scale, self.box.h*self.scale)
end