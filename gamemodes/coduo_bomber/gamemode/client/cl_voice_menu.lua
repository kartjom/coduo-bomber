function GM:ContextMenuOpen()
    return true
end

hook.Add("ContextMenuOpen", "ContextMenuAllowed", function()
	return GetGlobalBool("BOMBER_SANDBOX_TOGGLED")
end )

hook.Add("OnContextMenuOpen", "OpenVoiceMenu", function()
    /*VoiceMenu = vgui.Create( "DFrame" )
    VoiceMenu:SetTitle( "Voice menu" )
    VoiceMenu:SetSize( 300,300 )
    VoiceMenu:Center()
    VoiceMenu:ShowCloseButton(false)
    function VoiceMenu.Paint( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 180 ) )
    end*/

    
end)

hook.Add("OnContextMenuClose", "CloseVoiceMenu", function()
    if (IsValid(VoiceMenu)) then VoiceMenu:Close() end
end)