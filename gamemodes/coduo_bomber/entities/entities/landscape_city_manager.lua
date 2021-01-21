ENT.Type = "point"

if (SERVER) then

    ENT.Landscapes = {
        ["landscape_city_small"] = true,
        ["landscape_city_medium"] = true,
        ["landscape_city_big"] = true
    }

    ENT.ListOfLandscapes = {}

    ENT.NextCitySpawn = CurTime() + math.random(160, 240)
    ENT.FirstTime = true

    function ENT:Initialize()
       
        HookAdd("OnEntityCreated", "ManageCreatedCity", function(ent)       
            if (ent:GetClass() == "func_brush") then
                TimerAdd("LANDSCAPE_TEST_"..ent:EntIndex(), 0.01, 1, function()
                    if (self.Landscapes[ent:GetName()]) then
                        if ( IsValid(ent) ) then self:OnCityCreate(ent) end
                    end
                end)
            end
        end)
        
        local tbl = { "small", "medium", "big" }
        self:CreateCity(table.Random(tbl))
        
    end

    function ENT:CreateCity(type)
        // type: "small", "medium", "big"
        ents.FindByName("maker_landscape_city_"..type)[1]:Fire("ForceSpawn")

        self.NextCitySpawn = CurTime() + math.random(160, 240)
    end

    function ENT:OnCityCreate(ent)
        local newPos = ent:GetPos()
        newPos.x = math.random(2000, 7000)
        newPos.y = newPos.y + 1500

        if (self.FirstTime) then
            self.FirstTime = false

            newPos.x = math.random(3000, 7000)
            newPos.y = newPos.y + 2000
        end

        ent:SetPos(newPos)
        ent:SetAngles( Angle(0, math.random(0, 360), 0) )
        
        table.insert(self.ListOfLandscapes, ent)
    end

    function ENT:CityTypeCount(type)
        return #ents.FindByName("landscape_city_"..type)
    end
    
    function ENT:CitiesCount()
        local small = #ents.FindByName("landscape_city_small")
        local medium =  #ents.FindByName("landscape_city_medium")
        local big =  #ents.FindByName("landscape_city_big")

        return small + medium + big
    end

    function ENT:Think()
        for k,v in pairs(self.ListOfLandscapes) do
            /* Remove invalid (removed) landscapes */
            if ( v == nil || v == NULL ) then
                table.remove(self.ListOfLandscapes, k)
                continue
            end

            /* Move all landscapes on the Y axis (0.55 SHOULD be almost exact speed as moving ground) */
            v:SetPos( v:GetPos() + Vector(0, 0.55, 0) )

            /* Remove landscapes that are too far away */
            if (v:GetPos().y >= 15000) then v:Remove() end
        end

        if (CurTime() >= self.NextCitySpawn) then
            local chance = math.random(0, 1000)

            if (chance >= 850) then
                self:CreateCity("big")
            elseif(chance >= 550 && chance < 850) then
                self:CreateCity("medium")
            else
                self:CreateCity("small")
            end
        end

        self:NextThink(CurTime())
        return true
    end

end