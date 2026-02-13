local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y)
    local self = setmetatable({}, Enemy)

    self.x, self.y = x, y
    self.speed = 90
    self.frameWidth, self.frameHeight = 32, 32
    self.hitboxSize = 5

    self.state = "move"
    self.direction = "down"
    self.timer = 0
    self.currentFrame = 1
    self.animSpeed = 0.15

    self.animations = {
        ["down-idle"] = { img = love.graphics.newImage("assets/enemy/down-idle.png") },
        ["down-move"] = { img = love.graphics.newImage("assets/enemy/down-move.png") },
        ["down-left-idle"] = { img = love.graphics.newImage("assets/enemy/down-left-idle.png") },
        ["down-left-move"] = { img = love.graphics.newImage("assets/enemy/down-left-move.png") },
        ["down-right-idle"] = { img = love.graphics.newImage("assets/enemy/down-right-idle.png") },
        ["down-right-move"] = { img = love.graphics.newImage("assets/enemy/down-right-move.png") },
        ["right-idle"] = { img = love.graphics.newImage("assets/enemy/right-idle.png") },
        ["right-move"] = { img = love.graphics.newImage("assets/enemy/right-move.png") },
        ["up-idle"] = { img = love.graphics.newImage("assets/enemy/up-idle.png") },
        ["up-move"] = { img = love.graphics.newImage("assets/enemy/up-move.png") },
        ["up-left-idle"] = { img = love.graphics.newImage("assets/enemy/up-left-idle.png") },
        ["up-left-move"] = { img = love.graphics.newImage("assets/enemy/up-left-move.png") },
        ["up-right-idle"] = { img = love.graphics.newImage("assets/enemy/up-right-idle.png") },
        ["up-right-move"] = { img = love.graphics.newImage("assets/enemy/up-right-move.png") },
        ["left-idle"] = { img = love.graphics.newImage("assets/enemy/left-idle.png") },
        ["left-move"] = { img = love.graphics.newImage("assets/enemy/left-move.png") },
    }

    for _, data in pairs(self.animations) do
        data.quads = {}
        local count = data.img:getWidth() / self.frameWidth
        for i = 0, count - 1 do
            table.insert(data.quads, love.graphics.newQuad(i*32, 0, 32, 32, data.img:getDimensions()))
        end
    end

    return self
end

function Enemy:update(dt, player, map)
    local dx = player.x - self.x
    local dy = player.y - self.y
    local distance = math.sqrt(dx*dx + dy*dy)

    if distance > 5 then
        self.state = "move"

        local vx = (dx / distance) * self.speed
        local vy = (dy / distance) * self.speed


        local dirY = (vy < -20 and "up") or (vy > 20 and "down") or ""
        local dirX = (vx < -20 and "left") or (vx > 20 and "right") or ""

        local newDir = ""
        if dirX ~= "" and dirY ~= "" then newDir = dirY .. "-" .. dirX
        elseif dirX ~= "" or dirY ~= "" then newDir = dirY .. dirX
        end

        if newDir ~= "" and self.direction ~= newDir then
            self.direction = newDir
            self.currentFrame = 1
        end

        local nextX = self.x + vx * dt
        local nextY = self.y + vy * dt

        if not map:collides(nextX - self.hitboxSize, self.y) and not map:collides(nextX + self.hitboxSize, self.y) then
            self.x = nextX
        end
        if not map:collides(self.x, nextY - self.hitboxSize) and not map:collides(self.x, nextY + self.hitboxSize) then
            self.y = nextY
        end
    else
        self.state = "idle"
    end

    local animKey = self.direction .. "-" .. self.state
    local anim = self.animations[animKey] or self.animations["down-idle"]

    self.timer = self.timer + dt
    if self.timer >= self.animSpeed then
        self.timer = 0
        self.currentFrame = (self.currentFrame % #anim.quads) + 1
    end
end

function Enemy:draw()
    local animKey = self.direction .. "-" .. self.state
    local anim = self.animations[animKey] or self.animations["down-idle"]
    local frameIndex = math.min(self.currentFrame, #anim.quads)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        anim.img,
        anim.quads[frameIndex],
        math.floor(self.x),
        math.floor(self.y),
        0, 1, 1,
        16, 16
    )
end

return Enemy