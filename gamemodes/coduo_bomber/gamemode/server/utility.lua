/* Auto cleanup timers because i'm lazy as fuck */
function TimerAdd(id, delay, repetitions, func)
    timer.Create(id, delay, repetitions, function()
        TimersList[id] = nil
        func()
    end)
    TimersList[id] = true
end

/* Auto cleanup hooks */
function HookAdd(event, name, func)
    hook.Add(event, name, func)
    HooksList[name] = event
end

function RandVecFromBox(vec1, vec2)
    local x = math.random(vec1.x, vec2.x)
    local y = math.random(vec1.y, vec2.y)
    local z = math.random(vec1.z, vec2.z)

    return Vector(x, y, z)
end

function UseFuelCrank(ent)
    ent:Fire("FireUser2")
    ent:EmitSound("Bomber.FuelCrankRotate")
end

function EntityMakeObjective(ent)
    ent:SetSkin(1)
    ent:SetColor( Color(255, 255, 255, 127) )
    ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
    ent:SetRenderFX(4)
end

function EntityMakeNormal(ent)
    ent:SetSkin(0)
    ent:SetColor( Color(255, 255, 255, 255) )
    ent:SetRenderMode( RENDERMODE_NORMAL )
    ent:SetRenderFX(0)
end

function CreateParticle(particleName, pos, lifetime, moveDir)
    local particle = ents.Create("logic_particle")
    particle.Lifetime = lifetime or 2
    particle.MoveVector = moveDir
    particle.ParticleName = particleName
    particle:SetPos( pos or Vector() )
    particle:Spawn()
end

function CloudsEmitter()
    local nextCloud = 0
    HookAdd("Think", "CloudsEmitter", function()
        if (CurTime() <= nextCloud) then return end

        nextCloud = CurTime() + 0.525

        local xOffset = math.random(-7000, 7000)
        local zOffset = math.random(-1750, 1750)
        ParticleEffect("fx_cloud_"..math.random(1, 22), Vector(xOffset, -6000, zOffset), Angle())
    end)
end

local bombsOffsets = {
    Vector(34.464722, -205.243408, -45.094242),
    Vector(-34.464722, -205.243408, -45.094242),
    Vector(36.012867, -205.243408, -17.922077),
    Vector(-36.012867, -205.243408, -17.922077),
    Vector(38.082657, -205.243408, 10.195587),
    Vector(-38.082657, -205.243408, 10.195587),
    Vector(39.728436, -205.243408, 36.716461),
    Vector(-39.728436, -205.243408, 36.716461)
}

function RunBombBaySequence()
    if ( CurTime() <= BOMBER_BOMB_BAY_NEXT_USE) then return end

    if (BOMBER_BOMB_BAY_CLOSED) then
        OpenBombBay()
    else
        CloseBombBay()
    end

    BOMBER_BOMB_BAY_CRANK:EmitSound("Bomber.CrankRotate")

    TimerAdd("BOMBER_CrankStop", 20, 1, function()
        BOMBER_BOMB_BAY_CRANK:StopSound("Bomber.CrankRotate")
        BOMBER_BOMB_BAY_CRANK:Fire("FireUser1")
    end)

    BOMBER_BOMB_BAY_NEXT_USE = CurTime() + 40
end

function OpenBombBay()
    BOMBER_BOMB_BAY_CRANK:Fire("FireUser2")
    BOMBER_BOMB_BAY:Fire("FireUser1")

    BOMBER_BOMB_BAY_CLOSED = false

    TimerAdd("BOMBER_DropBombs", 25, 1, function()
        DropBombs()
    end)
end

function CloseBombBay()
    BOMBER_BOMB_BAY_CRANK:Fire("FireUser3")
    BOMBER_BOMB_BAY:Fire("FireUser2")

    BOMBER_BOMB_BAY_CLOSED = true

    TimerAdd("BOMBER_SpawnBombs", 40, 1, function()
        SpawnBombs()
    end)
end

function SpawnBombs()
    for i=1, 8 do
        local BombProp = ents.Create("prop_physics")
        BombProp:SetModel("models/coduo/bomber/bomb_prop.mdl")
        BombProp:SetName("bomb_"..i)
        BombProp:PhysicsInit(SOLID_VPHYSICS)
        BombProp:SetPos(bombsOffsets[i])
        BombProp:SetAngles(Angle())
        BombProp:SetCollisionGroup(COLLISION_GROUP_WORLD)
        BombProp:Spawn()
        BombProp:GetPhysicsObject():EnableMotion(false)
    end
end

function DropBombs()
    FriendliesDropBombs()
    
    for i=1, 8 do

        TimerAdd("BOMBER_DropBomb_"..i, 0.25*i, 1, function()
            local bomb = ents.FindByName("bomb_"..i)[1]
            bomb:GetPhysicsObject():EnableMotion(true)
            bomb:PhysWake()

            TimerAdd("BOMBER_DestroyBomb_"..i, 7, 1, function()
                bomb:Remove()

                /* 3D skybox bomb explosion FX */
                TimerAdd("BOMBER_ExplosionFX_"..i, 8, 1, function()
                    local skyboxPos = Vector(4631.817871, 6228.746094, -15250)

                    local effectdata = EffectData()
                    effectdata:SetOrigin( skyboxPos + Vector(0, 75 * i, 0) )
                    effectdata:SetScale(0.025)
                    util.Effect("Explosion", effectdata)
                end)
            end)

            local bombReleaseSound = ""

            if (i % 2 == 1) then
                bombReleaseSound = "coduo/bomber/bomb_release01.wav"
            else
                bombReleaseSound = "coduo/bomber/bomb_release03.wav"
            end

            sound.Play(bombReleaseSound, bomb:GetPos(), 65)
            bomb:EmitSound("coduo/bomber/bomb_whistle0"..math.random(1, 4)..".wav")
        end)

    end

end

/* Syncing sequences between server and clients */
util.AddNetworkString("NET_ANIM_RESET")

function PlayAnimation(ent, anim)
    net.Start("NET_ANIM_RESET")
        net.WriteEntity(ent)
        net.WriteInt(anim, 4)
    net.Broadcast()

    ent:ResetSequence(anim)
    ent:SetCycle(0)
end