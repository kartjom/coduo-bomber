BOMBER_NEXT_PLAYER_DEATH_COMMENT = 0

function GetTurretDistance(ply, turret)
    local turretPos = ents.FindByName(turret)[1]:GetPos()
    return ply:GetPos():DistToSqr(turretPos)
end

function PlayDeathComment(str)
    BOMBER_NEXT_PLAYER_DEATH_COMMENT = CurTime() + 5
    SendDialogue(str)
end

hook.Add("PlayerDeath", "PlayerDeathComments", function(ply)
    if (CurTime() <= BOMBER_NEXT_PLAYER_DEATH_COMMENT || BOMBER_ENDING_SEQUENCE) then return end

    if ( GetTurretDistance(ply, "l_waist_turret") <= (75*75) ) then
        PlayDeathComment("coduo/voiceovers/death_lwaist_1.mp3")
    elseif ( GetTurretDistance(ply, "r_waist_turret") <= (75*75) ) then
        PlayDeathComment("coduo/voiceovers/death_rwaist_1.mp3")
    elseif ( GetTurretDistance(ply, "tail_turret") <= (80*80) ) then
        PlayDeathComment("coduo/voiceovers/death_tail_1.mp3")
    else
        if ( math.random(100) > 80 ) then
            PlayDeathComment("coduo/voiceovers/death_common.mp3")
        end
    end
end)

/* Enemy fighter death comments */

BOMBER_NEXT_FIGHTER_DEATH_COMMENT = 0

hook.Add("OnEnemyFighterKill", "FighterDeathComments", function(ply)
    if (CurTime() <= BOMBER_NEXT_FIGHTER_DEATH_COMMENT || !BOMBER_ENEMY_FIGHTERS || BOMBER_ENDING_SEQUENCE) then return end

    if (math.random(0, 100) > 75) then
        BOMBER_NEXT_FIGHTER_DEATH_COMMENT = CurTime() + 20
        TimerAdd("KILL_DIALOGUE", 0.5, 1, function()        
            SendDialogue("coduo/voiceovers/kill_"..math.random(1, 6)..".mp3")
        end)
    end
end)