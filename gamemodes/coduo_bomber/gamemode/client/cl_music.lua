local LoadedSounds
if CLIENT then
	LoadedSounds = {} -- this table caches existing CSoundPatches
end

local function ReadSound( FileName )
	local sound
	local filter
	if SERVER then
		filter = RecipientFilter()
		filter:AddAllPlayers()
	end
	if SERVER or !LoadedSounds[FileName] then
		-- The sound is always re-created serverside because of the RecipientFilter.
		sound = CreateSound( game.GetWorld(), FileName, filter ) -- create the new sound, parented to the worldspawn (which always exists)
		if sound then
			sound:SetSoundLevel( 0 ) -- play everywhere
			if CLIENT then
				LoadedSounds[FileName] = { sound, filter } -- cache the CSoundPatch
			end
		end
	else
		sound = LoadedSounds[FileName][1]
		filter = LoadedSounds[FileName][2]
	end
	if sound then
		if CLIENT then
			sound:Stop() -- it won't play again otherwise
		end
	end
	return sound -- useful if you want to stop the sound yourself
end

BOMBER_MUSIC = nil

-- When we are ready, we play the sound:
function PlayMapMusic()
	if (BOMBER_MUSIC == nil) then BOMBER_MUSIC = ReadSound("coduo/music/pf_frantic.mp3") end

	BOMBER_MUSIC:Stop()
    BOMBER_MUSIC:Play()
	BOMBER_MUSIC:ChangeVolume(0.8)
end

function StopMapMusic()
    BOMBER_MUSIC:FadeOut(3)
end

net.Receive("PLAY_MUSIC", function()
	hook.Remove("Think", "BomberMusicStop")

	BOMBER_NEXT_MUSIC = 0
	hook.Add("Think", "BomberMusicRepeat", function()
		if (SysTime() <= BOMBER_NEXT_MUSIC) then return end

		BOMBER_NEXT_MUSIC = SysTime() + 83
    	PlayMapMusic()
	end)
end)

net.Receive("STOP_MUSIC", function()
	hook.Remove("Think", "BomberMusicRepeat")

	if (BOMBER_MUSIC == nil || BOMBER_MUSIC == NULL) then return end
	if ( !BOMBER_MUSIC:IsPlaying() ) then return end
	
    StopMapMusic()

	hook.Add("Think", "BomberMusicStop", function()
		if (BOMBER_MUSIC:IsPlaying() && BOMBER_MUSIC:GetVolume() <= 0.05) then
			BOMBER_MUSIC:Stop()
			hook.Remove("Think", "BomberMusicStop")
		end
	end)
end)