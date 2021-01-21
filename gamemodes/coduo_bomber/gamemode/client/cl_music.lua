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
		sound:Play()
	end
	return sound -- useful if you want to stop the sound yourself
end

local music = nil

-- When we are ready, we play the sound:
function PlayMapMusic()
    if (music != nil && music:IsPlaying()) then music:Stop() end
    music = ReadSound( "coduo/music/pf_frantic.mp3" )
end

function StopMapMusic()
    if (music != nil && music:IsPlaying()) then
        music:FadeOut(3)
    end
end

net.Receive("PLAY_MUSIC", function()
	BOMBER_NEXT_MUSIC = 0
	hook.Add("Think", "BomberMusicManager", function()
		if (CurTime() <= BOMBER_NEXT_MUSIC) then return end

		BOMBER_NEXT_MUSIC = CurTime() + 83
    	PlayMapMusic()
	end)
end)

net.Receive("STOP_MUSIC", function()
	hook.Remove("Think", "BomberMusicManager")
    StopMapMusic()
end)