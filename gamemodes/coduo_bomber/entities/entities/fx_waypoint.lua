AddCSLuaFile()

ENT.Type = "anim"

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "PrintName")
end

if (SERVER) then
    function ENT:Initialize()
        self:SetModel("models/props_c17/oildrum001_explosive.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

        self:SetPrintName(self:GetName())
    end
end

if (CLIENT) then
    function ENT:Draw()
        self:DrawModel()
    end

    hook.Add("HUDPaint", "DrawFloatingTexts", function()
        for k,v in pairs(ents.FindByClass("fx_waypoint")) do
            local distanceFromPlayer = v:GetPos():DistToSqr(LocalPlayer():GetPos())
            if (distanceFromPlayer >= (5000*5000)) then continue end

            local pos = v:GetPos()
            local pos2d = pos:ToScreen()
        
            draw.SimpleTextOutlined(v:GetPrintName(), "GModNotify", pos2d.x, pos2d.y, Color(255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 1, Color(0,0,0))
        end
    end)
end