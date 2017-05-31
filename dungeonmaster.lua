require("templates.rooms")

DungeonMaster = Class {
    init = function(self, width, height)
        --local templates = love.filesystem.load("templates/rooms.lua", "Failed to load room templates")
        self.templateIndex = TemplateIndex() -- invoke template file
        self.width = width
        self.height = height
        self.grid_width = love.graphics.getWidth()/width
        self.grid_height = love.graphics.getHeight()/height
        self.origin = vector(0,0)
    end;
    generate = function(self, steps)
        self.world = {}
        self.unresolvedTiles = {} -- keep list of tiles with openings we can use!
        for i=1, self.width do
            self.world[i] = {}
            for j=1, self.height do
                self.world[i][j] = GridTile(i,j)
            end
        end
        self.currentTile = self.world[love.math.random(self.width/4,self.width-1)][love.math.random(self.height/4,self.height/2-1)]
        self:allocateTemplateToTile(self.currentTile.x, self.currentTile.y, self.templateIndex:get('spawn'))
        local actualSteps = 0
        for i=1,steps do
            local tile_placed = false
            local tries = 0
            local too_many_tries = false
            local excludingDirections = {top = false, right = false, bottom = false, left = false}
            while not tile_placed and not too_many_tries do
                tries = tries + 1
                local decided = false
                local direction = self:decideWeightedRandom(self.currentTile.template:getOpenings(excludingDirections))
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
                    local selectedX, selectedY = self.currentTile:getCoords()
                    local template = self:chooseTemplate(selectedX, selectedY, self:opposite(direction))
                    self:allocateTemplateToTile(self.currentTile.x, self.currentTile.y, template, self:opposite(direction))
                    excludingDirections = {top = false, right = false, bottom = false, left = false}
                    tile_placed = true
                    actualSteps = actualSteps + 1
                elseif direction ~= nil then
                    --print("excluding " .. direction)
                    excludingDirections[direction] = true
                end
                if tries > 2 then
                    too_many_tries = true
                end
            end
            if too_many_tries then
                if #self.unresolvedTiles > 0 then
                    self:selectRandomUnresolvedTile()
                end
                --select a new current tile somewhere else connected to the dungeon
            end
        end
        print("---[Generated world. Attempted " .. steps .. " steps. Allocated " .. actualSteps .. " rooms]")
    end;
    selectRandomUnresolvedTile = function(self)
        --pick random from 1
        local indices = {}
        for k, v in pairs(self.unresolvedTiles) do
            indices[#indices + 1] = k
        end
        local selection = love.math.random(1, #indices )
        local tile = self.unresolvedTiles[indices[selection]]
        self.currentTile = self.world[tile.x][tile.y]
        self.unresolvedTiles[indices[selection]] = nil
    end;
    selectTile = function(self, x, y)
        if self:isUnoccupied(x, y) then
            self.currentTile = self.world[x][y]
            return true
        end
        return false
    end;
    isUnoccupied = function(self, x, y)
        if self.world[x] and self.world[x][y] and not self.world[x][y].occupied then
            return true
        end
        return false
    end;
    canConnect = function(self, x, y, direction)
        if self.world[x] and self.world[x][y] and not self.world[x][y].template == nil then
            return self.world[x][y].template[direction]
        end
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
                if v == true then weightings[k] = 1 end
            end
        end
        local weightings_sum = 0
        for k,v in pairs(options) do
            if v == true then
                weightings_sum = weightings_sum + weightings[k]
            end
        end
        local choice = love.math.random()*weightings_sum
        local decided = false
        local selection = nil
        local running_total = 0
        for k, v in pairs(options) do -- do we need to guarantee this iterates in some particular order?
            if v == true then
                if choice > running_total and choice < running_total + weightings[k] then
                    selection = k
                end
                running_total = running_total + weightings[k]
            end
        end
        if not selection then log("Made no decision.") end
        return selection
    end;
    chooseTemplate = function(self, forX, forY, from)
        local MustConnectTo = {}
        MustConnectTo[from] = true
        local DontConnectTo = {}
        if self:isUnoccupied(forX - 1, forY) then
        elseif self:canConnect(forX - 1, forY, self:opposite("left")) then
            MustConnectTo["left"] = true
        else
            if not from == "left" then DontConnectTo["left"] = true end
        end

        if self:isUnoccupied(forX + 1, forY) then
        elseif self:canConnect(forX + 1, forY, self:opposite("right")) then
            MustConnectTo["right"] = true
        else
            if not from == "right" then DontConnectTo["right"] = true end
        end

        if self:isUnoccupied(forX, forY + 1) then
        elseif self:canConnect(forX, forY + 1, self:opposite("bottom")) then
            MustConnectTo["bottom"] = true
        else
            if not from == "bottom" then DontConnectTo["bottom"] = true end
        end

        if self:isUnoccupied(forX, forY - 1) then
        elseif self:canConnect(forX, forY - 1, self:opposite("top")) then
            MustConnectTo["top"] = true
        else
            if not from == "top" then DontConnectTo["top"] = true end
        end

        local candidates = self.templateIndex:findCandidates(MustConnectTo, DontConnectTo)
        local selection = self:decideWeightedRandom(candidates)
        return self.templateIndex:get(selection)
    end;
    allocateTemplateToTile = function(self, x, y, template, from)
        if self.world[x][y] ~= nil then
            local isUnresolved = self.world[x][y]:allocate(template, from)
            if isUnresolved then
                self.unresolvedTiles[#self.unresolvedTiles + 1] = {x = x, y = y}
            end
        end
    end;
    opposite = function(self, direction)
        if direction == "left" then
            return "right"
        elseif direction == "right" then
            return "left"
        elseif direction == "bottom" then
            return "top"
        elseif direction == "top" then
            return "bottom"
        end
    end;
    resize = function(self, width, height)
        self.grid_width = width/self.width
        self.grid_height = height/self.height
    end;
}

GridTile = Class {
    init = function(self, x, y)
        self.x = x
        self.y = y
        self.template = nil
        --local randyNum = love.math.random(0, 10)
        self.occupied = false --randyNum%2 == 0
        self.openings = {}
    end;
    allocate = function(self, template, from)
        self.occupied = true
        self.template = template
        self.openings = {
            top = self.template.top,
            right = self.template.right,
            left = self.template.left,
            bottom = self.template.bottom
        }
        if from ~= nil then self.openings[from] = false end
        return self.openings.top or self.openings.right or self.openings.bottom or self.openings.left
    end;
    getCoords = function(self)
        return self.x, self.y
    end;
}
