DungeonMaster = Class {
    init = function(self, width, height)
        local templates = love.filesystem.load("templates/rooms.lua", "Failed to load room templates")
        self.templates = templates() -- invoke template file
        self.width = width
        self.height = height
        self.grid_width = love.graphics.getWidth()/width
        self.grid_height = love.graphics.getHeight()/height
        self.origin = vector(0,0)
        self:generate(5)
    end;
    generate = function(self, steps)
        self.world = {}
        for i=1, self.width do
            self.world[i] = {}
            for j=1, self.height do
                self.world[i][j] = GridTile(i,j)
            end
        end
        self.currentTile = self.world[love.math.random(self.width/4,self.width-1)][love.math.random(self.height/4,self.height/2-1)]
        self.currentTile:allocate(self.templates['spawn'])
        for i=1,steps do
            local tile_placed = false
            local tries = 0
            local too_many_tries = false
            while not tile_placed and not too_many_tries do
                tries = tries + 1
                local decided = false
                local direction = self:decideWeightedRandom(self.currentTile.template:getOpenings())
                if direction == 'top' then
                    decided = self:selectTile(self.currentTile.x, self.currentTile.y - 1)
                elseif direction == 'right' then
                    decided = self:selectTile(self.currentTile.x + 1, self.currentTile.y)
                elseif direction == 'bottom' then
                    decided = self:selectTile(self.currentTile.x, self.currentTile.y + 1)
                elseif direction == 'left' then
                    decided = self:selectTile(self.currentTile.x - 1, self.currentTile.y)
                end
                if decided then
                    print("decided to go " .. direction .. " after " .. tries .. " tries")
                    self.currentTile:allocate(self.templates[2])
                    tile_placed = true
                end
                if tries > 3 then
                    too_many_tries = true
                end
                print("tries " .. tries)
            end
            if too_many_tries then
                --select a new current tile somewhere else connected to the dungeon
            end
        end
    end;
    selectTile = function(self, x, y)
        if self.world[x] and self.world[x][y] and not self.world[x][y].occupied then
            self.currentTile = self.world[x][y]
            return true
        end
        return false
    end;
    update = function(self, dt)
    end;
    drawDungeon = function(self)
        for i=1, self.width do
            for j=1, self.height do
                if self.world[i][j].occupied then
                    love.graphics.setColor(150,150,150,200)
                    love.graphics.rectangle('fill', self.origin.x + (i-1)*self.grid_width, self.origin.y + (j-1)*self.grid_height, self.grid_width, self.grid_height)
                    love.graphics.setColor(255,255,255)
                    love.graphics.draw(self.world[i][j].template.label, self.origin.x + (i-1)*self.grid_width,
                        self.origin.y + (j-1)*self.grid_height, 0, self.grid_width/self.world[i][j].template.label:getWidth(),
                        self.grid_height/self.world[i][j].template.label:getHeight()
                    )
                    --love.graphics.draw(drawable (Drawable), x (number), y (number), r (number), sx (number), sy (number), ox (number), oy (number), kx (number), ky (number))
                else
                    love.graphics.setColor(40,0,0,255)
                    love.graphics.rectangle('fill', self.origin.x + (i-1)*self.grid_width, self.origin.y + (j-1)*self.grid_height, self.grid_width, self.grid_height)
                end
            end
        end
    end;
    decideWeightedRandom = function(self, options, weightings)
        if weightings == nil then
            weightings = {}
            for k,v in pairs(options) do
                weightings[v] = 1
            end
        end
        local weightings_sum = 0
        for k,v in pairs(options) do
            weightings_sum = weightings_sum + weightings[v]
        end
        local choice = love.math.random()*weightings_sum
        local decided = false
        local selection = nil
        local running_total = 0
        for k, v in pairs(options) do -- do we need to guarantee this iterates in some particular order?
            if choice > running_total and choice < running_total + weightings[v] then
                selection = k
            end
            running_total = running_total + weightings[v]
        end
        if not selection then print("Made no decision.") else print(selection) end
        return selection
    end;
}

GridTile = Class {
    init = function(self, x, y)
        self.x = x
        self.y = y
        self.template = nil
        --local randyNum = love.math.random(0, 10)
        self.occupied = false --randyNum%2 == 0
    end;
    allocate = function(self, template)
        self.occupied = true
        self.template = template
    end;
}
