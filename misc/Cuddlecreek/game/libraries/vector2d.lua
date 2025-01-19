local function rotate(vector, angleRadians)
    local cosTheta = math.cos(angleRadians)
    local sinTheta = math.sin(angleRadians)
    return {x = vector.x * cosTheta - vector.y * sinTheta, y = vector.x * sinTheta + vector.y * cosTheta}
end

function directionToAngle(direction)
    local angles = {
        down = 0,               -- 0 degrees
        left = math.pi / 2,    -- 90 degrees
        up = math.pi,           -- 180 degrees
        right = 3 * math.pi / 2  -- 270 degrees
    }

    return angles[direction] -- return angle in radians
end

return {
	rotate = rotate,
    directionToAngle = directionToAngle
}