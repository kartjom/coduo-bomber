function AddButton(text, color, pos, size, func)
    local btn = vgui.Create("DButton", UtilityMenu)
    btn:SetText( text )
    btn:SetTextColor( color )
    btn:SetPos( pos[1], pos[2] )
    btn:SetSize( size[1], size[2] )
    function btn.Paint( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
    end
    function btn.DoClick()
        func()
        UtilityMenu:Close()
    end
end

function GM:SpawnMenuOpen()
    return true
end

hook.Add("SpawnMenuOpen", "SpawnMenuAllowed", function()
	return GetGlobalBool("BOMBER_SANDBOX_TOGGLED")
end )

hook.Add("OnSpawnMenuOpen", "OpenUtilityMenu", function()
    if ( !LocalPlayer():IsAdmin() ) then return end

    UtilityMenu = vgui.Create( "DFrame" )
    UtilityMenu:SetTitle( "Useful stuff" )
    UtilityMenu:SetSize( 300,300 )	
    UtilityMenu:MakePopup()
    function UtilityMenu.Paint( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 180 ) )
    end

    if ( GetGlobalBool("BOMBER_SANDBOX_TOGGLED") ) then
        UtilityMenu:SetPos(ScrW() - 400, ScrH() - 400)
    else
        UtilityMenu:Center()
    end

    /* AddButton(text, color, pos, size, func) */

    AddButton("Restart", Color(255,255,255), {100, 60}, {100, 30}, function()
        RunConsoleCommand("gmod_admin_cleanup")
    end)
    
    AddButton("Toggle flak", Color(255,255,255), {100, 100}, {100, 30}, function()
        net.Start("FLAK_REQUEST")
        net.SendToServer()
    end)
    
    AddButton("Toggle fighters", Color(255,255,255), {100, 140}, {100, 30}, function()
        net.Start("FIGHTERS_REQUEST")
        net.SendToServer()
    end)
    
    AddButton("Attack bomber", Color(255,255,255), {45, 180}, {100, 30}, function()
        net.Start("ATTACK_BOMBER_REQUEST")
        net.SendToServer()
    end)

    AddButton("Attack friendlies", Color(255,255,255), {155, 180}, {100, 30}, function()
        net.Start("ATTACK_FRIENDLIES_REQUEST")
        net.SendToServer()
    end)

    AddButton("Toggle sandbox", Color(255,255,255), {100, 220}, {100, 30}, function()
        net.Start("TOGGLE_SANDBOX")
        net.SendToServer()
    end)
end)

hook.Add("OnSpawnMenuClose", "CloseUtilityMenu", function()
    if (IsValid(UtilityMenu)) then UtilityMenu:Close() end
end)