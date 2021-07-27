AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ai_b17_dorsal_turret"

if (SERVER) then
    ENT.vMin = -360
    ENT.vMax = -325

    ENT.StandbyRotation = Angle(180, 0, 0)
    ENT.StandbyVerticalRotation = 10

    function ENT:Initialize()
        self:SetModel("models/coduo/bomber/b17_dummy_ball_turret.mdl")
        self:PhysicsInit(SOLID_NONE)

        self.Guns = ents.Create("prop_dynamic")
        self.Guns:SetModel("models/coduo/bomber/b17_dummy_ball_turret_guns.mdl")
        self.Guns:SetParent(self)
        self.Guns:SetLocalPos(Vector())
        self.Guns:SetLocalAngles(Angle(0, self.StandbyVerticalRotation, 0))
        self.Guns:Spawn()

        self:SetParent(self.Plane, 1)
        self:SetLocalPos(Vector(485, -83, -430))
        self:SetLocalAngles(self.StandbyRotation)
    end

    function ENT:InDeadZone()
        return (self.Target:GetPos().z >= self:GetPos().z)
    end
end