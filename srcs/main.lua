local p_system
local spawn_p_system
local death_p_system
local Player = require("player")
local Enemy = require("enemy")
local Map = require("map")
local Collectibles = require("collectible")

local enemy
local score = 0
local highScore = 0
local collectibles = {}
local zoom = 2
local stars = {}
local floatingTexts = {}
local streak = 0
local streakTimer = 0
local gameTimer = 60
local streakDuration = 3
local gameState = "start"
local deathTimer = 0
local shakeTime = 0
local shakeMagnitude = 0

local function loadHighScore()
    if love.filesystem.getInfo("highscore.txt") then
        local content = love.filesystem.read("highscore.txt")
        highScore = tonumber(content) or 0
    end
end

local function saveHighScore(newScore)
    if newScore > highScore then
        highScore = newScore
        love.filesystem.write("highscore.txt", tostring(highScore))
    end
end

local function spawnCollectible()
    local rx, ry
    local isSafe = false
    local margin = 16
    while not isSafe do
        rx = math.random(32, (20 - 1) * 32)
        ry = math.random(32, (15 - 1) * 32)
        if not map:collides(rx - margin, ry - margin) and
           not map:collides(rx + margin, ry - margin) and
           not map:collides(rx - margin, ry + margin) and
           not map:collides(rx + margin, ry + margin) then
            isSafe = true
        end
    end
    table.insert(collectibles, Collectibles.new(rx, ry))
end

local function resetGameData()
    score = 0
    gameTimer = 60
    streak = 0
    streakTimer = 0
    collectibles = {}
    floatingTexts = {}
    enemy.x, enemy.y = 500, 400
    for i = 1, 5 do spawnCollectible() end
end

local function getStreakColor(s)
    if s < 3  then return {1, 1, 1} end
    if s < 6  then return {1, 1, 0} end
    if s < 10 then return {1, 0.5, 0} end
    return {0, 1, 1}
end

function love.load()
    math.randomseed(os.time())
    loadHighScore()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Lua Meow Spaceship")
    love.graphics.setBackgroundColor(0.02, 0.02, 0.05)

    local imgData = love.image.newImageData(2, 2)
    imgData:mapPixel(function() return 1, 1, 1, 1 end)
    local p_tex = love.graphics.newImage(imgData)

    p_system = love.graphics.newParticleSystem(p_tex, 1000)
    p_system:setParticleLifetime(0.5, 1)
    p_system:setEmissionRate(0)
    p_system:setSpeed(50, 100)
    p_system:setSpread(math.pi * 2)
    p_system:setColors(1, 1, 0, 1, 1, 0.5, 0, 0)

    spawn_p_system = love.graphics.newParticleSystem(p_tex, 500)
    spawn_p_system:setParticleLifetime(0.3, 0.6)
    spawn_p_system:setSpeed(150, 250)
    spawn_p_system:setSpread(math.pi * 2)
    spawn_p_system:setLinearAcceleration(-20, -20, 20, 20)
    spawn_p_system:setLinearDamping(5)
    spawn_p_system:setColors(1, 1, 1, 1,  0, 1, 1, 1,  0, 0, 1, 0)

    death_p_system = love.graphics.newParticleSystem(p_tex, 1000)
    death_p_system:setParticleLifetime(0.5, 1.2)
    death_p_system:setSpeed(200, 400)
    death_p_system:setSpread(math.pi * 2)
    death_p_system:setLinearDamping(5)
    death_p_system:setSizes(2, 4, 0)
    death_p_system:setColors(1, 1, 0, 1,  1, 0.5, 0, 1,  1, 0, 0, 0.8,  0.2, 0.2, 0.2, 0)

    map = Map.new()
    player = Player.new(64, 64)
    enemy = Enemy.new(500, 400)

    for i = 1, 100 do
        table.insert(stars, { x = math.random(0, love.graphics.getWidth()), y = math.random(0, love.graphics.getHeight()) })
    end
    for i = 1, 5 do spawnCollectible() end
end

function love.update(dt)
    p_system:update(dt)
    spawn_p_system:update(dt)
    death_p_system:update(dt)

    if shakeTime > 0 then shakeTime = shakeTime - dt end

    if gameState == "dying" then
        deathTimer = deathTimer - dt
        if deathTimer <= 0 then
            gameState = "gameover"
        end
    end

    if gameState == "playing" then
        gameTimer = gameTimer - dt
        if gameTimer <= 0 then
            gameTimer = 0
            gameState = "gameover"
            saveHighScore(score)
        end

        player:update(dt, map, spawn_p_system)
        enemy:update(dt, player, map)

        local distEnemy = math.sqrt((player.x - enemy.x)^2 + (player.y - enemy.y)^2)
        if distEnemy < 15 then 
            gameState = "dying"
            deathTimer = 1.5
            saveHighScore(score)
            death_p_system:setPosition(player.x, player.y)
            death_p_system:emit(100)
            shakeTime = 0.5
            shakeMagnitude = 8
        end

        if streakTimer > 0 then
            streakTimer = streakTimer - dt
            if streakTimer <= 0 then streak = 0 end
        end

        for i = #floatingTexts, 1, -1 do
            local t = floatingTexts[i]
            t.y = t.y - 40 * dt
            t.alpha = t.alpha - 2 * dt
            if t.alpha <= 0 then table.remove(floatingTexts, i) end
        end

        if #collectibles < 5 then spawnCollectible() end

        for i = #collectibles, 1, -1 do
            local c = collectibles[i]
            c:update(dt)
            local dist = math.sqrt((player.x - c.x)^2 + (player.y - c.y)^2)
            if dist < 15 then
                streak = streak + 1
                streakTimer = streakDuration
                local points = 10 * streak
                score = score + points
                p_system:setPosition(c.x, c.y)
                p_system:emit(20)
                table.insert(floatingTexts, { x = c.x, y = c.y, val = "+" .. points, alpha = 1, color = getStreakColor(streak) })
                table.remove(collectibles, i)
            end
        end
    end
end

function love.keypressed(key)
    if gameState == "start" and (key == "return" or key == "kpenter") then
        gameState = "playing"
        player:reset(64, 64)
    elseif gameState == "gameover" then
        if key == "r" then
            resetGameData()
            gameState = "playing"
            player:reset(64, 64)
        elseif key == "m" then
            resetGameData()
            gameState = "start"
        end
    end
end

function love.draw()
    local targetX = (love.graphics.getWidth() / 2) / zoom - player.x
    local targetY = (love.graphics.getHeight() / 2) / zoom - player.y
    local camX, camY = math.floor(targetX), math.floor(targetY)

    if shakeTime > 0 then
        camX = camX + math.random(-shakeMagnitude, shakeMagnitude)
        camY = camY + math.random(-shakeMagnitude, shakeMagnitude)
    end

    love.graphics.setColor(1, 1, 1, 1)
    for _, star in ipairs(stars) do
        local px = math.floor((star.x + camX * 0.1) % love.graphics.getWidth())
        local py = math.floor((star.y + camY * 0.1) % love.graphics.getHeight())
        love.graphics.points(px, py)
    end

    if gameState == "start" then

        local titleY = love.graphics.getHeight()/2 - 100 + math.sin(love.timer.getTime() * 2) * 10
        local titleWidth = love.graphics.getWidth() / 2

        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.printf("LUA MEOW SPACESHIP", 3, titleY + 3, titleWidth, "center", 0, 2, 2)
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.printf("LUA MEOW SPACESHIP", 0, titleY, titleWidth, "center", 0, 2, 2)

        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.printf("MEILLEUR SCORE : " .. highScore, 0, titleY + 130, love.graphics.getWidth(), "center")

        local pulse = math.abs(math.sin(love.timer.getTime() * 3))
        love.graphics.setColor(1, 1, 1, pulse)
        love.graphics.printf("APPUYEZ SUR [ENTRÉE] POUR COMMENCER", 0, love.graphics.getHeight()/2 + 60, love.graphics.getWidth(), "center")

        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.printf("Z,Q,S,D pour bouger - Évitez le chien alien !", 0, love.graphics.getHeight() - 40, love.graphics.getWidth(), "center")

    else
        love.graphics.push()
        love.graphics.scale(zoom, zoom)
        love.graphics.translate(camX, camY)
            map:draw()
            love.graphics.draw(p_system, 0, 0)
            love.graphics.draw(spawn_p_system, 0, 0)
            love.graphics.draw(death_p_system, 0, 0)
            for _, c in ipairs(collectibles) do c:draw() end
            for _, t in ipairs(floatingTexts) do
                love.graphics.setColor(t.color[1], t.color[2], t.color[3], t.alpha)
                love.graphics.print(t.val, t.x - 10, t.y)
            end
            if gameState == "playing" then
                love.graphics.setColor(1, 1, 1)
                player:draw()
            end
            enemy:draw()
        love.graphics.pop()

        love.graphics.setColor(1, 1, 1)
        love.graphics.print("SCORE: " .. score, 20, 20, 0, 1.2, 1.2)
        love.graphics.print("TEMPS: " .. math.ceil(gameTimer) .. "s", love.graphics.getWidth() - 150, 20, 0, 1.2, 1.2)

        if streak > 1 and gameState == "playing" then
            local color = getStreakColor(streak)
            love.graphics.setColor(color[1], color[2], color[3])
            love.graphics.print("COMBO X" .. streak, 20, 50, 0, 1.5, 1.5)
            love.graphics.rectangle("line", 20, 80, 100, 6)
            love.graphics.rectangle("fill", 20, 80, (streakTimer / streakDuration) * 100, 6)
        end

        if gameState == "gameover" then
            love.graphics.setColor(0, 0, 0, 0.8)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1, 1, 0)
            love.graphics.printf("MISSION TERMINÉE", 0, love.graphics.getHeight()/2 - 100, love.graphics.getWidth() / 2, "center", 0, 2, 2)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("SCORE FINAL : " .. score, 0, love.graphics.getHeight()/2 - 10, love.graphics.getWidth() / 1.5, "center", 0, 1.5, 1.5)
            love.graphics.setColor(0, 1, 1)
            love.graphics.printf("MEILLEUR SCORE : " .. highScore, 0, love.graphics.getHeight()/2 + 40, love.graphics.getWidth(), "center")
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Appuyez sur [R] pour relancer\n\nAppuyez sur [M] pour le Menu", 0, love.graphics.getHeight() - 80, love.graphics.getWidth(), "center")
        end
    end
end