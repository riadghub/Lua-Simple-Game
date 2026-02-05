local Player = {}
Player.__index = Player

function Player.new(x, y)
	local self = setmetatable({}, Player)
	self.x = x
	self.y = y
	self.speed = 120
	self.size = 20

	self.sprite = love.graphics.newImage("assets/hungry-dino.png")
	local maxDim = math.max(self.sprite:getWidth(), self.sprite:getHeight())
	self.spriteScale = self.size / maxDim
	return self
end

function Player:update(dt, map)
	local moveX, moveY = 0, 0

	if love.keyboard.isDown("w", "up") then moveY = -1 end
	if love.keyboard.isDown("s", "down") then moveY = 1 end
	if love.keyboard.isDown("a", "left") then moveX = -1 end
	if love.keyboard.isDown("d", "right") then moveX = 1 end
	if moveX ~= 0 and moveY ~= 0 then
		moveX = moveX * 0.7071
		moveY = moveY * 0.7071
  	end

	local newX = self.x + moveX * self.speed * dt
	local newY = self.y + moveY * self.speed * dt

	if not map:collides(newX, self.y, self.size) then
    	self.x = newX
  	end
  	if not map:collides(self.x, newY, self.size) then
    	self.y = newY
  	end
end

function Player:draw()
  love.graphics.setColor(1,1,1)
  love.graphics.draw(
    self.sprite,
    self.x,
    self.y,
    0,
    self.spriteScale,
    self.spriteScale,
    self.sprite:getWidth()/2,
    self.sprite:getHeight()/2
  )
end

return Player
