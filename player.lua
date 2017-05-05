Player = Class{
    init = function(self, x, y)
        self.pos = vector(x, y)
        self.inputVector = vector(0,0)
        self.image = love.graphics.newImage("assets/sprites/player.png")
        self.speed = 120
        self.width = self.image:getWidth()
        self.height = self.image:getHeight()
        self.collisionBox = HC.rectangle(self.pos.x, self.pos.y, self.width, self.height)
    end;
    draw = function(self)
        love.graphics.draw(self.image, self.pos.x, self.pos.y)
        self.collisionBox:draw()
    end;
    update = function(self, dt)
        self.pos = self.pos + self.inputVector * self.speed * dt
        self.collisionBox:moveTo(self.pos.x + self.width/2, self.pos.y + self.height/2)
    end;
    processInput = function(self, dt)
        local input = vector(0,0)
        if love.keyboard.isDown("a") then
            input.x = input.x - 1
        end
        if love.keyboard.isDown("d") then
            input.x = input.y + 1
        end
        self.inputVector = input
    end;
}
