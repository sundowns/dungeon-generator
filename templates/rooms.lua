RoomTemplate = Class {
    init = function(self, id, top, right, bottom, left, label_path)
        self.id = id
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
        self.label = love.graphics.newImage(label_path)
    end;
    getOpenings = function(self)
        return {
            top = self.top,
            right = self.right,
            bottom = self.bottom,
            left = self.left
        }
    end;
}

local index = {}
index[1] = RoomTemplate(1,true,true,true,true, "assets/labels/room1.png")
index[2] = RoomTemplate(2,true,false,true,false, "assets/labels/room2.png")
index[3] = RoomTemplate(3,false,true,false,true, "assets/labels/room3.png")
index[4] = RoomTemplate(4,true,true,true,false, "assets/labels/room4.png")
index[5] = RoomTemplate(5,true,false,true,true, "assets/labels/room5.png")
index[6] = RoomTemplate(6,false,true,true,true, "assets/labels/room6.png")
index[7] = RoomTemplate(7,true,true,false,true, "assets/labels/room7.png")
index[8] = RoomTemplate(8,true,false,false,false, "assets/labels/room8.png")
index[9] = RoomTemplate(9,false,false,true,false, "assets/labels/room9.png")
index[10] = RoomTemplate(10,false,false,false,true, "assets/labels/room10.png")
index[11] = RoomTemplate(11,false,true,false,false, "assets/labels/room11.png")
index['spawn'] = RoomTemplate('spawn',false,true,false,true, "assets/labels/spawn.png")

return index
