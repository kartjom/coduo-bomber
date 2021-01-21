AddCSLuaFile()

ENT.Type = "anim"

if (SERVER) then

    function ENT:Initialize()
        self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        self:SetUseType(SIMPLE_USE)
    end

    function ENT:Use(caller, this)
        // override
    end

end


if (CLIENT) then

    function ENT:Draw()
       // no drawing this time, only for debug
       //self:DrawModel()
    end

end