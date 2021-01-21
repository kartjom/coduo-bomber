AddCSLuaFile()

ENT.Type = "anim"

if (SERVER) then

    ENT.Plane = nil

    function ENT:Initialize()
        self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        self:PhysicsInit(SOLID_NONE)
    end

    function ENT:BindPlane(plane)
        self.Plane = plane
        self:SetParent(plane)
        self:SetLocalPos(Vector())
    end

    function ENT:Think()
        if (!self.Plane) then self:Remove() return end
        if (!self.Plane.CanTakeDamage) then return end

        if (CurTime() >= self.Plane.NextAnimRefresh) then
            PlayAnimation(self.Plane, self.Plane.FlySequence)
            self.Plane.NextAnimRefresh = CurTime() + self.Plane.AnimTime
        end

        self:NextThink(CurTime() + 0.5)
        return true
    end

end


if (CLIENT) then

    function ENT:Draw()
       // no drawing this time, only for debug
       //self:DrawModel()
    end

end