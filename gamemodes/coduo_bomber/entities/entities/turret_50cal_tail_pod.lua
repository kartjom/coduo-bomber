AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "turret_50cal_pod"
ENT.Spawnable = true

if (SERVER) then

    ENT.Owner = nil

    function ENT:Initialize()
        self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)

        self:SetUseType(SIMPLE_USE)

        self.Gun = ents.Create("turret_50cal_tail_gun")
        self.Gun:SetParent(self)
        self.Gun:SetLocalPos(self.Gun.PositionOffset)
        self.Gun:SetLocalAngles(Angle())
        self.Gun:Spawn()
    end

end

if (CLIENT) then

    function ENT:Draw() 
        //self:DrawModel()
    end

end