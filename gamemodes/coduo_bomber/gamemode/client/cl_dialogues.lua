function DialoguePlay(sndPath)
    EmitSound( Sound(sndPath), LocalPlayer():GetPos(), -2, CHAN_VOICE, 1, 75, SND_SHOULDPAUSE, 100, 0 )
end

net.Receive("NET_DIALOGUE", function()
    local str = net.ReadString()
    DialoguePlay(str)
end)