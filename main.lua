Class = require("libs.class")
vector = require("libs.vector")
HC = require("libs.HC")
require("util")
require("dungeonmaster")
require("roommanager")
require("player")

local dm = nil
local player = nil
world = nil
local tile_size = 32

function love.load()
    love.math.setRandomSeed(os.time())
    love.graphics.setBackgroundColor(100,0,0,255)
    dm = DungeonMaster(40,40)
    dm:generate(love.math.random(20,30))
    -- love.physics.setMeter(tile_size)
    -- world = love.physics.newWorld(0, 9.81*tile_size)
    -- load_room("spawn1.lua", tile_size, tile_size)
    -- player = Player(10, 10)
end

function love.update(dt)
    dm:update(dt)
    -- player:processInput(dt)
    -- player:update(dt)
end

function love.draw()
    dm:drawDungeon()
    -- draw_stage()
    -- player:draw()
end

function love.keypressed(key)
    if key == "space" then
        dm:generate(love.math.random(20,30))
    end
end
