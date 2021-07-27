local centerPos = Vector(-10029.3, 6481.2, -8780.8)

function BeginEndingSequence()
    for k,v in pairs(player.GetAll()) do
        v:ExitVehicle()
    end

    BOMBER_CHAIRS_DISABLED = true

    ents.FindByClass("event_manager")[1]:Remove()
    BOMBER_FLAK_BARRAGE = false
    BOMBER_ENEMY_FIGHTERS = false
    net.Start("STOP_MUSIC")
	net.Broadcast()

    timer.Remove("BOMBER_DropBombs")
    timer.Remove("BOMBER_DropBombs_Dialogue")
    timer.Remove("BOMBER_CrankStop")

    TimerAdd("BeginEndingDialogue", 1, 1, function()
        SendDialogue("coduo/voiceovers/ending_sequence_fire.mp3")
    end)

    TimerAdd("PlayEndingAnimation", 5, 1, function()
        local endingManager = ents.Create("ending_manager")
        endingManager.CenterPos = Vector(-10029.3, 6481.2, -8780.8)
        endingManager:Spawn()

        EndingChangeSkyCamera()
        EndingChangeAmbientSound()
        
        EndingEmitParticles(centerPos + Vector(0, 230, -50))
        TimerAdd("EndingParticle_2", 0.25, 1, function()
            EndingEmitParticles(centerPos + Vector(0, 180, -50))
        end)
        TimerAdd("EndingParticle_3", 0.5, 1, function()
            EndingEmitParticles(centerPos + Vector(0, 330, -30))
        end)
        TimerAdd("EndingParticle_4", 0.7, 1, function()
            EndingEmitParticles(centerPos + Vector(0, 360, -20))
        end)
        TimerAdd("EndingParticle_5", 0.9, 1, function()
            EndingEmitParticles(centerPos + Vector(0, 400, -20))
        end)

        EndingDestroySounds(endingManager)
    end)
end

function EndingEmitParticles(origin)
    ParticleEffect("explosion_huge_h", origin, Angle())
    ParticleEffect("explosion_huge_j", origin, Angle())
    local effect = EffectData()
    effect:SetOrigin(origin)
    effect:SetScale(50)
    util.Effect( "HelicopterMegaBomb", effect )
end

function EndingDestroySounds(endingManager)
    TimerAdd("EndingSoundMetal_1", 0.1, 1, function()
        endingManager.Helper:EmitSound("coduo/bomber/flak_hit01.mp3", 75, 100, 1)
    end)
    TimerAdd("EndingSoundMetal_2", 0.25, 1, function()
        endingManager.Tail:EmitSound("coduo/misc/metal_break0"..math.random(1, 2)..".wav", 75, 100, 0.5) 
    end)
end

function EndingChangeSkyCamera()
    local skyCameraPos = Vector(4620, 6247, -13876)

    for k,v in pairs(ents.GetAll()) do
        if (v:GetClass() == "sky_camera") then
            v:Fire("Kill")
        end
    end

    skyCameraPos.z = skyCameraPos.z - (centerPos.z/16)

    local skyCamera = ents.Create("sky_camera")
    skyCamera:SetKeyValue("scale", 16)
    skyCamera:SetKeyValue("fogblend", 1)
    skyCamera:SetKeyValue("fogstart", 50000)
    skyCamera:SetKeyValue("fogcolor", "126 124 132")
    skyCamera:SetKeyValue("fogcolor2", "126 117 117")
    skyCamera:SetKeyValue("fogend", 80000)
    skyCamera:SetKeyValue("fogenable", 1)
    skyCamera:SetPos(skyCameraPos)
    skyCamera:Spawn()
end

function EndingChangeAmbientSound()
    local sounds = {
        "bomber_ambient",
        "bomber_ambient_damaged"
    }
    local logic = {
        "bomber_ambient_replay",
        "bomber_ambient_damaged_replay",
        "ambient_changer"
    }

    TimerAdd("EndingChangeAmbient", 0.5, 1, function()
        for k,v in pairs(logic) do
            if (#ents.FindByName(v) > 0) then
                ents.FindByName(v)[1]:Remove()
            end
        end
        for k,v in pairs(sounds) do
            if (#ents.FindByName(v) > 0) then
                ents.FindByName(v)[1]:Fire("FadeOut", 1)
            end
        end
        ents.FindByName("bomber_ambient_ending_wind")[1]:Fire("PlaySound")
    end)
end