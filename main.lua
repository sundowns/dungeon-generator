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
local generation_steps = 30
debug = false

function love.load()
    love.math.setRandomSeed(os.time())
    love.graphics.setBackgroundColor(100,0,0,255)
    dm = DungeonMaster(40,40)
    dm:generate(generation_steps)
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
    love.graphics.setColor(0, 200, 80)
    love.graphics.print("[up] & [down] to change steps: [" .. generation_steps .."]", 10, 10)
    love.graphics.print("[space] to generate dungeon", 10, 30)
    love.graphics.setColor(255,255,255,255)
    -- draw_stage()
    -- player:draw()
end

function love.resize(width, height)
    dm:resize(width, height)
end

function love.keypressed(key)
    if key == "space" then
        dm:generate(generation_steps)
    elseif key == "up" then
        generation_steps = generation_steps + 1
    elseif key == "down" then
        generation_steps = generation_steps - 1
    elseif key == "f1" then
        debug = not debug
    end
end
