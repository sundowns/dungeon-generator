Class = require("libs.class")
vector = require("libs.vector")
HC = require("libs.HC")
require("roommanager")
require("player")

local player = nil
world = nil
local tile_size = 32


function love.load()
    love.physics.setMeter(tile_size)
    world = love.physics.newWorld(0, 9.81*tile_size)
    load_room("spawn1.lua", tile_size, tile_size)
    player = Player(10, 10)
end

function love.update(dt)
    player:processInput(dt)
    player:update(dt)
end

function love.draw()
    draw_stage()
    player:draw()
end
