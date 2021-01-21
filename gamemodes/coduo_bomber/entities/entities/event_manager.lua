ENT.Type = "point"

if (SERVER) then

    ENT.LastCityTrigger = nil

    ENT.CanTriggerFlakTime = 0
    ENT.FlakBarrageBreak = 180

    ENT.NextPossibleFighters = CurTime()

    function ENT:Think()
        if ( !BOMBER_FLAK_BARRAGE && CurTime() >= self.CanTriggerFlakTime ) then
            self:ManageEvents()
        end

        self:NextThink(CurTime() + 5)
        return true
    end

    function ENT:ManageEvents()
        for k,v in pairs(LANDSCAPE_CITY_MANAGER.ListOfLandscapes) do
            if ( v != nil && v != NULL && v == self.LastCityTrigger) then continue end

            local distance = Vector(4511, 6220, -14665):DistToSqr(v:GetPos())

            if (distance <= 10023898) then
                self.LastCityTrigger = v
                self:StartFlakEvent()
                return
            end
        end     
    end

    function ENT:StartFlakEvent()
        StopEnemyFighters()

        local flakDelay = 15
        local flakDuration = math.random(60, 75)
        self.CanTriggerFlakTime = CurTime() + flakDelay + flakDuration + self.FlakBarrageBreak
        TimerAdd("EVENT_MANAGER_FLAK_START", flakDelay, 1, StartFlakBarrage)
        TimerAdd("EVENT_MANAGER_FLAK_STOP", flakDelay + flakDuration, 1, StopFlakBarrage)

        local fightersStartDelay = math.random(15, 25)
        TimerAdd("EVENT_MANAGER_FIGHTERS_START", flakDelay + flakDuration + fightersStartDelay, 1, self.StartFightersEvent)

        //PrintMessage(HUD_PRINTTALK, "Started barrage")
    end

    function ENT:StartFightersEvent()   
        StartEnemyFighters()

        local fightersDuration = math.random(120, 150)
        TimerAdd("EVENT_MANAGER_FIGHTERS_STOP", fightersDuration, 1, StopEnemyFighters)

        //PrintMessage(HUD_PRINTTALK, "Started fighters")
    end

end