AddCSLuaFile()

ENT.Type = "anim"

if (SERVER) then
    
    ENT.MoveVector = nil
    ENT.ParticleName = nil
    ENT.Lifetime = 2

    function ENT:Initialize()
        self:SetModel("")

        if (self.ParticleName != nil) then
            ParticleEffectAttach(self.ParticleName, PATTACH_ABSORIGIN_FOLLOW, self, 1)
        end

        self.Lifetime = CurTime() + self.Lifetime
    end

    function ENT:Think()
        self:Move()

        if (CurTime() > self.Lifetime) then self:Remove() end

        if ( !self:IsInWorld() ) then self:Remove() print(HUD_PRINTTALK, "Particle out of world! Removing") end

        self:NextThink(CurTime())
        return true
    end

    function ENT:Move()
        if (self.MoveVector == nil || self.MoveVector == Vector()) then return end
        
        self:SetPos( self:GetPos() +  self.MoveVector)
    end

end

if (CLIENT) then

    function ENT:Draw()
        
    end

end