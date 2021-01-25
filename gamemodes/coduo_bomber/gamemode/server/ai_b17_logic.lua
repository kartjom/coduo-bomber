local soundLocations = {
    Vector(600, -640, -30),
    Vector(680, 1500, -500),
    Vector(1760, 1900, -150),
    Vector(-900, 1300, -110),
    Vector(-1340, -650, 200),
    Vector(-520, -1330, 420)
}

function ents.GetBombers()
    local bombers = {}
    for k,v in pairs(ents.FindByClass("prop_dynamic")) do
        if (v.IsBomber) then table.insert(bombers, v) end
    end

    return bombers
end

function CreateBomber(data)
    /* 'data' members:
        origin; rotation; targetname; sequence; dieSequence; fallPos; explodePos; setContrails
    */

    /* Initialization */
    local plane = ents.Create("prop_dynamic")
    plane:SetModel("models/coduo/bomber/b17_dummy.mdl")
    plane:SetPos(data.origin or Vector())
    plane:SetAngles(data.rotation or Angle())
    plane.AutomaticFrameAdvance = true
    plane:SetKeyValue("DefaultAnim", "idle")
    plane:PhysicsInit(SOLID_VPHYSICS)
    plane:SetName(data.targetname)
    plane:Spawn()

    if (data.setContrails) then SetContrails(plane) end

    /* Sync sequence with server and clients */
    TimerAdd("TIMER_ANIM_"..plane:GetName(), 0.5, 1, function() 
        PlayAnimation(plane, data.sequence)
    end)

    /* Key Values */
    plane.IsBomber = true
    plane.CanTakeDamage = true
    plane.EngineDamaged = false
    plane.EngineBurning = false
    plane.Durability = 2500

    plane.FallPosID = data.fallPos
    plane.ExplodePosID = data.explodePos or plane.FallPosID // use plane.FallPosID if data.explodePos not defined
    plane.DieSequence = data.dieSequence or math.random(1, 2) // use random sequence if default not defined

    plane.FlySequence = data.sequence
    plane.AnimTime = plane:GetAnimInfo(data.sequence).numframes / 30
    plane.NextAnimRefresh = CurTime() + plane.AnimTime

    plane.helper = ents.Create("prop_dynamic")
    plane.helper:SetModel("models/hunter/plates/plate.mdl")
    plane.helper:FollowBone(plane, 1)
    plane.helper:SetLocalPos(Vector())
    plane.helper:SetNoDraw(true)
    plane.helper:Spawn()

    /* Sequence refesher */
    local refresher = ents.Create("logic_bomber_refresher")
    refresher:BindPlane(plane)
    refresher:Spawn()

    /* Dorsal turret AI */
    plane.dorsal_turret = ents.Create("ai_b17_dorsal_turret")
    plane.dorsal_turret.Plane = plane
    plane.dorsal_turret:Spawn()
    
    /* Ball turret AI */
    plane.ball_turret = ents.Create("ai_b17_ball_turret")
    plane.ball_turret.Plane = plane
    plane.ball_turret:Spawn()
end

BOMBER_NEXT_FRIENDLY_DEATH_WARNING = 0
hook.Add("EntityTakeDamage", "DummyBomberDamageLogic", function(target, dmginfo)
	if (target.IsBomber && target.CanTakeDamage) then
		target.Durability = target.Durability - dmginfo:GetDamage()

        if (target.Durability <= 0) then
            /* Disable damage logic so this shit doesn't break anyhow */
            target.CanTakeDamage = false

            /* Play death sequence */
            PlayAnimation(target, 3 + target.DieSequence) // adding 3 to skip 4 fly sequences (counting from 0)
            sound.Play("coduo/bomber/bomber_die_0"..math.random(1, 2)..".wav", soundLocations[target.FallPosID])
            
            /* Remove bomber at the end of sequence */
            TimerAdd("BOMBER_"..target:GetName().."_Kill", 11, 1, function()
                sound.Play("coduo/bomber/bomber_explode01.mp3", soundLocations[target.ExplodePosID])
                DummyBomberWreckExplode(target)
                target:Remove()
            end)

            if (CurTime() > BOMBER_NEXT_FRIENDLY_DEATH_WARNING && math.random(1, 100) > 60) then
                BOMBER_NEXT_FRIENDLY_DEATH_WARNING = CurTime() + 15

                TimerAdd("FRIENDLY_DEATH_WARNING_"..CurTime(), math.random(1, 3), 1, function()
                    SendDialogue("coduo/voiceovers/friendly_bomber_death_"..math.random(1, 2)..".mp3")
                end)
            end
        end

        if (target.Durability <= 1250 && !target.EngineDamaged) then
            /* Emit smoke from random engine */
            target.EngineDamaged = true
            target.EngSmokeNum = math.random(1, 4)
            
            target:EmitSound("coduo/bomber/bomber_explode01.mp3", 140)
            ParticleEffectAttach("bomber_engine_smoke_big", PATTACH_POINT_FOLLOW, target, target.EngSmokeNum)
        end
        
        if (target.Durability <= 200 && target.EngineDamaged && !target.EngineBurning) then 
            /* Emit fire from previously randomized engine (might change it, idk) */
            target.EngineBurning = true
            
            target:EmitSound("coduo/bomber/bomber_explode01.mp3", 140)

            local engNum = math.random(1, 4)
            ParticleEffectAttach("bomber_engine_fire", PATTACH_POINT_FOLLOW, target, engNum)
            
            if (engNum != target.EngSmokeNum) then
                ParticleEffectAttach("bomber_engine_smoke_big", PATTACH_POINT_FOLLOW, target, engNum)
            end
        end
	end
end)

function DummyBomberWreckExplode(plane)

	local wreckPartNames = {
		"b17_wreck_engine_1",
		"b17_wreck_engine_2",
		"b17_wreck_engine_3",
		"b17_wreck_engine_4",
		"b17_wreck_fuselage",
		"b17_wreck_lwing",
		"b17_wreck_rwing",
		"b17_wreck_tail",
		"b17_wreck_tail_lwing",
		"b17_wreck_tail_rwing",

        "human_gib_1",
        "human_gib_2",
        "human_gib_3"
	}

    local igniteParts = {
        ["b17_wreck_fuselage"] = true,
		["b17_wreck_lwing"] = true,
		["b17_wreck_rwing"] = true,
		["b17_wreck_tail"] = true
    }

    local wreckParts = {}

    local explosionPos = plane.helper:GetPos()

	for k,v in pairs(wreckPartNames) do
		local part = ents.Create("prop_physics")
		part:SetModel("models/coduo/bomber/"..v..".mdl")
		part:SetPos(explosionPos)
		part:SetAngles(plane:GetAngles())
		part:Spawn()
        
        if ( igniteParts[v] ) then
            ParticleEffectAttach("bomber_engine_smoke_big", PATTACH_ABSORIGIN_FOLLOW, part, 0)
            ParticleEffectAttach("bomber_engine_fire", PATTACH_ABSORIGIN_FOLLOW, part, 0)
        end

        table.insert(wreckParts, part)
	end

    for k,v in pairs(wreckParts) do
		if (v:GetClass() == "prop_physics") then
			local dir = VectorRand(-2000, 2000)

			v:PhysWake()
			v:GetPhysicsObject():SetVelocity( dir )
		end
	end

    TimerAdd("TIMER_REMOVE_WRECK_"..plane:GetName(), 6, 1, function()
        for k,v in pairs(wreckParts) do
            if (IsValid(v)) then
                v:Remove()
            end
         end
    end)
end

function SetContrails(plane)
    TimerAdd("BOMBER_SET_CONTRAILS_"..plane:GetName(), 1, 1, function()
        ParticleEffectAttach("fx_contrail_a", PATTACH_POINT_FOLLOW, plane, 1)
        ParticleEffectAttach("fx_contrail_b", PATTACH_POINT_FOLLOW, plane, 2)
        ParticleEffectAttach("fx_contrail_b", PATTACH_POINT_FOLLOW, plane, 3)
        ParticleEffectAttach("fx_contrail_a", PATTACH_POINT_FOLLOW, plane, 4)
    end)
end

function DummyDropBombs(plane)
    local pos = plane.helper:GetPos() - Vector(0, 0, 55)

    for i = 1, 8 do
        if ( !IsValid(plane) || !plane.CanTakeDamage ) then return end

        local xOffset = 25
        if (i % 2 != 0) then xOffset = -25 end
        
        local name = plane:EntIndex().."_bomb_"..i

        TimerAdd("TIMER_DROP_"..name, i*0.25, 1, function()
            if ( !IsValid(plane) || !plane.CanTakeDamage ) then return end

            local BombProp = ents.Create("prop_physics")
            BombProp:SetModel("models/coduo/bomber/bomb_prop.mdl")
            BombProp:SetName(name)
            BombProp:PhysicsInit(SOLID_VPHYSICS)
            BombProp:SetPos(pos + Vector(xOffset, 0, 0))
            BombProp:SetAngles(Angle())
            BombProp:SetCollisionGroup(COLLISION_GROUP_WORLD)
            BombProp:Spawn()

            constraint.NoCollide(plane, BombProp, 0, 0)

            BombProp:GetPhysicsObject():SetVelocity( Vector(0, 100, 0) )

            if (i % 2 == 1) then
                bombReleaseSound = "coduo/bomber/bomb_release01.wav"
            else
                bombReleaseSound = "coduo/bomber/bomb_release03.wav"
            end

            BombProp:EmitSound("coduo/bomber/bomb_whistle0"..math.random(1, 4)..".wav")

            TimerAdd("TIMER_REMOVE_"..name, 5, 1, function()
                BombProp:Remove()
            end)
        end)
    end
end

function FriendliesDropBombs()
    for k,v in pairs(ents.GetBombers()) do
        TimerAdd("TIMER_STARTDROP_"..v:GetName(), math.random(1, 3), 1, function()
            if (IsValid(v) && v.CanTakeDamage) then
                DummyDropBombs(v)
            end
        end)
    end
end