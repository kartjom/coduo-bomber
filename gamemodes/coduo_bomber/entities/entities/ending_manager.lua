ENT.Type = "point"

ENT.Tail = nil
ENT.Chairs = {}

ENT.EntsToDelete = {}
ENT.EndingBombers = {}

function ENT:Initialize()
    BOMBER_BOMB_BAY_CRANK:StopSound("Bomber.CrankRotate")
    SendDialogue("coduo/voiceovers/ending_sequence_bail.mp3")
    
    BOMBER_ENDING_SEQUENCE = true
    
    self:CreateTail()
    self:MovePlaneComponents()

    self:PutPlayersInChairs()
    self:ChuteSoundTimer()
    self:FadeScreen()
end

function ENT:Think()

    if (self.Tail != NULL && self.Tail:GetCycle() >= 0.18 && !self.Tail.ParticlesOut) then
        local pos = self.Tail:GetBonePosition(1)
        ParticleEffect("explosion_huge_j", pos + Vector(0, 0, -30), Angle())

        self.Tail.ParticlesOut = true
    end

    if (self.Tail != NULL && self.Tail:GetCycle() >= 0.35) then
        self.Tail:SetNoDraw(true)
    end
    
    if (self.Tail != NULL && self.Tail:GetCycle() >= 0.98) then
        self.Helper:SetParent(NULL)
        self.Parachute:SetParent(self.Helper)
        self.Parachute:SetLocalPos(Vector())
        self.Tail:Remove()
    end

    if (self.Tail == NULL && self.Helper:GetPos().z >= -13000) then
        self.Helper:SetPos( self.Helper:GetPos() - Vector(0, -2, 6) )
    end

    for k,v in pairs(self.EndingBombers) do
        v:SetPos( v:GetPos() - Vector(0, 5, 0) )
    end

    self:NextThink(CurTime())
    return true
end

function ENT:CreateChair(ply, pos)
    local chair = ents.Create("prop_vehicle_prisoner_pod")
    chair:SetModel("models/nova/jeep_seat.mdl")
    chair:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
    chair:SetPos(pos)
    chair:SetNoDraw(true)
    chair:Spawn()
    chair:SetCollisionGroup(20)
    chair:GetPhysicsObject():EnableMotion(false)
    chair.Ending = true

    chair:SetParent(self.Helper)
    chair:SetLocalPos(Vector())

    table.insert(self.Chairs, chair)
    ply:EnterVehicle(chair)
end

function ENT:CreateTail()
    self.Tail = ents.Create("prop_dynamic")
    self.Tail:SetModel("models/coduo/bomber/b17_ending_tail.mdl")
    self.Tail:SetPos(self.CenterPos)
    self.Tail:PhysicsInit(SOLID_NONE)
    self.Tail:SetMoveType(MOVETYPE_NONE)
    self.Tail.AutomaticFrameAdvance = true
    self.Tail:SetKeyValue("DefaultAnim", "ending")
    self.Tail:Spawn()

    self.Helper = ents.Create("prop_dynamic")
    self.Helper:SetModel("models/hunter/plates/plate.mdl")
    self.Helper:FollowBone(self.Tail, 2)
    self.Helper:SetLocalPos(Vector())
    self.Helper:SetNoDraw(true)
    self.Helper:Spawn()
end

function ENT:MovePlaneComponents()
    for k,v in pairs({1274, 1275, 1276}) do
        ents.GetMapCreatedEntity(v):SetPos(self.CenterPos)
        table.insert(self.EntsToDelete, ents.GetMapCreatedEntity(v))
    end

    local waist_ending = ents.Create("prop_dynamic")
    waist_ending:SetModel("models/coduo/bomber/b17_ending_waist.mdl")
    waist_ending:SetPos(self.CenterPos)
    waist_ending:Spawn()
    table.insert(self.EntsToDelete, waist_ending)

    local allowedClasses = {
        ["prop_physics"] = true,
        ["turret_50cal_pod"] = true,
        ["turret_50cal_ball_pod"] = true,
        ["turret_50cal_dorsal_pod"] = true,
        ["bomber_dynamic_wing"] = true,
        ["item_firstaid_medium"] = true,
        ["logic_use"] = true,
    }

    for k,v in pairs(ents.FindInSphere(Vector(), 5700)) do
        if ( allowedClasses[v:GetClass()] ) then
            v:SetPos( v:GetPos() + self.CenterPos )
            table.insert(self.EntsToDelete, v)

            if (v:GetClass() == "bomber_dynamic_wing") then
                v:GetPropeller("inner"):SetPos(  v:GetPropeller("inner"):GetPos() + self.CenterPos )
                v:GetPropeller("outer"):SetPos(  v:GetPropeller("outer"):GetPos() + self.CenterPos )

                table.insert(self.EntsToDelete, v:GetPropeller("inner"))
                table.insert(self.EntsToDelete, v:GetPropeller("outer"))
            end
        end

        if ( string.StartWith(v:GetName(), "bomber") && v.IsBomber) then
            v:SetPos( v:GetPos() + self.CenterPos )
            table.insert(self.EndingBombers, v)
        end
    end

    for k,v in pairs(player.GetAll()) do
        v:SetPos( v:GetPos() + self.CenterPos )
    end

    local allowedNames = {
        ["l_waist"] = true,
        ["r_waist"] = true,
        ["radio"] = true,
        ["bomb_bay_animated"] = true,
        ["bomb_bay_crank_animated"] = true,
    }

    for k,v in pairs(ents.FindInSphere(Vector(), 5700)) do
        if ( allowedNames[v:GetName()] ) then
            v:SetPos( v:GetPos() + self.CenterPos )
            table.insert(self.EntsToDelete, v)
        end
    end
end

function ENT:PutPlayersInChairs()
    for k,v in pairs(player.GetAll()) do
        if (!v:Alive()) then v:Spawn() end
        v:SetNoDraw(true)
        v:SetEyeAngles(Angle(0, 90, 0))
        v:Freeze(true)
        self:CreateChair(v, self.CenterPos)
    end
end

function ENT:ChuteSoundTimer()
    TimerAdd("OpenChuteSound", 5, 1, function()
        for k,v in pairs(self.EntsToDelete) do
            if (v != NULL) then v:Remove() end
        end
        for k,v in pairs(self.EndingBombers) do
            if (v != NULL) then v:Remove() end
        end
        self.EndingBombers = {}

        self.Helper:EmitSound("coduo/misc/chute_deploy.wav")

        self.Parachute = ents.Create("prop_dynamic")
        self.Parachute:SetModel("models/coduo/bomber/ending_parachute.mdl")
        self.Parachute:SetPos(self.Helper:GetPos())
        self.Parachute:SetParent(self.Helper)
        self.Parachute:SetLocalAngles(Angle(0, 0, -90))
        self.Parachute:PhysicsInit(SOLID_NONE)
        self.Parachute:SetMoveType(MOVETYPE_NONE)
        self.Parachute.AutomaticFrameAdvance = true
        self.Parachute:SetKeyValue("DefaultAnim", "deploy")
        self.Parachute:Spawn()

        for k,v in pairs(player.GetHumans()) do
            v:Freeze(false)
        end
    end)
end

function ENT:FadeScreen()
    TimerAdd("EndingFadeScreen", 11, 1, function()
        TimerAdd("EndingRestart", 13, 1, function()
            game.CleanUpMap()
        end)

        for k,v in pairs(player.GetHumans()) do
            v:ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 255 ), 3, 15 )
        end
    end)
end