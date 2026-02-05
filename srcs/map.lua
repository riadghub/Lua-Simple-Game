local Map = {}
Map.__index = Map

function Map.new()
	local self = setmetatable({}, Map)

	self.tiles = {
		{1,1,1,1,1,1,1,1,1,1},
		{1,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,1,1,0,0,0,1},
		{1,0,0,0,0,0,0,1,0,1},
		{1,0,1,1,0,0,0,1,0,1},
		{1,0,0,1,0,0,0,0,0,1},
		{1,0,0,0,0,1,1,0,0,1},
		{1,0,0,0,0,0,0,0,0,1},
		{1,1,1,1,1,1,1,1,1,1},
	}
	self.tileSize = 32
	self.treeImage = love.graphics.newImage("assets/tree.png")
	self.treeScaleX = self.tileSize / self.treeImage:getWidth()
	self.treeScaleY = self.tileSize / self.treeImage:getHeight()
	return self
end

function Map:draw()
	for y = 1, #self.tiles do
		for x = 1, #self.tiles[y] do
			local tile = self.tiles[y][x]
			local drawX = (x - 1) * self.tileSize
			local drawY = (y - 1) * self.tileSize

			if tile == 1 then
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(
					self.treeImage,
					drawX,
					drawY,
					0,
					self.treeScaleX,
					self.treeScaleY
				)
			end
		end
	end

	love.graphics.setColor(1, 1, 1)
end

function Map:collides(px, py, size)
	local half = size / 2
	local left = px - half
	local right = px + half
	local top = py - half
	local bottom = py + half

	local tileSize = self.tileSize

	local function tileAt(px, py)
		local tx = math.floor(px / tileSize) + 1
		local ty = math.floor(py / tileSize) + 1
		return self.tiles[ty] and self.tiles[ty][tx]
	end

	return
		tileAt(left, top) == 1 or
		tileAt(right, top) == 1 or
		tileAt(left, bottom) == 1 or
		tileAt(right, bottom) == 1
end

return Map