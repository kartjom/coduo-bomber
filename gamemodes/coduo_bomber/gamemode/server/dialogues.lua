util.AddNetworkString("NET_DIALOGUE")

function SendDialogue(str)
    net.Start("NET_DIALOGUE")
        net.WriteString(str)
    net.Broadcast()
end

function DialoguePlayScene(sndTbl)
    /*  { snd = "coduo/voiceovers/luftwaffe_1.mp3", delay = 2 },
        { snd = "coduo/voiceovers/luftwaffe_2.mp3" }
    */

    for k,v in pairs(TimersList) do
        if ( string.StartWith(k, "DIALOGUE_SCENE_") ) then
            timer.Remove(k)
            TimersList[k] = nil
        end
    end

    local delay = 0
    for i=1, #sndTbl do
        if (i == 1) then SendDialogue( sndTbl[i].snd ) end
        
        if (i < #sndTbl) then
            delay = delay + sndTbl[i].delay + 0.5
            TimerAdd("DIALOGUE_SCENE_"..i.."_"..CurTime(), delay, 1, function()
                SendDialogue( sndTbl[i+1].snd )
            end)
        end
    end
end