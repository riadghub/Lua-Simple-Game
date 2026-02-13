local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)

    self.x, self.y = x, y
    self.speed = 140
    self.frameWidth = 32
    self.frameHeight = 32

    self.state = "spawning"
    self.spawnTimer = 0.5
    self.currentScale = 0

    self.direction = "down"
    self.timer = 0
    self.currentFrame = 1
    self.animSpeed = 0.15
    self.hitboxSize = 5

    self.animations = {
        ["down-idle"] = { img = love.graphics.newImage("assets/player/down-idle.png") },
        ["down-move"] = { img = love.graphics.newImage("assets/player/down-move.png") },
        ["down-left-idle"] = { img = love.graphics.newImage("assets/player/down-left-idle.png") },
        ["down-left-move"] = { img = love.graphics.newImage("assets/player/down-left-move.png") },
        ["down-right-idle"] = { img = love.graphics.newImage("assets/player/down-right-idle.png") },
        ["down-right-move"] = { img = love.graphics.newImage("assets/player/down-right-move.png") },
        ["right-idle"] = { img = love.graphics.newImage("assets/player/right-idle.png") },
        ["right-move"] = { img = love.graphics.newImage("assets/player/right-move.png") },
        ["up-idle"] = { img = love.graphics.newImage("assets/player/up-idle.png") },
        ["up-move"] = { img = love.graphics.newImage("assets/player/up-move.png") },
        ["up-left-idle"] = { img = love.graphics.newImage("assets/player/up-left-idle.png") },
        ["up-left-move"] = { img = love.graphics.newImage("assets/player/up-left-move.png") },
        ["up-right-idle"] = { img = love.graphics.newImage("assets/player/up-right-idle.png") },
        ["up-right-move"] = { img = love.graphics.newImage("assets/player/up-right-move.png") },
        ["left-idle"] = { img = love.graphics.newImage("assets/player/left-idle.png") },
        ["left-move"] = { img = love.graphics.newImage("assets/player/left-move.png") },
    }

    for key, data in pairs(self.animations) do
        data.quads = {}
        local count = data.img:getWidth() / self.frameWidth
        for i = 0, count - 1 do
            table.insert(data.quads, love.graphics.newQuad(i*32, 0, 32, 32, data.img:getDimensions()))
        end
    end

    return self
end

function Player:update(dt, map, spawn_p_system)

    if self.state == "spawning" then
        self.spawnTimer = self.spawnTimer - dt

        local progress = 1 - (self.spawnTimer / 0.5)
        self.currentScale = math.max(0, math.min(1, progress))

        if self.spawnTimer <= 0 then
            self.state = "idle"
            self.currentScale = 1

            if spawn_p_system then
                spawn_p_system:setPosition(self.x, self.y)
                spawn_p_system:emit(30)
            end
        end
        return
    end

    local moveX, moveY = 0, 0
    local oldX, oldY = self.x, self.y

    if love.keyboard.isDown("up", "w") then moveY = -1 end
    if love.keyboard.isDown("down", "s") then moveY = 1 end
    if love.keyboard.isDown("left", "a") then moveX = -1 end
    if love.keyboard.isDown("right", "d") then moveX = 1 end

    if moveX ~= 0 or moveY ~= 0 then
        local dirY = (moveY == -1 and "up") or (moveY == 1 and "down") or ""
        local dirX = (moveX == -1 and "left") or (moveX == 1 and "right") or ""
        local newDirection = (dirX ~= "" and dirY ~= "") and (dirY .. "-" .. dirX) or (dirY .. dirX)

        if self.direction ~= newDirection then
            self.direction = newDirection
            self.currentFrame = 1
            self.timer = 0
        end

        local currentSpeed = self.speed
        if moveX ~= 0 and moveY ~= 0 then currentSpeed = self.speed * 0.7071 end

        local nextX = self.x + moveX * currentSpeed * dt
        local nextY = self.y + moveY * currentSpeed * dt

        if not map:collides(nextX - self.hitboxSize, self.y) and
           not map:collides(nextX + self.hitboxSize, self.y) then
            self.x = nextX
        end
        if not map:collides(self.x, nextY - self.hitboxSize) and
           not map:collides(self.x, nextY + self.hitboxSize) then
            self.y = nextY
        end
    end

    local hasMoved = (math.abs(self.x - oldX) > 0.01) or (math.abs(self.y - oldY) > 0.01)
    local newState = hasMoved and "move" or "idle"

    if self.state ~= newState then
        self.state = newState
        self.currentFrame = 1
        self.timer = 0
    end

    local animKey = self.direction .. "-" .. self.state
    local anim = self.animations[animKey] or self.animations["down-idle"]

    if anim then
        self.timer = self.timer + dt
        if self.timer >= self.animSpeed then
            self.timer = 0
            self.currentFrame = (self.currentFrame % #anim.quads) + 1
        end
    end
end

function Player:draw()
    local animKey = (self.state == "spawning") and "down-idle" or (self.direction .. "-" .. self.state)
    local anim = self.animations[animKey] or self.animations["down-idle"]
    local frameIndex = math.min(self.currentFrame, #anim.quads)

    love.graphics.draw(
        anim.img,
        anim.quads[frameIndex],
        math.floor(self.x),
        math.floor(self.y),
        0, 
        self.currentScale, self.currentScale,
        16, 16
    )
end

function Player:reset(x, y)
    self.x, self.y = x, y
    self.state = "spawning"
    self.spawnTimer = 0.5
    self.currentScale = 0
    self.direction = "down"
end

return Player