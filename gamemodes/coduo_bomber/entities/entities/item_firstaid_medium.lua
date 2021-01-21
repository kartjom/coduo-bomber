AddCSLuaFile()

ENT.Type = "anim"

if (SERVER) then

    ENT.HealAmount = 100

    function ENT:Initialize()
        self:SetModel("models/coduo/pickup/health_medium.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        self:SetUseType(SIMPLE_USE)
    end

    function ENT:HealPlayer(ply)
        if ( !ply:IsPlayer() ) then return end
        if ( ply:Health() >= ply:GetMaxHealth() ) then return end
        
        ply:SetHealth( math.Clamp(ply:Health() + self.HealAmount, 0, ply:GetMaxHealth()) )
        sound.Play("coduo/pickup/medkit.wav", ply:GetPos(), 55)
        self:Remove()
    end

    function ENT:Use(caller, this)
        self:HealPlayer(caller)
    end

    function ENT:StartTouch(ent)
        self:HealPlayer(ent)
    end
end


if (CLIENT) then
    function ENT:Draw()
       self:DrawModel()
    end
end