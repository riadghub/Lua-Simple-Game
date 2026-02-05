local Player = require("player")
local Map = require("map")

function love.load()
	love.window.setTitle("Lua Simple Game")
	love.graphics.setBackgroundColor(0.85, 1, 0.85)

	map = Map.new()
	player = Player.new(64, 64)
end

function love.update(dt)
	player:update(dt, map)
end

function love.draw()

  local camX = love.graphics.getWidth() / 2 - player.x
  local camY = love.graphics.getHeight() / 2 - player.y
  love.graphics.push()
  love.graphics.translate(camX, camY)
  map:draw()
  player:draw()
  love.graphics.pop()
  love.graphics.print("Arrows / WASD to move", 10, 10)
end