function DialoguePlay(sndPath)
	surface.PlaySound( Sound(sndPath) )
end

net.Receive("NET_DIALOGUE", function()
    local str = net.ReadString()
    DialoguePlay(str)
end)