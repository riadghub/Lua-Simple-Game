local Map = {}
Map.__index = Map

function Map.new()
    local self = setmetatable({}, Map)

    -- 1. Chargement des textures de sol
    self.tileTextures = {
        love.graphics.newImage("assets/decor/clean-tile.png"),      -- ID 1
        love.graphics.newImage("assets/decor/not-clean-tile.png"),   -- ID 2
        love.graphics.newImage("assets/decor/not-clean-tile-2.png"), -- ID 3
        love.graphics.newImage("assets/decor/not-clean-tile-3.png")  -- ID 4
    }

    -- 2. Chargement des textures de murs (ID 5)
    self.wallTextures = {
        ul = love.graphics.newImage("assets/decor/wall-up-corner-left.png"),
        ur = love.graphics.newImage("assets/decor/wall-up-corner-right.png"),
        um = love.graphics.newImage("assets/decor/wall-up-mid.png"),
        dl = love.graphics.newImage("assets/decor/wall-down-corner-left.png"),
        dr = love.graphics.newImage("assets/decor/wall-down-corner-right.png"),
        dm = love.graphics.newImage("assets/decor/wall-down-mid.png"),
        lm = love.graphics.newImage("assets/decor/wall-left-mid.png"),
        rm = love.graphics.newImage("assets/decor/wall-right-mid.png"),
    }

    self.tileWidth = 32
    self.tileHeight = 32
    self.grid = {}
    local mapWidth = 20
    local mapHeight = 15

    for y = 1, mapHeight do
        self.grid[y] = {}
        for x = 1, mapWidth do
            -- On place des murs (ID 5) sur les bords
            if x == 1 or x == mapWidth or y == 1 or y == mapHeight then
                self.grid[y][x] = 5
            else
                -- Sol aléatoire à l'intérieur
                local rand = love.math.random(1, 10)
                if rand <= 7 then
                    self.grid[y][x] = 1
                else
                    self.grid[y][x] = love.math.random(2, 4)
                end
            end
        end
    end

    return self
end

function Map:isWall(x, y)
	return self.grid[y] and self.grid[y][x] == 5
end

function Map:isFloor(x, y)
	local id = self.grid[y] and self.grid[y][x]
	return id and id >= 1 and id <= 4
end

function Map:getWallTexture(x, y)
    local w, h = #self.grid[1], #self.grid
    if x == 1 and y == 1 then return self.wallTextures.ul end
    if x == w and y == 1 then return self.wallTextures.ur end
    if x == 1 and y == h then return self.wallTextures.dl end
    if x == w and y == h then return self.wallTextures.dr end
    if self:isFloor(x, y + 1) then return self.wallTextures.um end
    if self:isFloor(x, y - 1) then return self.wallTextures.dm end
    if self:isFloor(x + 1, y) then return self.wallTextures.lm end
    if self:isFloor(x - 1, y) then return self.wallTextures.rm end
    return self.wallTextures.um
end

function Map:collides(px, py)
    local gx = math.floor(px / self.tileWidth) + 1
    local gy = math.floor(py / self.tileHeight) + 1
    return self:isWall(gx, gy)
end

function Map:draw()
    for y = 1, #self.grid do
        for x = 1, #self.grid[y] do
            local tileID = self.grid[y][x]
            local posX = (x - 1) * self.tileWidth
            local posY = (y - 1) * self.tileHeight

            if tileID == 5 then
                -- Si c'est un mur, on calcule quelle texture utiliser
                local tex = self:getWallTexture(x, y)
                love.graphics.draw(tex, posX, posY)
            else
                -- Sinon on dessine le sol (ID 1 à 4)
                local texture = self.tileTextures[tileID]
                love.graphics.draw(texture, posX, posY)
            end
        end
    end
end

return Map