include( "shared.lua" )

/* Include Client Files (see init.lua) */

function GM:SpawnMenuOpen()
    return true
end

function GM:ContextMenuOpen()
    return false
end

function GM:OnSpawnMenuOpen()
    if ( !LocalPlayer():IsAdmin() ) then return end

    Frame = vgui.Create( "DFrame" )
    Frame:SetTitle( "Useful stuff" )
    Frame:SetSize( 300,300 )
    Frame:Center()			
    Frame:MakePopup()
    function Frame.Paint( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 180 ) )
    end
    
    local RestartBtn = vgui.Create("DButton", Frame)
    RestartBtn:SetText( "Restart" )
    RestartBtn:SetTextColor( Color(255,255,255) )
    RestartBtn:SetPos( 100, 100 )
    RestartBtn:SetSize( 100, 30 )
    function RestartBtn.Paint( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
    end
    function RestartBtn.DoClick()
        RunConsoleCommand("gmod_admin_cleanup")
        Frame:Close()
    end
end

function GM:OnSpawnMenuClose()
    if (IsValid(Frame)) then Frame:Close() end
end

function StartExplosionShock()
    GetConVar("pp_motionblur"):SetBool(true)
    GetConVar("pp_motionblur_addalpha"):SetFloat(0.2)
    GetConVar("pp_motionblur_drawalpha"):SetFloat(0.99)
    GetConVar("pp_motionblur_delay"):SetFloat(0)

    timer.Create("StopBlur", 4, 1, StopExplosionShock)
end

function StopExplosionShock()
    GetConVar("pp_motionblur"):SetBool(false)
end

net.Receive("NET_ANIM_RESET", function()
    local ent = net.ReadEntity()
    local anim = net.ReadInt(4)

    if (ent == nil || ent == NULL) then return end
    
    ent:ResetSequence(anim)
    ent:SetCycle(0)
end)

net.Receive("NET_START_BLUR", function()
    StartExplosionShock()
end)

net.Receive("NET_STOP_BLUR", function()
    StopExplosionShock()
end)

net.Receive("SEND_TABLE", function()
    local id = net.ReadInt(16)
    local tbl = net.ReadTable()

    print("{ // "..id)
    for k,v in pairs(tbl) do
        print("Vector("..v.x..", "..v.y..", "..v.z.."),")
    end
    print("},")
end)