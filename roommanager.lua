STI = require 'libs.sti'
local stage_file = nil
stage = nil
local TILE_WIDTH = nil
local TILE_HEIGHT = nil


function load_room(mapname, tile_width, tile_height)
    TILE_WIDTH = tile_width
    TILE_HEIGHT = tile_height
    stage_file = mapname
    if not love.filesystem.exists("assets/rooms/"..stage_file) then
        assert(false, "Room file does not exist " .. stage_file)
    end
    local ok = false
    if pcall(STI.new, "assets/rooms/"..stage_file) then
        stage = STI.new("assets/rooms/"..stage_file, { "box2d" })
        stage:resize(stage.width,  stage.height)
        stage:box2d_init(world)
        print("Loaded "..stage_file.." map succesfully")
    else
        assert(false, "Failed to load room. File is incorrect format or corrupt: " .. stage_file)
    end
end


function draw_stage()
  if stage == nil then return end

  stage:setDrawRange(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  stage:drawLayer(stage.layers["Ground"])

  love.graphics.setColor(255, 0, 0, 255)
  stage:box2d_draw()

  love.graphics.setColor(255, 255, 255, 255)
end
