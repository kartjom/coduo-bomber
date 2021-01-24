local soundLocations = {
    Vector(369, 436, -45),
    Vector(251, 729, 171),
    Vector(-227, 443, 118),
    Vector(-325, 760, -73),
    Vector(-271, -219, 147),
    Vector(256, -114, -88),
    Vector(202, -666, 127),
    Vector(-262, -577, -57),
    Vector(142, -14, -153),
    Vector(111, -134, 258)
}

function FlakBarrageLogic()
    local nextFlak = CurTime()
    local flakDelay = 0.1

    local nextFlakSound = CurTime()
    
    HookAdd("Think", "FlakBarrage", function()
        if (BOMBER_FLAK_BARRAGE && CurTime() >= nextFlak) then
            local x = math.random(-2500, 2500)
            local y = math.random(-4000, 4000)
            local z = math.random(-800, 1500)
            local pos = Vector(x, y, z)

            if (pos:WithinAABox( Vector(155, 753, -86), Vector(-216, -714, 191) )) then
                return
            end
            // fix all of this

            FlakHit( pos )

            nextFlak = CurTime() + flakDelay

            if (CurTime() >= nextFlakSound) then
                sound.Play("coduo/bomber/flak_burst_near0"..math.random(1, 5)..".wav", soundLocations[math.random(1, #soundLocations)])

                if (math.random(0, 100) > 50) then
                    if (math.random(0, 100) > 50) then
                        sound.Play("coduo/misc/big_shake0"..math.random(1, 2)..".wav", soundLocations[math.random(1, #soundLocations)])
                    else
                        sound.Play("coduo/misc/med_shake0"..math.random(1, 2)..".wav", soundLocations[math.random(1, #soundLocations)])
                    end
                end
                nextFlakSound = CurTime() + math.Rand(0.8, 2)
            end
        end
    end)
end

function FlakHit(pos)
    local hit = math.random(1, 7)
    local zPos = math.Rand(-0.25, 0.25)

    ParticleEffect("flak_hit_0"..hit, pos, Angle())
    
    util.ScreenShake( pos, 7.5, 5, 1, 2000 )

    for k,v in pairs(ents.FindInSphere(pos, 250)) do
        if (v:IsPlayer()) then continue end

        local dmg = DamageInfo()
        dmg:SetDamage(30)
        dmg:SetDamageType(DMG_BLAST) 
        v:TakeDamageInfo(dmg)
    end
end

BOMBER_NEXT_FLAK_WARNING = 0
function StartFlakBarrage()
    BOMBER_FLAK_BARRAGE = true

    if (CurTime() <= BOMBER_NEXT_FLAK_WARNING) then return end
    BOMBER_NEXT_FLAK_WARNING = CurTime() + 15

    TimerAdd("FLAK_BARRAGE_WARNING_"..CurTime(), math.random(2, 6), 1, function()
        if (BOMBER_FLAK_BARRAGE) then SendDialogue("coduo/voiceovers/flak_warning_"..math.random(1, 5)..".mp3") end
    end)
end

function StopFlakBarrage()
    BOMBER_FLAK_BARRAGE = false
end