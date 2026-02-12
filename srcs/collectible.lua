local Collectible = {}
Collectible.__index = Collectible

function Collectible.new(x, y)
    local self = setmetatable({}, Collectible)
    self.x = x
    self.y = y
    self.size = 16
    self.image = love.graphics.newImage("assets/collectible/collectible.png")

    self.baseY = y
    self.timer = math.random(0, 5)
    return self
end

function Collectible:update(dt)

    self.timer = self.timer + dt
    self.y = self.baseY + math.sin(self.timer * 3) * 4
end

function Collectible:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, 8, 8)
end

return Collectible