CreateClientConVar( "cl_draw_crosses", "1", true, false)

local crossIcon = Material("coduo/hud/m_bomber_hud-icon.png")
local iconSize = 32
local maxKills = 50

hook.Add("HUDPaint", "HUD_DrawCrosses", function()
    if ( !GetConVar("cl_draw_crosses"):GetBool() ) then return end

    if ( !LocalPlayer():Alive() ) then return end
    if ( LocalPlayer():Frags() <= 0 ) then return end

    local initX = 0
    local initY = ScrH() - 150

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(crossIcon)
    
    local widthOffset = 0
    local frags = math.Clamp(LocalPlayer():Frags() - 1, 0, maxKills - 1)
    for i=0, frags do
        if ( widthOffset >= (iconSize*10) ) then widthOffset = 0 end

        widthOffset = widthOffset + iconSize
        local heightOffset = math.floor(i/10) * iconSize

        surface.DrawTexturedRect(initX + widthOffset, initY - heightOffset, iconSize, iconSize)
    end
end)