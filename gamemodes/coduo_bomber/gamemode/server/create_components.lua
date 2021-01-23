function CreateChair(name, pos, angle, exitPos)
    local chair = ents.Create("prop_vehicle_prisoner_pod")
    chair:SetModel("models/nova/jeep_seat.mdl")
    chair:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
    chair:SetName(name)
    chair:SetPos(pos)
    chair:SetAngles(angle)
    chair.ExitPos = exitPos
    chair:SetNoDraw(true)
    chair:Spawn()
    chair:SetCollisionGroup(20)
    chair:GetPhysicsObject():EnableMotion(false)
end

function SpawnChairs()
    CreateChair("chair_radio_left", Vector(42.21, -50.72, -14), Angle(0, 173, 0), Vector(0, -58, -15))
    CreateChair("chair_radio_right", Vector(-48.2, -76.4, -14), Angle(0, -144, 0), Vector(0, -58, -15))

    CreateChair("chair_cockpit_left", Vector(24, -436, 0), Angle(0, 180, 0), Vector(0, -400, -15))
    CreateChair("chair_cockpit_right", Vector(-27, -436, 0), Angle(0, 180, 0), Vector(0, -400, -15))
end

function CreateTail_Waist()
    local l_tail = ents.Create("bomber_dynamic_part")
    l_tail.PartName = "l_tail"
    l_tail.MaxDamageLevel = 2
    l_tail:Spawn()

    local r_tail = ents.Create("bomber_dynamic_part")
    r_tail.PartName = "r_tail"
    r_tail.MaxDamageLevel = 2
    r_tail.MaxHealth = 300 // needs to be lower than rest because enemy planes rarely attack it
    r_tail:Spawn()

    local l_waist = ents.Create("bomber_dynamic_part")
    l_waist.PartName = "l_waist"
    l_waist.MaxDamageLevel = 3
    l_waist:Spawn()
    
    local r_waist = ents.Create("bomber_dynamic_part")
    r_waist.PartName = "r_waist"
    r_waist.MaxDamageLevel = 3
    r_waist:Spawn()
end

function CreateWaistTurrets()
    local lturret = ents.Create("turret_50cal_pod")
    lturret:SetAngles(Angle())
    lturret:SetPos(Vector(63, 200, 0))
    lturret:Spawn()
    lturret:GetPhysicsObject():EnableMotion(false)
    
    local rturret = ents.Create("turret_50cal_pod")
    rturret:SetAngles(Angle(0, 180, 0))
    rturret:SetPos(Vector(-65, 141, 0))
    rturret:Spawn()
    rturret:GetPhysicsObject():EnableMotion(false)
end

function CreateTailTurret()
    local tail_turret = ents.Create("turret_50cal_tail_pod")
    tail_turret:SetAngles(Angle(0, 90, 0))
    tail_turret:SetPos(Vector(-0.5, 585, -14))
    tail_turret:Spawn()
    tail_turret:GetPhysicsObject():EnableMotion(false)
end

function CreateDorsalTurret()
    local dorsal_turret = ents.Create("turret_50cal_dorsal_pod")
    dorsal_turret:SetAngles(Angle(0, -90, 0))
    dorsal_turret:SetPos(Vector(-2.65, -368.97, -10))
    dorsal_turret:Spawn()
    dorsal_turret:GetPhysicsObject():EnableMotion(false)
end

function CreateBallTurret()
    local ball_turret = ents.Create("turret_50cal_ball_pod")
    ball_turret:SetAngles(Angle(0, -90, 0))
    ball_turret:SetPos(Vector(-2, 68, -12))
    ball_turret:Spawn()
    ball_turret:GetPhysicsObject():EnableMotion(false)
end

function CreateWings()
    local l_wing = ents.Create("bomber_dynamic_wing")
    l_wing.PartName = "l_wing"
    l_wing.MaxDamageLevel = 2
    l_wing.InnerPropellerOffset = Vector(190.955887, -420.067444, -31.275034)
    l_wing.OuterPropellerOffset = Vector(399, -388, -18)
    l_wing:Spawn()

    local r_wing = ents.Create("bomber_dynamic_wing")
    r_wing.PartName = "r_wing"
    r_wing.MaxDamageLevel = 2
    r_wing.InnerPropellerOffset = Vector(-190.955887, -420.067444, -31.275034)
    r_wing.OuterPropellerOffset = Vector(-399, -388, -18)
    r_wing:Spawn()
end

function CreateRadioRoom()
    local radio = ents.Create("bomber_dynamic_part")
    radio.PartName = "radio"
    radio.MaxHealth = 900
    radio.MaxDamageLevel = 1
    radio:Spawn()

    /* Hurt players within radius and change ambient snd */
    function radio:PostDamageComponent()
        if (self.CurrentDamageLevel == 1) then
            for k,v in pairs(ents.FindInSphere(Vector(55, -47, 0), 120)) do
                if (v:IsPlayer()) then
                    local dmg = DamageInfo()
                    dmg:SetDamage(40)
                    dmg:SetDamageType(DMG_BLAST) 
                    v:TakeDamageInfo(dmg)
                end
            end
            
            ents.FindByName("ambient_changer")[1]:Fire("FireUser1")
            ents.FindByName("bomber_ambient_radio")[1]:Fire("PlaySound")

            local leftChair = ents.FindByName("chair_radio_left")[1]
            local leftChairDriver = leftChair:GetDriver()
            if (leftChairDriver != NULL) then
                leftChairDriver:ExitVehicle()

                leftChairDriver:SetHealth( leftChairDriver:Health() - 40 )
                leftChairDriver:StartExplosionShock()

                if (leftChairDriver:Health() <= 0) then leftChairDriver:Kill() end
            end
            leftChair:Remove()

            local rightChairDriver = ents.FindByName("chair_radio_right")[1]:GetDriver()
            if (rightChairDriver != NULL) then
                rightChairDriver:SetHealth( rightChairDriver:Health() - 40 )
                rightChairDriver:StartExplosionShock()

                if (rightChairDriver:Health() <= 0) then rightChairDriver:Kill() end
            end
        end
    end
end

function CreateFirstAidKits()
    local firstAids = {
        Vector(40.25, 14 ,19),
        Vector(40.25, 14 ,7),           
        Vector(-42.5, 14 ,19),
        Vector(-42.5, 14 ,7)
    }

    for k,v in pairs(firstAids) do
        local firstAid = ents.Create("item_firstaid_medium")
        firstAid:SetPos(v)
        firstAid:SetAngles(Angle(0, -180, 90))
        firstAid:Spawn()
        firstAid:GetPhysicsObject():EnableMotion(false)
    end
end

function CreateLogicEntities()
    local bombBayCrank = ents.Create("logic_use")
    bombBayCrank:SetPos( BOMBER_BOMB_BAY_CRANK:GetPos() )
    bombBayCrank:Spawn()

    function bombBayCrank:Use()
        RunBombBaySequence()
    end
end

function CreateManagers()
    LANDSCAPE_CITY_MANAGER = ents.Create("landscape_city_manager")
    LANDSCAPE_CITY_MANAGER:Spawn()

    EVENT_MANAGER = ents.Create("event_manager")
    EVENT_MANAGER:Spawn()
end

/* BOMBER FORMATION */

function CreateBombersFormation()
    // See ai_b17_logic.lua for constructor members

    // 2 close left
    CreateBomber({
        origin = Vector(2107.25, -1766.61, 41.66),
        targetname = "bomber1",
        sequence = 1, dieSequence = 1,
        fallPos = 1
    })

    CreateBomber({
        origin = Vector(1966.74, 2158.10, -213.39),
        targetname = "bomber2",
        sequence = 2, dieSequence = 2,
        fallPos = 2
    })
    
    // 2 far left
    CreateBomber({
        origin = Vector(8722.82, 7762.6, 846.62),
        targetname = "bomber3",
        sequence = 3,
        fallPos = 3
    })

    CreateBomber({
        origin = Vector(10183, 9962.72, 477.78),
        targetname = "bomber4",
        sequence = 2,
        fallPos = 3
    })
    
    // 2 back right
    CreateBomber({
        origin = Vector(-2136.84, 2917.14, 352.61),
        targetname = "bomber5",
        sequence = 1,
        fallPos = 4
    })

    CreateBomber({
        origin = Vector(-4686.48, 4827.13, -148.32),
        targetname = "bomber6",
        sequence = 3,
        fallPos = 4
    })
    
    // 2 front right
    CreateBomber({
        origin = Vector(-5831.40, -4123.313, 1663.61),
        targetname = "bomber7",
        sequence = 2,
        fallPos = 5
    })

    CreateBomber({
        origin = Vector(-8463.66, -1292.39, 1011.88),
        targetname = "bomber8",
        sequence = 3,
        fallPos = 5
    })

    // 3 up
    CreateBomber({
        origin = Vector(408, -8844.44, 4093.8),
        targetname = "bomber9",
        sequence = 1, dieSequence = 1,
        fallPos = 6,
        setContrails = true
    })

    CreateBomber({
        origin = Vector(-3626, -6943, 3804.24),
        targetname = "bomber10",
        sequence = 3,
        fallPos = 6,
        setContrails = true
    })

    CreateBomber({
        origin = Vector(-2044.58, -9935.68, 4050.73),
        targetname = "bomber11",
        sequence = 2,
        fallPos = 6,
        setContrails = true
    })
      
    /* Custom ones */

    CreateBomber({
        origin = Vector(12321.96, -5546.44, 884.55),
        targetname = "bomber12",
        sequence = 2,
        fallPos = 1
    })
    
    CreateBomber({
        origin = Vector(8901.24, -3318.76, 1843.58),
        targetname = "bomber13",
        sequence = 3,
        fallPos = 1
    })
    
    CreateBomber({
        origin = Vector(10387.46, -1344.24, 491.23),
        targetname = "bomber14",
        sequence = 1,
        fallPos = 1
    })
    
    CreateBomber({
        origin = Vector(-3158.18, -2478.12, -258.22),
        targetname = "bomber15",
        sequence = 2,
        fallPos = 1
    })
    
    CreateBomber({
        origin = Vector(5016.04, -4029.32, 786.7),
        targetname = "bomber16",
        sequence = 3,
        fallPos = 1
    })
    
    CreateBomber({
        origin = Vector(7832.52, 9792.33, 69.37),
        targetname = "bomber17",
        sequence = 1,
        fallPos = 2
    })
    
    CreateBomber({
        origin = Vector(-6499.19, 2270, -585),
        targetname = "bomber18",
        sequence = 1,
        fallPos = 2
    })
end