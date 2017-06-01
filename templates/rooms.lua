RoomTemplate = Class {
    init = function(self, id, top, right, bottom, left, label_path)
        self.id = id
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
        self.label = love.graphics.newImage(label_path)
        self.openings = 0
        self:calculate_openings()
    end;
    calculate_openings = function(self)
        local openings = 0
        if self.top then openings = openings + 1 end
        if self.right then openings = openings + 1 end
        if self.bottom then openings = openings + 1 end
        if self.left then openings = openings + 1 end
        self.openings = openings
    end;
}

TemplateIndex = Class {
    init = function(self)
        self.templates = {}
        self.templates[1] = RoomTemplate(1,true,true,true,true, "assets/labels/room1.png")
        self.templates[2] = RoomTemplate(2,true,false,true,false, "assets/labels/room2.png")
        self.templates[3] = RoomTemplate(3,false,true,false,true, "assets/labels/room3.png")
        self.templates[4] = RoomTemplate(4,true,true,true,false, "assets/labels/room4.png")
        self.templates[5] = RoomTemplate(5,true,false,true,true, "assets/labels/room5.png")
        self.templates[6] = RoomTemplate(6,false,true,true,true, "assets/labels/room6.png")
        self.templates[7] = RoomTemplate(7,true,true,false,true, "assets/labels/room7.png")
        self.templates[8] = RoomTemplate(8,true,false,false,false, "assets/labels/room8.png")
        self.templates[9] = RoomTemplate(9,false,false,true,false, "assets/labels/room9.png")
        self.templates[10] = RoomTemplate(10,false,false,false,true, "assets/labels/room10.png")
        self.templates[11] = RoomTemplate(11,false,true,false,false, "assets/labels/room11.png")
        self.templates['spawn'] = RoomTemplate('spawn',false,true,false,true, "assets/labels/spawn.png")
    end;
    get = function(self, index)
        if self.templates[index] ~= nil then
            return self.templates[index]
        end
        return false
    end;
    findCandidates = function(self, MustConnectTo, DontConnectTo, step)
        local candidates = {}
        local weightings = {}
        for i, template in ipairs(self.templates) do --only goes over numbered templates (good!)
            local eligible = true
            for k, _ in pairs(DontConnectTo) do
                if template[k] == true then eligible = false end
            end
            for k, _ in pairs(MustConnectTo) do
                --if the template cant connect to a door that it MUST, its not eligible
                if template[k] == false then eligible = false end
            end

            if eligible then
                candidates[i] = true
                weightings[i] = self:weightCandidate(step, template)
            end
        end
        return candidates
    end;
    weightCandidate = function(self, step, template)
        if step <= GENERATION_STEPS*0.2 then --first 20% of generation
            log("0 -> 20")
            if template.openings == 1 then
                return 0
            else return template.openings/4 end --more openings = higher weight
        elseif step < GENERATION_STEPS*0.5 then -- 20% -> 49%
            log("20 -> 49")
            return 1 -- all equal weightings
        elseif step < GENERATION_STEPS*0.8 then -- 50% -> 79%
            log("50 -> 79")
            return 1/(template.openings/4) -- less openings = better
        else --80% -> 100%
            log("80 -> 100")
            -- less openings = much better
            if template.openings == 4 then
                return 0
            else
                return 1/(template.openings/4)
            end
        end
    end;
}

Set = Class {
    init = function(self, list)
        self.set = {}
        for _, l in pairs(list) do self.set[l] = true end
    end;
    unionWith = function(self, with)
        local result = {}
        for _, l in pairs(self.set) do result[l] = true end
        for _, l in pairs(with) do result[l] = true end
    end;
}
