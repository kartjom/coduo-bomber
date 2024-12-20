/* Include two main files */
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

/* Include Client Files (see cl_init.lua) */
AddCSLuaFile( "client/cl_menu.lua" )
AddCSLuaFile( "client/cl_voice_menu.lua" )
AddCSLuaFile( "client/cl_music.lua" )
AddCSLuaFile( "client/cl_hud.lua" )
AddCSLuaFile( "client/cl_dialogues.lua" )

/* Include Server Files */
include( "shared.lua" )
include( "server/player.lua" )
include( "server/initialize.lua" )
include( "server/utility.lua" )
include( "server/ai_b17_logic.lua" )
include( "server/enemy_fighters_logic.lua" )
include( "server/net_messages.lua" )
include( "server/dialogues.lua" )
include( "server/death_comments.lua" )
include( "server/ending.lua" )
//include( "server/debug.lua" ) // stuff for creating waypoints

function GM:PlayerSpawn(ply)
	ply:SetModel("models/player/Group03/male_0"..math.random(1, 9)..".mdl")
	ply:SetupHands()
	ply:AllowFlashlight(true)

	ply:SetWalkSpeed(100)
	ply:SetRunSpeed(160)
	ply:SetMaxSpeed(160)

	ply:CrosshairDisable()
	ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	ply:StopExplosionShock()

	ply:ConCommand("cl_showhints 0")
end

function GM:PlayerDeath(ply)
	ply:StopExplosionShock()
end

function GM:GetFallDamage(ply, speed)
    return (speed / 7)
end

function GM:PlayerSpray(ply)
	return true
end

function GM:PlayerNoClip(ply)
	return GetGlobalBool("BOMBER_SANDBOX_TOGGLED") && !BOMBER_ENDING_INITIALIZED
end

function GM:CanPlayerSuicide(ply)
	return !BOMBER_ENDING_INITIALIZED
end

function GM:PlayerEnteredVehicle(ply, veh, nrole)
	ply:SetCollisionGroup(11)
	ply.ExitAngles = ply:LocalEyeAngles()
end

function GM:PlayerLeaveVehicle(ply, veh)
	ply:SetCollisionGroup(11)

	if (veh.ExitPos != nil) then
		ply:SetPos(veh.ExitPos)
	end

	if (ply.ExitAngles != nil) then
		ply:SetEyeAngles(ply.ExitAngles)
	end

	TimerAdd("TIMER_VEH_EXIT_"..ply:GetName().."_"..CurTime(), 0.05, 1, function()
		if (ply:IsValid()) then ply:CrosshairDisable() end
	end)
end

function GM:CanPlayerEnterVehicle(ply, veh, role)
	if ( string.StartWith(veh:GetName(), "chair_") ) then
		if (ply:GetPos():DistToSqr(veh:GetPos()) >= 4750 || BOMBER_CHAIRS_DISABLED == true) then
			return false
		else
			return true
		end
	else
		return true
	end
end

function GM:IsSpawnpointSuitable(ply, spawnpoint, makeSuitable)
	return true
end

hook.Add("CanExitVehicle", "EndingChair", function(veh, ply)
    return !veh.Ending
end)

hook.Add("EntityTakeDamage", "ExplosionShock", function(ent, dmginfo)
	if ( dmginfo:IsDamageType(DMG_BLAST) && ent:IsPlayer() ) then
		ent:StartExplosionShock()
	end
end)

local RemoveManagedEntities_NextThink = 0
hook.Add("Think", "RemoveManagedEntities", function()
	if (CurTime() < RemoveManagedEntities_NextThink) then return end

	if (ents.Iterator == nil) then -- Fallback to legacy iteration if not on beta branch
		for _, ent in ipairs(ents.GetAll()) do
			if (ent.ManagedRemoval != nil && CurTime() >= ent.ManagedRemoval) then
				ent:Remove()
			end
		end
	else
		for _, ent in ents.Iterator() do
			if (ent.ManagedRemoval != nil && CurTime() >= ent.ManagedRemoval) then
				ent:Remove()
			end
		end
	end

	RemoveManagedEntities_NextThink = RemoveManagedEntities_NextThink + 0.1
end)

hook.Add("InitPostEntity", "InitializeMap", InitializeMap)
hook.Add("PostCleanupMap", "InitializeMap", InitializeMap)